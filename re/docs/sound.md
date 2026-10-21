# Sound subsystem (sound drivers `*.117`, SPEECH.117, game call sites)

Sources: `re/unpacked/ASOUND.117 ISOUND.117 RSOUND.117 NSOUND.117`, VGAME/START/END listings.
Tool: `re/tools/sound.py` -> `re/out/sound/` (ID table, instrument bank, decoded event streams, speech WAVs).

**Note on the existing listings:** `re/disasm/ASOUND.asm` etc. disassemble the vectors relative to
image 0, which is wrong. The vectors are offsets in the driver's **code segment** (header +0x18). In
this doc, driver addresses are `cs:XXXX` (code-segment offsets) or `ds:XXXX` (offsets from the image
start, where DS = load segment). For ASOUND, cs = image + 0x1B60. The disassembly used here was made by
seeding capstone at `cs:vector` (scratch script; `sound.py` re-derives what it needs from the bytes).

## 1. Driver file layout (all four `.117`)

| image off | ASOUND | ISOUND | RSOUND | NSOUND | meaning |
|---|---|---|---|---|---|
| +00 | "F117A  AdLib10-23-91" | "F117A IBM   10-23-91" | "F117A Roland10-23-91" | "F117A NoSnd 06-26-91" | id string |
| +18 | 01B6 | 019C | 023E | 0006 | code segment (paragraph, relocated: MZ reloc at 0000:0018) |
| +1A | 0000 | 0000 | 0000 | 0000 | data segment = load segment (relocated: reloc at 0000:001A) |
| +1C | 0064 | 0064 | 0064 | 0064 | thunk slot base (100), see section 4 |
| +1E | 382A | 25F2 | 2403 | 006D | image size |
| +22 | 5 | 5 | 5 | 5 | number of vectors |
| +24 | 0B76 0B98 0BB5 0C08 0C1C | 0008 008E 0079 00B5 0102 | 11F9 1225 12B4 1309 1321 | 000E x5 | entry offsets in code seg |

DS-relative data (variables, instruments, songs) sits *before* the code segment (ASOUND: image
0x0000..0x1B5F; code 0x1B60..0x3829). Every entry does `push ds; mov ax,SEG0(reloc); mov ds,ax`.

## 2. The 5-entry API (all far, C convention, args at [bp+6], [bp+8] ...)

| # | thunk (VGAME) | name | args | ASOUND behaviour | ISOUND | RSOUND | NSOUND |
|---|---|---|---|---|---|---|---|
| 0 | 1E42:030E | `snd_init(seg)` | arg = initial speech paragraph (F117.COM passes 2) | `cs:0B76`: `ds:17E2 = arg`; `cs:005E` detect: OPL2 timer test at 0x388 (fail -> AX=0x41); SB DSP at 0x220 (`cs:18C8(3)`) -> `ds:17F2=1`; SB-Pro mixer reg 0x26 read-back -> 2; Pro AudioSpectrum ports 0xB8B/0xB8A/0xF8A (?) -> 3. Then `cs:018F` silence. Returns 0 ok / 0x41 | `cs:0008` saves port 61, resets, AX=0 | `cs:11F9` MPU-401 reset at 0x331/0x330 (`cs:0D07`), AX=0 or 0x52 if no MPU | AX=0 |
| 1 | 1E42:0313 | `snd_play(id, a2, a3, a4)` | id 0..0x2D (>45 ignored) | `cs:0B98`: `call cs:[0911 + 2*id]` with AX=0, BX=2*id. Return AX = handler's AX (only id 2 is meaningful) | table `cs:05CA` | table `cs:119D` | AX=0 |
| 2 | 1E42:0318 | `snd_shutdown()` | - | `cs:0BB5`: silence (`018F`), SB shutdown (`18C8(9)`), then re-sets DOS time from the RTC (`cs:0BD4`: int 1A/02 -> int 21/2D) because the game reprograms the PIT | port 61 restore + RTC->DOS time | MPU reset + RTC->DOS time | - |
| 3 | 1E42:031D | `snd_tick()` | - | `cs:0C08`: `ds:17DC=0`; sequencer tick `cs:0430`; returns `ds:17DC`: +1 = a noise voice just started, -1 = all noise voices ended, 0 = no change | `cs:00B5`, returns `ds:0078` (same meaning) | `cs:1309` returns `ds:1520` | AX=0 |
| 4 | 1E42:0322 | `snd_noise()` | - | `cs:0C1C` -> `cs:0562`: re-randomise the frequency of the (max 2) "noise" channels; AX=0 | `cs:0102` random PIT2 count | `retf` (no-op) | AX=0 |

