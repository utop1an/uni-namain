"""Build reusable narrative domains or plan from an explicit initial state."""
import argparse


def main(argv=None):
    parser = argparse.ArgumentParser(prog='python -m rcnc', description=__doc__)
    commands = parser.add_subparsers(dest='command', required=True)
    for name, help_text in (
        ('build-union', 'Build a source-preserving namespaced domain'),
        ('build-aligned', 'Build a domain with explicit alignment assumptions'),
        ('build-shared', 'Compile native shared types and reusable source actions'),
        ('plan-shared', 'Plan in a saved shared-type domain from an explicit world'),
        ('plan', 'Plan or explore outcomes from an explicit initial state'),
    ):
        # Each existing parser owns its arguments, including subcommand --help.
        commands.add_parser(name, help=help_text, add_help=False)
    selected, remaining = parser.parse_known_args(argv)
    prog = f'{parser.prog} {selected.command}'
    if selected.command == 'plan':
        from .pipeline_cli import main as run
    elif selected.command == 'build-shared':
        from .shared_type_cli import build_main as run
    elif selected.command == 'plan-shared':
        from .shared_type_cli import plan_main as run
    elif selected.command == 'build-union':
        from .domain_builder_cli import union_main as run
    else:
        from .domain_builder_cli import aligned_main as run
    return run(remaining, prog=prog)


if __name__ == '__main__':
    main()
