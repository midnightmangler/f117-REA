#!/usr/bin/env python3
"""
Per-project test runner (HEARTBEAT template), run by watcher2.py from the local clone.

0. git pull --ff-only, so a machine never tests stale code (skipped if git is absent).
1. Builds the game with tools/bundle.py (no Dropbox copy). A broken build = FAIL.
2. Runs every tests/*.test.js with Node. Each test file passes if it exits 0.
3. Prints a SHORT summary: counts, then the first few lines of each failure.

Exit code 0 = all passed, 1 = something failed. The watcher reads that.
Needs Node.js for the JS tests; the build step does not.
"""
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
FAIL_LINES = 6  # lines of output kept per failing test


def tail(text, n):
    lines = [l for l in text.strip().splitlines() if l.strip()]
    return lines[:n]


def main():
    failures = []
    passed = 0

    # 0. Pull
    git = shutil.which("git")
    if git and (ROOT / ".git").exists():
        g = subprocess.run([git, "pull", "--ff-only"], cwd=ROOT, capture_output=True, text=True)
        if g.returncode != 0:
            failures.append(("git pull --ff-only", tail(g.stdout + g.stderr, FAIL_LINES)))

    # 1. Build
    bundle = ROOT / "tools" / "bundle.py"
    if bundle.exists():
        b = subprocess.run([sys.executable, str(bundle), "--no-dropbox"], cwd=ROOT,
                           capture_output=True, text=True)
        if b.returncode != 0:
            failures.append(("build (bundle.py)", tail(b.stdout + b.stderr, FAIL_LINES)))
        else:
            passed += 1

    # 2. JS tests
    tests = sorted((ROOT / "tests").glob("*.test.js"))
    node = shutil.which("node")
    if tests and not node:
        failures.append(("setup", ["Node.js not found; install it to run JS tests"]))
    elif tests:
        for t in tests:
            r = subprocess.run([node, str(t)], cwd=ROOT, capture_output=True, text=True, timeout=300)
            if r.returncode == 0:
                passed += 1
            else:
                failures.append((t.name, tail(r.stdout + r.stderr, FAIL_LINES)))

    # 3. Summary
    print(f"passed: {passed}  failed: {len(failures)}")
    for name, lines in failures:
        print(f"\nFAIL {name}")
        for l in lines:
            print(f"  {l}")
    sys.exit(1 if failures else 0)


if __name__ == "__main__":
    main()
