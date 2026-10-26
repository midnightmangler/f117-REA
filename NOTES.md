# F117-REA
Faithful HTML5/iPad re-creation of F-117A Nighthawk Stealth Fighter 2.0 (MicroProse DOS, 1991). Slug: f117-rea. Dropbox: F117-REA.
GitHub repo and local clone are spelled `f117-REA` (C:\Users\pauli\Games\f117-REA); request.txt for the test watcher says `f117-rea` (lowercase).

## Engine
None: own 320x200 palettised framebuffer (decided 2026-10-21; render-engine not used).

## File map
- index.src.html, src/main.js: shell + phase-0 placeholder; tools/bundle.py â†’ dist/f117-rea.html â†’ Dropbox builds/
- src/platform/: png.js, fb.js, timer.js (task 1.1), gfx.js + gfx-text.js + gfx-sprite.js (task 1.2: createGfx(fb, fonts) = MGRAPHIC API); window.F117.*, also module.exports for Node
- src/platform/input.js (task 1.5): key buffer + keypad virtual stick + buttons
- src/frontend/setup.js (task 2.3): SETUP port (sound question, block values); src/main.js now runs runFlow (setup, logo, player real; start/vgame/end quit stubs)
- src/frontend/intro.js (task 2.2): createLogoRun / createPanRun steppers + createIntroPrograms(host) = flow programs `logo`, `player`
  (decomp re/decomp/player/player-timing.md)
- src/flow.js (F117.COM loop over async "programs"), src/block.js (shared block, named fields), src/roster.js (ROSTER.FIL in
  localStorage + START 6D07 sync + pilot record fields) (task 2.1; decomp re/decomp/flow/flow.md); assets/roster/ROSTER.FIL = default seed
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
Task 2.1 done (2026-10-21): runFlow(programs, block, {maxLoops}) = F117.COM 0000:0100..03C9 verified in the listing (SETUP must exit 0x24;
LOGO exit 2 quits, exit 0 plays the intro; START exit 0 quits, 0x0C plays PLAYER " title-2", 0x0D goes straight to VGAME; VGAME exit 0 quits;
END exit 0x23 loops WITHOUT replaying the intro, anything else quits; logo arg = upper-cased first letter of block sound driver name;
DSWAP optional, default "disk present"). bios = {firstEntry (0:04F2)=1, soundInit (0:04F4)=0}; START's roster screen clears firstEntry.
Block: 5120 bytes, FIELDS table = start-map 1.3, pilot view at +0x1272, world view +0x7A. Roster: 802-byte file as base64 in localStorage
'f117-rea.ROSTER.FIL', missing -> seed = shipped file; sync() = START 6D07 incl. quirks (record 0 plane &= 1 every loop; plane!=0 bumps type
0/2 -> 1/3; clearance 0 -> theatre 0 + training bit); save header low byte = PR.slot. The START port (2.4+) calls roster.sync(block, bios).
tests/flow.test.js (16). WARNING: tools/export_assets.py deletes tests/golden/pic/pic_sha1.json (not regenerated): `git checkout` it after a run.
Task 2.2 done (2026-10-21): logo = SS sprites at BIOS ticks 18.2065 Hz (t += delay, draw when reached, accumulate; 146 ticks; key/tap draws the
rest at once; result none 0 / Esc 1 / Alt-Q 2 / other 3, so a key SKIPS the PAN intro and Alt-Q quits). Player = 60 Hz tick callback 0738 verified
on the unpacked image: cel 0 on tick 1, then the FADE (300 ticks = 5 s, whole palette per tick, step k scale 219k, step 1 black) FREEZES the
animation, then 3 ticks per cel (6 for TITLE-2); last cel drawn = done (no hold); VRAM shared across files; later files set the DAC directly;
every launch (also " title-2") fades. The fade step width is hardware-measured in the original (ds:13D2); JS fixes 0x100 (?). Missing "-.PAN" skipped.
Key quits with the key code, tap 0x1B. OPEN: nobody in PLAYER starts the intro music (snd_play(3) only in poll under a guard, (2) in finish waits for
it) - find the starter (timer module 026B?) before wiring music; Opus job if it needs the listing. Host contract for intro.js: {fb, present, assets,
now, raf, pollKey, tapped}; not yet wired into main.js. tests/intro.test.js (9).
Task 2.3 done (2026-10-26): setup.js = setup-dswap-map steps 6-12 (clearance 1, sndArg/unk2A/unk70 0, +0x32 word FFFF then 3 for 'M' graphics name, gfxName Mgraphic.exe, endState 1, inputFlags 0; sndName Asound.117 or Nsound.117 from an on-screen question whose click is the first gesture: audio unlock + fullscreen). Joystick/mouse questions dropped (touch stick later; calibration format +0x48 not needed yet). main.js: host {fb, present, assets, now, raf, pollKey, tapped, choose}, sound init after SETUP when AdLib, START/VGAME/END are quit stubs that show 'Front end not ported yet'. Verified in the browser pane (bundled build over http): SETUP -> MPS logo -> TITLE-1 intro. Found + fixed: pan.js/ss.js were missing from index.src.html. tests/setup.test.js (5). Not tested on the iPad yet.
HEARTBEAT: razer run of f117-rea PASSED 2026-10-21 (4 passed, 0 failed; watcher allowlist fix applied, razer clone confirmed). 14900ks run also PASSED (4 passed, 0 failed); re-run confirmed 2026-10-21T20:49Z.

## Next up
1. Phase 2: START screens 2.4+ (Opus). 1.5, 2.1, 2.2 and 2.3 are done. Sound confirmed on the iPad 2026-10-21 in both HTML viewers (incl. Sitecase:
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



