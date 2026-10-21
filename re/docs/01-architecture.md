# F-117A Nighthawk Stealth Fighter 2.0 (MicroProse, 1991, "Version 473.03") — architecture

Source: GOG release, DOS files in `reference/F-117A/F-117A/`. DOSBox runs `F117` (= F117.COM).
Everything below is read from the code (listings in `re/disasm/`), not from memory or the manual.

## Executables

| File | Packed | Role | Model | Code seg(s) | DGROUP |
| --- | --- | --- | --- | --- | --- |
| F117.COM | no | 1.7 KB assembly loader: chains the EXEs, loads driver overlays, owns the shared block | asm | 0000 | — |
| SETUP.EXE | LZEXE91 | Sound-driver menu, joystick calibration, loads MGRAPHIC.EXE, writes shared block. Exit 0x24 = OK | MSC small | 0000 | 024C |
| MPS_LOGO.EXE | LZEXE91 | "MPS Labs" animated logo (LABS.EXE, `.SS` sprite series, `*SOUND.LOG` jingle drivers). Exit 2 = user abort | MSC | 8 segs | 00DA |
| PLAYER.EXE | LZEXE91 | `.PAN` animation player (intro: title-1 title-2 title-3a credit c-pit bunker; later ` title-2`) | MSC small | 0000 | 02A3 |
| START.EXE | LZEXE91 | Front end: roster, theatre, mission, briefing, map, armament; writes TEMP.WLD; exit 0 quit / 0x0C / other | MSC small | 0000 (43 KB) | 0A95 |
| VGAME.EXE | LZEXE91 | Flight simulation: cockpit, HUD, MFDs, 3D world, AI, weapons. Exit 0 = quit | MSC + asm | 0000 (64 KB C) + 0FAE..14C2 asm, far data 14D1/1872/1D6F | 1E42 |
| END.EXE | LZEXE91 | Debrief, awards, promotions, death/capture/rescue, roster save. Exit 0x23 = back to START | MSC small | 0000 (24 KB) | 05FA |
| DSWAP.EXE | LZEXE91 | Floppy "insert disk" prompt (swap.pic). Exit 0 = abort | MSC small | 0000 | 0225 |
| MGRAPHIC.EXE | no | MCGA (320x200x256) graphics driver overlay, 84-entry vector API (see mgraphic-api.md) | asm overlay | — | — |
| MISC.EXE | no | 1988 "MISCOVR" overlay: tiny BIOS helpers (keyboard, etc.), 7-entry vector | asm overlay | — | — |
| ASOUND/ISOUND/RSOUND/NSOUND.117 | no | Sound driver overlays (AdLib / IBM speaker / Roland MT-32 / none), 5-entry vector, music+SFX data embedded (see sound.md) | asm overlay | — | — |
| ASOUND/ISOUND/RSOUND.LOG | no | MPS_LOGO jingle drivers (same overlay scheme) | asm overlay | — | — |

Compiler: Microsoft C 6.0 ("MS Run-Time Library - Copyright (c) 1990"), 80186+ code generation.
Dev tools used here: `re/tools/unlzexe.py` (LZEXE 0.91 unpacker), `re/tools/disasm.py` (capstone recursive descent).

## Loader protocol (F117.COM, `re/disasm/F117.asm`, func_0000_0100) [verified]

1. Shrinks itself, allocates a 0x140-paragraph (5 KB) **shared block**; stores its segment at BIOS
   0000:04F0 (the Inter-Application Communication Area 0040:00F0), word 0:04F2 = 1, 0:04F4 = 0.
   All child EXEs find the block through 0:04F0.
2. `exec SETUP.EXE` (args "<mem seg string>"). Exit code must be 0x24, else quit.
   SETUP leaves in the block: chosen sound driver file name (string at block+0x0D? copied by loader from
   es:[0x0D]), joystick calibration, and loads nothing itself — the loader loads drivers next.
3. `exec MPS_LOGO.EXE`. Exit 2 → set text mode, quit. Exit code saved as "intro seen" flag [0x6F9].
4. Loads overlays with int 21h/4B03 (func_0000_03CB): allocates max memory minus 0x400 paragraphs,
   loads, reads the overlay header (image+0x18 = seg, +0x1E/+0x20 = sizes, +0x24.. = vectors), shrinks.
   - graphics driver: name string written by SETUP at block+0x00 ("Mgraphic.exe"); seg stored in block+0x1C;
     calls vector #0 `init(0,0,0)` (returns 0xA000, allocates no back buffer); loader keeps vector #2 at [0x4F1]
     and calls it at exit — but #2 is actually a text routine (mgraphic-api.md), a harmless leftover.
   - `MISC.EXE` → block+0x1E (7-entry BIOS helper: key ready/get key/joystick buttons...).
   - sound driver: name written by SETUP at block+0x0D ("Asound.117" etc.); seg → block+0x1A; calls vector #0
     `init(2)`; the loader stores the return at block+0x20, which VGAME later reuses as the cockpit-art page segment.
