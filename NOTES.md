# F117-REA
Faithful HTML5/iPad re-creation of F-117A Nighthawk Stealth Fighter 2.0 (MicroProse DOS, 1991). Slug: f117-rea. Dropbox: F117-REA.
GitHub repo and local clone are spelled `f117-REA` (C:\Users\pauli\Games\f117-REA); request.txt for the test watcher says `f117-rea` (lowercase).

## Engine
None: own 320x200 palettised framebuffer (decided 2026-10-21; render-engine not used).

## File map
- index.src.html, src/main.js: shell + phase-0 placeholder; tools/bundle.py â†’ dist/f117-rea.html â†’ Dropbox builds/
- src/platform/: png.js, fb.js, timer.js (task 1.1), gfx.js + gfx-text.js + gfx-sprite.js (task 1.2: createGfx(fb, fonts) = MGRAPHIC API); window.F117.*, also module.exports for Node
- src/platform/input.js (task 1.5): key buffer + keypad virtual stick + buttons
- src/platform/opl2.js, music.js, sound.js (task 1.4): OPL2 emulator, ASOUND driver port, WebAudio front end (F117.sound)
- tools/run_tests.py: git pull, bundle, tests/*.test.js (Node). tools/export_assets.py: game files â†’ assets/ + tests/golden/
- assets/: pic/*.png (52, indexed), palettes.json (21), fonts.json (7), world/*.json (9 regions + PHOTO, STFLT),
  pan/*.PAN + pan.json (raw, decode at runtime), ss/LABSLOGO.SS + labslogo.json, sound/ASOUND.117 + asound.json,
  sound/speech/*.wav + speech.json, manifest.json (sha1 of every file; tests/assets.test.js checks it)
- tests/golden/: Python decoder outputs (pan cels + sample frames, ss final screen, world dumps, sound tables, fonts)
- re/docs/00-conventions.md: addressing, compiler facts, listing defects â€” read before any RE work
- re/docs/01-architecture.md: executables, loader protocol, overlay drivers, data files
- re/docs/02-build-plan.md: the phased build plan with task cards
- re/docs/vgame-map.md: flight sim map (main loop, 213 functions, globals, tables, key mapping)
- re/docs/vgame-asm.md: calling conventions of the VGAME asm modules + decoded code islands; re/docs/rand.md: rand()/srand()
- re/disasm/vgame-asm/*.asm + index.txt: per-module capstone listings of segments 0FAE..14C2 (re/tools/vgame_asm.py; committed)
- re/docs/start-map.md, end-map.md, setup-dswap-map.md: front end / debrief maps, shared block layout, roster, scoring
- re/docs/mgraphic-api.md: 84-entry graphics driver API + fonts; sound.md: OPL2 driver, 46 sound IDs, speech
- re/docs/format-pic.md, format-pan.md, format-ss.md, format-3d.md: data formats (all verified by decoders)
- re/tools/: unlzexe.py, disasm.py, vgame_asm.py, strings.py, pic.py, pan.py, ss.py, world.py, sound.py, mgraphic_*.py
- re/decomp/mgraphic/gfx-notes.md: quirks of the MGRAPHIC code found while porting (text clip, sprite DDA, spans)
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
Task 1.2 done (2026-10-21): src/platform/gfx*.js = every MGRAPHIC entry with a call site (pages/draw seg/origin, text #1-10 with clip rules, char_width, sprite grab/draw with scale+mirror+clip, line, spans incl. shade, blits, recolor, present, flicker/shake, tick tape, dissolve, blank); tests/gfx.test.js (glyphs of all 7 fonts vs golden, clip = masked picture, spans, lines, sprites). 5 tests pass locally; no pixel golden from the original (no DOSBox), derived from the listing. API: gfx.textDraw/textDrawClip/..(vp,str), spriteDraw(vp,x,y,w,h,data,off), fillSpans(ytop,ybot,left[],right[],mode), blit(...), blitTranspClip(bs).
Task 1.3 done (2026-10-21): src/platform/pan.js (lzUnpack = PLAYER 0BE2, runSkipDump = 1006, createPanPlayer(bytes).step() applies one cel to a 64 KB screen, exposes rate/ticksPerFrame/palette(6-bit)/table), ss.js (parseSs, drawSprite(series,i,screen64000), dac[] with base+i palette), world.js (loadWorld(code, readJson), JSON loader only); tests/decoders.test.js: every PAN cel screen = golden sha1 (all 6 files, 1666 cels), cel sizes = table, SS 82 cumulative screens + final, world JSON keys. 6 test files pass (run individually; run_tests.py needs git on PATH).
Task 1.4 done (2026-10-21): src/platform/music.js = ASOUND.117 port (decomp re/decomp/asound/sequencer.md): driver DS kept as a
byte copy of the image, play(id,a2) all 46 ids, tick() (60 Hz, returns +1/-1/0 for noise mode), noise() (280 Hz), engine voice 6,
speech 41-45 the AdLib way (OPL carrier TL at 7954.5 Hz, returns duration: the original blocks the game), dumpSequence = sound.py text.
opl2.js = OPL2 emulator (Nuked-OPL3 algorithm, OPL2 subset) + timed write queue/resampler (writes >= 2 OPL samples apart = ISA delay,
DC blocker = AC-coupled output). sound.js = AudioWorklet (ScriptProcessor fallback), game-time stamped writes + 60 ms latency,
unlock() on first touch, sfx(id,prio) = VGAME D3F9/D41F with sound.state {level, c09a, throttlePct}, hooks(ticker) for timer.js.
tests/sound.test.js: all 55 golden streams dump identically and the live interpreter visits them in the same order; engine/noise/
speech pinned; 440 Hz tone check; song renders. main.js demo: each tap plays the next id. Checked in the browser pane (worklet runs).
Task 1.5 done (2026-10-21): src/platform/input.js = BIOS key buffer (15 words, typematic head-run collapse as ISR 1132:0149) +
INT 9 virtual stick (table DS:2CDE verified from VGAME.EXE: 13 entries; 0x5A / 0x7F within <5 BIOS ticks of the last accepted press
of the same mask; one key held at a time; release of the held mask recentres; Shift ignores keypad keys but not grey cursor keys,
also on key-up (original quirk)). API: createInput({ticks, joystick}) -> keyDown/keyUp(ev)/attach(win), pushKey (touch injection),
frameKey() (1EB0:1F08 drain: first key, rest discarded), keyReady/getKey (misc driver, assumed same buffer (?)), stickX/stickY
(virtual or joystick bytes), setStick, button(n)/setPseudoButton/setJoyButton. wordOf(ev) maps DOM keys to INT 16h words (NumLock
forced off: keypad = 4800-style unless Shift). Bytes only: Up arrow = Y low (0x26); pitch sign is decided by the 1EB0:2189 port.
tests/input.test.js (21). Not yet used by main.js; no touch overlay yet.
HEARTBEAT: razer run of f117-rea PASSED 2026-10-21 (4 passed, 0 failed; watcher allowlist fix applied, razer clone confirmed). 14900ks run also PASSED (4 passed, 0 failed); re-run confirmed 2026-10-21T20:49Z.

## Next up
1. Phase 2 (2.1 flow, Opus); 1.5 input is done. Sound confirmed on the iPad 2026-10-21 in both HTML viewers (incl. Sitecase:
   needs touchend/click unlock; may run the ScriptProcessor fallback).
2. Decided: reproduce the ds:263F vsync-measure path in resync 1D01 exactly (measures the real retrace period; port currently uses a fixed 70 Hz). Needs a task card.
3. Done 2026-10-21: assets inline. bundle.py puts every assets/ file as base64 in window.F117_ASSETS (build 4.5 MB);
   src/platform/assets.js (F117.assets.bytes/json) reads it, falls back to fetch('assets/..') unbundled. run_tests.py does NOT
   publish: after a change, run `py -3 tools/bundle.py` on the RE PC to refresh builds/latest.html.
4. HEARTBEAT 14900ks re-run 2026-10-21T20:49Z: PASS (4 passed, 0 failed). Note: 4 tests, while the repo has 6 test files - check the test machines' clones are pulled.
5. Open: speech on AdLib freezes the game ~0.5-1.2 s (IRQ0 masked). sound.speechSec gives the time; the flow task decides whether to freeze the ticker.

## Tests
`py -3 tools/run_tests.py` â€” bundle + tests/*.test.js. Expected run time: under 1 min. Needs Node.

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
- 2026-10-21: OPL2 emulator follows Nuked-OPL3 (more exact than dbopl); speech uses the AdLib OPL-TL path, not separate PCM.



