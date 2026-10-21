# VGAME assembly modules — fresh listings and calling conventions

Listings: `re/disasm/vgame-asm/<SEG>.asm` (one per segment) and `index.txt` (every entry: size, frame type, callers from
C / from asm, how it was found). Made by `re/tools/vgame_asm.py` with capstone, recursive descent from every far call in
the image, far pointers, the 1377 vtable and a few vector-installed handlers:

```
py -3 re/tools/vgame_asm.py --segs '0FAE,0FB2,1039,104E,1058,1132,114A,11B8,11D8,11ED,120A,130D,1377,1452,14C2' --vtab 1377:0070:24 --seed 1132:006C:isr --seed 0FB2:04DD:isr --seed 0FB2:084E:isr --seed 120A:0971:isr --seed 11D8:0000:exit --seed 130D:0214:jmp --seed 104E:0016 --seed 104E:0025 --seed 104E:0057
py -3 re/tools/vgame_asm.py --range 0000:6B0B 0xD3        # linear disassembly of a code island
```

Coverage is 97–100 % of every module (the rest is data: 1058 HUD tables, 0FB2/130D/1377 scratch, 1452 nothing).
These listings replace the broken parts of `VGAME.asm` for segments ≠ 0000. Function names stay `func_SEG_OFF`.

**Module layout fact.** The paragraph values (0FB2, 1058, …) are the first far-called entry of each module rounded
down to a paragraph, so a module's last few bytes sit at the start of the next "segment": 1452:0000 is the tail of
1377:0CB3, 11ED:0000 the tail of 11D8:00EA, 1377:0000 the tail of 130D, 130D:0000 the tail of 120A:0F97,
11D8:0000..0009 is 11B8's `exit` stub. The tool follows near jumps across the boundary and lists them in the owning module.

**Segment registers.** VGAME runs with SS = DS = DGROUP (1E42): 1132 and 11B8 address DGROUP through SS, 104E reads
stack arguments through SS:[SP+n]. Modules that load ES set it to DGROUP (`push ds / pop es`) or to a page segment;
the C side never relies on ES. Direction flag is always up.

## 1. Calling-convention classes

| class | shape | used by |
|---|---|---|
| **C-far** | `push bp / mov bp,sp` (or `enter`), args at `[bp+6]`, `[bp+8]`… (near-call variants `[bp+4]`…), caller cleans (`add sp,n` / `pop bx`), result AX (DX:AX long), `retf`. SI/DI/ES/DS saved when used. | all entries listed as `bp-frame` in index.txt: 0FAE, 0FB2:0000/01E6/0246/04FE, 114A (all 12), 11B8, 11D8, 120A:0008/00CF/01B4/098C/0EEE, 130D:0116/01BD, 1377:000C/07E8, 1452 (all 21), 14C2 |
| **stack, no frame** | `mov bx,sp` then `ss:[bx+4]`, `ss:[bx+6]`; result AX; clobbers BX, DX | 104E:0000 fmul15r, 0016 fmul15, 0025 fdiv8, 0057 muldiv, 0066 fcos, 0076 fsin |
| **no args** | far entry, no frame; reads/writes DGROUP only; saves what it uses | 1039 (all 7), 1058:000A/000E/0012/0C91/0CB2, 1132:0002/0052, 0FB2:0324 (saves bp,si,di,es), 0FB2:0519/069A (save and call core), 120A:0F97 |
| **register** | arguments in registers, internal to the asm modules; listed per module below | 0FB2 core routines, 104E:0082/0086, 11ED, 120A internals, 130D, 1377 vtable slots, 1452:02AC |
| **driver thunk** | `call far 1E42:xxxx` (T:xxxx, slot = (xxxx-11A)/5) into MGRAPHIC; register protocols in §3 | 0FB2, 1058, 114A, 11D8 |
| **ISR** | `push bp / mov bp,sp` to reach the IRET frame: `[bp+2]` = return IP; INT 0 handlers return a saturated quotient and skip the `idiv` | 0FB2:04DD, 0FB2:084E, 120A:0971 (divide overflow); 1132:006C (INT 9) |

