"""Inject a parser failure to test domain-only compiler validation admission.

The fixture is valid; this tests checker invocation, not PDDL or semantic error.
"""
import argparse
from pathlib import Path
from unittest.mock import patch

from rcnc.aligned_domain import build as align
from rcnc.domain_union import build as union
from rcnc.domain_building import digest, require_empty_output, save, snapshot_implementation


def run(output):
    require_empty_output(output); output.mkdir(parents=True)
    inputs=output/'inputs'; inputs.mkdir()
    source=inputs/'A_domainfile.pddl'
    source.write_text('''(define (domain a) (:requirements :strips) (:predicates (done))
        (:action finish :parameters () :precondition (and) :effect (done)))''',encoding='utf-8')
    original=digest(source)
    implementation=snapshot_implementation(output,[Path(__file__),Path('rcnc/domain_union.py'),
        Path('rcnc/aligned_domain.py'),Path('rcnc/domain_building.py'),Path('rcnc/pddl.py'),Path('rcnc/pddl_checks.py')])
    save(output/'manifest.json',{'status':'frozen_before_checker_injection','source_sha256':original,
        'implementation_sha256':implementation,'injected_failure':'independent domain parse sentinel; no source problems'})
    rows=[]
    for name,builder in (('union',union),('alignment',align)):
        row={'id':name}
        with patch('rcnc.domain_building.PDDLReader') as parser:
            parser.return_value.parse_problem.side_effect=ValueError('injected independent-domain parse failure')
            try:
                result=builder(inputs,output/name,{'version':1,'decision_basis':'authored_assumption','predicate_groups':[],'type_groups':[],
                    'source_sha256':{source.name:original}}) if name=='alignment' else builder(inputs,output/name)
                row.update(compiler_valid=result['valid'],status='accepted_without_checker' if result['valid'] and not parser.return_value.parse_problem.called else 'validation_not_passed')
            except ValueError as exc:
                row.update(status='rejected',reason=str(exc))
            row['checker_calls']=parser.return_value.parse_problem.call_count
        rows.append(row)
    result={'status':'complete','task_count':2,'rows':rows,
        'all_checker_failures_blocked':all(r['checker_calls']>0 and r['status']!='accepted_without_checker' for r in rows),
        'source_unchanged':digest(source)==original,'implementation_unchanged':all(digest(Path(p))==h for p,h in implementation.items()),
        'manifest_sha256':digest(output/'manifest.json'),'model_calls':0,'planner_calls':0,
        'scope':'Two compiler paths on one authored valid domain without problem files, under an injected checker failure. Tests validation admission only; no actual invalid-model, semantic or planning efficacy conclusion.'}
    save(output/'report.json',result)
    return result


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--output',type=Path,required=True)
    print(run(parser.parse_args().output))
