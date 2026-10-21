# Handover prompt - next chat

Paste this as the first message of the next session (after the hobby-game-studio skill). Sonnet is enough for 1.3.

---
Project F117-REA: faithful HTML5/iPad port of F-117A Nighthawk Stealth Fighter 2.0 (DOS, 1991).
Repo clone: `C:\Users\pauli\Games\f117-REA` (GitHub midnightmangler/f117-REA; git = GitHub Desktop's bundled git.exe, see NOTES).
Read `NOTES.md` in the clone, then `re/docs/02-build-plan.md` section 0 rules and task card 1.3, then `re/docs/format-pan.md`, `format-ss.md`.

Status: Phase 0, tasks 1.1 and 1.2 done and committed. 5 tests pass. Platform layer (`src/platform/`): png.js, fb.js, timer.js,
gfx.js (+ gfx-text.js, gfx-sprite.js = whole MGRAPHIC API; `createGfx(fb, fonts)`, see re/decomp/mgraphic/gfx-notes.md).

Task for this chat: **1.3 decoders in JS** - `src/platform/pan.js` (PAN: LZ tokens + RunSkipDump cels + palette header) and `ss.js`;
world data is already shipped as JSON (NOTES Decisions) so `world.js` is only a loader; the PIC decoder is dropped (PNGs).
Golden tests: tests/golden/pan, tests/golden/ss (Python decoder outputs). Keep files under ~600 lines, tests in `tests/*.test.js`,
run `py -3 tools/run_tests.py`. Decompile first (re/tools/pan.py, ss.py are the reference), JS carries the original address in a comment.
Finish by updating NOTES.md (Current state / Next up), rewriting this HANDOVER.md for task 1.4 (Opus), committing and pushing. Keep replies short.
---

Task cards after that: 1.4 (Opus) -> 1.5 -> 2.1 (Opus) -> 2.2 ... as in 02-build-plan.md. Open items: asset delivery to the iPad build,
ds:263F vsync-measure path (NOTES Next up 2-3), 14900ks HEARTBEAT untested.