C-far entries that are *also* called from asm (1452:*, 14C2:0000, 0FB2:0246, 130D:0116, 1377:004C/07E8, 120A:098C) are
called the C way: `push` args, `call far`, `add sp,n`.

## 2. Per-module register conventions

### 0FB2 — 2D clipping, span tables, horizon
Globals: line `2299`=x0 `229D`=y0 `229B`=x1 `229F`=y1; clip `2293`=xmax `2295`=ymax (0..max inclusive); span tables
`22A1[y]` left x, `2459[y]` right x (words, 0x1B8 apart); `2615`/`2617` = min/max row touched (empty = -1/0);
clipper scratch `228A` outcode, `228B` dx, `228D` dy, `228F` dx/2, `2291` dy/2 (line) and `261A..2621` (edge);
`2611`/`2613` |dx|,|dy| for the edge rasteriser; horizon `0D1E`/`0D20` screen centre, `0D44` = −sin(roll), `0D46`
ground colour, `0D48` ground/sky toggle, `0D42` x at far edge.

| entry | convention | in | out / effect |
|---|---|---|---|
| 0000 draw_horizon(colour) | C-far | `[bp+6]` byte colour → 0D46 | calls 0012 |
| 0012 horizon_build | reg, no args | 49B6 pitch, 49B8 divisor (≤0x1F0B → 0x3FF), 49BA/49BC sin/cos roll, 4368 zoom shift, 294B halves | line 2299.. = horizon through centre; 0330 clip; CF=1 (fully out) → whole viewport in ground colour, or sky 0x78 if pitch<0; else ground side filled via 0555 + 06A6 + T:01D3 then the other side in 0x78 |
| 01E6 fill_polygon(unused, n, pts*, colour) | C-far | `[bp+8]` n, `[bp+A]` DS ptr to n (x,y) word pairs, `[bp+C]` colour byte; `[bp+6]` not read | AH=colour → T:01BA; 051F; each edge → 06A6; T:01D3 AX=2615 CX=2617 BX=22A1 DX=0 |
| 0246 fill_rect(page*, x0, y0, x1, y1) | C-far | `[bp+6]` page struct ({+0 page id, +4 colour}), `[bp+8..E]` | saves draw page (T:016A → AX … T:0165 AX); T:015B AX=page; left[y]=x0, right[y]=x1 for y0..y1; T:01E2 AX=y0 CX=y1 BX=22A1 DX=0 |
| 02B4 | near variant of 0246 with colour at page+6 | — | **dead** (no callers; found by prologue sweep) |
| 0320 | far stub for asm callers | line globals | → 0330, nothing saved (1058:085B saves SI/DI itself) |
| 0324 line_clip_draw() | far, saves bp si di es | line globals | → 0330 |
| 0330 line_clip_core | reg | 2299..229F, 2293/2295 | Cohen–Sutherland (outcodes via 04BC), hooks INT 0 → 04DD during the two `idiv`; accepted: T:01B5 AX=x0 BX=y0 CX=x1 DX=y1, **CF=0**; rejected **CF=1**; clipped endpoints written back; clobbers all GP regs, ES=DGROUP |
| 04BC outcode | reg | BX=x, BP=y | AL: 8=x<0, 1=x>2293, 4=y<0, 2=y>2295; ZF=1 inside |
| 04DD int0 | ISR | `[bp+2]` return IP; 0x46E = the `idiv [228D]` | AX=±0x7F00 (sign from DX xor divisor), DX=0, IP+=4 |
| 04FE fill_spans(pattern) | C-far | `[bp+6]` → DX | T:01D3 AX=2615 CX=2617 BX=22A1 |
| 0519 spans_reset() | far (saves DI) → 051F | — | rows 2615..2617: left←FFFF, right←0; then 2615←FFFF, 2617←0 |
| 0555 border_edge | reg | SI = x (0 → left table, 2293 → right table, anything else: no-op), DI/DX = y range (any order) | clamps y to 0..2295, widens 2615/2617, table[y]=SI; ES=DGROUP |
| 05B3 edge_rasterise | reg (jumped to from 06A6) | accepted edge in 2299..229F | Bresenham; left[y]=min, right[y]=max; widens 2615/2617 |
| 069A add_edge() | far (saves es si di bp) → 06A6 | edge in 2299..229F | clip (INT 0 → 084E), accepted → 05B3; edge entirely left/right of the window → 05A4 → 0555 vertical border edge at x=0 / x=2293; entirely above/below → dropped |
| 084E int0 | ISR | 0x7C8 = the `idiv [261D]` | as 04DD with 261B/261D |

