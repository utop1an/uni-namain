"""Local finite regressions for priority-one intake, using an unchanged runtime."""
import argparse
import json
from pathlib import Path
import shutil

from rcnc.domain_building import digest, save
from rcnc.glaive_merge import Source, build, map_problem
from rcnc.glaive_runtime import linux_path
from scripts.audit.recheck_human_single_domain import REPO, verify
from scripts.experiments.build_glaive_runtime_correction import run_logged

JAR = REPO / 'data/validation/glaive_intention_reader_2026_11_05_v2/glaive-language.jar'
DOMAIN = '''(define (domain consent-fixture) (:requirements :adl :intentionality)
 (:types character) (:predicates (has ?x - character))
 (:action give :parameters (?giver ?receiver - character)
  :precondition (has ?giver) :effect (and (not (has ?giver)) (has ?receiver))
  :agents (?giver) :consent (?giver ?receiver)))'''
PROBLEM = '''(define (problem consent-fixture) (:domain consent-fixture) (:requirements :adl :intentionality)
 (:objects alice bob - character) (:init (has alice) (intends alice (has bob)) {extra}) (:goal (has bob)))'''


def check(output):
    if output.exists(): raise ValueError('Fresh output directory required')
    output.mkdir(parents=True)
    harness = REPO / 'scripts/java/GlaivePriorityOneRegression.java'
    code = [Path(__file__), harness, REPO/'rcnc/glaive_intake.py', REPO/'rcnc/glaive_merge.py', REPO/'tests/test_glaive_priority1.py']
    upstream = REPO/'data/external/there_and_back_gpt4_revised_2026_11_01_v1/upstream/there_and_back/glaive/Glaive'
    references = [upstream/'PlanWare/src/com/stephengware/java/planware/logic/Taxonomy.java',
                  upstream/'Intentional Planning/src/com/stephengware/java/planware/io/pddl/intp/OperatorAgentsExtension.java']
    for path in code:
        target = output/'implementation'/path.relative_to(REPO)
        target.parent.mkdir(parents=True, exist_ok=True); shutil.copyfile(path, target)
    cases = {}
    for name, extra in [('missing_receiver_intention', ''), ('both_intentions', '(intends bob (has bob))')]:
        folder = output/name; folder.mkdir()
        d, p = folder/'domain.pddl', folder/'problem.pddl'
        d.write_text(DOMAIN, encoding='utf-8'); p.write_text(PROBLEM.format(extra=extra), encoding='utf-8')
        source = Source('s', d, p, consent_policy='require_intentional_agents')
        meta = build([source], folder/'mapped'); map_problem([source], 's', meta, folder/'mapped/problem.pddl')
        cases[name] = folder
    classes = output/'classes'; classes.mkdir()
    hashes = {str(p): digest(p) for p in [JAR, *code, *references, *[x for x in output.rglob('*') if x.is_file()]]}
    save(output/'protocol.json', {'status': 'frozen_before_native_checks', 'sha256': hashes,
        'runtime': str(JAR), 'scope': '26 reflexive-type membership checks and three authored one-step role controls; no corpus planning or semantic labels.',
        'policy': 'Explicit consent interpreted as requiring each consenting role to have intentional agent explanation; no equivalence to native consent-ignoring behavior.'})
    compiler = run_logged(['wsl.exe', '--exec', 'javac', '--release', '8', '-encoding', 'UTF-8', '-cp', linux_path(JAR),
                           '-d', linux_path(classes), linux_path(harness)], output/'compile.log')
    if compiler['returncode'] != 0: raise RuntimeError('Regression harness compile failed')
    tests = []
    def run(name, arguments):
        result = run_logged(['wsl.exe', '--exec', 'timeout', '30s', 'java', '-Xmx4096m', '-cp',
                            linux_path(JAR)+':'+linux_path(classes), 'GlaivePriorityOneRegression', *arguments], output/(name+'.log'))
        result.update(name=name, passed=result['returncode']==0); tests.append(result)
    run('reflexive_type_relations', ['types'])
    raw = cases['missing_receiver_intention']
    run('native_ignores_consent', [linux_path(raw/'domain.pddl'), linux_path(raw/'problem.pddl'), 'give', 'alice', 'bob', '1', '0'])
    for name, expected in [('missing_receiver_intention', '1'), ('both_intentions', '0')]:
        mapped = cases[name]/'mapped'
        run(name, [linux_path(mapped/'domain.pddl'), linux_path(mapped/'problem.pddl'), 's_a_give', 's_o_alice', 's_o_bob', '2', expected])
    verify(hashes)
    report = {'status': 'verified' if all(t['passed'] for t in tests) else 'failed', 'tests': tests,
              'compiler': compiler, 'runtime_sha256': digest(JAR), 'inputs_unchanged': True,
              'model_calls': 0, 'search_calls': 0, 'corpus_plan_replay_calls': 0, 'authored_one_step_checks': 3,
              'scope': 'Finite regression fixtures, not independent narrative semantics or original-plan preservation evidence.'}
    save(output/'report.json', report)
    if report['status'] != 'verified': raise RuntimeError('Priority-one finite regression failed; logs retained')
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__); parser.add_argument('--output', type=Path, required=True)
    result = check(parser.parse_args().output.resolve())
    print(json.dumps({'status': result['status'], 'tests': len(result['tests']), 'search_calls': 0}))
