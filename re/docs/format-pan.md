# .PAN animation format (PLAYER.EXE)

Files: TITLE-1, TITLE-2, TITLE-3A, CREDIT, C-PIT, BUNKER `.PAN`. Player: `PLAYER.EXE` (MSC small model,
DGROUP 02A3, linear 0x2A30, header 128). Decoder: `re/tools/pan.py` -> `re/out/pan/NAME/`. [verified]

Summary: the whole file is **one LZ77 stream (LZEXE 0.91 token set)**; the unpacked data is a list
of **cels**. Cel 0 starts with a `'Z'` header (frame rate, cel-size table, 256-colour VGA palette);
every cel is a `'B' 00 01 00` record holding a **Deluxe-Paint-ANM-style RunSkipDump** delta that is
written straight into MCGA video memory A000:0000 (320x200, linear, 64000 bytes) on top of the
previous frame.

## 1. Compression layer — `func_0000_0BE2 = lz_segment(dst_linear)`

Input buffering: `func_0000_0BA2 = pan_open(name)` (int 21h/3D00, handle in ds:11B8, resets
bit state ds:11BC=0, eof flag ds:11BE=0, read pointer ds:01B6 = ds:01B8+0x1000 = "buffer empty").
`func_0000_0B84` refills the 4 KB input buffer ds:01B8..11B7 (int 21h/3Fh, 0x1000 bytes), first
copying the byte at the old end to just before the buffer so a `lodsw` can straddle the refill.
`func_0000_0BCD = FAB_close()` (int 21h/3Eh). `func_0000_0BDC` returns the EOF flag ds:11BE.

Bitstream (0BE2, 0C1F..0CF0) — identical to the LZEXE 0.91 decompressor (cf. `tools/unlzexe.py`):
- 16-bit little-endian control words, consumed LSB first; a new word is fetched as soon as the
  16th bit of the previous one is consumed (0C2E..0C43). Bit state (bp=ds:11BA, count=ds:11BC)
  and read pointer (ds:01B6) persist between calls.
- `1` -> literal byte (0C50).
- `0 0 b1 b0` -> short match: len = 2*b1+b0+2, offset byte `o`, distance = 0xFF00|o (-1..-256)
  (0C54..0CB1).
- `0 1` -> long match (0CB4): word `w` (lo, hi): distance = 0xE000 | ((hi>>3)<<8) | lo (-1..-8192);
  `n = hi & 7`; n!=0 -> len = n+2; n==0 -> extra byte `c`: c>=2 -> len = c+1;
  **c==1 -> end of segment** (return), **c==0 -> end of file** (0CE2..0CFE: ds:11BE = c^1).
- Output goes to `es:di` with `es = (dst>>4) - 0x200`, `di = (dst & 15) + 0x2000` (0BFF..0C0A), i.e.
  the same linear address, offset so that the 8 KB look-back may reach data from previous
  segments. Returns the number of bytes produced in this segment (0D01..0D04).

Segments are just flush points: the stream (window and bit state) is continuous across them. In the
shipped files a segment ends at the first cel boundary after ~0xA000 bytes of output (e.g. C-PIT:
40962, 81924, ...) (?). The file is zero-padded to a 16-byte multiple after the EOF token
(e.g. TITLE-1: 12052 bytes used of 12064). [verified on all 6 files]

## 2. Cel stream (unpacked data)

Cel 0:

