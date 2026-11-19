"""Audit opt-in HTTP attempt ledgers without inference or prompt reconstruction."""
import argparse
from collections import Counter
import hashlib
import json
import math
from pathlib import Path


def audit(path):
    raw = path.read_bytes()
    violations, unknown = [], []
    intents, finished = {}, {}
    header = None
    for number, line in enumerate(raw.splitlines(keepends=True), 1):
        if not line.endswith(b'\n'):
            unknown.append({'line': number, 'reason': 'unterminated_record'})
            continue
        try:
            row = json.loads(line)
            if not isinstance(row, dict):
                raise ValueError('Object record required')
        except (ValueError, UnicodeDecodeError) as error:
            unknown.append({'line': number, 'reason': type(error).__name__})
            continue
        event = row.get('event')
        if event == 'ledger_created':
            if number != 1 or header is not None or type(row.get('version')) is not int or row['version'] != 1:
                violations.append({'line': number, 'reason': 'invalid_or_duplicate_header'})
            header = row
        elif event in ('dispatch_intent', 'attempt_finished'):
            identifier = row.get('attempt_id')
            if not isinstance(identifier, str) or not identifier:
                violations.append({'line': number, 'reason': 'missing_attempt_id'})
                continue
            target = intents if event == 'dispatch_intent' else finished
            if identifier in target:
                violations.append({'line': number, 'reason': 'duplicate_' + event})
                continue
            if event == 'attempt_finished' and identifier not in intents:
                violations.append({'line': number, 'reason': 'finish_without_preceding_intent'})
            target[identifier] = row
            if event == 'dispatch_intent':
                key = row.get('request_key')
                if not isinstance(key, str) or len(key) != 64 or any(c not in '0123456789abcdef' for c in key):
                    violations.append({'line': number, 'reason': 'invalid_request_key'})
                if header is None or row.get('model') != header.get('model'):
                    violations.append({'line': number, 'reason': 'model_header_mismatch'})
            else:
                elapsed = row.get('client_elapsed_seconds')
                if type(elapsed) not in (int, float) or not math.isfinite(elapsed) or elapsed < 0:
                    violations.append({'line': number, 'reason': 'invalid_duration'})
                if row.get('outcome') not in ('decoded_json', 'invalid_content_json',
                        'http_request_error', 'http_status_error', 'response_json_error', 'content_json_error'):
                    violations.append({'line': number, 'reason': 'unknown_outcome'})
                for name in ('prompt_eval_count', 'eval_count', 'total_duration'):
                    value = row.get(name)
                    if value is not None and (type(value) is not int or value < 0):
                        violations.append({'line': number, 'reason': 'invalid_' + name})
        else:
            violations.append({'line': number, 'reason': 'unknown_event'})
    if header is None:
        violations.append({'reason': 'missing_header'})
    unresolved = sorted(set(intents) - set(finished))
    for identifier in unresolved:
        unknown.append({'attempt_id': identifier, 'reason': 'intent_without_finish_dispatch_or_result_indeterminate'})
    tokens = {}
    for name in ('prompt_eval_count', 'eval_count'):
        values = [row.get(name) for row in finished.values()]
        valid = [value for value in values if type(value) is int and value >= 0]
        tokens[name] = {'observed_total': sum(valid), 'known_finished_attempts': len(valid),
                        'unknown_finished_attempts': len(values) - len(valid),
                        'unresolved_intents': len(unresolved)}
    unchanged = path.read_bytes() == raw
    if not unchanged:
        violations.append({'reason': 'ledger_changed_during_audit'})
    return {
        'status': 'invalid_ledger' if violations else 'incomplete_observation' if unknown else 'verified_recorded_attempts',
        'ledger_sha256': hashlib.sha256(raw).hexdigest(),
        'inputs_unchanged': unchanged, 'dispatch_intents': len(intents),
        'finished_attempts': len(finished), 'unresolved_intents': len(unresolved),
        'outcome_counts': dict(Counter(str(row.get('outcome')) for row in finished.values())),
        'returned_token_counts': tokens,
        'violations': violations, 'unknown': unknown,
        'model_calls': 0,
        'scope': 'Recorded client attempt observations only. Unmatched intent does not prove dispatch or failure. Returned counters are partial server observations, not total billing cost, model identity, validation success or semantic accuracy. No reconstruction of historical missing attempts.'
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--ledger', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    if args.output.exists():
        raise ValueError('Fresh audit output directory required')
    report = audit(args.ledger)
    args.output.mkdir(parents=True)
    (args.output / 'ledger.jsonl').write_bytes(args.ledger.read_bytes())
    if hashlib.sha256((args.output / 'ledger.jsonl').read_bytes()).hexdigest() != report['ledger_sha256']:
        raise ValueError('Ledger changed before snapshot; incomplete output retained')
    (args.output / 'report.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    print(json.dumps(report, indent=2))
    return 0 if report['status'] == 'verified_recorded_attempts' else 1


if __name__ == '__main__':
    raise SystemExit(main())
