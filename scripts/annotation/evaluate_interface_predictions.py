"""Score saved predictions offline against two independent annotation files."""
import argparse
import hashlib
import json
from pathlib import Path

from rcnc.interface_evaluation import evaluate


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--packet', type=Path, required=True)
    parser.add_argument('--annotations', type=Path, nargs=2, required=True)
    parser.add_argument('--predictions', type=Path, required=True)
    parser.add_argument('--prediction-manifest', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    paths = [args.packet, *args.annotations, args.predictions, args.prediction_manifest]
    values = [json.loads(p.read_text(encoding='utf-8')) for p in paths]
    result = evaluate(values[0], values[1:3], values[3], values[4]['packet_sha256'])
    result['input_sha256'] = {str(p): hashlib.sha256(p.read_bytes()).hexdigest() for p in paths}
    result['implementation_sha256'] = {str(p): hashlib.sha256(p.read_bytes()).hexdigest()
        for p in (Path(__file__), Path('rcnc/interface_evaluation.py'),
                  Path('rcnc/interface_annotation.py'), Path('rcnc/annotation_agreement.py'),
                  Path('scripts/annotation/run_annotation_predictions.py'))}
    args.output.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open('x', encoding='utf-8') as stream:
        stream.write(json.dumps(result, indent=2) + '\n')
    print(json.dumps({k: v for k, v in result.items() if k not in ('rows', 'confusion_matrix', 'agreement')}, indent=2))


if __name__ == '__main__':
    main()