## 3. Timing (game side, VGAME)

| item | value | evidence |
|---|---|---|
| base timer IRQ | PIT ch0 reprogrammed to one video frame: `ds:263B` = measured retrace period (16 frames averaged, `0000:1D88`); fallback 0x4DAE (19886 = 60.0 Hz) | `0000:1D88..1E1B` |
| ISR | `0000:1C9B` (int 8 hooked at `0000:1C29`) | |
| game tick | every `ds:2636` IRQs -> `0000:1E79` | `0000:1CB6..1CCA` |
| **`snd_tick` rate** | called from `0000:1E79` on 6 of every 7 game ticks (counter `ds:264B`, `0000:1E8A..1E9D`) -> 70 Hz x 6/7 = **60 Hz** (VGA mode 13h); 51.4 Hz on the 60 Hz fallback | `0000:1E9D` |
| tick return handling | >0: `ds:2636 = ds:2639` (4 at 70 Hz, 5 at fallback) -> PIT runs 4x faster; <0: back to 1 | `0000:1EA2`, `1C6D`, `1C85` |
| **`snd_noise` rate** | every IRQ while `ds:2636 != 1` -> 280 Hz (4 x 70) during noise effects | `0000:1CCD..1CD4` |
| START/END | same scheme: tick thunk called at START `0000:8E71`, END `0000:4D67`; noise at START `8D44`, END `4C28` | |

All durations in event streams are in **sequencer ticks = 1/60 s**.

## 4. How the game binds the driver

`func_0000_0010` (VGAME) calls `func_0FAE_0002 = drv_bind(seg)` three times with the paragraphs from
the shared block (+0x1A sound, +0x1E, +0x1C). `drv_bind` (`0FAE:0002..003E`): thunk index =
`es:[1C]` (=100 for sound) -> thunks at `ds:011A + 5*100 = ds:030E`, each `EA off seg` (far jmp),
filled with `es:[24+2k]` / `es:[18]`. START binds at `ds:69B8+500 = ds:6BAC`, END at `ds:23FA+500 = ds:25EE`.
The block word +0x20 (init result) is copied to VGAME `ds:E584` (`0000:009B`).

## 5. ASOUND internals

### 5.1 Global variables (ds = image)

| ds: | meaning |
|---|---|
| 17DC/17DE | tick return value / last noise state (`05A5`, `054E`) |
| 17E0/17E1 | saved PIC mask / port 61 (speech) |
| 17E2 | speech buffer paragraph (init arg, or play id 40 arg2) |
| 17E4 | RNG state: `r = ror3(r + 0x9248)` (`cs:03C4`, far; `cs:0562` inline) |
| 17E6/17E8/17EA | engine: last throttle, fnum word, TL value |
| 17EC | sequencer lock (0 = run; -1 while play() edits voices or paused) |
| 17F2 | card: 0 AdLib, 1 SB, 2 SB Pro (stereo OPL, pan used), 3 PAS (?) |
| 17F4 | engine throttle 0..0x301 (play 23) |
| 17F6 | engine enable (play 24/25) |
| 17FA | 128-byte pan attenuation table (SB Pro only, `cs:0C2E`) |
| 187A | F-number table, 12 words: 200 21E 23F 261 285 2AB 2D4 2FF 32D 35D 390 3C7 |
| 1892/1893/1894 | reg BD bit7 (AM depth), BD bit6 (VIB depth), reg 08 bit6 sources (`cs:1048`) |
| 1896 | channel -> (modulator slot, carrier slot), 9 pairs: 0,3 1,4 2,5 6,9 7,10 8,11 12,15 13,16 14,17 |
| 18A8 | slot -> register offset: 00 01 02 03 04 05 08 09 0A 0B 0C 0D 10 11 12 13 14 15 |
| 1902..1908, 19DC/19FC, 19FE/1A00, 1A03..1A05 | the two noise channels: base fnum, step, tick counter, mask, alternator, OPL channel |
| 190A + 0x1E*v | voice v = 0..6 (OPL channel v); 6 is reserved for the engine |
| 1A02 | channel being processed by the sequencer |
| 1A06 | 256-byte OPL register shadow (every write goes through `cs:036B`) |
| 1B06 + 8*ch | per-channel noise params copied from the instrument (flag/dur, mask, base, step) |

