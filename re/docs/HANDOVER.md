# Handover prompt — next chat

Paste this as the first message of the next session (after the hobby-game-studio skill):

---
Project F117-REA: faithful HTML5/iPad port of F-117A Nighthawk Stealth Fighter 2.0 (DOS, 1991).
Read `C:\Dropbox\Game Projects\F117-REA\NOTES.md`, then `re/docs/00-conventions.md`, `re/docs/01-architecture.md`
and `re/docs/02-build-plan.md` (skim §0 rules and §9 decisions). Do not read listings or other docs until a task needs them.

Status: reverse-engineering phase 1 is complete (architecture, all data formats decoded + verified with Python
tools in `re/tools`, graphics/sound driver APIs, structural maps of every executable). No port code yet, no git repo yet.

Decisions are settled (§9): slug f117-rea, own framebuffer, port an OPL2 emulator. Git status: [say whether the
repo exists and where the clone is].

Task for this chat: **0.1 repo setup** (Sonnet is fine) — lay out the repo per the studio standard, bundle.py,
run_tests.py, .gitignore, copy NOTES.md, first commit. Then, if time allows, **0.2 asset export** per the card.
Finish by updating NOTES.md (Current state / Next up) and rewriting this HANDOVER.md for the following task.
Keep replies short.
---

Task cards after that, in order: 0.3 (Opus, RE gap-fill: rand(), VGAME asm modules, code islands) → 1.1 → 1.2 (Opus) →
1.3 → 1.4 (Opus) → 1.5 → 2.1 (Opus) → 2.2 … as listed in 02-build-plan.md.
