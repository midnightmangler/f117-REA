# Handover prompt - next chat

Paste this as the first message of the next session (after the hobby-game-studio skill). Task 1.4 needs Opus.

---
Project F117-REA: faithful HTML5/iPad port of F-117A Nighthawk Stealth Fighter 2.0 (DOS, 1991).
Repo clone: `C:\Users\pauli\Games\f117-REA` (GitHub midnightmangler/f117-REA; git = GitHub Desktop's bundled git.exe, see NOTES).
Read `NOTES.md` in the clone, then `re/docs/02-build-plan.md` section 0 rules and task card 1.4, then `re/docs/sound.md` and `re/out/sound/*` (Dropbox).

Status: Phase 0, tasks 1.1-1.3 done. Platform layer in `src/platform/`: png, fb, timer, gfx(+text,sprite), pan, ss, world.
Test files in `tests/*.test.js` all pass (run each with node, or `py -3 tools/run_tests.py` if git is on PATH).

Task for this chat: **1.4 sound** - `src/platform/opl2.js` (port a dbopl-style YM3812 emulator, third-party algorithm allowed),
`sound.js` (WebAudio, iOS unlock on first touch, speech slices as PCM 7954 Hz, `sfx(id, priority)` for the 46 IDs), `music.js`
(sequencer: 7 voices x 0x1E-byte records, events F3-FF, instrument/F-number tables, noise voices + 4x tick mode, engine voice 6 with
throttle). Timing hooks come from timer.js (60 Hz sound tick, 6-of-7 rule, 280 Hz noise mode). Test: sequence dump matches
asound_sequences.txt (tests/golden/sound). Decompile first, JS carries the original address in a comment. Keep files under ~600 lines.
Finish by updating NOTES.md, rewriting this HANDOVER.md for task 1.5, committing and pushing. Keep replies short.
---

Task cards after that: 1.5 (Sonnet) -> 2.1 (Opus) -> 2.2 ... as in 02-build-plan.md. Open items (decided):
- ds:263F vsync-measure path in resync 1D01: reproduce exactly (needs a task card; touches timer.js).
- Asset delivery to the iPad: inline in the single HTML or a folder next to it (iPad viewer handles folders; size no concern); pick in bundle.py and test.
- 14900ks HEARTBEAT passed per NOTES; re-run to confirm.
