# Handover prompt — next chat

Paste this as the first message of the next session (after the hobby-game-studio skill). Use **Opus** (task 1.2 reads
MGRAPHIC assembly).

---
Project F117-REA: faithful HTML5/iPad port of F-117A Nighthawk Stealth Fighter 2.0 (DOS, 1991).
Repo clone: `C:\Users\pauli\Games\f117-REA` (GitHub midnightmangler/f117-REA; git = GitHub Desktop's bundled git.exe, see NOTES).
Read `NOTES.md` in the clone, then `re/docs/02-build-plan.md` §0 rules and task card 1.2, then `re/docs/mgraphic-api.md`
and `re/docs/vgame-asm.md` §3 (register protocols of the thunks). MGRAPHIC code: `re/out/mgraphic/MGRAPHIC_code.asm`.

Status: Phase 0 and task 1.1 done and committed. 4 tests pass. Platform layer so far (`src/platform/`): `png.js` (indexed PNG
reader), `fb.js` (`createFramebuffer()`: `pages[0..4]` Uint8Array(64000), 6-bit `dac`, `lut`, `setDacEntry`, `setPalette`,
`presentWords(n)` = MGRAPHIC #44, `copyPage`; `computeLayout`, `createDisplay`), `timer.js` (`createTicker`: 70 Hz frame, 60 Hz sound,
pause when hidden). gfx.js must draw into `fb.pages[...]` and use `fb.setDacEntry/setPalette` for DAC calls.

Task for this chat: **1.2 MGRAPHIC API port** as `src/platform/gfx.js` (card 1.2: every entry with at least one call site,
pixel-exact; tests for span fill and text metrics against the font goldens in `tests/golden/mgraphic/fonts.json`).
Decompile first (`re/decomp/mgraphic/*.md`), then port, JS carries the original address in a comment. Keep files under ~600 lines
(split gfx-text.js / gfx-blit.js if needed), tests in `tests/*.test.js`, run `py -3 tools/run_tests.py`.
Finish by updating NOTES.md (Current state / Next up), rewriting this HANDOVER.md for task 1.3, committing and pushing.
Keep replies short.
---

Task cards after that, in order: 1.3 (PIC decoder dropped, see NOTES Decisions) → 1.4 (Opus) → 1.5 → 2.1 (Opus) → 2.2 … as in
02-build-plan.md. Open items: razer watcher restart + HEARTBEAT run `f117-rea` (NOTES Next up 1), asset delivery to the iPad build.
