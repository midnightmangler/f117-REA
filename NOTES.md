# F117-REA
Faithful HTML5/iPad re-creation of F-117A Nighthawk Stealth Fighter 2.0 (MicroProse DOS, 1991). Slug: f117-rea. Dropbox: F117-REA.
GitHub repo and local clone are spelled `f117-REA`; request.txt for the test watcher must say `f117-REA`.

## Engine
None: own 320x200 palettised framebuffer (decided 2026-10-21; render-engine not used).

## File map
- index.src.html, src/main.js: shell + phase-0 placeholder; tools/bundle.py → dist/f117-rea.html → Dropbox builds/
- tools/run_tests.py: git pull, bundle, tests/*.test.js (Node)
- re/docs/00-conventions.md: addressing, compiler facts, listing defects — read before any RE work
- re/docs/01-architecture.md: executables, loader protocol, overlay drivers, data files
- re/docs/02-build-plan.md: the phased build plan with task cards
- re/docs/vgame-map.md: flight sim map (main loop, 213 functions, globals, tables, key mapping)
- re/docs/start-map.md, end-map.md, setup-dswap-map.md: front end / debrief maps, shared block layout, roster, scoring
- re/docs/mgraphic-api.md: 84-entry graphics driver API + fonts; sound.md: OPL2 driver, 46 sound IDs, speech
- re/docs/format-pic.md, format-pan.md, format-ss.md, format-3d.md: data formats (all verified by decoders)
- re/tools/: unlzexe.py, disasm.py, strings.py, pic.py, pan.py, ss.py, world.py, sound.py, mgraphic_*.py
- re/decomp/: pseudo-C per function, written before porting (empty so far)
- re/docs/HANDOVER.md: prompt for the next chat
- Dropbox only (not committed): re/unpacked, re/disasm (listings), re/out (decoded assets), reference/ (game files)

## Conventions
- Everything from the disassembly; cite SEG:OFF addresses; mark guesses (?)
- Decompile to re/decomp/*.md before porting; JS carries the original address in a comment
- Tooling on the RE PC: py -3 (capstone, PIL, numpy), node 24, git via GitHub Desktop's bundled git.exe
  (C:\Users\pauli\AppData\Local\GitHubDesktop\app-*\resources\app\git\cmd\git.exe; not on PATH). No DOSBox.
- re/tools read the game files from Dropbox by default; override with env F117_REF (game dir) and F117_RE (re/ dir)

## Current state
RE phase 1 complete (2026-10-21). Repo laid out per studio standard with bundle.py, run_tests.py and one smoke
test (passes). No port code yet beyond the canvas placeholder. Asset export (0.2) not started.

## Next up
1. Task 0.2 asset export (Sonnet): tools/export_assets.py → assets/ + manifest.json + tests/golden/.
2. Task 0.3 RE gap-fill (Opus): rand(), VGAME asm modules, code islands.
3. Phase 1 platform layer.

## Tests
`py -3 tools/run_tests.py` — bundle + tests/*.test.js. Expected run time: under 1 min. Needs Node.

## Decisions
- 2026-10-21: RE text (docs, tools, strings, decomp) lives in the repo under re/; binaries and listings stay in Dropbox re/.
- 2026-10-21: AdLib (OPL2) is the reference sound; IBM speaker / Roland not planned.
- 2026-10-21: Accepted: slug f117-rea, own framebuffer, port an existing OPL2 emulator (dbopl-style) in JS.