OPL write `cs:036B` (AH=8 -> port 0x388; with card>=2 AH=8 writes both 0x388 and 0x38A; AH=0/2 = left/right chip):
30 status reads before the index write, 5 after.

### 5.2 Voice structure (0x1E bytes, set up by `cs:05E7`)

| off | init | meaning | set by |
|---|---|---|---|
| +00 | 1 | ticks left in current note; 0 = voice idle | note |
| +01 | 0 | pitch slide: signed, added to the 13-bit (block,fnum) every tick (`cs:0DCE`) | FA |
| +02 | 0 | step added to +1D every +0A ticks | F8 |
| +03 | 0 | step added to +0D every +0C ticks | F3 |
| +04 | - | current note | note |
| +05 | - | instrument | FC |
| +06 | (kept) | volume 0..63 (TL = 0x3F - vol) | F9 |
| +07 | 0 | gap: key-off happens `dur - gap` ticks after key-on | FB |
| +08 | - | key-off countdown | |
| +09/+0A | -/0xFF | counter/period for +02 | F8 |
| +0B/+0C | - | counter/period for +03 | F3 |
| +0D | 0x40 | pan 0..127 (SB Pro only) | F4 |
| +0E | seq | stream start (FD jumps here) | |
| +10 | seq | stream pointer | |
| +12/+14 | seq | REPEAT1 / REPEAT2 marks | FF/FE |
| +16/+18 | 0 | REPEAT1 / REPEAT2 counters | |
| +1A | 0 (AX) | chain: if non-zero, FD continues there instead of looping | id 37 sets it |
| +1C | 0 | detune, signed, added to fnum | F7 |
| +1D | 0 | volume offset, signed; effective level = (vol + ofs) & 0x3F | F5, F8 |

### 5.3 Event stream format (interpreter `cs:1360`, called for voices 0..6 by `cs:1882`)

Each tick per active voice: if +08 counts to 0 -> key off (`cs:0E5E`); +00 decremented; when it
reaches 0, bytes are read at +10 until a note:

| byte(s) | name | effect (handler) |
|---|---|---|
| `nn dd` (nn < 0xF3) | NOTE | +04=nn, +00=dd, ptr+=2. nn=0 or dd=0 -> key off (dd=0: voice stays idle = end of effect). Else +08=dd-gap, note on `cs:0E8A` |
| `F3 p s` | PANSWEEP | +0C=p, +03=s, +0B=1 (`cs:16F0`) |
| `F4 x` | PAN | +0D=x, volume refresh (`16D2`) |
| `F5 x` | VOLOFS | +1D=x (`16B8`) |
| `F6 n v0..vn-1 o` | RANDPATCH | byte at (ptr+3+n+o) := v[rand & (n-1)] (self-modifying stream, `165E`) |
| `F7 x` | DETUNE | +1C=x (`1644`) |
| `F8 p s` | VOLSWEEP | +0A=p, +02=s, +09=1 (`1612`) |
| `F9 x` | VOLUME | +06=x, volume refresh (`15F4`) |
| `FA x` | SLIDE | +01=x (`15DA`) |
| `FB x` | GAP | +07=x (`15C0`) |
| `FC x` | INSTR | +05=x, load instrument `cs:123E` (`1594`) |
| `FD` | LOOP | ptr = +1A if set (and +0E=+12=+14=+1A) else ptr = +0E (`153E`) |
| `FE n` | REPEAT2 | n=0: mark2=mark1=next; else jump to mark2 n times (`146A`) |
| `FF n` | REPEAT1 | n=0: mark1=next; else jump to mark1 n times (`13D6`) |

Per-tick after the note logic: slide (+01), every +0A ticks +1D += +02, every +0C ticks +0D += +03
(then volume refresh `cs:0C2E`) (`cs:17D1..1875`).

**Pitch** (`cs:0D1C`): block = note / 12, fnum = `ds:187A[note % 12] + detune`;
A0+ch = fnum & FF, B0+ch = keyon | fnum>>8 | block<<2. Hz = fnum x 49716 / 2^(20-block).
Note 0x30 = 388 Hz, i.e. the table is ~7 semitones above the usual AdLib C table (`sound.py` prints Hz).