5. If intro flag == 0: `exec PLAYER.EXE - title-1 title-2 title-3a credit c-pit bunker`.
6. Loop:
   - `exec DSWAP.EXE` (arg 0x6E9 string) — exit 0 → quit.
   - `exec START.EXE`; exit code saved [0x6F8]; 0 → quit.
   - `exec DSWAP.EXE`; exit 0 → quit.
   - if START exit == 0x0C (land-base takeoff): `exec PLAYER.EXE  title-2` (hangar/taxi animation).
     START exits 0x0D for a carrier takeoff (no animation) (?), 0 for Alt-Q quit.
   - `exec VGAME.EXE`; exit 0 → quit.
   - `exec DSWAP.EXE`; exit 0 → quit.
   - `exec END.EXE`; exit 0x23 → loop, else fall through.
7. Calls graphics shutdown vector, exits.

Each exec saves SP at [0x610] and restores SS:SP/DS/ES after return (DOS exec clobbers registers).
Inter-EXE game state lives in: the **shared block** (layout in start-map.md §1.3: driver names/segments,
options, +0x22 clearance, +0x26/+0x28 mission end state, +0x38.. bay loadout, +0x48 joystick calibration,
+0x72 input flags, +0x7A the serialised mission world followed by the 256×6-byte event log, +0x1272 the
80-byte current pilot record) and `ROSTER.FIL` on disk (2-byte header + 80-byte pilot records).
**`TEMP.WLD` is never written to disk** — START's "temp.wld" call copies the world into the block [verified].
0:04F2 = "first entry into START since launch", 0:04F4 = "sound driver initialised".

## Overlay driver format [verified from headers]

MZ file with 0x20-paragraph header; image at file+0x200:
```
+0x00  char name[24]      e.g. "MGRAPHIC.EXE03-20-91", "F117A  AdLib10-23-91", "MISCOVR.EXE 05-11-88"
+0x18  u16 code_seg       relocated by DOS at load (segment-relative 0 in file)
+0x1A  u16 ?              0
+0x1C  u16 ?              MGRAPHIC 0, sound 0x64
+0x1E  u16 data_size      bytes of the data segment (segment 0 of the image; header, vectors, fonts, state)
+0x20  u16 code_size      bytes of the code segment (vectors are offsets into THIS segment, at image+data_size)
+0x22  u16 n_vectors      MGRAPHIC 0x54=84, sound 5, MISC 7
+0x24  u16 vectors[n]     near offsets of exported entry points (called far: push args, call far seg:off)
```
Game EXEs copy `vectors[]` into DGROUP as 5-byte far-jump thunks and call them as C functions.

## Data files

| Pattern | Count | Format | Used by | Doc |
| --- | --- | --- | --- | --- |
| *.PIC | 48 | compressed 256-colour images / sprite sheets (header byte F5) | START, END, VGAME (256PIT/LEFT/RIGHT/REAR cockpit, ADV, ORDNANCE) | format-pic.md |
| *.PAL | 12 | 768-byte VGA palettes (6-bit); PALETTES.PAL = 9 palettes | all | format-pic.md |
| *.PAN | 6 | streamed cel animation (FF FE 5A 14 header) | PLAYER | format-pan.md |
| XX.3DX | 9 + PHOTO + STFLT | 3D object library (word offset table) | VGAME | format-3d.md |
| XX.3DG | 9 | 1810 bytes, "22" header: terrain grid (16x16 level-3 grid + 3x32 4x4 patterns) | VGAME, START map | format-3d.md |
| XX.3DT | 9 | "11" header: per-level, per-terrain-code prop lists (x, z, height, shape) | VGAME, START | format-3d.md |
| XX.WLD | 9 | region world: 16-byte objects, 36-byte mobile units, per-type tables, 16x16 sector grid, string pool | START (map, mission gen) → block → VGAME → END | format-3d.md |
| LABSLOGO.SS | 1 | "MADSS1" sprite series | MPS_LOGO | format-ss.md |
| SPEECH.117 | 1 | raw 8-bit PCM speech | VGAME | sound.md |
| ROSTER.FIL | 1 | 4-byte header + pilot records | START, END | start-map.md |
| CTR_GEOM.EPS | 1 | Illustrator EPS, not used by the game (dev leftover) | — | — |

Regions (XX): LB Libya, PG Persian Gulf, NC North Cape, CE Central Europe, VN Vietnam, ME Middle East,
KU Kuwait/Desert Storm, CU Cuba, KO Korea. Map screens: LIBYA/PERSIAN/N_CAPE/C_EUROPE/VIETNAM/MID_EAST/KUWAIT/CUBA/KOREA.PIC.

## Where to look next
- `vgame-map.md` — the simulation (the bulk of the port).
- `start-map.md`, `end-map.md`, `setup-dswap-map.md` — front end and debrief.
- `mgraphic-api.md` — every drawing primitive the game uses.
- `sound.md` — music/SFX/speech.
- `02-build-plan.md` — the port plan.
