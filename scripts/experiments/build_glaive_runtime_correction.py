"""Build a separately labelled runtime; preserve every pinned upstream byte."""
import argparse
from datetime import datetime, timezone
import difflib
import json
from pathlib import Path
import subprocess
import zipfile

from rcnc.domain_building import digest, save
from rcnc.glaive_runtime import linux_path
from scripts.experiments.run_revised_development import JAR

SOURCE = JAR.parent / 'PlanWare/src/com/stephengware/java/planware'
HARNESS = Path('scripts/java/GlaiveRuntimeRegression.java')
DOMAIN = '''(define (domain runtime-regression)
 (:requirements :adl :intentionality)
 (:types character empty token - object)
 (:predicates (done) (ready) (empty-tag ?e - empty) (pair ?x - character ?y - character)
              (mixed ?x - character ?e - empty) (tag ?x - character ?t - token))
 (:action boolean-or :parameters (?x ?y ?z - character)
  :precondition (or (not (= ?x ?y)) (not (= ?x ?z))) :effect (done))
 (:action empty-mixed :parameters (?x - character ?e - empty)
  :precondition (ready) :effect (mixed ?x ?e))
 (:action empty-single :parameters (?e - empty)
  :precondition (ready) :effect (empty-tag ?e))
 (:action zero-arity :parameters () :precondition (ready) :effect (done))
 (:action product-two :parameters (?x ?y - character)
  :precondition (ready) :effect (pair ?x ?y))
 (:action product-one :parameters (?x - character ?t - token)
  :precondition (ready) :effect (tag ?x ?t)))
'''
PROBLEM = '''(define (problem runtime-regression-problem) (:domain runtime-regression)
 (:objects c1 c2 - character t1 - token) (:init (ready)) (:goal (done)))
'''


def replace_once(text, before, after):
    if text.count(before) != 1: raise ValueError('Pinned source patch does not apply exactly once')
    return text.replace(before, after)


def run_logged(cmd, path):
    p = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=60)
    log = p.stdout.decode('utf-8', errors='replace')
    path.write_text(log, encoding='utf-8')
    return {'command': cmd, 'returncode': p.returncode, 'log': str(path), 'log_sha256': digest(path)}


def build(root):
    if root.exists(): raise ValueError('Fresh directory required')
    root.mkdir(parents=True)
    before_hash = digest(JAR)
    edits = {
        'logic/Disjunction.java': [
            ('else if(substitutedArguments.size() == 0)\n\t\t\treturn Expression.TRUE.substitute(substitution);',
             'else if(substitutedArguments.size() == 0)\n\t\t\treturn Expression.FALSE.substitute(substitution);')],
        'ground/CartesianProductBindings.java': [
            ('this.values = new Entity[this.variables.length][];',
             'this.values = new Entity[this.variables.length][];\n\t\tboolean emptyDomain = false;'),
            ('this.hasNext = true;\n\t\t}',
             'this.hasNext = true;\n\t\t\telse\n\t\t\t\temptyDomain = true;\n\t\t}\n\t\tif(emptyDomain)\n\t\t\tthis.hasNext = false;')],
    }
    patches=[]; inputs={str(JAR):before_hash,str(HARNESS):digest(HARNESS),str(Path(__file__)):digest(Path(__file__))}; modified=[]
    for rel, replacements in edits.items():
        source=SOURCE/rel; original=source.read_text(encoding='utf-8'); corrected=original
        inputs[str(source)]=digest(source)
        for old,new in replacements: corrected=replace_once(corrected,old,new)
        target=root/'src/com/stephengware/java/planware'/rel
        target.parent.mkdir(parents=True,exist_ok=True);target.write_text(corrected,encoding='utf-8',newline='\n');modified.append(target)
        patches.extend(difflib.unified_diff(original.splitlines(True),corrected.splitlines(True),fromfile='pinned/'+rel,tofile='corrected/'+rel))
    (root/'runtime.patch').write_text(''.join(patches),encoding='utf-8')
    classes=root/'classes';classes.mkdir()
    (root/'domain.pddl').write_text(DOMAIN,encoding='utf-8');(root/'problem.pddl').write_text(PROBLEM,encoding='utf-8')
    harness=root/'GlaiveRuntimeRegression.java';harness.write_bytes(HARNESS.read_bytes())
    save(root/'build_protocol.json',{'created_utc':datetime.now(timezone.utc).isoformat(),'input_sha256':inputs,
         'scope':'Two runtime defects, two classes. No source-domain, mapping, or original runtime mutation. Eight deterministic regressions; zero search/model calls.'})
    compiler=run_logged(['wsl.exe','--exec','javac','--release','8','-encoding','UTF-8','-cp',linux_path(JAR),'-d',linux_path(classes)] +
                        [linux_path(p) for p in modified+[harness]],root/'compile.log')
    if compiler['returncode']!=0: raise RuntimeError((root/'compile.log').read_text(encoding='utf-8'))
    new_jar=root/'glaive-corrected.jar';changed=[]
    with zipfile.ZipFile(JAR) as src,zipfile.ZipFile(new_jar,'w') as dst:
        for entry in src.infolist():
            original=src.read(entry.filename);replacement=classes/entry.filename
            data=replacement.read_bytes() if replacement.is_file() and entry.filename.startswith('com/stephengware/java/planware/') else original
            if data!=original:changed.append(entry.filename)
            dst.writestr(entry,data)
    expected={('com/stephengware/java/planware/'+x).replace('.java','.class') for x in edits}
    if set(changed)!=expected:raise ValueError('Unexpected changed JAR entries: '+str(changed))
    regressions={}
    # Only the harness class is on the additional classpath; the selected JAR comes first.
    for label,jar in [('original',JAR),('corrected',new_jar)]:
        regressions[label]=run_logged(['wsl.exe','--exec','java','-cp',linux_path(jar)+':'+linux_path(classes),
            'GlaiveRuntimeRegression',linux_path(root/'domain.pddl'),linux_path(root/'problem.pddl')],root/(label+'_regressions.log'))
    unchanged=all(digest(Path(p))==h for p,h in inputs.items())
    report={'status':'verified' if unchanged and regressions['corrected']['returncode']==0 else 'failed',
        'jar':str(new_jar),'jar_sha256':digest(new_jar),'original_jar_sha256':before_hash,'inputs_unchanged':unchanged,
        'changed_jar_entries':changed,'all_other_entry_contents_identical':True,'compiler':compiler,'regressions':regressions,
        'output_sha256':{str(p):digest(p) for p in root.rglob('*') if p.is_file()},'model_calls':0,'search_calls':0}
    save(root/'report.json',report)
    if report['status']!='verified':raise RuntimeError('Regression gate failed; inspect saved logs')
    return report


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--output',type=Path,required=True)
    print(json.dumps(build(p.parse_args().output),indent=2))