**Volume** (`cs:0C2E`): carrier TL = (0x3F - ((vol + volofs) & 0x3F)) | KSL. SB Pro: left/right TLs
add `ds:17FA[pan]` / `ds:17FA[127-pan]` (clamped at 0x3F).

### 5.4 Instrument record (44 bytes at `ds:002E + 0x2C*n`, loader `cs:123E` -> `cs:1048` per operator)

Two 22-byte operator halves (first = modulator slot, second = carrier slot). Byte offsets:

| off | field | register |
|---|---|---|
| 0 / 1 | AR / DR | 60 = AR<<4 \| DR |
| 2 / 3 | SL / RR | 80 = SL<<4 \| RR |
| 4 / 5 | EG(sustain) / KSR | 20 bit5 / bit4 |
| 6 | level | 40 = KSL<<6 \| (0x3F - level) |
| 7 | KSL | 40 bits 7-6 |
| 8 | waveform | E0 = WS & 3 |
| 9 | MULT | 20 bits 3-0 |
| A | feedback | C0 = FB<<1 \| ... |
| B / C | AM / VIB | 20 bit7 / bit6 |
| D | FM flag | C0 bit0 = (flag ? 0 : 1); the 2nd (carrier) call overwrites C0 |
| E | noise duration (ticks), first half only | -> `ds:1B06+8ch` |
| 10/12/14 | noise mask / base (block\|fnum) / signed step (words) | -> `ds:1B08..1B0C+8ch` |

Before loading, TL of the modulator is set to 0x3F and reg BD/08 are rewritten from `ds:1892..1894`.
`sound.py` dumps records 0..41 (highest referenced = 41; unreferenced ones flagged) to `out/sound/asound_instruments.txt`.

### 5.5 Noise voices (explosions, jets, drums)

If the instrument has a non-zero noise byte, note-on (`cs:0E8A`) does **not** program the pitch; it
claims one of two noise slots (alternating, `ds:1A03..1A05`), copies count/mask/base/step and makes
`snd_tick` return +1. Then:
- `snd_noise` (`cs:0562`, 280 Hz): r = rng; slot A writes (base + (~r & mask)), slot B (base + (r & mask))
  as a 13-bit block|fnum word with key-on (`cs:030B`).
- every `snd_tick` (`cs:04CE..054D`): base += step, count-1; at 0 the channel is keyed off (A0=B0=0).
  When both are idle the tick returns -1.

Used by instruments 2 3 5 10 11 12 15 24 (24 = percussion in the songs).

### 5.6 Engine (voice 6)

| step | code |
|---|---|
| play 24 / 25: enable / disable (`ds:17F6`) | `cs:041E`, `cs:0424` |
| play 23, arg2 = throttle 0..0x301: `ds:17E8 = (t & ~1) + 0x883` (block 2, fnum 0x83+t: 24.8..171 Hz) | `cs:03D5` |
| every tick, if enabled and throttle != 0: voice 6 idle -> start stream `ds:0E94` (INSTR 9, VOLUME 43); else keep +00=+08=2 | `cs:045C..048B` |
| when throttle changed: write fnum to ch6 with key-on (`030B`); v = 0x36 + throttle/85 (low byte); TL(0x50) = 0x3F - v, TL(0x53) = v | `cs:048F..04BB`, `cs:03FB` |

(The TL formula makes the carrier quieter as throttle rises; the low byte is used, AH remainder ignored. (?) intent.)

### 5.7 play() ID table (dispatch `cs:0911`; full output `out/sound/asound_ids.txt`)

v = voice (OPL channel). Seq = stream address (image offset), decoded in `out/sound/asound_sequences.txt`.

