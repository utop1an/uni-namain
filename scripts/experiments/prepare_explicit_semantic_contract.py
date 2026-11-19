"""Prepare the same fixed matrix with an explicit schema in the model prompt."""
import argparse
import json
from pathlib import Path

from rcnc.domain_building import save
from rcnc.model_semantics_contract import include_output_contract
from scripts.experiments.run_automatic_merge import prepare


def run(output, model, model_digest, num_predict=4096):
    result=prepare(output,'semantic_facets',model=model,model_digest=model_digest,num_predict=num_predict)
    include_output_contract(output/'judgments')
    protocol=json.loads((output/'protocol.json').read_text(encoding='utf-8'))
    protocol['output_contract_in_prompt']=True
    save(output/'protocol.json',protocol)
    return result


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--output',required=True,type=Path);p.add_argument('--model',required=True)
    p.add_argument('--model-digest',required=True);p.add_argument('--num-predict',type=int,default=4096)
    a=p.parse_args();print(json.dumps(run(a.output,a.model,a.model_digest,a.num_predict),indent=2))
