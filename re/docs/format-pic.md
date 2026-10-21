# .PIC / .PAL formats (START.EXE)

Decoder: `re/tools/pic.py` (`py -3 -I pic.py IN.PIC OUT.PNG [PAL[:index]]`, `--all` -> `re/out/pic/*.png` + `index.txt`).

## Summary
A .PIC is one full 320x200 screen, LZW + RLE compressed, with a 1-byte header and **no width/height,
no palette, no sub-image directory**. All 52 PICs in the reference folder decode cleanly [verified].
Sprite sheets are ordinary 320x200 screens; START addresses cells with hard-coded coordinates / rect tables.

## Loading path
| addr | alias | what |
|---|---|---|
| `func_0000_3641` | `show_pic(idx, cb)` | `pic_load(idx, page 1)`; `set_pal(idx)` (826C); blit page1->page0 320x200; optional callback `cb`. |
| `func_0000_35FC` | `pic_load(idx, page)` | `sprintf(buf,"%s.pic", names[idx])` (names: word table ds:0CBA, fmt ds:0CB2); `load_file(buf, [d336]:[d338])`; `pic_decode([e086], pages[page])`. Page segments: word table ds:CAB0 (5 pages, filled by `func_0000_73CE`). |
| `func_0000_2864` | `load_file(name, far buf)` | `func_0000_8075` (DOS 3Dh open, aborts with "File not found" on error) + `func_0000_816F` (DOS 3Fh read, count 0xFFFF, into far buf) + `func_0000_8123` close. Whole compressed file is read raw. Buffer = 0x5DC0 (24000) bytes allocated at `0:7339`/`0:73D4`; `[e086]`=`[d338]`=its segment, `[d336]`=0. |
| `func_0000_8782` | `pic_decode(src_seg, dst_seg)` | Assembly (not C: register calling, stack-switch tricks). Sets refill callback `[8d6a]=0x819D` (copy next 0x200 bytes from `src_seg:[6499]` into ds:6235), then 200 rows (`[8d60]=0xFA00`, -0x140 per row): `func_0000_885F` decodes one row into ds:8C20, then far `0A95:6AB7`/`0A95:6ACB` store the row to the page. |
| `func_0000_871A`, `loc_0000_87F6` | streaming variants | Same decoder, refill callback `0x81C6` = DOS read 0x200 bytes from handle `[649f]` (decode straight from file). No direct callers found. |

`0A95:xxxx` far calls land in DGROUP (linear 0A950) at a table of `EA 00 00 00 00` (`jmp far 0:0`) stubs
that are patched at run time (graphics driver; presumably MGRAPHIC (?)). `0A95:6A8A` = blit
`(src_page, sx, sy, dst_page, dx, dy, w, h)` (signature from its uses, e.g. `func_0000_3641`, `func_0000_2901`).

## Byte layout
| offset | size | meaning |
|---|---|---|
| 0 | 1 | signed `B`. `func_0000_8889` @`0:88C3`: if `B<0`: 8-bit pixels, max code width `-B`; else 4-bit pixels (`[8d7d]=1`), max width `B`. |
| 1.. | - | LZW bit stream, read LSB-first in 16-bit little-endian words (`func_0000_8983`). The first word's high byte is the first 8 stream bits (`[8d7c]=8` after reading the header). |

All reference files have `B = F5h` (-11): 8 bpp, 11-bit max codes. The 4-bpp path (two pixels per byte,
low nibble first: `0:8958..8964`, row byte count halved at `0:8911`) is unused by the shipped files.
Decoded stream ends within 0-3 bytes of EOF for every file (PLANES2: 11) [verified].

## LZW (`func_0000_88D4`, `func_0000_8983`)
- Dictionary: 0x800 entries x 3 bytes at ds:7420 (`word prefix`, `byte char`). Reset (`88D4`):
  all prefixes = FFFFh, char[i]=i for i<256 (chars >= 0x100 are *not* cleared), width 9 (`[8d74]`),
  mask 1FFh (`[8d76]`), next code 100h (`[8d78]`/DX).
- **No clear code, no stop code.** Codes 100h.. are all data entries.
- Per code: `code = bits & mask`. If `code >= next` (KwKwK): emit `old` string + its first char.
  Walk prefix chain pushing chars (output stack at ds:..8F81 via SP switch), first char saved in `[8d80]`.
- An entry `(prefix=old, char=first)` is added at `next` for **every** code, including the first one after
  a reset (where `old` = last code before reset; initial `old` `[8d7e]` = 0). So the encoder's first real
  entry lands at 101h - mirror this exactly.
- `next++`; if `next > mask`: width++, `mask = mask*2+1` (`0:8A10`). If `width > maxbits` -> full reset (`0:8A22`).
- `old = code` (or `next` in the KwKwK case: `mov cx,dx` @`0:89D7`).

## RLE (`func_0000_890A`, applied to LZW output)
- byte `!= 90h`: output it, remember as `last` (`[8d73]`).
- `90h 00`: literal 90h (also becomes `last`).
- `90h n` (n>0): output `last` n-1 more times (run of n total including the earlier byte).
- RLE state `[8d72]/[8d73]` persists across rows; rows are one continuous stream of 64000 pixels.

## .PAL
- 768 bytes = 256 x (R,G,B), 6-bit VGA DAC values (0..63). Set via `func_0000_8364` -> `func_0000_8378`
  (direct port 3C8h/3C9h writes after vertical retrace, or INT 10h AX=1012h stub at `0:8352`).
