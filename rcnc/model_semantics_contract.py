"""Expose the exact output schema in text for endpoints ignoring format metadata."""
import json
from pathlib import Path

from .domain_building import digest, save, snapshot_implementation


def include_output_contract(output):
    """Finalize a freshly prepared request set, before any model invocation.

    This changes prompts, not model answers or compiler acceptance rules.
    Older requests remain untouched in their separately versioned directories.
    """
    if any((output/name).exists() for name in ('progress.json','report.json','requests_before_contract.json')):
        raise ValueError('Contract finalization requires a fresh, unexecuted request set')
    manifest=json.loads((output/'manifest.json').read_text(encoding='utf-8'))
    requests=json.loads((output/'requests.json').read_text(encoding='utf-8'))
    if digest(output/'requests.json')!=manifest['requests_sha256']:
        raise ValueError('Prepared request hash differs')
    original=(output/'requests.json').read_bytes()
    for request in requests.values():
        instruction, data=request['messages'][0]['content'].rsplit('\n',1)
        request['messages'][0]['content']=(instruction+'\nRequired output JSON schema (all required fields, exact names and types; '
            'no markdown fences, no extra prose):\n'+json.dumps(request['format'])+'\nInput data:\n'+data)
    (output/'requests_before_contract.json').write_bytes(original)
    save(output/'requests.json',requests)
    manifest['requests_sha256']=digest(output/'requests.json')
    manifest['output_contract_in_prompt']=True
    manifest['pre_contract_requests_sha256']=digest(output/'requests_before_contract.json')
    manifest['implementation_sha256'].update(snapshot_implementation(output,[Path(__file__)]))
    save(output/'manifest.json',manifest)
    return manifest
