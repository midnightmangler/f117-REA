# F117-REA
Faithful HTML5/iPad re-creation of F-117A Nighthawk Stealth Fighter 2.0 (MicroProse DOS, 1991). Slug: f117-rea. Dropbox: F117-REA.
GitHub repo and local clone are spelled `f117-REA` (C:\Users\pauli\Games\f117-REA); request.txt for the test watcher says `f117-rea` (lowercase).

## Engine
None: own 320x200 palettised framebuffer (decided 2026-10-21; render-engine not used).

## File map
- index.src.html, src/main.js: shell + phase-0 placeholder; tools/bundle.py → dist/f117-rea.html → Dropbox builds/
- src/platform/: png.js, fb.js, timer.js (task 1.1; window.F117.{png,fb,timer}, also module.exports for Node tests)
- tools/run_tests.py: git pull, bundle, tests/*.test.js (Node). tools/export_assets.py: game files → assets/ + tests/golden/
- assets/: pic/*.png (52, indexed), palettes.json (21), fonts.json (7), world/*.json (9 regions + PHOTO, STFLT),
  pan/*.PAN + pan.json (raw, decode at runtime), ss/LABSLOGO.SS + labslogo.json, sound/ASOUND.117 + asound.json,
  sound/speech/*.wav + speech.json, manifest.json (sha1 of every file; tests/assets.test.js checks it)
- tests/golden/: Python decoder outputs (pan cels + sample frames, ss final screen, world dumps, sound tables, fonts)
- re/docs/00-conventions.md: addressing, compiler facts, listing defects — read before any RE work
- re/docs/01-architecture.md: executables, loader protocol, overlay drivers, data files
- re/docs/02-build-plan.md: the phased build plan with task cards
- re/docs/vgame-map.md: flight sim map (main loop, 213 functions, globals, tables, key mapping)
- re/docs/vgame-asm.md: calling conventions of the VGAME asm modules + decoded code islands; re/docs/rand.md: rand()/srand()
- re/disasm/vgame-asm/*.asm + index.txt: per-module capstone listings of segments 0FAE..14C2 (re/tools/vgame_asm.py; committed)
- re/docs/start-map.md, end-map.md, setup-dswap-map.md: front end / debrief maps, shared block layout, roster, scoring
- re/docs/mgraphic-api.md: 84-entry graphics driver API + fonts; sound.md: OPL2 driver, 46 sound IDs, speech
- re/docs/format-pic.md, format-pan.md, format-ss.md, format-3d.md: data formats (all verified by decoders)
- re/tools/: unlzexe.py, disasm.py, vgame_asm.py, strings.py, pic.py, pan.py, ss.py, world.py, sound.py, mgraphic_*.py
- re/decomp/: pseudo-C per function, written before porting (empty so far)
- re/docs/HANDOVER.md: prompt for the next chat
- Dropbox only (not committed): re/unpacked, re/disasm (listings), re/out (decoded assets), reference/ (game files)

## Conventions
- Everything from the disassembly; cite SEG:OFF addresses; mark guesses (?)
- Decompile to re/decomp/*.md before porting; JS carries the original address in a comment
- Work in the clone; Dropbox re/docs is a frozen copy from 2026-10-21 (GitHub wins). Listings stay in Dropbox re/disasm.
- Tooling on the RE PC: py -3 (capstone, PIL, numpy), node 24, git via GitHub Desktop's bundled git.exe
  (C:\Users\pauli\AppData\Local\GitHubDesktop\app-*\resources\app\git\cmd\git.exe; not on PATH). No DOSBox.
- re/tools read the game files from Dropbox by default; override with env F117_REF (game dir) and F117_RE (re/ dir)

## Current state
Phase 0 complete (2026-10-21): 0.1 repo, 0.2 asset export (83 files, 3.3 MB; 3 tests pass), 0.3 RE gap-fill: rand.md
(MS C LCG verified in START/VGAME/END, seeded once from the BIOS tick), vgame-asm.md + re/disasm/vgame-asm (all 15 asm
segments, 97-100 % coverage, register conventions), four code islands decoded. No port code yet beyond the canvas placeholder.
Task 1.1 done (2026-10-21): src/platform/png.js (indexed-PNG reader), fb.js (5 pages, 6-bit DAC -> RGBA LUT, present #44,
integer scaler in device px, fullscreen/landscape), timer.js (70 Hz frame tick, 60 Hz sound tick 6-of-7, 280 Hz noise mode,
pause when hidden); src/main.js demo draws ADV.png (needs assets/ served next to the page); tests/platform.test.js (all 52 PIC
PNGs equal pic.py output via tests/golden/pic/pic_sha1.json). 4 tests pass locally; demo checked in the browser pane.
HEARTBEAT: razer watcher is alive but its running copy of watcher2.py predates the fix (request name is lowercased, so the
allowlist key must be `f117-rea`; fixed in Dropbox watcher2.py 2026-10-21, **razer must restart it**). Until then a request
`f117-rea` returns "unknown project". The razer clone `~/Games/f117-REA` is still unconfirmed, and 14900ks is offline.

## Next up
1. Restart watcher2.py on razer, drop request.txt `f117-rea`, confirm PASS (this also proves the razer clone).
2. 1.2 MGRAPHIC primitives (Opus, src/platform/gfx.js), 1.3 (drop native PIC decoder, see Decisions), 1.4 (Opus), 1.5, Phase 2.
3. Open: ds:263F vsync-measure path in resync 1D01 (measures the real retrace period; the port uses a fixed 70 Hz).
4. Open: how the single-file build gets assets/ onto the iPad (bundle.py copies only the HTML to Dropbox builds/).

## Tests
`py -3 tools/run_tests.py` — bundle + tests/*.test.js. Expected run time: under 1 min. Needs Node.

## Decisions
- 2026-10-21: RE text (docs, tools, strings, decomp) lives in the repo under re/; binaries and listings stay in Dropbox re/.
- 2026-10-21: PAN, SS and ASOUND.117 shipped raw and decoded at runtime (PAN frames would be 4.5 MB vs 361 KB raw).
- 2026-10-21: 3D data (WLD/3DX/3DG/3DT) shipped as parsed JSON per region, not decoded at runtime.
- 2026-10-21: AdLib (OPL2) is the reference sound; IBM speaker / Roland not planned.
- 2026-10-21: Accepted: slug f117-rea, own framebuffer, port an existing OPL2 emulator (dbopl-style) in JS.
- 2026-10-21: PICs load as the indexed PNGs in assets/pic (own chunk parser; inflate = DecompressionStream in browsers, zlib in Node
  tests). No raw .PIC / JS LZW port needed, so card 1.3's PIC decoder is dropped (PAN/SS decoders stay). Palettes come from palettes.json.
- 2026-10-21: timer.js verified against VGAME 0000:1E79..1EAE, ISR 1C9B, 1C6D/1C85: sound runs on ticks 1-6 of each 7, the 7th is skipped;
  noise mode = 1 noise call after the entry tick, then 3 before + 1 after each tick; none after the exit tick (offsets passed in ms).
- 2026-10-21: request.txt names are lowercased by watcher2.py: the slug is `f117-rea` (earlier note saying `f117-REA` was wrong).
- 2026-10-21: VGAME asm listings are committed (re/disasm/vgame-asm, 350 KB); regenerate with the command in vgame-asm.md.
