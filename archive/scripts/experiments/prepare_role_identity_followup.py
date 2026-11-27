"""Separate predeclared prompt clarification; never replace prior responses."""
from prompts import load_prompt

import argparse
import copy
from datetime import datetime, timezone
from pathlib import Path
import shutil

from rcnc.domain_building import digest, require_empty_output, save, snapshot_implementation
from rcnc.model_semantics import prepare as prepare_model
from rcnc.model_semantics_contract import include_output_contract
from scripts.experiments.run_role_contract_merge import read, code_paths
from scripts.experiments.run_transport_merge import MODEL_DIGEST

OLD_SENTENCE = 'A different prerequisite or required object does not by itself change the event. Record such a difference as preconditions_only.'
CLARIFICATION = load_prompt('historical_alignment/role_identity_clarification')


def prepare(parent, output):
    require_empty_output(output)
    output.mkdir(parents=True)
    protocol = copy.deepcopy(read(parent / 'protocol.json'))
    for name in ('inputs', 'native'):
        shutil.copytree(parent / name, output / name)
    for case in protocol['originals']:
        relative = Path(case['directory']).relative_to(parent)
        case['directory'] = (output / relative).as_posix()
    protocol.update(created_utc=datetime.now(timezone.utc).isoformat(), followup_parent=parent.as_posix(),
        model_conditions={'role_identity_first': {'pairs': 11, 'policy': 'semantic_facets_optional_roles', 'prompt_clarification': CLARIFICATION}},
        reused_budget_control=(parent / 'budget_control').as_posix(),
        scope=protocol['scope'] + ' Separately frozen adaptive prompt followup after the optional-role contract still truncated. Acceptance thresholds/compiler unchanged. Budget-only control reused, not new calls.')
    save(output / 'protocol.json', protocol)
    prepare_model(output / 'inputs', protocol['pairs'], output / 'judgments', model='glm-5.3:cloud',
        model_digest=MODEL_DIGEST, total_seconds=2640, request_seconds=240,
        schema_policy='semantic_facets_optional_roles', num_predict=16384, num_ctx=32768)
    include_output_contract(output / 'judgments')
    folder = output / 'judgments'
    requests, manifest = read(folder / 'requests.json'), read(folder / 'manifest.json')
    (folder / 'requests_before_role_identity.json').write_bytes((folder / 'requests.json').read_bytes())
    for request in requests.values():
        text = request['messages'][0]['content']
        if text.count(OLD_SENTENCE) != 1:
            raise ValueError('Expected exactly one applicability instruction')
        request['messages'][0]['content'] = text.replace(OLD_SENTENCE, CLARIFICATION)
    save(folder / 'requests.json', requests)
    manifest.update(requests_sha256=digest(folder / 'requests.json'), prompt_policy='role_identity_before_applicability',
                    previous_requests_sha256=digest(folder / 'requests_before_role_identity.json'))
    manifest['implementation_sha256'].update(snapshot_implementation(folder, [Path(__file__)]))
    save(folder / 'manifest.json', manifest)
    code = snapshot_implementation(output / 'pre_model', [*code_paths(), Path(__file__)])
    frozen = [p for p in output.rglob('*') if p.is_file() and 'implementation' not in p.parts]
    save(output / 'pre_model_freeze.json', {'status': 'frozen_before_model_calls',
        'input_sha256': {p.as_posix(): digest(p) for p in frozen}, 'implementation_sha256': code})
    return {'status': 'prepared', 'model_calls_planned': 11, 'reused_control_calls': 0, 'solver_tasks': 126}


if __name__ == '__main__':
    import json
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--parent', required=True, type=Path)
    p.add_argument('--output', required=True, type=Path)
    args = p.parse_args()
    print(json.dumps(prepare(args.parent, args.output), indent=2))
