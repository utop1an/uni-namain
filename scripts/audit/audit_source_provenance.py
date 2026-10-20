"""Record local custody evidence without inferring upstream model provenance."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import subprocess

from rcnc.pddl import parse_sexpr


def git(*arguments):
    return subprocess.check_output(['git', *arguments])


def audit(inputs, output):
    if output.exists():
        raise ValueError('Use a fresh output path')
    rows = []
    for domain in sorted(inputs.glob('*_domainfile.pddl')):
        source = domain.name.removesuffix('_domainfile.pddl')
        row = {'source': source, 'domain_name': parse_sexpr(domain.read_text(encoding='utf-8'))[1][1],
               'evaluation_role': 'observed_development_source', 'files': [],
               'upstream': {key: None for key in ('repository_url','release','author','learner',
                    'learner_version','training_material','training_split','model_license')},
               'upstream_status': 'unverified_not_inferred_from_names_or_local_git_history'}
        for path in (domain, inputs/(source+'_problemfile.pddl')):
            relative = path.as_posix()
            history = git('log','--reverse','--format=%H','--',relative).decode().splitlines()
            if not history:
                raise ValueError(f'No local history: {relative}')
            first = history[0]
            initial = git('show',f'{first}:{relative}')
            current = path.read_bytes()
            row['files'].append({'path': relative,
                'sha256': hashlib.sha256(current).hexdigest(),
                'first_local_commit': first,
                'first_local_commit_time': git('show','-s','--format=%cI',first).decode().strip(),
                'initial_git_blob': git('rev-parse',f'{first}:{relative}').decode().strip(),
                'same_bytes_as_first_local_commit': initial == current,
                'same_lf_normalized_bytes': initial.replace(b'\r\n',b'\n') == current.replace(b'\r\n',b'\n'),
                'commits_touching_path': len(history)})
        rows.append(row)
    result = {'version': 1, 'checked_utc': datetime.now(timezone.utc).isoformat(),
        'source_count': len(rows), 'file_count': sum(len(r['files']) for r in rows),
        'verified_upstream_sources': 0, 'independent_test_sources': 0,
        'scope': 'Local file custody only; local commits are not upstream attribution or learning provenance',
        'implementation_sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest(), 'rows':rows}
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
    return result


if __name__ == '__main__':
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--inputs',type=Path,default=Path('data/narra-domains'))
    p.add_argument('--output',type=Path,required=True)
    a=p.parse_args()
    report=audit(a.inputs,a.output)
    print(json.dumps({k:v for k,v in report.items() if k != 'rows'},indent=2))
