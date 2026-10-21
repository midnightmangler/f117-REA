# 3D / world data: 3DX, 3DG, 3DT, WLD (and the "temp.wld"/"regn.xxx" hand-over)

Tool: `re/tools/world.py FILE... [--render N]` -> `re/out/world/<FILE>.txt` (+ PNG of 3DX object N).
All 11 3DX files parse with every LOD block ending exactly at another block/object start [verified].
Regions (index = options field `+38`, tables VGAME ds:0090 / START ds:0D6A):
0 LB Libya, 1 PG Persian Gulf, 2 NC North Cape, 3 CE Central Europe, 4 VN Vietnam, 5 ME Middle East,
6 KU Desert Storm, 7 CU Cuba, 8 KO Korea (names: START ds:9ABE).

## 1. Who loads what

| file | START (mission map) | VGAME (flight) |
|---|---|---|
| XX.WLD | `func_0000_54BB` (called by `func_0000_5466`) | never from disk: copied from shared memory block, `func_0000_4D5D` |
| XX.3DG | `func_0000_7D71` -> ds:BAA0/B9A0/B7A0/B5A0/B3A0 | `func_0000_0C38` |
| XX.3DT | `func_0000_7E88` (checks magic, counts <= 0x20) | `func_0000_0B05` |
| XX.3DX | - | `func_0000_09A0` -> seg [B78C] (bank 1) |
| PHOTO.3DX | - | `func_0000_09A0` @0A36 -> seg [B78E] (bank 2) |
| STFLT.3DX | - | `func_0000_BAA2` -> seg [B78A] (bank 0) |

`func_0000_0986` = region_load(): 3DG, 3DX, 3DT in that order. File I/O: `func_0000_E586` = load whole
file, returns paragraph; `func_0000_EA1C/EA30/E946` = fopen/fread/fclose; `func_0000_0CF3` = replace
extension after the '.'.

## 2. Shape codes (used by WLD, 3DT and the game)

`code = bank<<8 | index`, bit 15 = extra flag (`func_0000_E2B6` @E2D3). Segment table ds:B78A
(`[B78A + bank*2]`): bank 0 STFLT.3DX, 1 region XX.3DX, 2 PHOTO.3DX. Per-object attribute byte
table pointer at ds:0A60+bank*2 = 0760 / 07E0 / 0860 (attr `&7` -> [49AA], E2F4; bit 0x10 tested @10CA;
meaning (?)). `func_0000_C436` remaps bank-1 codes through word table ds:0510 (`[510+2i]=0x100+i`, filled
@0A30); the primary/secondary photo targets append entries `0x200|photo_idx` (@0A92-0ADE), and region 6
(KU) patches slots 5 and 0x59 to PHOTO objects 0x0A and 0x0D (@0ADF-0B00).

## 3. 3DX (shape library)  [verified by full parse + renders]

Header (`func_0000_09A0`, `func_120A_00CF`):

| off | size | field |
|---|---|---|
| 0 | u16 | N objects ([0610]) |
| 2 | u16[N+1] | object offsets (absolute in file). `off[N]` = "vector table" (u16 count + count*6 bytes; `func_120A_0F97`); count = 0 in all shipped files |
| 4+2N | u8[N] | attribute bytes -> ds:07E0 and ds:0960 (bank 1); 0860 (photo); 0760 (stflt) |
| 4+3N | ... | object data |

Object = LOD list of `(u16 maxdepth, u16 block_offset)` pairs; the renderer takes the first pair whose
`maxdepth >= |view depth hi-word|` ([7CDC], 120A:0131-013F). Last pair has maxdepth 0x8001 (= infinity).
LOD blocks are shared between objects (e.g. CE objects 1,2,57,61 all fall back to block 0122).

LOD block (walk order of `func_120A_00CF`; sub-routines at 120A:0317, 0561, 06B5, 0A33, 0C76):

