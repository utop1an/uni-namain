"""Text assets used to construct NarraFuse model requests."""
from pathlib import Path


_ROOT = Path(__file__).resolve().parent


def load_prompt(name):
    """Drop the text file's terminating newline, preserving message whitespace."""
    return (_ROOT / 'narrafuse' / (name + '.txt')).read_text(encoding='utf-8').removesuffix('\n')


def prompt_sources():
    """Repo-relative dependencies for reproducible implementation snapshots."""
    files = [Path(__file__).resolve(), *sorted((_ROOT / 'narrafuse').glob('*/*.txt'))]
    return [path.relative_to(_ROOT.parent) for path in files]