| id | handler | action | game use (section 7) |
|---|---|---|---|
| 0 | 018F | stop everything (all voice/noise bytes 0, all channels key-off `0210`) | VGAME 0272, START/END |
| 1 | 0761 | writes 0E9A into +12 of every voice (BX=2 at call) -> next REPEAT1 jumps to the empty stream (?) | none found |
| 2 | 0839 | returns OR of voice-active bytes | START 30BF, END 161A (wait for music end) |
| 3 | 0694 | song, v0..v5: 0FE0 11AC 121A 12FC 1448 154C | none found (?) |
| 4 | 0876 | v1 <- 1542 (instr 3, noise sweep down 2 s): big explosion | many (VGAME) |
| 5 | 085F | v0 <- 0F00 (instr 15 noise, 81 ticks): explosion/impact | many |
| 6 | 0887 | v4 <- 0F28 (instr 4, 10 x 2-tick blips): cannon burst (?) | 4820 |
| 7 | 08B7 | v3 <- 0F52 beep | 6598, 66BD |
| 8 | 08B0 | v3 <- 0F4A beep | 5496, 56B5 |
| 9 | 089C | v3 <- 0F3C rising tone, not restarted while playing | 6AA8 |
| 10 | 0895 | v5 <- 0F94 | 2B14 |
| 11 | 08E8 | v3 <- 0FA2 (slide up + fade); sets throttle 1 if 0 | 1FB8 |
| 12 | 08FC | v3 <- 0FB4 | 1FFC |
| 13 | 088E | v0 <- 0F34 (instr 5 noise, 90 ticks) | 78E8 |
| 14 | 08DA | v5 <- 0F8A | 2992 |
| 15 | 08E1 | v0 <- 0F78 (instr 11 noise, 145 ticks) | 415E, 4731 |
| 16 | 08CC | v0 <- 0F70 (instr 10 noise, 127 ticks) | 78E8 |
| 17 | 08C5 | v1 <- 0F68 (instr 12 noise) | 203D |
| 18 | 08D3 | v5 <- 0F80 (two high notes) | A741 |
| 19 | 0903 | v3 <- 0FC8, v2 <- 0FD4 | C98A |
| 20 | 08BE | v5 <- 0F5A | CD1B |
| 21 | 0782 | pause: save/zero noise counters, TL=0x3F on carriers 43 44 45 4B 4C 4D 53, lock | none found |
| 22 | 07C7 | resume: TL from voice +06, restore noise, unlock | none found |
| 23 | 03D5 | engine throttle = arg2 | VGAME 0269 (0), 2805 |
| 24 / 25 | 041E / 0424 | engine on / off | D41F, 20B1, 3A54 |
| 26 | 0634 | v5 <- 0E9C blip | START 355D 3901 4074 4087 |
| 27 | 0647 | v0 <- 0EB4 two-note blip | START 5D13 707A |
| 28 | 064D | v0 <- 0EC0, note byte 0EC6 := 0x21 + rand&3 | START 1A52, END 0543 |
| 29 / 30 | 0662 / 0669 | v0 <- 0ED2 / 0ECA | START 0A71 / 0A20 |
| 31 | 0686 | v2 <- 0EE4 | START 0454, VGAME C9BA |
| 32 | 068D | v2 <- 0EEC (error buzz) | VGAME 76B4 76E2 |
| 33 | 0670 | v0 <- 0EDA, byte 0EE0 := 1 + rand&3 | START 6F3E |
| 34 / 35 | 063A / 0640 | v5 <- 0EAC / 0EA4 | START 09D2 / none |
| 36 | 06E8 | song v0..v3: 0876 0992 0A9A 0B2E | END 22D4 ("awards") |
| 37 | 0720 | song v0..v5: 0B66 0BA0 0BDE 0C1C 0B5E 0B5E, chains v4->0B6A v5->0BA6 | END 371B (cemetery / landed2-4 pics) |
| 38 | 0704 | song v0..v3: 0C76 0D10 0DB2 0E24 | END 3BAB 3BD4 (bail-out rescue) |
| 39 | 06BE | song v0..v5: 0766 07B4 07CE 07EE 0830 085C (loops) | END 389E ("landed1", successful return) |
| 40 | 0B90 | `ds:17E2 = arg2` (speech paragraph) | VGAME 0129 (load), 0299 (0) |
| 41..45 | 096D..09A1 | speech phrase (section 6) | VGAME 3DEC 3E01 4252 4379 40B7 |

Ids 4 and 5 read their stream from 4-entry tables (`cs:086E`, `cs:0857`) indexed by `(2*id >> 3 or 2) & 6`;
since BX is always 2*id this is constant (1542 and 0F00). The other entries (0EF8 0F08 0F10, 0F18 143C 0F20)
are unreachable (?).

## 6. SPEECH.117

| item | value | evidence |
|---|---|---|
| format | 26408 bytes, raw unsigned 8-bit mono PCM, no header | file |
| load | VGAME `func_0000_00F0` @0110: `func_0000_E586("speech.117")` -> paragraph in `ds:008A`; `snd_play(40, para, ds:C0A0, ds:C0A2)` (the dword = file length, used by ISOUND/RSOUND) | `0000:0110..012E` |
| phrase tables | not in the file: per driver, lists of `(end, start, segoff)` words, terminated by 0; `end` exclusive; byte address = `ds:17E2*16 + segoff*16 + off` | ASOUND `cs:09AA..09F0`, ISOUND `cs:078D..07CC` (same values) |

