# Handover prompt - next chat

Paste this as the first message of the next session (after the hobby-game-studio skill). Task 2.2 is a Sonnet task.

---
Project F117-REA: faithful HTML5/iPad port of F-117A Nighthawk Stealth Fighter 2.0 (DOS, 1991).
Repo clone: `C:\Users\pauli\Games\f117-REA` (GitHub midnightmangler/f117-REA; git = GitHub Desktop's bundled git.exe, see NOTES).
Read `NOTES.md` in the clone, then `re/docs/02-build-plan.md` section 0 rules and task card 2.2, then `re/docs/format-pan.md`,
`re/docs/format-ss.md` and `re/decomp/flow/flow.md` (the intro programs are called by `src/flow.js` as `logo` and `player`).

Status: Phase 1 complete, task 2.1 done. `src/flow.js` (runFlow over async programs), `src/block.js`, `src/roster.js`; platform layer
in `src/platform/` (png, fb, timer, gfx, pan, ss, world, opl2, music, sound, assets, input). 8 test files in `tests/*.test.js` pass
(run each with node from the clone, or `py -3 tools/run_tests.py` if git is on PATH).

Task for this chat: **2.2 intro** - `src/frontend/intro.js`: MPS logo (.SS playback via platform/ss.js, 18.2 Hz delays, accumulate) as the
`logo` program (exit 2 = user abort, 0 = play the intro afterwards, other = skip it) and the PAN player (platform/pan.js; fps from the 'Z'
header, 60-tick clock, palette fade ~300 ticks (?) - resolve from PLAYER 0000:0738 and the DAC fade code) as the `player` program with the
args strings in flow.js (INTRO_ARGS, TITLE2_ARGS); skip on tap/key with the same exit codes. If a rule needs the PLAYER listing, say so and
stop (that part becomes an Opus task). Tests in `tests/intro.test.js` (timing model on a fake clock). Files under ~600 lines.
Finish by updating NOTES.md, rewriting this HANDOVER.md for task 2.3, committing and pushing. Keep replies short.
---

Open items (decided):
- ds:263F vsync-measure path in resync 1D01: reproduce exactly (needs a task card; touches timer.js).
- AdLib speech blocks the game ~1 s in the original: decide in the flight tasks whether the ticker freezes (sound.speechSec).
- Input: keyReady/getKey assume the misc driver T:02DC/02E1 reads the INT 16h buffer (verify when porting pause/quit, 1EB0 2071/2183).
- Input: pitch sign of the keypad stick (Up = Y low 0x26) is settled when 1EB0:2189 is ported.
- Touch overlay (cockpit lights/MFD bezels) not started; input.pushKey/setStick/setPseudoButton are its hooks.
- Roster: missing file seeds from the shipped ROSTER.FIL (original: DGROUP initial data, unknown) (?). Disk check 804E is skipped.
- Test machines ran only 4 tests on the last HEARTBEAT although the repo has 8 test files: check their clones pull.
- tools/export_assets.py deletes tests/golden/pic/pic_sha1.json (fix or `git checkout` it).
