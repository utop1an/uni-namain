"""Command-line interfaces for union and explicit-alignment domain builders."""
import argparse
import json
from pathlib import Path

from . import domain_union, aligned_domain


def argument_parser(description, *, alignment=False, prog=None):
    parser = argparse.ArgumentParser(prog=prog, description=description)
    parser.add_argument('--input', type=Path, default=Path('data/narra-domains'))
    if alignment:
        parser.add_argument('--alignment', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    return parser


def union_main(argv=None, *, prog=None):
    args = argument_parser(domain_union.__doc__, prog=prog).parse_args(argv)
    result = domain_union.build(args.input, args.output)
    print(json.dumps(result, indent=2))
    raise SystemExit(0 if result['valid'] else 1)


def aligned_main(argv=None, *, prog=None):
    args = argument_parser(aligned_domain.__doc__, alignment=True, prog=prog).parse_args(argv)
    specification = json.loads(args.alignment.read_text(encoding='utf-8'))
    print(json.dumps(aligned_domain.build(args.input, args.output, specification), indent=2))
