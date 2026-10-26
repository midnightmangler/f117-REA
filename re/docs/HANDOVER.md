# Handover prompt - next chat

Paste this as the first message of the next session (after the hobby-game-studio skill). Task 2.5 is an Opus task.

---
Project F117-REA: faithful HTML5/iPad port of F-117A Nighthawk Stealth Fighter 2.0 (DOS, 1991).
Repo clone: `C:\Users\pauli\Games\f117-REA` (GitHub midnightmangler/f117-REA; git = GitHub Desktop's bundled git.exe, see NOTES).
Read `NOTES.md` in the clone, then `re/docs/02-build-plan.md` section 0 rules and task card 2.5, then `re/docs/start-map.md` (2.2, 2.3 orders,
5.x) and `re/decomp/start/roster.md` (the START toolkit you build on). START listing: `C:\Dropbox\Game Projects\F117-REA\re\disasm\START.asm`
(the unpacked image is `re\unpacked\START.EXE`; DGROUP file offset = MZ header + 0x0A95*16 + ds offset; data tables are easiest to dump with a short python script).

Status: tasks 1.1-2.4 done. `src/frontend/menu.js` = START machinery (createUi(host): pages 0-4, DAC patch queue ui.setColour, fade, cursor, menuWait(desc),
requester(dlg,x,y), wrapText, text helpers, quitScreen), `roster-screen.js`, `start.js` (START program: init, roster sync, state machine with state 4 = roster and a
stub home screen: picture + hotspots, state 0). main.js runs the whole F117.COM flow in the browser; `?skipintro` skips the logo and the PAN intro. 11 test files
in `tests/*.test.js` pass (run each with node from the clone; `tests/start.test.js` shows how to script pointer clicks and keys headless).
To look at a build: `py -3 tools/bundle.py`, serve `dist/` with a static server (node http server one-liner works; python -m http.server needs a few seconds),
open `f117-rea.html?skipintro` in the browser pane (rAF is throttled there, the front end uses timers).

Task for this chat: **2.5 START - theatre / options / mission type screen (orders)**: `func_0000_5BF0` orders_screen (hotspots: 9 theatres via ds:0DE2, 3 war states,
4 mission types, done; clearance requester ds:7338; "Changing pilot orders will cancel..." requester ds:70AA when a mission is scheduled), `5A8A` orders_draw (ordrscrn +
ordrsprt, markers ds:0DEC/0DFA/0DF2/0E00, theatre highlight colours ds:0DD8), `5E6F` hover, `5FFA`/`6045`/`60DC` theatre texts, and the home screen's info panel
`008D` + difficulty rating `02BA` (start-map 2.4) so the state machine can be driven from home: hotspot 1 = orders. Put the screen in `src/frontend/orders.js`, wire it
into `start.js` (state 1), decompile first into `re/decomp/start/orders.md`. Tests in `tests/orders.test.js` (logic via scripted clicks; pixels by eye in the browser pane).
Finish by updating NOTES.md, rewriting this HANDOVER.md for task 2.6, committing and pushing. Keep replies short.
---

Open items (decided):
- Intro music: nobody in PLAYER starts song 3 (see NOTES 2.2); find the starter before wiring music.
- ds:263F vsync-measure path in resync 1D01: reproduce exactly (needs a task card; touches timer.js).
- AdLib speech blocks the game ~1 s in the original: decide in the flight tasks whether the ticker freezes (sound.speechSec).
- Input: keyReady/getKey assume the misc driver reads the INT 16h buffer; START normalises keys as ASCII byte else scan<<8 (inferred); keypad stick pitch sign at 1EB0:2189.
- Touch overlay (cockpit lights/MFD bezels, plus Esc/Delete buttons for the START menus) not started; input.pushKey/setStick/setPseudoButton are its hooks.
- Roster: missing file seeds from the shipped ROSTER.FIL (?). Disk check 804E skipped. PLAYER fade step width fixed at 0x100 (?). Roster row 1 red until hovered (palette data, (?)).
- 0E23 (weapon shortages roll at START init) not run yet: belongs to the armament task.
- Test machines ran only 4 tests on the last HEARTBEAT although the repo has 11 test files: check their clones pull.
- tools/export_assets.py deletes tests/golden/pic/pic_sha1.json (fix or `git checkout` it).
