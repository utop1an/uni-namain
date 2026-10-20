"""Compatibility command for the historical offline semantic merge baseline.

Current PDDL parsing/export is in rcnc.pddl; this command retains the old CLI.
"""
from archive.domain_merge import main


if __name__ == '__main__':
    main()
