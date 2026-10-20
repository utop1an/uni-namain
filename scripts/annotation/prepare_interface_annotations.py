"""Prepare outcome-blind development annotation packets without contacting anyone."""
import argparse
import json
from pathlib import Path
from rcnc.interface_annotation import build_packet, validate_annotations

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest='command', required=True)
    build = sub.add_parser('build')
    build.add_argument('--inputs', type=Path, default=Path('data/narra-domains'))
    build.add_argument('--output', type=Path, required=True)
    build.add_argument('--per-stratum', type=int, default=24)
    build.add_argument('--seed', default='icaps-development-v1')
    check = sub.add_parser('check')
    check.add_argument('--packet', type=Path, required=True)
    check.add_argument('--annotations', type=Path, required=True)
    args = parser.parse_args()
    if args.command == 'build':
        result = build_packet(args.inputs, args.output, args.per_stratum, args.seed)
        result = {k: v for k, v in result.items() if k not in ('selection', 'source_sha256')}
    else:
        result = validate_annotations(json.loads(args.packet.read_text(encoding='utf-8')),
                                      json.loads(args.annotations.read_text(encoding='utf-8')))
    print(json.dumps(result, indent=2))
    if args.command == 'check' and not result['valid']:
        raise SystemExit(1)
