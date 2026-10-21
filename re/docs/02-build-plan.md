# F-117A HTML5 (iPad) port — build plan

Goal: a faithful re-creation of F-117A Nighthawk Stealth Fighter 2.0 as a single bundled HTML file played on an
iPad. Every behaviour, number, table, and pixel routine comes from the disassembly (`re/docs/*`), never from memory
or the manual. The one permitted departure: touch controls mapped onto the cockpit lamps, MFD bezels and nested menus.

## 0. Ground rules for every build task

1. Start by reading `NOTES.md` (project root) and the task card below. Read only the docs/functions the card names.
2. **Decompile first, then port.** For each function on the card, write `re/decomp/<exe>/<func>.md`: pseudo-C with
   the original address on every block, every constant in hex+dec, DGROUP variables named (keep a growing
   `re/decomp/globals-<exe>.md`). Only then write the JS. A JS function carries a comment `// VGAME 0000:1EB0`.
3. JS mirrors the original data layout where it is cheap to do so (same table order, same units, same integer
   arithmetic — use `|0`, `>>`, `Math.imul`; no floats where the original used 16-bit fixed point).
4. Tests: `tests/*.test.js` (Node, exit non-zero on failure). Golden-file tests compare JS decoders against the
   Python outputs in `re/out/`. Logic tests pin numeric results (scores, thresholds, generator output for a seed).
5. One task = one chat. Finish by: update `NOTES.md` (Current state, Next up), write the next task's handover
   prompt into `re/docs/HANDOVER.md`, commit. Never leave a task half-built without saying so in NOTES.
6. Files under ~600 lines; one concern per file; `index.src.html` + `tools/bundle.py` as in the studio standard.
7. Model: **Opus** for any task that reads assembly (all decompile/port tasks). **Sonnet** for tasks whose spec is
   already complete in the docs and needs no listing reads (asset pipeline, canvas/scaler, touch overlay
   scaffolding, bundling, tests for already-ported code). The card says which.

## 1. Repository and asset pipeline (Phase 0)

