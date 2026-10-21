# .SS sprite series ("MADSS1") — MPS_LOGO.EXE

Only file: `LABSLOGO.SS` (12348 bytes), the animated "MPS Labs / The MicroProse Design Group" logo.
Loader/drawer: module `SPRITES.C` inside `MPS_LOGO.EXE` (header 560). Decoder: `re/tools/ss.py`
-> `re/out/ss/LABSLOGO/` (82 sprites + cumulative screens + frames.txt). [verified]

Note on the listing: `MPS_LOGO.asm` says dgroup=00DA, but the strings used here are addressed
relative to segment **0332** (linear 0x3320): the C runtime banner "MS Run-Time Library" is at
0332:0008, and `push 59h` (006D:018D) / `mov ax,530h` (0006:01C9) / `mov ax,539h` (0006:01E9)
point at "MADSS1", "labslogo", "04 bad series load" only with ds = 0332. Below, `ds:XXXX` = 0332:XXXX
(?: conventions file says 00DA0). Several functions in the listing are mis-split; addresses below
are SEG:OFF as in the listing (linear = SEG*16+OFF), disassembled linearly.

## File layout (all little-endian)

| off | size | field | loader (func_006D_0112 = `series_load(name, mode, pal)`) |
|---|---|---|---|
| 0x00 | 7 | `"MADSS1" 1A` | fread 7, byte 6 := 0, `strcmp(buf,"MADSS1")` else error 2 (006D:017D..01AF) |
| 0x07 | 9 | series name, NUL padded (`"labslogo"`) | fread 9, `strcmp(buf, name)` mismatch -> error 5 (warning only, 01B2..01D4) |
| 0x10 | 4 | alloc size (12196) | allocate `(size>>4)+1` paragraphs (0045:00BC) -> `ser`; fail -> error 3 |
| 0x14 | 2 | count = number of sprites (82) | -> ser+0x10 |
| 0x16 | 4 | pixel-data size (11016) | -> local [bp-20h] |
| 0x1A | 2 | ? (260) | -> ser+0x0C, not used by the code seen (?) |
| 0x1C | 2 | ? (177 = tallest sprite's row count) | -> ser+0x0E (?) |
| 0x1E | 1 | type (4) | -> ser+0x0A; must be 1..5 else error 7 (02C0..02D6) |
| 0x1F | 14*count | sprite records (below) | 0331..03F4 |
| .. | 1 | ncol = number of palette entries (38) | -> ser+0x12 (03F9..041B) |
| .. | 4*ncol | palette entries R,G,B,x (6-bit VGA values; 4th byte unknown (?)) | -> ds:0674 (042C..0453) |
| .. | datasize | pixel data (RLE, below) | `0000:0030` = huge fread into ser+0x22+14*count (0455..0469) |

Sprite record (file, 14 bytes): `uint32 offset` (into the pixel data), `uint16 delay`,
`uint16 x`, `uint16 y`, `uint16 w-1`, `uint16 h-1`.
In memory the offset is replaced by a normalised far pointer (0342..0366), and record *i* (1-based)
sits at ser + 0x14 + 14*i. Other in-memory fields: ser+0 name (far strcpy 0045:008E), ser+9 `scaled`
flag (cleared at 02BB; the draw routine asserts `ser->scaled==no`, SPRITES.C line 400, 006D:0603),
ser+0x13 colour base.
Error code variable ds:0C74 (1 = open failed, 2 = bad magic, 3 = no memory, 5 = name mismatch,
6 = free(NULL), 7 = bad type).

w/h are stored minus one: decoded sprites have exactly w+1 columns max and h+1 rows (all 82). [verified]

## Colours

After loading (046C..0567):
- type 1: every pixel byte v is replaced through the palette table byte ds:0670+4*v (=byte 0 of
  entry v-1) (`006D:0084`) (?: meaning of type 1 not exercised).
- other types: base = (mode == 2) ? 0xF8 - ncol : `ds:004A[type]` (table 01 51 1F 38 1F 01 for types
  0..5); ser+0x13 = base; palette entry i (0-based) RGB is copied into the caller's 768-byte palette at
  DAC index base+i (04D2..0519); every pixel byte is rebased `v += base-1` in place (`006D:0002`), so
  pixel value v (1..ncol) = entry v-1. LABSLOGO: type 4, mode 0 -> base 0x1F, DAC 0x1F..0x44.
  [verified: colours match the real logo]

## Pixel data (row RLE) — draw `func_006D_05BE`, inner loop 006D:0650..06DD; rebase pass 006D:0002

Per row a mode byte, then data, row ends with `FE`; the sprite ends with `FF` in mode-byte position.

| byte (mode position) | meaning |
|---|---|
| `FE` | empty row (next row) |
| `FF` | end of sprite |
| `FA` | literal row: bytes are pixels until `FE`; `FC` = transparent pixel (skip 1); `FD n v` = run of n pixels v (v = `FC` -> skip n) |
| `F9` (any other) | run row: pairs `n v` until `FE` in the n position; v = `FC` -> skip n |

Destination: `di = seg:off + y*pitch + x`, pitch 320 (passed in a view struct {200, 320, 0, A000h}
from 0006:0280..0296); x,y = record x,y when the caller passes 999 (0x3E7) (05C4..05FD).

## Playback (MPS_LOGO main, 0006:0072)

argv[1] first letter (upper-cased) selects the sound driver R/A/T/I/N ("01/02 Specify sound driver").
Mode 13h (0006:03E4), read the DAC (0006:038E), `series_load("labslogo", 0, pal)` (null ->
"04 bad series load"), write the DAC (0006:033A), start the jingle unless 'N' (00DA:030E(2)).
`t = BIOS tick count (0040:006C, 0045:0062)`; for i = 1..count: `t += rec[i].delay`; busy-wait
until the tick count reaches t (18.2 Hz ticks); draw sprite i onto the screen **without clearing**
(sprites accumulate: frame 1 is the frame/background box, the rest draw the "MPS" stroke, "LABS" and
the caption piece by piece). Total 146 ticks = ~8.0 s. A key press (0146:0724, `_bios_keybrd`)
clears ds:0E76 so the remaining sprites are drawn without waiting. Then free the series (006D:05A2),
stop the sound (00DA:030E(0), 00DA:0315, 00DA:04C4). Return value: no key 0, Esc (011Bh) 1,
Alt-Q (1000h) 2, other key 3 (0006:02FE..0330).

Last record (82) is an empty 0x0 sprite with delay 34 = the final hold.
