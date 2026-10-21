# Handover prompt - next chat

Paste this as the first message of the next session (after the hobby-game-studio skill). Task 1.5 is a Sonnet task.

---
Project F117-REA: faithful HTML5/iPad port of F-117A Nighthawk Stealth Fighter 2.0 (DOS, 1991).
Repo clone: `C:\Users\pauli\Games\f117-REA` (GitHub midnightmangler/f117-REA; git = GitHub Desktop's bundled git.exe, see NOTES).
Read `NOTES.md` in the clone, then `re/docs/02-build-plan.md` section 0 rules and task card 1.5, then `re/docs/vgame-map.md` section 7.

Status: Phase 1 tasks 1.1-1.4 done. Platform layer in `src/platform/`: png, fb, timer, gfx(+text,sprite), pan, ss, world,
opl2, music, sound. Test files in `tests/*.test.js` all pass (run each with node, or `py -3 tools/run_tests.py` if git is on PATH).

Task for this chat: **1.5 input core** - `src/platform/input.js`: one key word per frame queue (`ds:DEBC` semantics), stick bytes
X/Y (0x80 centre) with the keypad virtual-stick rules (deflection 0x5A/0x7F, 5-tick double-press), buttons 0/1, misc-driver
key-ready/get-key for the pause/quit prompts; hardware keyboard for desktop testing. Touch overlay comes later (only allowed
departure: touch on cockpit lights/MFD bezels). Read only the docs the card names; if a rule needs the listing, stop and say so
(that part becomes an Opus task). Tests in `tests/input.test.js`. Keep files under ~600 lines.
Finish by updating NOTES.md, rewriting this HANDOVER.md for task 2.1, committing and pushing. Keep replies short.
---

Task cards after that: 2.1 (Opus) -> 2.2 ... as in 02-build-plan.md. Open items (decided):
- ds:263F vsync-measure path in resync 1D01: reproduce exactly (needs a task card; touches timer.js).
- Asset delivery to the iPad: inline in the single HTML (user decision); implement in bundle.py and test.
- AdLib speech blocks the game ~1 s in the original: decide in 2.1 whether the ticker freezes (sound.speechSec).
- Sound not yet heard on the iPad: the main.js demo plays the next id per tap.
- Test machines ran only 4 tests on the last HEARTBEAT although the repo has 6+ test files: check their clones pull.