### 1039 — palette manager
All seven entries are far, no arguments, no frame; 011A returns AL. Register use is internal (CX counts, SI/DI table
pointers, ES=DGROUP); all state is in DGROUP (see vgame-map.md §4). Call 14C2:0000 the C way.

### 104E — fixed point and fast sin/cos
| entry | convention | detail |
|---|---|---|
| 0000 fmul15r(a,b) | stack, no frame: `ss:[sp+4]`,`[sp+6]` | AX = (a*b)>>15 rounded; clobbers BX DX |
| 0016 fmul15(a,b) / 0025 fdiv8(a,b) / 0057 muldiv(a,b,c) | same | truncating; (a<<8)/b saturating ±7FFF (0025); a*b/c (0057). No callers found for these three (dead or via pointer) |
| 0066 fcos(a) / 0076 fsin(a) | stack, no frame | arg → BX (+0x4000 for cos) → 008A → AX |
| 0082 sin_bx / 0086 cos_bx | **register**: BX = angle (0x10000 = 360°) | BX = sin (Q15); clobbers AX DX; 0086 = `add bx,0x4000` then 008A. 1058 HUD calls 0082 only |
| 008A | reg | BL = fraction, BH = index into DS:2084 (257 words): BX = T[i] + ((T[i+1]-T[i])*frac)>>8 |

### 1058 — HUD symbology + joystick
All three drawing entries are far stubs with no arguments (000A → 0016, 000E → 09D8, 012 → 0A2C). Inside, the module
drives MGRAPHIC with **BP = parameter block** (0x16-byte blocks at 284C, 2862, 2878, 288E, 28A4, 28AA, 28C2, 28C8, 28E0,
28E6, 28FE, 2904; word +0 = page flag from T:01FB, +4 colour, +6 x, +8 y, … copied in by 09D8/0A2C) and **BX = data
pointer** (glyph/number descriptors 296C/2972/2976/297A, heading-tape string 2AAA+n, ladder block 2C8C). DI = loop
index (saved around thunk calls by push/pop), SI = tape selector for T:0151. Geometry constants live in 291C..2948 and are
rewritten by 0A2C for normal/large HUD (294B). The ladder rotates its 5 rungs with 104E:0082 (BX = −roll, −roll+0x4000)
and draws them with 0FB2:0320 after writing 2299..229F directly (clip set to the HUD window: 2293/2295 saved/restored
around it, T:01A1 origin, T:0197 reset).

| entry | convention | detail |
|---|---|---|
| 0C91 joy_center() | far, no args | 0CC1 then 0C9F with SI=0 and SI=2: [si+2CB2]=[si+2CA2]=[si+2CAA]=[si+2CCA] (centre=min=max=raw) |
| 0CB2 joy_read() | far, no args | 0CC1 then 0D09 with SI=0 (X) and SI=1 (Y) |
| 0CC1 joy_raw | reg, saves all | port 0x201 timing loop, BX=3 axis mask; raw counts → 2CCA (X), 2CCC (Y); 0xFFFF on timeout |
| 0D09 joy_scale | reg: SI = axis (0/1) | updates min 2CA2+2si / max 2CAA+2si, range 2CBA, centre 2CB2; result byte 2CD2+si, 0x80 = centre |
| 0D7A joy_cal_save(far*) / 0D8C joy_cal_load(far*) | C-far, `[bp+6]` off `[bp+8]` seg | 0x14 words at 2CA2 |