| id | segments (byte offsets) | duration @8 kHz | VGAME trigger |
|---|---|---|---|
| 41 | [0000,2422) | 1.16 s | `0000:3DEC`: countdown `ds:DF04` reaches 0; set to 4*`ds:368E` at `0000:74A2` in `func_0000_73C8` (after a hit/kill, explosion sound 4) (?) |
| 42 | [1078,2422) (tail of 41) | 0.63 s | `0000:3E01`: countdown `ds:9D3A` (set `0000:7457`, other branch of 73C8) (?) |
| 43 | [2423,294B)+[321D,3D25) or [294C,321C)+[321D,3D25), chosen by tick counter `cs:000E` parity | 0.52 / 0.64 s | `0000:4252` with message "Safe Landing" |
| 44 | [3D26,47A6)+[47A7,5666) | 0.81 s | `0000:4379`: first increment of `ds:9912` (mission clock) (?) |
| 45 | [3D26,47A6)+[5667,6727) | 0.87 s | `0000:40B7`: once (`ds:3DC2`) when `ds:E00C==ds:E31A`, `ds:3666 < 5000`, `ds:46F2==2` (?) |

WAVs: `out/sound/speech_41.wav .. speech_45.wav` (43a/43b) - listen to name the phrases.

Playback per driver:

| driver | path | rate | blocking |
|---|---|---|---|
| ASOUND, card 0 (plain AdLib) | `cs:0A09`: silence, `cs:0A5B` sets ch0 (20=23 23=28 40=3F 43=3F 60=AF 63=AF 80=0D 83=0F C0=05 E0=00 E3=02, A0=8F B0=2E key-on, wait 0x988 PIT counts, then A0=00 B0=20 -> held DC); PIT2 mode 2 count 0x96; `cs:0B01` polls PIT2 and per wrap writes reg 0x43 (carrier TL) = `cs:0018[sample>>2]` (64-entry log table 3F 2D 26 23 20 1D 1B 19 ... 00) | 1193182/150 = 7954.5 Hz | yes: IRQ0 masked, CLI during playback |
| ASOUND, card 1/2 (Sound Blaster) | `cs:09F2` -> `cs:18C8(6)`: DSP time constant 0x83, DMA ch1 single-cycle (cmd 0x14) per segment, IRQ (default 7, port 0x220 at `cs:0058`) chains segments | 8000 Hz | no |
| ISOUND / RSOUND | PC speaker PWM: id 40 converts the buffer in place `b = (b>>1)*9/16 + 1` (ISOUND `cs:07E5`); PIT0 count 79, each sample held 2 IRQs, sample written to PIT2 mode-0 (ISOUND `cs:0A4B..0B6F`, ISR `cs:08E7`) | ~7552 Hz (?) | yes |

Port recommendation: play the WAV slices at 8000 Hz through WebAudio regardless of card.

## 7. Game-side triggers (VGAME unless noted)

`func_0000_D3F9 = sfx(id, prio)`: plays if `prio >= ds:43F2` (sound-level option (?)) and, when
`ds:C09A != 0`, only if prio > 1; then always calls `func_0000_D41F = engine_sound_update()`:
play 24 if `ds:43F2==0 && ds:2E0A!=0 && ds:C09A==0`, else 25 (`ds:2E0A` = throttle % 0..100 (?)).