| field | size | read at | notes |
|---|---|---|---|
| radius | u16 | 0143 / 02B2 | bounding radius for frustum test; also "too far" test |
| nparts | s16 | 0168 | part 0 = whole object (caller's orientation) |
| part anim | 2*(nparts-1) | 0355 | per extra part: anim-slot byte (index into caller word table [7D4E]), axis byte (1 / <1 / >1) |
| part pivot | 6*(nparts-1) | 043C+0402 | s16 x,y,z |
| nverts | s16 | 0171 -> [7D5C] | <0: |n| bytes = indices into vector table (075A) (unused in data) |
| nplanes | s16 | 0561 -> [7D5A] | <0: planes + BSP order table follows |
| planes | 10 each | 0589 | s16 nx,ny,nz (1.0 = 0x4000), s32 d. Visible if `n.eye+d >= 0` (sign -> [7702+i]); all-zero plane = always visible (05DC). Prefix words not counted: `0x80kk` = following planes use part k (0540); `0x8100,slot,val` = hide following planes unless anim[slot]==val (051D) |
| vertex-use lists | per plane: u8 n, n*u8 | 0612 | vertices needed when that plane is visible (flags [7A02]) |
| BSP table | 2*|n|+1 bytes | 063C -> 0E5B | only if nplanes<0; produces draw order list [7902] |
| vertices | 6 each | 072C | s16 x,y,z; words 0x8000-0x800F in the stream = "following vertices belong to part k" (2 bytes, not counted) |
| edges | u16 n, n*u16 | 0A37 | lo byte = v0, hi byte = v1 |
| draw lists | | 0C76 | nplanes==0: one list inline; else u16[|nplanes|] offsets (absolute) of one list per plane, run only if the plane is visible |

Draw list bytes (`120A:0CE9`), terminated by 0xFF:

| first byte | meaning |
|---|---|
| 0x00-0x1F = n | polygon: n edge indices, then colour byte; colour 0xFF = skipped (0D0E). Fill via `func_130D_0116` |
| 0x20-0x3F | dots: n=b&0x1F, colour, n vertex indices (draw call removed in this build, 0E46-0E4D) |
| 0x40-0x5F | lines: n=b&0x1F, colour, n edge indices (`1377:004C` set colour, `1377:0055` line) |
| 0x80-0xFF | conditional: slot=b&0x7F, s8 value; if anim[slot]!=value the next command (size (b&0x1F)+1) is skipped |

Colour byte -> word table at [7D80] = ds:7F90 or ds:8390 (selected in `func_0000_03CE` @041A by [990E]==3);
both are identity (`lo=index, hi=FF`) except a few remapped entries (0x22,0x26,0x31-0x39), i.e. colour =
VGA palette index (?: hi byte meaning).

Units/axes: +Y is up (objects stand on y=0; ground patches have normal (0,0x4000,0)) [verified by
renders: CE obj 77 tank, obj 33 SA-missile launcher, STFLT obj 0 fighter]. Object units = world units
(ground-patch objects 0-2 span +-2048 = one level-1 cell, see 3DT) (?).

Counts: CE 94, CU 106, KO 105, KU 115, LB 99, ME 96, NC 94, PG 100, VN 100, PHOTO 37, STFLT 43 objects.
Multi-part objects: 1-5 per file (CE: 38 SAM radar, 56, 65 windmill, 66).

### CE.3DX objects

Names are the WLD string-pool entry with the same index (VGAME `func_0000_4B06` names a world object by
`strings[shape&0x7F]`); proven for shapes placed in CE.WLD (*), visually checked (v), else (?) - slots 1-19,
22-27, 31-32, 34-37, 41-48, 50-52, 54-56, 63-64, 66-67, 69 carry city names (pool shared) and are terrain
props placed by 3DT. Columns: attr, #LODs, LOD0 radius/verts/polys, 3DT levels using it.

| # | attr | LODs | r/v/p | 3DT | name | | # | attr | LODs | r/v/p | 3DT | name |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
|0|07|1|2896/4/1|4|ground patch| |47|05|1|724/6/2|1| |
|1|07|2|2896/12/6|4|ground patch| |48|05|1|724/5/2|1| |
|2|07|2|2896/9/5|4|ground patch| |49|A4|1|320/52/25|1|Bridge (?)|
|3|95|2|680/9/8|4| | |50|85|1|320/32/12|-| |
|4|95|2|546/7/7|4| | |51|84|1|323/6/2|-| |
|5|07|1|2048/7/0|2,3|(lines only)| |52|00|1|0/1/0|-|dot|
|6|07|1|2048/6/0|2,3|(lines only)| |53|84|3|256/66/39|1|Patrol Boat *|
|7|06|2|1024/6/1|1,3| | |54|84|1|256/11/4|-| |
|8|06|2|1448/6/1|1,3| | |55|03|1|97/2/0|-| |
|9|06|2|1024/6/1|1,3| | |56|82|1|58/6/2|-|2 parts|
|10|06|3|1448/17/1|3| | |57-61|07|2|2896/..|4|ground patches|
|11-12|06|1|1448|-|(LODs of 10)| |62|A5|1|590/47/30|1|Buildings *|
|13|00|1|0/0/0|-|empty| |63|85|1|572/25/13|-| |
|14-16|04|2|362/8/2|2,3| | |64|83|1|124/9/5|-| |
|17|47|1|2560/7/0|1|(lines)| |65|83|3|134/27/21|1|Windmill (?) 2 parts|
|18-19|95|1|515/6/6|4| | |66|83|1|134/20/10|-|2 parts|
|20|07|1|2896/4/1|4|Army HQ (?)| |67|07|1|2896/20/2|1,2| |
|21|25|4|513/117/38|2|Airbase *| |68|A4|3|362/31/15|1|OTH Radar *|
|22-24|05|1|513|-|(LODs of 21)| |69|84|1|362/17/11|-|(LOD of 68)|
|25|06|2|1448/6/1|1,3| | |70|A6|4|768/66/26|2|Bridge (?)|
|26|A4|3|362/31/16|1| | |71-72|8x|1|-|-|(LODs of 70)|
|27|84|1|341/23/8|-|(LOD of 26)| |73|83|1|143/12/10|-| |
|28|A3|4|143/46/34|1|Depot (?)| |74|04|1|256/10/1|2| |
|29|A6|4|778/45/24|1|Headquarters (?)| |75|86|1|778/27/14|-|(LOD of 29)|
|30|A3|3|101/15/9|1|Tank Farm (?)| |76|A2|3|62/46/32|1|Mobile SAM (?)|
|31-32|8x/03|1|-|-|(LODs of 30/28)| |77|A2|3|69/55/30|1|Tank (v)|
|33|83|3|94/70/39|1|SA Missile (v)| |78|00|1|0/1/0|-|dot|
|34-37|..|1|-|-|LODs/dots| |79|02|2|53/4/1|-| |
|38|83|3|116/19/28|1|SAM Radar * 2 parts| |80,81,83|..|1|-|-|LODs of 76,40,82; 82: 04, 2 LODs, 273/11/1|
|39|A3|3|118/32/26|1|Tower (?)| |84|00|1|0/0/0|1|Airplane (empty)|
|40|A3|4|137/22/11|1|Hangar (?)| |85|00|1|0/0/0|2|POW Camp (empty)|
|41-44|05|1|724/2/0|2,3|(single line)| |86|00|1|0/0/0|1|SS Missile (empty)|
|45-46|05|1|724/4-5/1|1| | |87|A6|4|768/70/28|2|bridge (?)|
| | | | | | | |88-93|..|1|-|-|88 LOD of 87; 89/90 own (95, like 3/4); 91 own 120/25/17; 92/93 ("Special Object 1/2") = LODs of 39/77|

## 4. 3DG (terrain code hierarchy), 1810 bytes  [layout verified: 2+16+256+3*512]

`func_0000_0C38` (VGAME), `func_0000_7D71` (START):

| off | size | VGAME dest | START dest | meaning |
|---|---|---|---|---|
| 0 | u16 | [075E] | [104C] | magic 0x3232 "22" (START rejects otherwise, 7DFC) |
| 2 | 16 | 9F98 (overwritten by next read) | BAA0 | 00..0F in every file; START default = identity (?) |
| 0x12 | 256 | 9F98 | B9A0 | level-3 grid 16x16, `[y*16+x]` |
| 0x112 | 512 | 9D40 | B7A0 | 32 level-2 4x4 patterns |
| 0x312 | 512 | 9B38 | B5A0 | 32 level-1 4x4 patterns |
| 0x512 | 512 | 9934 | B3A0 | 32 level-0 4x4 patterns |

`func_0000_0871(level, x, y)` = terrain code: L4 = ds:B03C[(y+2)*8+(x+2)] (8x8 built into VGAME at
ds:0A68+region*64, copied @0CC2; inner 4x4 = codes 0..15, border 0x10/0x11); L3 = grid[y*16+x];
L2/L1/L0 = pattern[code(L+1, x>>2, y>>2)*16 + (y&3)*4 + (x&3)]. Bounds [0506+2L] = 1024,256,64,16,8.
Cell size (from `func_0000_0810`, world coord >> 12 after scaling): L1 4096, L2 16384, L3 65536
(= WLD>>11, same as the WLD sector grid), L4 262144 world units; L0 = 2048 (? inconsistent with the
x4 pattern nesting).

## 5. 3DT (props per terrain code)  [verified: sizes match exactly for all 9]

`func_0000_0B05` (VGAME), `func_0000_7E88` (START):

| off | size | field |
|---|---|---|
| 0 | u16 | magic 0x3131 "11" ([0612]; START 7EB9) |
| 2 | u16[5] | codes per level (32 each) [0614] |
| 12 | 5 * u16[32] | prop count per (level, code) [061E + L*64] |
| .. | 8 each | props, in level/code order: s16 a, s16 b (horizontal, +-2048 within the cell), s16 h (height, 0/16/32), u16 shape (low byte: bit7 flag, &0x7F = region-3DX index) |

In memory each prop is 7 bytes at ds:A09A, pointer per (level,code) at ds:E330. Placement loop
`func_0000_04C7` region 0517-080E: for level L the code under the viewer is `func_0000_0871`, then every
prop is drawn with `func_0000_E2B6(shape|0x100, 0,0,0, a,b,h)`; flag 0x80 props go through
`func_0000_0FBD` (substitution by world objects (?)). Level 0 is empty in all files; L4 draws only the
first prop (@0725).

## 6. WLD (region map / object database)

File layout (`START func_0000_54BB`; START keeps it in DGROUP):

| off | size | START | VGAME | field |
|---|---|---|---|---|
| 0 | u8,u8 | D88C | DED0, C0D8 | two bank-1 shape indices chosen by side (VGAME 7523/793E, 43E0 adds 0x100) (?) e.g. CE 0x49,0x5B |
| 2 | u16 | D33C | C0E0 | A = number of world objects |
| 4 | u16 | CACE | 992C | count used as loop limit @44BC/515D (?) |
| 6 | u16 | E084 | E56C | count used as loop limit @572C/621D (?) |
| 8 | 16*A | CBDE | B2CE | world objects (below) |
| .. | u16 | D890 | DEFC | B = number of mobile units |
| .. | 36*B | D3BE | C16A | mobile units: +2 x, +4 y (VGAME BA5B), +0x19 bit0 (58A6); all zero in files except a few type/flag words (filled by mission generator) |
| .. | 128 | D7F6 | C630 | per-shape-type flags, index shape&0x7F (bits 0xC0 tested @AA60) |
| .. | 128 | D33E | C0E6 | per-shape-type table (?) |
| .. | 128 | D2A6 | - | START only (?) |
| .. | 256 | CAD8 | B1A0 | 16x16 sector grid, cell = WLD coord>>11; bits &3 -> [49F6] (985C, 9E7D, BA70), &0x0C (55EB), bit0 (AA85) (?) |
| .. | <=750 | DD70 | E016 | string pool, NUL separated; pointer table built at START DC70 / VGAME DF08 (`func_0000_4BEC`), 128 entries |

World object (16 bytes, VGAME B2CE+16*i):

| off | field | evidence |
|---|---|---|
| +0 | u16 name index into string pool (city), 0 = none | 4B2D, 4B9E |
| +2 | u16 x (0..0x7FFF); world X = x<<5 | 4C3F |
| +4 | u16 y; world Z = (0x8000-y)<<5 (y grows southward) | 4C59 |
| +6 | u16 (?) (2..0x15 on SAM/radar sites) | |
| +8 | u16 flags; byte +9 `&5` = not hostile (0x04 friendly, 0x01 neutral) | AA6D |
| +A,+C | u16 (?) zero in files | |
| +E | u16 shape code (bank<<8|idx); type name = strings[idx&0x7F] | 4B0E, 4D29 |

CE.WLD: 75 objects (0-2 empty, SAM radars, OTH radar, patrol boats, airbases, cities "Buildings").

## 7. Region selection ("regn.xxx") and the START -> VGAME hand-over ("temp.wld")

* No `temp.wld` file exists or is written. START `func_0000_0010` pushes ds:0042 "temp.wld" to
  `func_0000_5625`, which never reads its argument; `func_0000_5625` instead copies the WLD image +
  mission data into the shared far block. Other "temp.wld"/"regn.xxx" xrefs (START 0E96, 3CEA, 959E, A520,
  9826; VGAME C8CA, F04A, F3DE) are immediates equal to 0x42 (e.g. DOS AH=42h lseek at F44A).
* Shared block: segment word at 0000:04F0 (BIOS inter-application area), read by START `func_0000_7387`
  ([E096]=blk:0, [CACA]=blk:1272) and VGAME `func_0000_0010` ([E574]=blk:0, [9924]=blk:1272).
* VGAME region choice: `func_0000_00F0` does `strcpy(ds:0042 "regn.xxx", regtab[blk:1272+0x38])`
  (regtab ds:0090 -> "lb.xxx".."ko.xxx"), then `func_0000_0986` swaps the extension to .3dG/.3DX/.3dT.
  Also `[0D47] = byte ds:00EE[region]` (06 06 02 02 02 06 06 02 02) (?).
* blk+0x7A = WLD image in file order minus the START-only 128-byte table, then mission data
  (START `func_0000_5625` writes, VGAME `func_0000_4D5D` reads with [DEBA]=1 at start via `func_0000_4BEC`,
  writes back with [DEBA]=0 in `func_0000_4D45`, which also stores 0x600 bytes from ds:BA56):

| START | VGAME | size | field |
|---|---|---|---|
| D876 | DEB4 | 2 | compared with clock [9912] @41F0/4392/6E8B: time limit (?) |
| CABC | 3D9C | 2 | mobile-unit index or -1 (58AD, 7307) (?) |
| 15B2 | 2E9E | 16 | 4x4 bytes (?) |
| E05E | E304 | 2*18 | primary/secondary target: +0 u16 kind (3/4 tested @41E9/6E84), +2 u16 world-object index (START sets in `func_0000_4239` @42D7/42EE/45CD; VGAME `func_0000_4C73`), +6 flags, +7 u8 PHOTO.3DX object for photo missions (`func_0000_09A0` @0A92) |

* blk+1272 (options/pilot): +00 roster index (x0x50, START 00BF), +20 rank (START 1D78 table),
  +38 region, +3A war level (Cold/Limited/Conventional), +3C mission set (Air/Strike Missions,
  Air/Strike Training), +3E opposition (Green..Elite), +40 landings (No Crashes/Easy/Realistic),
  +42 aircraft (0 MicroProse F117A = 4 bays, 1 Lockheed = 2 bays; VGAME `func_0000_0300` @0314)
  (tables printed by START `func_0000_008D`).
* blk+0 fields: +38..+3E loadout, one weapon id per bay (VGAME `func_0000_0300` @0336: id*0x1A ->
  weapon table ds:36A8, draws ordnance.pic icons); +72 bit0 flag (0010, 0235); +26/+28/+2C/+30
  written by START `func_0000_0010` (+30 = mission set > 1); others (?).
* Not proven here: waypoints (not found in the WLD hand-over; possibly in the 0x600-byte block or the
  mobile-unit records (?)).
