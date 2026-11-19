"""Frozen no-search native admission and separate development search."""
import argparse
from collections import Counter
from datetime import datetime, timezone
import json
from pathlib import Path

from rcnc.domain_building import digest, require_empty_output, save
from rcnc.glaive_runtime import invoke


def run(intake, output, classes, mode):
    require_empty_output(output); output.mkdir(parents=True)
    source_protocol = json.loads((intake / 'protocol.json').read_text(encoding='utf-8'))
    rows = source_protocol['sources']
    if mode == 'development': rows = [r for r in rows if r['split'] == 'development']
    jar = intake / 'upstream/there_and_back/glaive/Glaive/glaive.jar'
    protocol = {'status': 'frozen_before_execution', 'created_utc': datetime.now(timezone.utc).isoformat(),
                'mode': mode, 'sources': rows, 'seconds_each': 10 if mode == 'inspect' else 30,
                'memory_mb': 4096, 'workers': 1, 'attempts': 1,
                'intake_protocol_sha256': digest(intake / 'protocol.json'), 'jar_sha256': digest(jar),
                'implementation_sha256': {str(p): digest(p) for p in [Path(__file__), Path('rcnc/glaive_runtime.py'),
                                                                   Path('scripts/java/GlaiveProbe.java'), classes / 'GlaiveProbe.class']},
                'semantics': 'Unmodified revised domain and problem; native Glaive with intentionality and axioms. Parse inspection does not search or supply semantic labels.'}
    save(output / 'protocol.json', protocol)
    results = []
    for row in rows:
        folder = intake / 'upstream/results/runs' / row['upstream_id']
        domain, problem = folder / 'revised-domain.pddl', folder / 'revised-problem.pddl'
        record = dict(row)
        if not domain.stat().st_size or not problem.stat().st_size:
            record.update(status='empty_revised_output', search_calls=0)
        else:
            result = invoke(jar, domain, problem, output / row['id'], mode='inspect' if mode == 'inspect' else 'search',
                            seconds=protocol['seconds_each'], classes=classes)
            record.update(result)
        results.append(record)
        save(output / 'progress.json', {'completed': len(results), 'total': len(rows), 'rows': results})
        print(row['id'], record['status'], flush=True)
    report = {'status': 'complete', 'mode': mode, 'source_count': len(rows),
              'counts': dict(Counter(r['status'] for r in results)),
              'search_calls': sum(r['search_calls'] for r in results), 'model_calls': 0, 'rows': results}
    save(output / 'report.json', report)
    print(json.dumps({k: v for k, v in report.items() if k != 'rows'}, indent=2))


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('mode', choices=['inspect', 'development'])
    p.add_argument('--intake', type=Path, required=True)
    p.add_argument('--output', type=Path, required=True)
    p.add_argument('--classes', type=Path, default=Path('.tmp/glaive_classes_v1'))
    a = p.parse_args(); run(a.intake, a.output, a.classes, a.mode)
