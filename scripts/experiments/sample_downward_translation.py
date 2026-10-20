"""Linux-only bounded stack sampling; diagnostic instrumentation, not a solver baseline.

Run in a fresh directory containing domain.pddl/problem.pddl. The planner's
installed Python package is imported without modifying its source or binary.
"""
import argparse
from collections import Counter
import json
from pathlib import Path
import resource
import signal
import sys
import time


class DiagnosticDeadline(BaseException):
    pass


def run(package_dir, seconds, output):
    if output.exists():
        raise ValueError('Never overwrite a diagnostic report')
    sys.path.insert(0, str(package_dir))
    sys.argv = ['translation-sampling', 'domain.pddl', 'problem.pddl', '--sas-file', 'diagnostic.sas']
    from fast_downward.translate.options import set_options
    set_options()
    from fast_downward.translate.main import main
    from fast_downward.translate import instantiate
    resource.setrlimit(resource.RLIMIT_AS, (4096 * 1024 ** 2,) * 2)
    resource.setrlimit(resource.RLIMIT_CPU, (seconds + 1, seconds + 2))
    start = time.monotonic()
    tops, stacks, current_actions = Counter(), Counter(), Counter()
    ground_actions = None
    original_explore = instantiate.explore
    def explore(task):
        nonlocal ground_actions
        result = original_explore(task)
        ground_actions = result[2]
        return result
    instantiate.explore = explore
    def sample(signum, frame):
        nonlocal ground_actions
        if time.monotonic() - start >= seconds:
            # Disable before raising so another alarm cannot interrupt cleanup.
            signal.setitimer(signal.ITIMER_REAL, 0)
            raise DiagnosticDeadline()
        tops[(Path(frame.f_code.co_filename).name, frame.f_code.co_name)] += 1
        seen = set()
        while frame:
            key = (Path(frame.f_code.co_filename).name, frame.f_code.co_name)
            seen.add(key)
            if frame.f_code.co_name == 'translate_task':
                ground_actions = frame.f_locals.get('actions')
            operator = frame.f_locals.get('operator')
            if operator is not None and hasattr(operator, 'name'):
                current_actions[str(operator.name).split()[0].lstrip('(')] += 1
            frame = frame.f_back
        stacks.update(seen)
    signal.signal(signal.SIGALRM, sample)
    signal.setitimer(signal.ITIMER_REAL, 0.01, 0.01)
    status = 'translation_complete'
    try:
        main()
    except DiagnosticDeadline:
        status = 'diagnostic_wall_limit'
    except SystemExit as exc:
        status = 'translator_exit_' + str(exc.code)
    finally:
        signal.setitimer(signal.ITIMER_REAL, 0)
    elapsed = time.monotonic() - start
    def rows(counter):
        return [{'file': file, 'function': function, 'samples': count}
                for (file, function), count in counter.most_common(25)]
    action_counts = Counter(str(a.name).split()[0].lstrip('(') for a in (ground_actions or []))
    report = {'status': status, 'scope': 'Instrumented translator-only diagnostic; excluded from planning-success counts and timing comparisons',
        'wall_budget_seconds': seconds, 'memory_mb': 4096, 'sampling_interval_seconds': 0.01,
        'elapsed_seconds': elapsed, 'samples': sum(tops.values()),
        'top_frames': rows(tops), 'stack_presence': rows(stacks),
        'current_action_samples': dict(current_actions.most_common()),
        'grounded_actions': len(ground_actions) if ground_actions is not None else None,
        'grounded_actions_by_schema': dict(action_counts.most_common())}
    output.write_text(json.dumps(report, indent=2), encoding='utf-8')
    print(json.dumps({k: report[k] for k in ('status', 'samples', 'grounded_actions')}), flush=True)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--package-dir', type=Path, required=True)
    parser.add_argument('--seconds', type=int, default=20)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    run(args.package_dir, args.seconds, args.output)
