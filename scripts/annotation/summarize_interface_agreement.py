"""Report annotation coverage and agreement without fabricating absent judgments."""
import argparse
import hashlib
import json
from pathlib import Path
from rcnc.annotation_agreement import agreement


if __name__ == '__main__':
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--packet',type=Path,required=True)
    p.add_argument('--annotation',type=Path,action='append',default=[])
    p.add_argument('--output',type=Path,required=True)
    a=p.parse_args()
    if a.output.exists():
        p.error('Use a fresh output path')
    paths=[a.packet,*a.annotation]
    values=[json.loads(path.read_text(encoding='utf-8')) for path in paths]
    result=agreement(values[0],values[1:])
    result['input_sha256']={str(path):hashlib.sha256(path.read_bytes()).hexdigest() for path in paths}
    result['implementation_sha256']={str(path):hashlib.sha256(path.read_bytes()).hexdigest() for path in
        (Path(__file__),Path('rcnc/annotation_agreement.py'),Path('rcnc/interface_annotation.py'))}
    a.output.parent.mkdir(parents=True,exist_ok=True)
    a.output.write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(result,indent=2))