### 1132 — keyboard INT 9 hook
0002 install / 0052 remove: far, no args, save DS; DGROUP reached through SS. 006C is the ISR: reads port 0x60, skips
E0/E1 prefixes (2CDD), ignores keys while Shift xor NumLock, maps scancodes 0x29..0x51 through DS:2CDE to a direction
mask, one key held at a time (2CD8), re-press within 5 BIOS ticks (2CD9) gives full deflection ±0x7F else ±0x5A into
2CD6 (X) / 2CD7 (Y) (0x80 = centre; release recentres), then removes duplicate keystrokes from the BIOS ring buffer
(0040:001A/001C/0080/0082) and chains to the saved vector at cs:0181.

### 114A — C-callable drawing helpers
All C-far (see vgame-map.md §4 for arguments). Internally they push arguments and call 0FB2:0246, T:01EC, T:0250/019C,
104E:0000 the C way with `pop bx`/`mov sp,bp` cleanup. 014F calls 0070 with `push cs / call` (a near call that looks far)
so 0070 must stay `retf`. No register conventions.

### 11B8 — DOS file I/O
C-far: 0008 fopen(name*, mode), 0066 fcreate(name*, attr), 00C4 fclose(h), 00EC fread(h, n, buf*), 011E fread_far(h, n,
off, seg), 0174 refill(h), 0195 fwrite_far(h, n, off, seg, extra). Each reloads DS=DGROUP then DS=SS for the near
pointer. **0153 refill_buffer**: far, register convention, no args: reads 0x200 bytes from handle 4662 into DS:43F8
(callers 11ED). Errors: 01CD (name + message) / 01E8 (message [+ error code digit]) print with INT 21h/09 after INT 10h
mode 3 and terminate through 11D8:0000 (`mov ah,9; int 21h; mov ax,4C00h; int 21h`). Message strings: 45F8 "File not
found", 4608 "No file buffers", 4623 "Open error", 4630 close, 4643 read, 464E write.

### 11D8 + 11ED — PIC loader
| entry | convention | detail |
|---|---|---|
| 11D8:000A pic_decode(handle, page) | C-far | 4662=handle, 4666=page → T:0232 SI=page (ES := page seg), T:0241 clear; per row (466C, 200 rows: 4664 counts 0xFA00 down by 0x140): T:023C DI=row → AX=row offset (4668); 11ED:0006; T:0219 with DI=row offset, BP=9546 (row buffer), BX=row; T:0223 hook |
| 11D8:007F / 00EA | C-far, same args | variants writing to ES=`[bp+8]` directly with hooks T:022D and T:021E/0228; no callers found |
| 11D8:0155 | near, `ret` only | empty init hook (= 11ED:0005) |
| 11ED:0006 lzw_row() | far, **register**: DI = row index from the caller (DI>>1 == 0 → header read + dictionary reset 0030; i.e. rows 0 and 1 (?)), saves ES only | ES=DS; SI = 43F8 + 4660 (input position, 0x200 = buffer empty → 11B8:0153 refill); output DS:9546, count 968A = 0x140 bytes (halved in nibble mode); 4660 updated |
| 11ED:0030 header | reg | first word → 9694 bit buffer; AL<0 → nibble mode off (9697=0) and |AL| = max code width 968F; else nibble mode (2 pixels per byte, low nibble first) |
| 11ED:0078 dict_reset | reg | width 968E=9, mask 9690=0x1FF, next code 9692=0x100, dictionary DS:C6B4 (3 bytes per entry: prefix word, suffix byte), prefixes ← FFFF, suffix[i]=i |
| 11ED:00AE decode_row | reg | **switches SP to a private stack at DS:989B** and pushes decoded bytes on it; 0127 pops them back (returns via `jmp bp`); RLE layer on top: byte 0x90 escapes — 0x90,0 = literal 0x90, 0x90,n = repeat previous byte n-1 times (968C/968D); KwKwK handled with 9698/969A; width grows when next code > mask, dictionary reset when width > 968F |

The format is the one in `format-pic.md` [verified by re/tools/pic.py]; this is the reference for the in-game decoder.