| off | size | field |
|---|---|---|
| 0 | 1 | `'Z'` (0x5A) palette/header record marker (07EA: `cmp es:[bx],5Ah` at 0815) |
| 1 | 1 | rate = frames per second; ticks per frame = `60 / rate` (`idiv`, 0821..082D -> ds:1DEC) |
| 2 | 2 | N = number of cels (also read by the loader, 0319; `assert(cels <= 1024)` 0322) |
| 4 | 2N | cel size table, uint16 each, size of cel *i* in unpacked bytes (cel 0's size includes this 'Z' header) |
| 4+2N | 768 | palette: 256 x (R,G,B), 6-bit VGA DAC values (0..63) |
| 4+2N+768 | ... | the `'B'` record of cel 0 |

07EA skips the header with `ptr += (N + 0x182) * 2` (0830..0839) = 4 + 2N + 0x300 and loads the
palette from `ptr - 0x300` (0845) via `func_0000_0D0C = set_dac(first=0, count=0x100, far src)`.
Before loading, the screen is blanked (`func_0000_0DB0`: SEQ reg 1 bit 5 = screen off) and after
the B record it is re-enabled (`0000:0DCA`, no function header in the listing). The 'Z' test is done
for every cel, so a later cel could change the palette too (none of the 6 files does). [verified]

Every cel ('B' record), checked by asserts at 085A..08C3 (line 0x1DD..0x1E0):

| off | value |
|---|---|
| 0 | `'B'` (0x42) |
| 1 | 0 |
| 2 | 1 |
| 3 | 0 |
| 4.. | RunSkipDump opcodes, until the end op |

The next cel begins right after the end op (07EA returns that pointer, 08D9..0902); the size table is
only used by the loader for buffering. pan.py checks that the decoded sizes equal the table: 0
mismatches in all six files. [verified] An "empty" cel is 7 bytes: `42 00 01 00 80 00 00`.

### RunSkipDump — code at 0000:1006..1095 (inside a data block of the listing; called from 08D9 with dst = A000:0000)

Destination pointer `di` starts at 0 (top-left), 16-bit wrap. Opcodes (byte `c`):

| c | action |
|---|---|
| 0x01..0x7F | dump: copy next `c` bytes |
| 0x00 | run: next byte `n`, next byte `v`: write `v` n times |
| 0x81..0xFF | skip `c - 0x80` pixels (keep previous frame) |
| 0x80 | long op: word `w`: `w == 0` end of cel; `1..0x7FFF` skip w; `0x8000..0xBFFF` dump `w-0x8000` bytes; `0xC000..0xFFFF` run of `w-0xC000` copies of the next byte |

This is the same opcode set as Electronic Arts' Deluxe Paint Animation (.ANM) "RunSkipDump".
Frames are deltas against the current screen; cel 0 is a full picture (0 skip). The routine returns
the normalised far pointer after the end op (1081..1095).

Stats (pan.py, `out/pan/*/cels.txt`):

| file | cels | rate (fps) | ticks/frame | unpacked | content |
|---|---|---|---|---|---|
| TITLE-1 | 111 | 20 | 3 | 33702 | pilot in cockpit, canopy in hangar |
| TITLE-2 | 200 | 10 | 6 | 137769 | hangars at night, F-117 taxiing |
| TITLE-3A | 259 | 20 | 3 | 467814 | "F-117A Stealth Fighter 2.0" title |
| CREDIT | 452 | 20 | 3 | 143288 | credits over sky/clouds |
| C-PIT | 300 | 20 | 3 | 187871 | cockpit panel / MFD view |
| BUNKER | 344 | 20 | 3 | 138512 | target bunker in desert |

## 3. Player structure and streaming buffer

- `func_0000_0010 = main(argc, argv)`: argc < 2 -> print `usage: player pan_file(s)` and exit 0x63.
  Calls `func_0000_005C = init()`, then `func_0000_0244 = play_file(argv[i])` for i = 1..argc-1,
  then `func_0000_019A = finish(argc)`.
- `init` (005C): reads the far segment at 0000:04F0 (BIOS inter-application area) = F117.COM's
  shared block -> ds:208A/208C; patches the sound-driver jump table at ds:11C0 from it
  (`func_0000_0F6C`, slots of 5 bytes `EA off seg`, so ds:13B9/13BE/13C3/13C8 = slots 0x65..0x68);
  allocates the largest DOS block (`_dos_allocmem(-1)` must fail with 8, then alloc that size,
  `assert(size >= 0x2000)` paragraphs = 128 KB) -> mseg ds:207C. Layout: mseg+0 .. +0x7FF cel-size
  table (1024 words, linear ds:207E), ring buffer from mseg+0x800 (ds:1E6A) to mseg+size*16 (ds:1E60).
  Then screen off (0DB0), fade setup `func_0000_0E0C(5)`, installs the timer (`func_026B_000A`),
  ctrl-break/ctrl-C handlers (`func_0000_0583`, int 1Bh/23h -> stub 0560 sets ds:2092=3), sets
  video mode 13h if not already (0520 = int 10h/0Fh, 0540 = int 10h/00h).
- `play_file` (0244): name = argv + "." ; the last '.' is cut (strrchr, 0296) and ".PAN" appended,
  so any extension given is replaced. If the open fails the file is **silently skipped** (02D4).
  Loop until EOF (03D5): wait while `func_0000_03FE` (room check / ring wrap) says no room,
  calling the idle/input poll `func_0000_0696`; decompress one segment to the write pointer ds:2082;
  for the first segment read N and copy the size table to mseg (05F6 = far memcpy); advance the
  write pointer; then advance "head" ds:2094 over every cel that is now complete (03A6..03D3).
- Ring wrap (03FE): when fewer than 0xC000 bytes are left before the end, the unfinished bytes plus at
  least 0x2000 bytes of history (the LZ window: `si = max(write-head, 0x2000)`, 048B..049B) are moved
  to the ring start and the pointers rebased (ds:2086 = old head, ds:1E66 = new head).
- Debug status line builder at 0000:0A20 ("time: cels: full: tail: head: size: skip:"; time=ds:1DEE,
  cels=ds:1E64, full=% of ring used, tail=ds:1E6E, head=ds:2094, size=ring size, skip=ds:1DF0)
  has no caller in the image (dead debug code).

## 4. Timing — frames are shown from the timer interrupt

- `func_026B_000A` hooks int 08h (ISR at 026B:01A2) after calibrating (026B:0272): it reads PIT
  counter 0 at 16 consecutive vertical retraces (port 3DAh bit 3, 026B:0307) to measure the display
  refresh period (ds:1A12, PIT clocks). ratio = (period*17/16)/3977 must be 4..6 (4 = 70 Hz VGA,
  5 = 60 Hz), otherwise period = 0x4DAE (19886 = 60.0 Hz) and ratio 5 (02CE..02E6). The PIT is
  reprogrammed to fire once per refresh and re-synchronised to the retrace every 20 IRQs
  (026B:0211). The original BIOS int 8 is chained at ~18.2 Hz using a 32-bit accumulator (ds:1A04).
- Every refresh the ISR far-calls 026B:0336: when ratio == 4 (70 Hz) it drops one call in 7, so
  the animation clock is **60 ticks per second** on both 60 and 70 Hz displays. It then calls the
  frame callback 0000:0738 and the sound driver slot 0x66 (ds:13C3); the driver's return value can
  switch the PIT to `ratio` interrupts per refresh (026B:0073/008B) with slot 0x67 (ds:13C8) called on
  every IRQ (?) (sound sample/music servicing).
- Frame callback 0000:0738 (retf; re-entry guard ds:1E7A): time++ (ds:1DEE). While a fade is running
  (ds:13D4 != 0) and a frame is pending, it performs a fade step (0EE3) instead. Otherwise the
  countdown ds:1DEA is decremented; at 0, if tail (ds:1E6E) == head (ds:2094) the underrun counter
  ds:1DF0 ("skip") is incremented, else the cel at tail is drawn (07EA), tail advances (with ring
  wrap at 07A4..07D1), frame counters ds:1E72/ds:1E64 ++, countdown = ticks/frame (ds:1DEC).
  So a cel is displayed every `60/rate` ticks: 3 ticks (20 fps) or 6 ticks (10 fps, TITLE-2).
- Fade-in: init calls `func_0000_0E0C(5)`: ds:13D4 = 5*60 = 300 ticks (?) of fade; while it is
  nonzero `set_dac` (0D0C) stores the palette at ds:13DA and writes black to the DAC; the fade
  (0E65/0EE3) then ramps the stored palette in a few entries per tick (count per vblank measured
  by `func_0000_0DE4`). Only the first palette of a PLAYER run is faded; the first frame is held
  meanwhile.
- `set_dac` (0D0C) honours BIOS 0040:0089 bit 1 (grey-scale summing): grey = 0.30R+0.59G+0.11B
  (constants 4CCDh, 970Ah, 1C29h).

## 5. Input, exit and the command line

- `func_0000_0696 = poll()`: ds:2092 (ctrl-break) -> exit(3). Calls sound slot 0x65 (ds:13B9) with 3.
  If shared-block byte [+0x72] bit 0: joystick buttons (port 201h, `func_0000_0F1A`); bit 1: mouse
  buttons (int 33h/3, `0F47`, `0F32`). A key (`func_0000_1380` kbhit, `13A6` getch) exits with the key
  code; a button exits with 0x1B. Exit path `func_0000_01F6 = quit(code)`: slot 0x65 (0) (stop
  sound (?)), unhook timer (`func_026B_004D`, PIT back to 18.2 Hz), restore handlers (05D0),
  restore the original video mode if it was not 13h, free mseg, `exit(code)`.
- `finish(argc)` (019A): wait (polling) until tail == head, i.e. all cels shown. Then **if argc > 2**:
  loop `while (slot_0x65(2) != 0) poll();` (01C7..01E6) — waits for the sound driver (music) to
  report finished (?) — then quit(0).
- F117.COM runs `PLAYER - title-1 title-2 title-3a credit c-pit bunker` (intro) and later
  `PLAYER  title-2` (see 01-architecture.md). In PLAYER the `-` is an ordinary file argument:
  it becomes `-.PAN`, which does not exist, so `play_file` skips it silently. Its only effect is
  on argc (the "> 2" test that makes PLAYER wait for the music after the last animation). With the
  six intro files argc is 8 anyway, so for PLAYER the `-` is a no-op placeholder; why F117.COM
  emits it (e.g. its command-tail construction sharing the string with the second call) is not
  visible in PLAYER (?). The second call has argc = 2: no music wait.

## Not code in the player

`func_0000_1A7E` (1034 bytes) is the C runtime `printf` formatter (`_output`, jump table 1A6E), not
the cel decoder.
