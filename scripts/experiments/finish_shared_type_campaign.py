"""Post-run interface audit and evidence verification; never searches again."""
import argparse
from collections import Counter, defaultdict
from copy import deepcopy
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import time


def read(p):
    return json.loads(Path(p).read_text(encoding='utf-8'))


def sha(p):
    return hashlib.sha256(Path(p).read_bytes()).hexdigest()


def save(p, v):
    p.parent.mkdir(parents=True, exist_ok=True)
    tmp = p.with_suffix('.tmp')
    tmp.write_text(json.dumps(v, indent=2) + '\n', encoding='utf-8')
    tmp.replace(p)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--primary', type=Path, required=True)
    parser.add_argument('--official', type=Path, required=True)
    parser.add_argument('--archive', type=Path, required=True)
    parser.add_argument('--campaign-state', type=Path,
                        help='Separate coordinator receipt when recovering an unstarted follow-up stage')
    a = parser.parse_args()
    a.primary, a.official, a.archive = (p.resolve() for p in (a.primary, a.official, a.archive))
    status = a.primary / 'postprocess_status.json'
    if status.exists():
        raise ValueError('Postprocessing already launched')
    save(status, {'status': 'waiting_for_campaign', 'implementation_sha256': sha(Path(__file__))})
    while True:
        state = read(a.campaign_state or a.primary / 'campaign.json')
        if state['status'] == 'complete':
            break
        if state['status'] == 'failed':
            save(status, {'status': 'blocked_by_campaign_failure'})
            return
        time.sleep(15)
    # Use the experiment's code snapshot, never later workspace edits.
    sys.path.insert(0, str(a.official / 'code'))
    from rcnc.pddl import parse_sexpr, serialize
    from rcnc.glaive_intake import predicate_atom
    from rcnc.causal_attribution import VERSION, value_digest
    from scripts.evidence.build_paper_results import build
    review = a.official / 'interface_review_v1'
    review.mkdir()
    prior = read(a.official / 'report.json')
    prior_hash = sha(a.official / 'report.json')
    rows = deepcopy(prior['rows'])
    audit_inputs = {}
    for row in rows:
        if row['kind'] != 'composition' or row['condition'] != 'official_unidomain' or not row['dual_pass']:
            continue
        folder = review / row['id']
        folder.mkdir()
        lineage = a.archive / 'projection' / row['group'] / 'lineage.json'
        audit_inputs[str(lineage)] = sha(lineage)
        owners = defaultdict(set)
        for sid, original, target, order in read(lineage)['predicates']:
            owners[target].add(sid)
        # Prefix-sensitive legacy attribution must not call an interface absent
        # merely because official UniDomain spells a shared predicate "at".
        names = set(owners)
        renaming = {n: 'shared_official_' + hashlib.sha256(n.encode()).hexdigest()[:16]
                    for n, ids in owners.items() if len(ids) > 1}
        if set(renaming.values()) & names:
            raise ValueError('Audit alpha-renaming collision')
        def rename(x):
            if not isinstance(x, list) or not x:
                return x
            if predicate_atom(x, names):
                return [renaming.get(x[0], x[0]), *[rename(v) for v in x[1:]]]
            return [rename(v) for v in x]
        for key in ('domain', 'problem'):
            f = Path(row[key])
            audit_inputs[str(f)] = sha(f)
            (folder / (key + '.pddl')).write_text(serialize(rename(parse_sexpr(f.read_text(encoding='utf-8')))) + '\n', encoding='utf-8')
        mapping = read(row['mapping'])
        save(folder / 'mapping.json', mapping)
        save(folder / 'provenance.json', {'version': VERSION, 'actions': {},
             'domain_sha256': sha(folder / 'domain.pddl'), 'mapping_digest': value_digest(mapping)})
        save(folder / 'interface_renaming.json', {'renaming': renaming,
             'owners': {n: sorted(ids) for n, ids in owners.items()},
             'scope': 'Observed shared symbol identity in frozen lineage, not independent semantic equivalence. Multi-source action branches without certificates remain unknown.'})
        req = {**row, 'mode': 'attribution', 'domain': str(folder / 'domain.pddl'),
               'problem': str(folder / 'problem.pddl'), 'mapping': str(folder / 'mapping.json'),
               'provenance': str(folder / 'provenance.json'), 'max_interpretations': 4096, 'max_supports': 256}
        save(folder / 'request.json', req)
        cmd = [sys.executable, '-X', 'utf8', '-m', 'scripts.experiments.run_shared_type_tables', 'worker',
               '--request', str(folder / 'request.json'), '--output', str(folder / 'result.json')]
        with (folder / 'audit.log').open('xb') as log:
            try:
                result = subprocess.run(cmd, cwd=a.official / 'code', stdout=log, stderr=subprocess.STDOUT,
                     timeout=60, creationflags=getattr(subprocess, 'CREATE_NO_WINDOW', 0))
                attribution = read(folder / 'result.json') if result.returncode == 0 else {'status': 'unknown', 'reason': 'audit_error'}
            except subprocess.TimeoutExpired:
                attribution = {'status': 'unknown', 'reason': 'audit_wall_time_limit'}
        row['attribution_before_interface_audit'] = row.get('attribution')
        row['attribution'] = attribution
    for f, digest in audit_inputs.items():
        if sha(Path(f)) != digest:
            raise ValueError('Audit input changed')
    if sha(a.official / 'report.json') != prior_hash:
        raise ValueError('Campaign report changed')
    cells = defaultdict(list)
    for row in rows:
        if row['kind'] == 'composition':
            cells[(row['size'], row['condition'])].append(row)
    matched = []
    for (k, method), rr in sorted(cells.items()):
        item = {'k': k, 'method': method, 'registered': len(rr), 'physical_validated': sum(r['dual_pass'] for r in rr)}
        for depth in range(2, k + 1):
            item['C_at_least_' + str(depth)] = dict(Counter(
                r.get('attribution', {}).get('source_count_profile', {}).get('at_least', {}).get(str(depth), {}).get('status', 'unknown')
                for r in rr if r['dual_pass']))
        matched.append(item)
    report = {**prior, 'status': 'complete_shared_type_matched_physical_review', 'prior_report_sha256': prior_hash,
              'audit_inputs_sha256': audit_inputs, 'matched_composition': matched, 'rows': rows}
    save(review / 'report.json', report)
    primary_report = read(a.primary / 'report.json')
    save(a.primary / 'tables_2_3_4_reviewed.json', {
        **primary_report['tables'], 'official_unidomain': {'condition': 'shared_type_physical_export_adaptation',
        'matched_table_3': matched, 'report': str(review / 'report.json'),
        'scope': 'Shared-type export, frozen matched cohort, fresh 60-second Glaive physical condition; separate from intentional validation.'}})
    index = {'reports': {}, 'excluded_pending': {}}
    for name, f, r, metrics in [('primary', a.primary / 'report.json', primary_report, ['registered', 'summary', 'tables']),
                               ('official_physical', review / 'report.json', report, ['registered', 'counts', 'matched_composition'])]:
        index['reports'][name] = {'path': str(f), 'sha256': sha(f), 'terminal_status': r['status'],
              'denominator': 'registered', 'required_true': ['inputs_unchanged'], 'metrics': metrics,
              'scope': 'Shared-type campaign; main intentional and matched physical conditions kept separate. A manual-pause receipt, if present, requires the separately reviewed continuation report before reporting primary counts. Ontology assumptions are not independent semantic labels.'}
    save(a.primary / 'campaign_evidence_index.json', index)
    build(a.primary / 'campaign_evidence_index.json', a.primary / 'verified_campaign')
    save(status, {'status': 'complete', 'official_interface_review': str(review / 'report.json'),
                  'verified_inventory': str(a.primary / 'verified_campaign/results.json')})


if __name__ == '__main__':
    main()
