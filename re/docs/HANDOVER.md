# Handover prompt — next chat

Paste this as the first message of the next session (after the hobby-game-studio skill). Use **Sonnet** (the card needs
no listing reads; switch to Opus only if you end up reading assembly).

---
Project F117-REA: faithful HTML5/iPad port of F-117A Nighthawk Stealth Fighter 2.0 (DOS, 1991).
Repo clone: `C:\Users\pauli\Games\f117-REA` (GitHub midnightmangler/f117-REA; git = GitHub Desktop's bundled git.exe, see NOTES).
Read `NOTES.md` in the clone, then `re/docs/02-build-plan.md` §0 rules and task card 1.1, then the docs the card names
(`re/docs/mgraphic-api.md` pages/present section, `re/docs/sound.md` §timing). Do not read listings.

Status: Phase 0 done and committed (0.1 repo, 0.2 assets, 0.3 RE gap-fill: rand.md, vgame-asm.md, re/disasm/vgame-asm).
3 tests pass. No port code yet beyond the canvas placeholder in src/main.js.

Task for this chat: **1.1 Framebuffer + palette + scaler** — `src/platform/fb.js` and `src/platform/timer.js`:
320×200 `Uint8Array` pages (0 screen, 1 back, 2 cockpit art), 256-entry 6-bit DAC → RGBA LUT, present via ImageData,
integer scale + letterbox, iPad fullscreen/orientation, 70 Hz frame tick with the 60 Hz sound tick (6-of-7 rule), pause
when hidden; demo page that draws one PIC. Decide the open question first and record it in NOTES Decisions: load PICs
as the indexed PNGs in assets/pic (browsers decode PNG to RGBA, so reading the indices means a small inflate + PNG
parser) **or** ship the raw .PIC files and port the LZW/RLE decoder (format-pic.md; the exact routine is described in
vgame-asm.md §2 under 11ED — 9→11-bit codes, 0x90 RLE escape, nibble mode). Keep files under ~600 lines, tests in
tests/*.test.js (Node), `py -3 tools/run_tests.py`.
Finish by updating NOTES.md (Current state / Next up), rewriting this HANDOVER.md for task 1.2, committing and pushing.
Keep replies short.
---

Task cards after that, in order: 1.2 (Opus) → 1.3 → 1.4 (Opus) → 1.5 → 2.1 (Opus) → 2.2 … as listed in 02-build-plan.md.
Note for 1.2: the asm-side register protocols of the MGRAPHIC thunks are tabulated in `re/docs/vgame-asm.md` §3.