- `PALETTES.PAL` = 9 x 768 (6912 = 0x1B00) bytes, loaded once by `func_0000_73CE` (`0:74A6`) into far `[d092]:[d094]`.
  `func_0000_826C(n)` = `set_pal`: copies `PALETTES.PAL[min(n,8)]` to ds:64E3 (current DAC image).
- `func_0000_3641(idx)` uses `n = idx` => palettes 0..7 belong to air_id, armsscrn, brefscrn, folder1,
  hangscrn, homescrn, ordrscrn, rostscrn; every later index (e.g. climbin, 0x20) gets palette 8.
- Explicit calls: `826C(2)` after brefscrn + theatre map (`0:0F8E`, `0:24BB`); `826C(3)` before folder2 (`0:2219`).
- `adv.pal` (ds:0EE5): `func_0000_7611` (exit-to-DOS "advert" screen) loads `adv` (idx 0x1F) and reads
  ADV.PAL straight into ds:64E3 with `func_0000_289A` (DOS read 0x300). Other per-file .PALs
  (AWARDS, CEMETARY, DESK, ...) are not referenced by START (END/VGAME (?)).
- Sprite sheets have no palette; they use the palette of the screen that loads them. pic.py's `--all`
  applies: same-name .PAL > START palette index (table above / sheet->screen map in pic.py) > PALETTES.PAL[0].

## START name table (ds:0CBA, index -> file)
0 air_id, 1 armsscrn, 2 brefscrn, 3 folder1, 4 hangscrn, 5 homescrn, 6 ordrscrn, 7 rostscrn, 8 breficon,
9 folder2, 10 ordrsprt, 11 requestr, 12 rostsprt, 13 weapons1, 14 weapons2, 15 weapons3, 16 libya,
17 persian, 18 n_cape, 19 c_europe, 20 vietnam, 21 mid_east, 22 kuwait, 23 cuba, 24 korea, 25-29 planes1-5,
30 hangsprt, 31 adv, 32 climbin. Theatre maps are `16 + [campaign+0x38]` (`0:0F7D`, `0:248F`).
Not loaded by START: 256*.PIC, AWARDS, CEMETARY, DESK, ENDHANGR, FLAG, FLIGHT, LANDED1-4, MEDALS,
ORDNANCE, RESCUE, SWAP, TASS.

## Sprite-sheet indexing (blits from `0A95:6A8A`, args `src,sx,sy,dst,dx,dy,w,h`)
- **PLANES1-5** (page 4, aircraft-ID quiz, `0:057E`..): `r = rand(20)`, file `planes[r>>2]`,
  cell `sx = (r&1)*160`, `sy = ((r&2)>>1)*79`, size 150x79 -> page1 (146,48). 4 cells/file, 20 aircraft. [verified visually]
- **WEAPONS1/2** (pages 3/4, arms screen `func_0000_07EE`/`0963`): weapon `i` 0..19; `i>9` -> page 4, `i-=10`;
  `sx = ds:0232[i]` (0,0,0,0,0,160x5), `sy = ds:0246[i]` (0,40,80,120,160 x2), size 160x40 -> (0x3F,0x88) (`0:0C73`).
- **WEAPONS3** (page 2): name strips 58x6 at `sx = 204` (weapons1 set) / `262` (weapons2 set), `sy = 80+12*i` and `+6` (`0:0CB1`);
  red frames 55x36 at `sx = 210+(n&1)*55`, `sy = (n>>1)*36` and icons 51x32 at `sx = (k/6)*51`, `sy = (k%6)*32` (`func_0000_0D65`). [verified visually]
- **HANGSPRT** (page 3, hangar callback `0:0311`, `func_0000_0448`): 12-byte records `{sx,sy,dx,dy,w,h}` (int16)
  at ds:006A (13 records, door-opening frames, all dy=108 h=92) and ds:0106 (4 records, 73-wide, dy=0);
  frame order byte list ds:0136 (18 entries, FFh = skip).
- **ORDRSPRT** (page 4, orders screen): `func_0000_28CE(src_page=4, recs=ds:10E0, seq, period)` +
  `func_0000_2901` animate: `seq` = byte pairs `(first_record, count)` (ds:10C0 forward, ds:10D2 reverse (?)),
  records 12 bytes `{sx,sy,dx,dy,w,h}` at ds:10E0.
- **BREFICON, FOLDER2, REQUESTR, ROSTSPRT**: loaded (`0:20E6`/`0:2253` folder2/folder1 page 4, `0:09E0` requestr page 2,
  `0:616C` rostsprt page 4, `0:5A9A` ordrsprt) but their cell tables were not catalogued yet.

## Decode status [verified]
All 52 .PIC files decode to 320x200 with no errors; viewed: 256PIT, ADV, HOMESCRN (pal 5), CLIMBIN (pal 8),
BREFICON (pal 2), PLANES1, WEAPONS3, HANGSPRT - all correct images/colours.
256*.PIC (cockpit) palette unknown (not in START; shown with PALETTES.PAL[0], looks plausible).

## Unknown
- Which program/palette shows 256*.PIC, LANDED2-4, MEDALS, ORDNANCE (VGAME/END (?)).
- Exact cell tables for BREFICON, REQUESTR, ROSTSPRT, FOLDER2; full semantics of the ORDRSPRT sequence bytes.
