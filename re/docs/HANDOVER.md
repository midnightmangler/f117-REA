# Handover prompt - next chat

Paste this as the first message of the next session (after the hobby-game-studio skill). Task 2.1 is an Opus task.

---
Project F117-REA: faithful HTML5/iPad port of F-117A Nighthawk Stealth Fighter 2.0 (DOS, 1991).
Repo clone: `C:\Users\pauli\Games\f117-REA` (GitHub midnightmangler/f117-REA; git = GitHub Desktop's bundled git.exe, see NOTES).
Read `NOTES.md` in the clone, then `re/docs/02-build-plan.md` section 0 rules and task card 2.1, then the docs the card names
(`01-architecture.md`, `start-map.md` section 1.3, `setup-dswap-map.md`).

Status: Phase 1 complete (1.1-1.5). Platform layer in `src/platform/`: png, fb, timer, gfx(+text,sprite), pan, ss, world,
opl2, music, sound, assets, input. Test files in `tests/*.test.js` (7) all pass (run each with node from the clone, or
`py -3 tools/run_tests.py` if git is on PATH).

Task for this chat: **2.1 program flow + shared block** - `src/flow.js` (F117.COM state machine SETUP->LOGO->INTRO->loop{START->
[title-2]->VGAME->END}), `src/block.js` (shared block as a typed structure, every offset from start-map.md 1.3 + vgame-map.md),
ROSTER.FIL persisted in localStorage (2-byte header + 80-byte records, exact bytes). Tests for flow, block and roster.
Cite SEG:OFF addresses; decompile to re/decomp/ before porting. Keep files under ~600 lines.
Finish by updating NOTES.md, rewriting this HANDOVER.md for the next card, committing and pushing. Keep replies short.
---

Task cards after that: 2.2 ... as in 02-build-plan.md. Open items (decided):
- ds:263F vsync-measure path in resync 1D01: reproduce exactly (needs a task card; touches timer.js).
- AdLib speech blocks the game ~1 s in the original: decide in 2.1 whether the ticker freezes (sound.speechSec).
- Input: keyReady/getKey assume the misc driver T:02DC/02E1 reads the INT 16h buffer (verify when porting pause/quit, 1EB0 2071/2183).
- Input: pitch sign of the keypad stick (Up = Y low 0x26) is settled when 1EB0:2189 (stick -> roll/pitch cmd) is ported.
- Touch overlay (cockpit lights/MFD bezels) not started; input.pushKey/setStick/setPseudoButton are its hooks.
- Test machines ran only 4 tests on the last HEARTBEAT although the repo has 7 test files: check their clones pull.
