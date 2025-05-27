#!/usr/bin/env python3

import glob
import re
import sys

# adjust these to whatever indicates a failure in your logs
ERROR_PATTERNS = [
    re.compile(r'DECISION MISMATCH\b'),
]
# capture the final decision value (0 or 1)
DECISION_PATTERN = re.compile(r'SB: DECISION OK WORKED FINE! = (\d)')

def extract_run_number(fname):
    # assumes filenames like 'sim.<n>.log'
    m = re.match(r'sim\.(\d+)\.log$', fname)
    return int(m.group(1)) if m else float('inf')

def check_log(path):
    """
    Returns (failed: bool, first_err_line: str or None, decision: str or None),
    scanning only the last 25 lines for ERROR_PATTERNS and DECISION_PATTERN.
    """
    with open(path, 'r', errors='ignore') as f:
        lines = f.readlines()[-25:]

    # look for decision line (0 or 1)
    decision = None
    for line in lines:
        m = DECISION_PATTERN.search(line)
        if m:
            decision = m.group(1)
            break

    # look for error patterns
    for line in lines:
        for pat in ERROR_PATTERNS:
            if pat.search(line):
                return True, line.strip(), decision

    return False, None, decision

def main():
    # sort by the integer inside the filename instead of lexicographically
    logs = sorted(glob.glob('sim.*.log'), key=extract_run_number)
    if not logs:
        print("No sim.*.log files found.", file=sys.stderr)
        sys.exit(1)

    # Header (added DEC column)
    print(f"{'LOG':<12}  {'STATUS':<6}  {'FIRST ERROR LINE':<40}  DEC")
    print("-" * 70)
    any_fail = False

    for log in logs:
        failed, first_err, decision = check_log(log)
        status = "FAIL" if failed else "PASS"
        print(f"{log:<12}  {status:<6}  {first_err or '':<40}  {decision or ''}")
        if failed:
            any_fail = True

    sys.exit(1 if any_fail else 0)

if __name__ == "__main__":
    main()