| # | Task | Model | Inputs | Output / done when |
|---|---|---|---|---|
| 0.1 | Agree slug `f117-rea`, Dropbox folder `F117-REA` (exists). Create private GitHub repo, standard layout, `.gitignore dist/`, `tools/bundle.py`, `tools/run_tests.py` (HEARTBEAT template), add slug to watcher2.py, clone on test machines. **git is not installed on the RE machine** — install or commit from the clone. | Sonnet | hobby-game-studio skill | first commit; NOTES.md |
| 0.2 | Asset export: script `tools/export_assets.py` that runs the `re/tools` decoders and writes `assets/`: PIC→PNG (52) + `palettes.json` (12 PALs + 9 from PALETTES.PAL), fonts.json (7 MGRAPHIC fonts), 3DX/3DG/3DT/WLD → JSON per region, PAN → kept as raw `.PAN` (decoded in JS at runtime, ~300 KB total) or pre-decoded frame PNG strips (decide by size), SS → frames, sound tables JSON (`re/out/sound/asound_*.txt` → JSON), speech slices → WAV/PCM. Keep each asset < 2 MB. | Sonnet | re/tools/*, re/docs/format-*.md | `assets/` populated, `assets/manifest.json`, golden copies in `tests/golden/` |
| 0.3 | RE gap-fill needed by later phases: (a) MS C 6 `rand()`/`srand()` as used by START/VGAME (find the LCG constants in the runtime: `seed*214013+2531011`? verify in START listing ~0000:8xxx) and where the seed comes from (clock?); (b) fresh capstone disassembly of the VGAME asm modules (0FB2 line/poly, 1058 HUD tapes/stick, 11D8, 1132 INT 9 hook, 114A, 120A renderer, 130D, 1377, 1452) into `re/disasm/vgame-asm/*.asm` with the register conventions written in `re/docs/vgame-asm.md`; (c) code islands 0CDD tail, 2031, 6B0B..6BDD, E447/E4B6. | Opus | vgame-map.md §4, §8 | docs written; `re/disasm/vgame-asm/` |

## 2. Platform layer (Phase 1) — `src/platform/*`

| # | Task | Model | Inputs | Output |
|---|---|---|---|---|
| 1.1 | **Framebuffer + palette + scaler**: 320×200 `Uint8Array` pages (page 0 screen, 1 back, 2 cockpit art), 256-entry 6-bit DAC → RGBA LUT, present to a canvas via ImageData, integer scale, letterbox, iPad fullscreen/orientation, 70 Hz frame tick model and 60 Hz sound tick (6-of-7 rule), pause when hidden. | Sonnet | mgraphic-api.md (pages, present), sound.md §timing | `src/platform/fb.js`, `timer.js`, demo page draws a PIC |
| 1.2 | **MGRAPHIC API port** (`src/platform/gfx.js`): all entries with ≥1 call site (mgraphic-api.md lists unused ones): viewport/text struct, 7 fonts with per-glyph widths and colour-change chars ≥0x80, clipping rules, sprite blits (row-compressed, colour 0 transparent, scaled, mirrored), cut-from-page, Bresenham lines, span fill (solid/OR/AND/shade 0x98..0x9F), page copy, present N rows, DAC load, flicker/shake effect, blank/unblank, random-dissolve copy. Pixel-exact. | Opus | mgraphic-api.md, re/out/mgraphic/MGRAPHIC_code.asm | gfx.js + tests (span fill, text metrics golden against font.png) |
| 1.3 | **Decoders in JS**: PIC (LZW 9→11 bit + RLE 0x90), PAN (LZEXE-token LZ + RunSkipDump cels + 'Z' header palette), SS, 3DX/3DG/3DT/WLD parsers (or load the JSON from 0.2 — decide: JSON for 3D/WLD, native decode for PIC/PAN). Golden tests vs `re/out`. | Sonnet | format-pic/pan/ss/3d.md, re/tools/*.py | `src/platform/pic.js`, `pan.js`, `ss.js`, `world.js` |
| 1.4 | **Sound**: OPL2 (YM3812) emulator in JS feeding WebAudio (decision: port a known-correct emulator, e.g. the DOSBox `dbopl` algorithm, as `src/platform/opl2.js` — it is hardware emulation, not game logic, so a faithful third-party port is allowed); sequencer port from sound.md (7 voices × 0x1E-byte records, event commands F3–FF, instrument table, F-number table, noise voices + 4× tick mode, engine voice 6 with throttle); speech slices as PCM at 7954 Hz; `sfx(id, priority)` API with the 46 IDs. iOS audio unlock on first touch. | Opus | sound.md, re/out/sound/* | `src/platform/sound.js`, `opl2.js`, `music.js`; test: sequence dump matches asound_sequences.txt |
| 1.5 | **Input core**: one-key-word-per-frame queue (`ds:DEBC` semantics), stick bytes X/Y (0x80 centre) with keypad virtual-stick rules (deflection 0x5A/0x7F, 5-tick double-press), buttons 0/1, misc-driver key-ready/get-key for pause/quit prompts; hardware keyboard support for desktop testing. | Sonnet | vgame-map.md §7 | `src/platform/input.js` |

## 3. Front end (Phase 2) — `src/frontend/*`

| # | Task | Model | Inputs | Output |
|---|---|---|---|---|
| 2.1 | **Program flow + shared block**: `src/flow.js` state machine reproducing F117.COM (SETUP→LOGO→INTRO→loop{START→[title-2]→VGAME→END}), `src/block.js` = the shared block as a typed structure (every offset from start-map.md §1.3 + vgame-map.md), `ROSTER.FIL` persisted in localStorage (2-byte header + 80-byte records, exact bytes). | Opus | 01-architecture.md, start-map.md §1.3, setup-dswap-map.md | flow + block + roster tests |
| 2.2 | **Intro**: MPS logo (.SS playback, 18.2 Hz delays, accumulate), PAN player (fps from 'Z' header, 60-tick clock, palette fade ~300 ticks (?) — resolve from PLAYER 0000:0738 and the DAC fade code), skip on tap/key with the same exit codes. | Sonnet | format-pan.md, format-ss.md | `src/frontend/intro.js` |
| 2.3 | **SETUP screen** (port equivalent: sound on/off = AdLib emulation, joystick = touch stick calibration into block+0x48; clearance +0x22 = 1). | Sonnet | setup-dswap-map.md | `src/frontend/setup.js` |
| 2.4 | **START — roster & pilot screens** (`func_0000_64E5`, `6861`, `6DB8`, `615C`, `623E`, `7218/7272` roster I/O, rank strings, delete, retired/killed rules). | Opus | start-map.md | `src/frontend/roster.js` |
| 2.5 | **START — theatre/options/mission type screens** (`5BF0`, `5E6F`, `5A8A`, theatre texts, skill/war-state/landing/aircraft options, clearance check). | Opus | start-map.md | `src/frontend/options.js` |
| 2.6 | **START — mission generator** (`func_0000_4239` 3077 bytes + helpers): 82 templates at ds:11DA, filters, retry loop with skill-dependent distance limits, fighter quality/alert, suggested armament, waypoints, times, night flag; uses the exact `rand()` from 0.3. Test: for a fixed seed the JS produces the same template/targets as a hand-traced run. | Opus | start-map.md, format-3d.md (WLD) | `src/frontend/missiongen.js` |
| 2.7 | **START — orders/briefing/map screens** (`20D6`, `24F7`, `2651`, `149C`, `1308`, `1B37` map ranges/overlays, `1C2F` info box, `3F33`, map PICs, ONC grid codes `58DF`). | Opus | start-map.md | `src/frontend/briefing.js`, `map.js` |
| 2.8 | **START — armament & hangar** (`0963`, `07EE` weight/bay rules, `0D65` WEAPONS3 cells, `28CE/2901` ORDRSPRT animation, HANGSPRT records, climb-in, exit codes 0x0C/0x0D) and the world hand-over into the block (`5625`). | Opus | start-map.md, format-pic.md §sprites | `src/frontend/arming.js`, `hangar.js` |

## 4. Simulation (Phase 3) — `src/sim/*` (VGAME)

Order matters: each task builds on the previous and ends with something visible.

| # | Task | Model | Inputs (vgame-map.md addresses) | Output |
|---|---|---|---|---|
| 3.1 | **Sim init + world load**: `0010`, `00F0`, `01C1`, `0235`, `0300`, region selection, 3DX/3DG/3DT load (`09A0`, `0B05`, `0C38`), STFLT/PHOTO shape banks (`E2B6`), block read-back (`4D5D`), object arrays (§6), globals file. | Opus | §1, §3 init group, format-3d.md | `src/sim/init.js`, `world.js`, `globals.js` |
| 3.2 | **Math + 3D pipeline**: far-data tables (sin/cos/atan/perspective in 14D1/1D6F — export as JSON), view transform `D826`, sky/ground `1450`, terrain `0871`/`04E6`/`04C7`, object renderer `120A_00CF` (LOD by depth, plane-eqn culling, BSP order, polygon/line/dot/conditional commands), sorted draw `D87C`, explosion sprites (1872). Visible: static scene from a WLD. | Opus | §3 render group, §4, format-3d.md, vgame-asm.md | `src/sim/render3d.js`, `terrain.js` |
| 3.3 | **Views + cockpit + HUD symbology**: `2F9D` camera/view codes (0x41-0x44, 0x84-0x8C), 256PIT/LEFT/RIGHT/REAR + viewport switch, asm `1058:000A` tapes/pitch ladder, `D6DD` side strip, `17B4` attitude ball, big HUD `c`, declutter `v`. | Opus | §2, §3 cockpit group | `src/sim/views.js`, `hud.js` |
| 3.4 | **Flight model** `1EB0` (3543 bytes): keys, stick scaling, autopilot/alt hold, engine/fuel/throttle, G, stall, speed, attitude matrix, integration, touchdown, catapult, brakes/flaps/gear effects, history ring. Test: numeric trace for a scripted input sequence. | Opus | §3 flight group, §5 globals | `src/sim/flight.js` |
| 3.5 | **World update** `3ADA`: clock (ds:9912 unit — resolve open question 1), threats `5046`/`528D` (radar/SAM detection, signature incl. jammers/bay doors), enemy aircraft AI `5852`/`63F2`/`66F8`/`72D8`, missiles & hits `683E`, landing/crash checks, mission events → event log (6-byte entries). | Opus | §3 AI/threat groups | `src/sim/threats.js`, `ai.js`, `missiles.js` |
| 3.6 | **Weapons & countermeasures**: `7663` release rules (bay doors, min altitude, fuel transfer), `4777` gun, `462E` flares/chaff/decoys, stations `3680`, weapon table, target designation `b`/`n`, F2 target modes, target camera `[ ]`, photo frames. | Opus | §3 weapons group, §6 tables | `src/sim/weapons.js` |
| 3.7 | **MFDs, messages, nav**: left MFD radar/map `8A90`, right MFD pages (stores F5, nav F7/F8 + waypoint editing, objectives F10 `9515`, `BCEF` BRG page, `8F71` time/ETA), ILS `971A`, HUD message line, speech triggers, time acceleration, pause/quit/eject/end-of-mission (`end_mission` codes 0/1/2/5/6/7) and block write-back. | Opus | §3 MFD/text groups, sound.md IDs | `src/sim/mfd.js`, `messages.js`, `mission.js` |
| 3.8 | **Command dispatcher** `C8CA` + `450A` tail (fire button, cooldowns, animations such as gear), options keys (detail, sound level, frame rate display, lamp colours, training mode keys). | Opus | §7 | `src/sim/commands.js` |

## 5. Debrief (Phase 4) — `src/end/*`

| # | Task | Model | Inputs | Output |
|---|---|---|---|---|
| 4.1 | Event log → debrief text (`0A98`, `05CA`), mission end screens (landed1-4, cemetery, rescue, tass, requestr, flag), bar-talk quote selection, `3021` scoring tables (war-state points, eighths multipliers), `2BEC` rating text. | Opus | end-map.md | `src/end/debrief.js`, `score.js` + threshold tests |
| 4.2 | Awards/medals/promotion (`2703`, `2A01`, thresholds table), awards music IDs 36-39, roster update/save, exit back to START. | Opus | end-map.md | `src/end/awards.js` |

## 6. Touch interface (Phase 5) — `src/touch/*` (the only non-faithful layer)

Principle: touch never talks to game logic; it only injects the same key words, stick bytes and button states the
DOS game read (vgame-map.md §7 "Touch-port notes"). Hit regions are defined in 320×200 cockpit coordinates and
drawn as a faint outline only while a "show controls" option is on.

| # | Task | Model | Mapping |
|---|---|---|---|
| 5.1 | **Cockpit lamp toggles** (regions from 256PIT.PIC lamp rectangles, confirm lamp numbers from `79BE` lamp table): GEAR→`6`, FLAPS→`9`, BRAKES→`0`, BAY→`8`, IR JAM→`3`, RDR JAM→`4`, FLARE→`1`, CHAFF→`2`, DECOY→`5`, ALT HOLD→`7`, ILS→`F9`. Throttle: vertical drag strip at the THRUST lamp (`-`/`=`/`_`/`+` steps or direct set — direct set must go through the same throttle variable rules as `1F84..1FF4`). | Sonnet |
| 5.2 | **MFD bezel buttons**: left bezel: map/radar `F3`, zoom `z`/`x`, target mode `F2`, designate `b`/`n`; right bezel: stores `F5`, nav `F7`/`F8`, objectives `F10`, BRG/`F6`, waypoint prev/next `PgUp`/`PgDn`, move waypoint arrows (nav edit mode), clock `Home`/`End`. | Sonnet |
| 5.3 | **Stick + fire**: right-thumb virtual stick → stick bytes (same deflection values as keypad or proportional like joystick mode — proportional, calibrated like the 0x201 port), left-thumb buttons: GUN (button 0), FIRE/SHUTTER (button 1), NEXT WEAPON (`Space`). Optional device-tilt stick. | Sonnet |
| 5.4 | **Nested menus** (a small tab on the HUD frame): Views {F1, left/right/rear `M<>?`, no-panel, chase/delayed/side/weapon/player→target/target→player `Shift-F1..F6`, target-camera dirs `m,./`, zoom `[ ]`}; System {pause Alt-P, time accel Z/X, detail Alt-D, sound Alt-V, big HUD `c`, declutter `v`, frame rate Alt-F, quit Alt-Q (+ Y/N prompt), eject Shift-F10, training Alt-T + its Alt-R/I/J/K/L/N}; Nav {reset waypoints Shift-F8}. | Sonnet |
| 5.5 | **Front-end touch**: "Selector" = tap, "Escape" = back button, on-screen keyboard for pilot names, map pan/zoom gestures mapped to the original keys only. | Sonnet |

## 7. Verification (Phase 6)

- Side-by-side with DOSBox on Alastair's PC (no DOSBox on the RE machine): intro, each START screen, cockpit at
  mission start, a full training mission, debrief. Visual checks stay on the iPad per the studio rules.
- Performance target: 70 fps frame tick on iPad; if the software renderer is too slow, keep the algorithm and
  optimise data layout only (typed arrays, no allocations per frame).
- Save data: roster in localStorage, export/import as a `.FIL`-compatible blob.

## 8. Open RE questions carried into the build (resolve inside the task that needs them)

1. Clock unit of ds:9912 and exact PIT/retrace tick length (3.5).
2. Shared-block fields +0x20, +0x32/33, blk2+0x3A..0x42 — reconcile START writers vs VGAME readers (2.1).
3. Uncalled SA-14 MANPADS function 5737 — dead code? (3.5)
4. ds:9B34 bit 0x08 brake/hook/speed-brake semantics (3.4).
5. Keypad virtual-stick pitch sign (1.5).
6. PAN palette fade length (2.2); `-` argument purpose (harmless).
7. PIC cell tables for BREFICON, REQUESTR, ROSTSPRT, FOLDER2; ORDRSPRT sequence bytes (2.7/2.8).
8. END theatre multiplier for theatres 5-8 (4.1).
9. IBM-speaker / Roland drivers: not ported (AdLib is the reference sound). Decision for Alastair.

## 9. Decisions (accepted by Alastair 2026-10-21)

- Slug `f117-rea`, Dropbox folder `F117-REA`.
- No shared WebGL render-engine; own 320×200 palettised framebuffer.
- OPL2: port an existing emulator (dbopl-style) to JS.
- Git: Alastair handles it (not installed on the RE PC); Claude commits once a clone/git exists.
