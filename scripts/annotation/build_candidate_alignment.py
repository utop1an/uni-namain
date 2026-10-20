"""Offline candidate -> consistency audit -> alignment -> optional domain compile."""
import argparse
import json
from pathlib import Path

from rcnc.candidate_alignment import run


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    for field in ('packet', 'predictions', 'prediction-manifest', 'inputs', 'output'):
        parser.add_argument('--' + field, type=Path, required=True)
    parser.add_argument('--infer-role-types', action='store_true',
                        help='Explicit experimental role-type hypotheses; never semantic approval')
    parser.add_argument('--compile', action='store_true')
    args = parser.parse_args()
    result = run(args.packet, args.predictions, args.inputs, args.output, args.infer_role_types, args.compile,
                 args.prediction_manifest)
    print(json.dumps({k: v for k, v in result.items() if k not in ('graph', 'decisions')}, indent=2))
    if result['status'] != 'complete':
        raise SystemExit(1)