| site | id (prio) | context |
|---|---|---|
| 0129 / 0299 | 40 | speech buffer set / cleared |
| 0269, 0272 | 23(0), 0 | `func_0000_0235` end of flight: throttle 0, stop all |
| 2805 | 23, arg `ds:B07E/27` | engine pitch follows thrust `ds:B07E` |
| 20B1, 3A54 | 25 | engine off (after "adv.pic"; `func_0000_3A4E`) |
| 1FB8 | 11 (2) | throttle non-zero and `ds:B19C==0` (?) |
| 1FFC | 12 (prio=throttle=0) | throttle cut to 0 |
| 203D | 17 (2) | throttle at 100 with `ds:C0CE` set (?) |
| 2454, 24AD | 5, 4 (2) | `func_0000_1EB0`, `ds:9D3C=-16` (crash/ground impact (?)) |
| 2992 | 14 (1) | `ds:2DF0` underflow or `ds:2DF4 >= 200` (?) |
| 2B14, 2B71 | 10, 4 (2) | gear/landing logic (`ds:2DF4`, `ds:3DA2`) (?) |
| 415E | 15 (2) | `func_0000_3ADA`, sets `ds:9910=1` |
| 42AD, 4302 | 4 (2) | after "Cargo delivered"/"Safe Landing" checks (?) |
| 4252 | 43 | "Safe Landing" |
| 4379 | 44 | first mission-clock step |
| 40B7 | 45 | see section 6 |
| 4731 | 15 (2) | "... released" message (countermeasure/weapon release (?)) |
| 4820 | 6 (2) | `func_0000_4777`, decrements `ds:3682` (gun rounds (?)) |
| 5496 | 8 (1) | " - Radar ID" message |
| 56B5 | 8 (1) | `func_0000_56A9` |
| 6598, 66BD | 7 (1) | "Visual ID - <type>" |
| 6AA8 | 9 (1) | `func_0000_683E`, every 4th frame while a threat is inside range (warning tone (?)) |
| 6D45 | 5 (2) | `func_0000_683E` (missile result, "Sidewinder"/" misses " strings nearby) |
| 73AB, 7558 | 5 (2) | `func_0000_73C8` (aircraft destroyed / hit) |
| 7491 | 4 (2) | `func_0000_73C8` (target destroyed), then arms speech 41/42 |
| 765C | 4 (2) | `func_0000_761A` ("Primary target"/"Second. target") |
| 76B4, 76E2 | 32 | "Bay closed" / "Insufficient Altitude" (error buzz) |
| 78E8 | 13 or 16 (2) | `func_0000_7663` weapon fired ("... fired"): 16 if `ds:339C+0x12*w == 0`, else 13 |
| A741 | 18 (2) | after a "Frame "-style message |
| C98A, C9BA | 19, 31 | key handlers toggling `ds:A098` / `ds:E58A` |
| CD12, CD1B | 5 then 20 (2) | key handler (`func_0000_C8CA`), not when `ds:C09A` (eject (?)) |

START (UI, thunks `ds:6BB1`): ids 26 (355D 3901 4074 4087), 27 (5D13 707A), 28 (1A52), 29 (0A71),
30 (0A20), 31 (0454), 33 (6F3E), 34 (09D2), 2 (30BF), 0 (761B 76DA).
END (thunks `ds:25F3`): 28 (0543), 2 (161A), 26 (1BFF 21D1 21E4), 36 (22D4), 0 (22E3 3015 3985 3E6B 3F4D),
37 (371B), 39 (389E), 38 (3BAB 3BD4).

## 8. Other drivers (summary)

| driver | notes |
|---|---|
| ISOUND (PC speaker) | one voice: PIT2 square wave via port 61; streams of words (count, ticks, freq, sweep...) interpreted by `cs:026C`; noise = random PIT2 count `rng & ds:49 + ds:47` in entry 4; play table `cs:05CA` (46 ids, same numbering) |
| RSOUND (Roland MT-32/MPU-401 UART) | MIDI sequencer, play table `cs:119D`; entry 4 is a bare `retf`; speech ids 41..45 at `cs:0577..05AA` use the PC-speaker code like ISOUND |
| NSOUND | every entry `xor ax,ax; retf` |
| `*.LOG` (MPS_LOGO jingle) | different header: 16 zero bytes, name at +0x10 ("AdLib Logo 7-18-91", "IBM Logo     7-12-91", "RolandMT-32 3-25-91"); MPS_LOGO calls thunks `00DA:0307/030E/0315`. Not decoded |

## 9. For the HTML5 port

1. Recommended: run an OPL2 emulator (e.g. a JS port of Nuked-OPL3/DOSBox OPL) in an AudioWorklet and
   re-implement `snd_tick` (sections 5.3-5.6) at 60 Hz, writing registers exactly as described.
   Noise channels: re-randomise at ~280 Hz.
2. Instruments, streams and IDs are all in `out/sound/*.txt` (regenerated by `py -3 -I re/tools/sound.py`).
3. Speech: play `SPEECH.117` slices (section 6) as 8 kHz unsigned PCM.
4. Stereo pan (+0D) only matters for SB Pro; mono is the reference.
