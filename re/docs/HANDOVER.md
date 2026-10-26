# Handover prompt - next chat

Paste this as the first message of the next session (after the hobby-game-studio skill). Task 2.4 is an Opus task.

---
Project F117-REA: faithful HTML5/iPad port of F-117A Nighthawk Stealth Fighter 2.0 (DOS, 1991).
Repo clone: `C:\Users\pauli\Games\f117-REA` (GitHub midnightmangler/f117-REA; git = GitHub Desktop's bundled git.exe, see NOTES).
Read `NOTES.md` in the clone, then `re/docs/02-build-plan.md` section 0 rules and task card 2.4, then `re/docs/start-map.md`
(sections 1-3 and the function table) and `re/decomp/flow/flow.md`. START listing: `C:\Dropbox\Game Projects\F117-REA\re\disasm\START.asm`.

Status: Phase 1 and tasks 2.1-2.3 done. `npm`-free: `src/main.js` runs `F117.flow.runFlow` with real programs setup, logo, player and quit stubs for
start/vgame/end (it shows "Front end not ported yet"). Verified in the browser pane (SETUP -> MPS logo -> TITLE-1 intro); not yet on the iPad.
10 test files in `tests/*.test.js` pass (run each with node from the clone). To look at the build: `py -3 tools/bundle.py`, serve `dist/` with
any static server (python -m http.server needs a few seconds), open it in the browser pane.

Task for this chat: **2.4 START - roster and pilot screens** (`func_0000_64E5`, `6861`, `6DB8`, `615C`, `623E`, `7218/7272` roster I/O (done in
`src/roster.js`), rank strings, delete, retired/killed rules) -> `src/frontend/roster.js` as the first screens of the `start` program, plus the
START shell they need: generic menu machinery (`3641` pic load + fade, `38AC` menu_wait, `39F7` input incl. Alt-Q quit prompt, `393D` hit test,
`3CEA` requester) in `src/frontend/menu.js`, using `src/platform/gfx.js` (MGRAPHIC port: text, sprites, blits), `src/platform/input.js`
(add touch/mouse cursor support there or in menu.js; Enter/Esc/arrow-jump rules from 39F7) and `src/roster.js` (pilot record fields, sync).
START main (`0000:0010`): init, roster_sync (done), 0E23, state machine 020F starting on the roster screen when `bios.firstEntry != 0` or
PR status != 0. Decompile first into `re/decomp/start/*.md`, mark guesses (?). Tests in `tests/roster-screen.test.js` (logic: slot selection,
status rules 1 retired / 2 killed requesters, delete, header byte) - pixel output only checked by eye in the browser pane.
Finish by updating NOTES.md, rewriting this HANDOVER.md for task 2.5, committing and pushing. Keep replies short.
---

Open items (decided):
- Intro music: nobody in PLAYER starts song 3 (see NOTES 2.2); find the starter (timer module 026B?) before wiring music.
- ds:263F vsync-measure path in resync 1D01: reproduce exactly (needs a task card; touches timer.js).
- AdLib speech blocks the game ~1 s in the original: decide in the flight tasks whether the ticker freezes (sound.speechSec).
- Input: keyReady/getKey assume the misc driver reads the INT 16h buffer; keypad stick pitch sign settled at 1EB0:2189.
- Touch overlay (cockpit lights/MFD bezels) not started; input.pushKey/setStick/setPseudoButton are its hooks.
- SETUP: joystick/mouse questions dropped; calibration block format (+0x48) not needed until the touch stick exists.
- Roster: missing file seeds from the shipped ROSTER.FIL (?). Disk check 804E skipped. PLAYER fade step width fixed at 0x100 (?).
- Test machines ran only 4 tests on the last HEARTBEAT although the repo has 10 test files: check their clones pull.
- tools/export_assets.py deletes tests/golden/pic/pic_sha1.json (fix or `git checkout` it).
