# Handover prompt - next chat

Paste this as the first message of the next session (after the hobby-game-studio skill). Task 2.3 is a Sonnet task.

---
Project F117-REA: faithful HTML5/iPad port of F-117A Nighthawk Stealth Fighter 2.0 (DOS, 1991).
Repo clone: `C:\Users\pauli\Games\f117-REA` (GitHub midnightmangler/f117-REA; git = GitHub Desktop's bundled git.exe, see NOTES).
Read `NOTES.md` in the clone, then `re/docs/02-build-plan.md` section 0 rules and task card 2.3, then `re/docs/setup-dswap-map.md`
(SETUP section) and `re/decomp/flow/flow.md`. SETUP is the flow program `setup` (src/flow.js: must return 0x24; fills the shared block).

Status: Phase 1 complete; 2.1 flow/block/roster and 2.2 intro done (`src/flow.js`, `src/block.js`, `src/roster.js`, `src/frontend/intro.js`).
9 test files in `tests/*.test.js` pass (run each with node from the clone, or `py -3 tools/run_tests.py` if git is on PATH).

Task for this chat: **2.3 SETUP screen** - `src/frontend/setup.js`: port equivalent of SETUP.EXE (sound on/off = AdLib emulation: write the sound
driver name "Asound.117" or "Nsound.117" into block sndName (the logo arg and nothing else reads its first letter), joystick = touch stick
(calibration block +0x48 = a fixed centred calibration, inputFlags +0x72 bit0 only if the touch stick is on), clearance +0x22 = 1,
SB+0x00 = "Mgraphic.exe", +0x26 = 1, +0x24/+0x2A/+0x70 = 0, +0x32 = 3 ('M' graphics name), +0x30 = joystick flag byte (?), exactly as listed in
setup-dswap-map.md steps 6-12). Keep the original's order and values; the text UI may be a simple HTML/canvas prompt "Select Sound Driver" that
doubles as the first user gesture (audio unlock + fullscreen). Return 0x24. Also wire `src/main.js` to run runFlow with the real programs where they exist
(setup, logo, player) and stubs that return 0 (quit) for start/vgame/end, with a host built from fb/display/input/F117.assets. If a rule needs a
listing, say so and stop (Opus task). Tests in `tests/setup.test.js`. Files under ~600 lines.
Finish by updating NOTES.md, rewriting this HANDOVER.md for task 2.4 (Opus), committing and pushing. Keep replies short.
---

Open items (decided):
- Intro music: nobody in PLAYER starts song 3 (see NOTES 2.2); find the starter before wiring music.
- ds:263F vsync-measure path in resync 1D01: reproduce exactly (needs a task card; touches timer.js).
- AdLib speech blocks the game ~1 s in the original: decide in the flight tasks whether the ticker freezes (sound.speechSec).
- Input: keyReady/getKey assume the misc driver reads the INT 16h buffer; keypad stick pitch sign settled at 1EB0:2189.
- Touch overlay (cockpit lights/MFD bezels) not started; input.pushKey/setStick/setPseudoButton are its hooks.
- Roster: missing file seeds from the shipped ROSTER.FIL (?). Disk check 804E skipped. PLAYER fade step width fixed at 0x100 (?).
- Test machines ran only 4 tests on the last HEARTBEAT although the repo has 9 test files: check their clones pull.
- tools/export_assets.py deletes tests/golden/pic/pic_sha1.json (fix or `git checkout` it).