### 120A — 3D object renderer
C-far entries: 0008 camera_setup(matrix*, fov), 00CF draw_object(id, x, y, z, a, b), 01B4 test_object(id, x, y, z, a),
098C midpoint(p0: 3 dwords, p1: 3 dwords) (12 words on the stack; results 7D72/7D74, 7D76/7D78 and the near-clipped
copy written back into the caller's frame), 0EEE object_extent(id, out*) (no callers), 0F97 prerotate_grid() (no args).
Throughout the module **ES = object database segment [8590]** and **SI = read cursor into the object stream (es:[si])**.

| routine | in | out |
|---|---|---|
| 02B2 sphere_cull | AX = radius | AX=0/ZF=1 visible, AX=FFFF culled (uses 7CDC z, 7D5E scale, 7CD2/7CD6 x,y) |
| 0317 sub_objects | CX = count (→7D58); es:[si] = per-sub-object {angle index byte, mode byte} | matrices 7B4C+0x24·i via 1452:03AB/0288/02E4; angle from table [7D4E]; position copies 7CDE..; 7D50 = current matrix |
| 043C transform_pivot | ES:SI = vertex (3 words), BX = out, DI = matrix | rotates by [7D50] (1452:0330), 32-bit position into [7D56] |
| 04C9 / 04F5 | DI = matrix | rotate 7D84.. / 7C9C.. by 1452:021B into [7D7C] |
| 0561 transform_vertices | ES:SI = vertex list, count word first (→7D5A; negative = BSP object) | per vertex 10 bytes (nx,ny,nz plane normal, 2-word constant): visibility byte 7702[i] (bit7 = front-facing), 7802[i] = depth/shade via 0674; markers 0x80xx select sub-matrix (0540), 0x8100 = conditional on [7D4E] table (051D); 7A02[] face flags (0654 clears); then per face a byte count + index list; BSP objects → 0E5B builds 7902 |
| 0674 | DI = vertex index, BX = [7D7C] matrix | 7802[di] = (normal·view)>>14 byte |
| 06B5 project_all | 7D5C = vertex count (negative = grid object: 075A uses 4EE6 prerotated cache + 7CD2 offset) | 0815: ES:SI vertex (x,y,z words) × matrix [BX] + position → 32-bit at DI (C6B4+16i); 0902 projects DI → BX (D6B4+8i): sx = x/z, sy = y/z as dwords, z<1 → hi word 0x8000 (behind), 7D8E≠0 → fixed shift instead of divide; INT 0 → 0971 saturates |
| 0A33 edges | es:[si] = count, then (v0,v1) byte pairs | per edge 0B3B: 32-bit segment at BP = 5EEA+0x18·i (+0 x0 +4 y0 +8 x1 +C y1 dwords, +10/+14 clipped copy, hi word of +2 doubles as status) with 8602/8604 screen centre added; behind-camera endpoints → 098C midpoint subdivision; 130D:033F clip |
| 0C76 faces | 7D5A count (0 → one face; <0 → BSP list 7902) | 0CA8: skip unless 7702[bx] > 0x7F; 7D8A = shade; SI = es:[si+2bx] face stream → 0CE9 |
| 0CE9 face_interp | ES:SI = face stream | byte: 0xFF end; bit7 → compare next byte with table [7D4E][al&0x7F], skip block if unequal; bit5 → point list (count, colour, indices) — **the pixel call was compiled out** (pushes then `add sp,6`; 0DAB..0DF9 is the dead old body); bit6 → line list: colour byte → [7D80] table → AX → 1377:004C, each index → segment 5EEA+24i → 1377:0055 unless flag 0x80; else polygon: count, indices → 130D:004A (SI = segment), then colour byte → [7D80] → push → 130D:0116 |
| 0E5B bsp_order | ES:SI = tree stream, BX = 7702 (plane flags), DI = 7902 out | emits face indices (bit7 set) front-to-back by the sign of each node's plane flag; terminator 0xFF |
| 0971 int0 | ISR, skips 3 bytes (`idiv cx` + `cdq`) | saturated quotient in DX:AX |

### 130D — 32-bit line/polygon clipping
Clip window (same units as 1377): `85FA` xmin `85FC` ymin `85FE` xmax `8600` ymax. Segment struct as in 120A (16 bytes
of dwords + 8-byte clipped copy; after clipping the high word of x0 (+2) holds the status: 0 ok 16-bit, 0x4040 subdivided,
0x8080 rejected, 0x85/0x8A edge-touching cases; low bits = outcodes). Scratch: 85DC/85DE dx,dy; 85E0 bisection counter;
85E2 flag accumulator; 85E4..85EA y-extent of edges clipped at xmin/xmax; 85EC any-edge flag; 85EE count of 0x40 edges;
85F0 overflow; 85F1 saved outcode; 8598..85B7 two working copies; 85B8/85C0 saved endpoints for the closing edge.

| routine | in | out |
|---|---|---|
| 004A add_edge | far, **SI = segment** | 85E2 \|= flags; flag 0x40 → 00EC saves endpoint; unless 0x80: 85EC\|=4, 1377:072B (SI), then per outcode bits 00B6/00D1 widen 85E4..85EA with BX,CX = the clipped endpoint's y |
| 0116 polygon_emit(colour) | C-far, `[bp+6]` (also in AX) | 1377:004C set colour; if 85EE==2 add the closing edge (033F + 004A on 85B8); 0191/01A7 → 1377:07E8(y0,y1,x) close spans at xmax+1 / xmin−1 when edges were clipped there; 1377:005E fill; reset accumulators (85E4/85E8=7FFF, 85E6/85EA=8001, 85E2/85EC/85EE=0) |
| 01BD line3d(x0,y0,x1,y1,colour) | C-far, no callers | builds a segment at 5EEA, 033F, 0205 |
| 0205 draw_if_visible | far, SI = segment | 1377:0055 unless flag 0x80 |
| 033F clip_segment | far, **SI = segment** | all four hi words sign-extensions → 0471 16-bit path (outcodes 02DD: BX=x CX=y → AL bits 4=x<xmin 8=x>xmax 1=y<ymin 2=y>ymax; 0217/0271 compute the intersections with 85DC/85DE); else 32-bit: 0671 (DX:AX, CX:BX → BP outcode, ZF inside), one end inside → 0577 bisection, both outside different sides → 04FB bisection; 05E5 clamps and writes flags; result written into the segment, status in +2 |
| 0271 clip_point | AL = outcode of (DX,BP) against the other point (BX,CX) | CF=0: BP,DX = clipped point; CF=1: AL=AH=new outcode (still outside) |
| 04FB / 0577 bisect | SI = inside copy, DI = outside copy (8 bytes: x,y dwords) | up to 0x20 halvings until 0671/064A says the midpoint sits on the window edge |

### 1377 — rasteriser (MCGA path 'M' is the one VGAME uses: `push 0x4D` at main 008F)
000C raster_init(mode) selects a 6-word vtable at cs:0070 (E), 007C (M), 0088 (C), 0094 (T) into `[85F2]`; slots:
+0 row-table init, +2 put_pixel(x,y,colour) (C-far), +4 set_colour(AX), +6 line(SI), +8 fill_spans, +A (same as +8).
Row offset table DS:861C (M: row·320, 200 rows), page segment table 8612/8614, current page `[861A]` (ES for drawing),
colour `8606`, span tables: left `89DC[y]` (empty = 0x7FFF), right `8D9E[y]` (empty = 0x8001), `9160` = topmost row
touched (0x7FFF = none). Dispatchers 004C/0055/005E are far, register-convention wrappers around slots +4/+6/+8;
the 0043 wrapper for slot +2 is dead.

| routine (M) | in | effect |
|---|---|---|
| 01E0 set_colour | AX = colour word | 8606 = AX; AH==0xFF and AL ≥ 0xA0: AL = max(AL − [48C4], AL & 0xF0) (fog within the 16-step ramp); ES=[861A] |
| 0287 put_pixel(x,y,colour) | C-far | clipped to 85FA..8600; byte at 861C[y]+x |
| 046F line | SI = 16-bit segment (+0 x0 +4 y0 +8 x1 +C y1), colour 8606 | Bresenham, unclipped (caller clips) |
| 072B edge_to_spans | SI = 16-bit segment | sorts by x, y must be inside 85FC..8600 else nothing; 9160 = min y; left[y]=min x, right[y]=max x along the edge (both tables get every pixel so thin polygons still fill) |
| 07E8 hspan(y0,y1,x) | C-far | rows y0..y1 (clipped to 85FC..8600): left=min(x), right=max(x); 9160 updated |
| 0B09 fill_spans | colour 8606 | rows from 9160 downwards (increasing y) **until the first empty row** (so polygons must be row-contiguous), each row clipped to 85FA..85FE, then the row is reset. Colour high byte: < 0xFB → solid 2-byte pattern AH:AL swapped by row parity (checkerboard dither when AH≠AL; AH==0xFF → solid AL); 0xFE → AND mask AL (0A09); 0xFD → OR mask (0A89); 0xFC → every other pixel (099F); 0xFB → discard spans (096B) |
| 01A7 set_page(n) | C-far, no callers | 85F6=n, 861A = [8612+2n] |
| 00A0 dos_alloc_max(min) | C-far, no callers | INT 21h/48 |

EGA/CGA/Tandy variants (00F3, 0246, 01BD, 037B, 0846/0886, 0517, 0619, 0BC5, 0CB3…) are present but unreachable in the
VGA build; they are not needed for the port.

### 1452 — 3D math (tables in 14D1, see vgame-map.md §4)
Every entry is C-far with stack arguments; asm callers (120A, 130D) push and `add sp,n` like C. Angles are 16-bit with
0x10000 = 360°, values Q15. 0006 sin, 0033 cos, 0063 atan2(y,x) (octant table DS:91A8 + 14D1:1000), 00DB v·sin(a) /
011C v·cos(a) (no callers), 0160 asin, 0190 hypot2, 01E2 hypot3 (falls back to |c|/2+hypot2 on overflow), 021B
vec_rot(v*, m*) in place (out[j] = Σᵢ m[3i+j]·v[i]), 0288 mat_mul(a*,b*,out*) (02AC: SI row, BX matrix, DI out — the
only register routine), 02E4 transpose, 0316 copy, 0330 vec_mul32(v*, m*, out*) (three dword sums, no shift), 03AB
mat_from_euler(a1,a2,a3,out*) (sin/cos cached at 919C..91A6; note argument order: `[bp+6]`→919C/E, `[bp+A]`→91A4/6,
`[bp+8]`→91A0/2), 04D9 euler_from_mat(m*,o1*,o2*,o3*) (no callers), 0544 mulQ15, 0556 safe muldiv, 0591 sat_div(lo,hi,c),
05C8 imul → DX:AX, 05D3 mat_from_euler (other axis order, no callers).

### 14C2 — DAC
0000 dac_set(first, count, far rgb*) and 00B7 dac_read_all(far*): C-far, also called the C way from 1039.

## 3. MGRAPHIC thunk register protocols seen from the asm modules

| thunk | protocol (as called) |
|---|---|
| T:011F/0124/0129/012E/0138 | BP = parameter block, BX = data pointer (glyph / number / string / ladder), SI/DI preserved by the caller |
| T:0151 | SI = tape (0 airspeed, 2 altitude), BX = position, CL = large-HUD flag, DL = digit |
| T:0174 | BP = opaque-blit block |
| T:015B | AX = page id; T:0165 AX = page seg; T:016A → AX current draw page |
| T:01A1 | AX = origin offset; T:01AB → AX default origin; T:0197 reset origin (no args); T:01FB → AX visible-page flag |
| T:01B5 | AX=x0 BX=y0 CX=x1 DX=y1 line in current colour |
| T:01BA | AH = colour |
| T:01D3 / T:01E2 | AX = first row, CX = last row, BX = left table (right = BX+0x1B8), DX = pattern (01E2: DX=0) |
| T:0219 | SS:BP = 320-byte row buffer (9546), DI = row offset, BX = row; T:0223/0228/022D row hooks (no args); T:0232 SI = page → ES; T:023C DI = row → AX offset; T:0241 clear ES page |
| T:0250 / T:019C / T:01EC | stack arguments (C style) |

## 4. Segment 0000 code islands (task 0.3c) — all resolved with `--range`

| island | what it is |
|---|---|
| 0CDD..0CF2 | `load_error(msg)`: text_draw(msg, 0, 0x60, 0x0F) then `mov sp,bp; call 0000:EBEA` — EBEA is a second entry of the runtime's exit routine (`mov dh,8` then the body at EBEC: onexit table 9406/9408 (?), then DOS terminate), so the function never returns; the `leave; ret` at 0CF1 is dead. 0CF3 is `set_ext(name, ext)` as already mapped. |
| 2025..2044 | ordinary code inside 1EB0's key handler (the '0' key path): `if ([C0CE] != 0 && [2E0A] == 100) { [B07E] = 0x546; sfx(0x11, 2); }` — on a carrier deck (runway elevation C0CE ≠ 0) at 100 % throttle the key sets speed to 1350 and plays sound 0x11: the catapult launch. 2045.. is the next key (toggle 294B large HUD + 1058:0012). |
| 6B0B..6BDD | continuation of missile steering in 683E (locals: `[bp-1E]` missile slot, `[bp-10]` distance, `[bp-34]` target alt, `[bp-12]` weapon index, `[bp-8]` desired pitch, `[bp-26]` pitch command). Pseudo-C: `m.heading += turn / fps[368E]; m.roll = [bp-1C]*2; if (slot<8 && dist<0x400) dz = (tgtAlt − m.alt)>>4; else { k = |dist|>0x140 ? |dist|>>3 : 0; dz = ((tgtAlt − m.alt)>>5) + k; } want = atan2(dz, |dist|) (C702); cmd = want − m.pitch; if (slot<8) cmd = clampw(cmd, −(skill+1)<<9, (skill+1)<<9);   /* skill = [3686] */ rate = weapon[idx].turn (byte 3394+idx*0x12+0xE) << 8; cmd = clampw(cmd, −rate, rate); m.pitch += cmd*4 / fps; goto 6C05`. Missile fields: 3C3E alt, 3C42 heading, 3C44 pitch, 3C46 roll (stride 0x1C). |
| E447..E449, E4B6..E512 | the frustum test of `transform_and_cull` E3BF, fully decoded: after the far (48E6) and near (48F6[49AA]) z tests, path A ([438E] ≠ 0): limits from tables 4966/4976 indexed by size class — `lim = (|z| + T[i]) >> 3; cull if |x| ≥ lim + lim/8 + lim/16` and `limy = (|z| + U[i]) >> 2; cull if |y| ≥ limy + limy/8`; path B ([438E] == 0): tables at [E56A]/[E570] (viewport perspective tables), `lim = (|z| + T[i]) >> cl` with `cl = [294B] ^ 1`, `cull if |x| > lim + lim/4`; `limy = (|z| + U[i]) >> cl`, narrowed to `limy*9/16` when [368C] ≠ 0, `cull if |y| > limy`; then `[49A8] = (|x| + |y|)>>2 + |z|` (approximate distance; path A uses limy in place of |x|) and cull if > [48E6]. |x|,|y|,|z| are the high words of the 32-bit camera coordinates. Return AX=0 (ZF=1) visible, AX=1 culled. |

## 5. Corrections to vgame-map.md §4 made by these listings
- 130D: the first entry is 004A; `line3d` is 130D:01BD (no callers), 0205 is `draw_if_visible(SI)`, 0116 is
  `polygon_emit(colour)`; 130D:000E does not exist (it is the tail of 120A:0F97).
- 1377: vtable slots are +0 init, +2 put_pixel, +4 set_colour, +6 line, +8/+A fill_spans; 0043/004C/0055/005E/0067 are
  the slot wrappers (0043 and 0067 dead); 072B/07E8 as above; "0B09 fill polygon spans" pattern codes corrected (FB..FF).
- 0FB2: 02B4 is dead; 0330 returns CF; 0555 only writes for x == 0 or x == xmax.
- 104E:0016/0025/0057 have no callers.
- 11D8:0155 is an empty hook; 11ED's decoder uses a private stack at DS:989B.
