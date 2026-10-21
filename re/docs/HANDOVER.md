# Handover prompt — next chat

Paste this as the first message of the next session (after the hobby-game-studio skill). Use **Opus**.

---
Project F117-REA: faithful HTML5/iPad port of F-117A Nighthawk Stealth Fighter 2.0 (DOS, 1991).
Repo clone: `C:\Users\pauli\Games\f117-REA` (GitHub midnightmangler/f117-REA; git = GitHub Desktop's bundled git.exe, see NOTES).
Read `NOTES.md` in the clone, then `re/docs/00-conventions.md` and `re/docs/02-build-plan.md` §0 rules and task card 0.3.
Do not read other docs or listings until the card needs them. Listings live in Dropbox `Game Projects\F117-REA\re\disasm\`,
unpacked EXEs in `...\re\unpacked\`; docs/tools are in the repo under `re/`.

Status: tasks 0.1 (repo) and 0.2 (asset export) are done and committed; 3 tests pass. No port code yet.

Task for this chat: **0.3 RE gap-fill** —
(a) MS C 6 `rand()`/`srand()`: find the LCG in the START/VGAME runtime (expect `seed*214013+2531011`, verify in the
    listing) and where the seed comes from; write `re/docs/rand.md`.
(b) Fresh capstone disassembly of the VGAME asm modules (segments 0FB2, 1058, 11D8, 1132, 114A, 120A, 130D, 1377, 1452)
    into `re/disasm/vgame-asm/*.asm` (commit these, they are small) with register conventions in `re/docs/vgame-asm.md`.
(c) Code islands 0CDD tail, 2031, 6B0B..6BDD, E447/E4B6 (see vgame-map.md §4, §8).
Finish by updating NOTES.md (Current state / Next up), rewriting this HANDOVER.md for task 1.1, committing and pushing.
Keep replies short.
---

Task cards after that, in order: 1.1 → 1.2 (Opus) → 1.3 → 1.4 (Opus) → 1.5 → 2.1 (Opus) → 2.2 … as listed in 02-build-plan.md.
Open question carried forward: PIC loading in JS (indexed PNG + inflate vs. raw .PIC + JS LZW) — decide in 1.1.
