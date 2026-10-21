# MGRAPHIC.EXE - MCGA graphics driver API

Every pixel of the game goes through this overlay. Sources: `re/unpacked/MGRAPHIC.EXE`,
correct listing `re/out/mgraphic/MGRAPHIC_code.asm` (made by `re/tools/mgraphic_disasm.py`),
call-site table `re/out/mgraphic/xref.txt` (`re/tools/mgraphic_xref.py`),
fonts `re/out/mgraphic/font.png` + `fonts.json` (`re/tools/mgraphic_font.py`).

> NOTE: `re/disasm/MGRAPHIC.asm` / `.funcs.txt` are **wrong** - they disassemble the data segment as code.
> Segment 0000 (0x19C0 bytes) is DATA, segment 019C (0x12EE bytes) is CODE. All addresses below
> are `019C:xxxx` (code) or `DATA:xxxx` (= image offset; file offset = +0x200).

## 1. Image layout / loading

| DATA off | value | meaning |
|---|---|---|
| 0000 | "MGRAPHIC.EXE03-20-91" | name/date |
| 0018 | 019C (relocated) | code segment; becomes the far-jump segment of every thunk |
| 001C | 0000 | **thunk slot base**: game loaders put entry i in thunk `base + 5*(this+i)` |
| 001E | 19C3 | (?) ~ data segment size (0x19C0) |
| 0020 | 12EE | = code segment length (4846 bytes) - not BSS |
| 0022 | 0054 | 84 entries |
| 0024 | 84 x word | near offsets in seg 019C (table below) |
| 00CC/00CE | 0 | write-only words (set by #38/#64, #39/#65; never read) |
| 00D0 | 0007 | font max index (accepts 0..7, but slot 7 = 0x7F00 is garbage; valid fonts 0..6) |
| 00D2 | 7 x word | font pointers (sec. 5) |
| 0060..1797 | | font headers / width tables / bitmaps |
| 17F8..180D | | text state (sec. 4) |
| 180E / 1834 | "Insufficient memory for MCGA graphics$" / "MCGA is not supported on your machine$" | |
| 185A..1866 | | line/plot state, current colour |
| 1867 | 5 x word | ptrs to 16-colour palettes (DATA:1871 + 0x30*k) |
| 1962..1965 | | text draw temporaries |
| 1966/196E/1976 | 4 words each | HUD tick-tape tables (#11) |
| 197E | 0C 04 0C 0E | flicker colour indices (#46) |
| 1982 | 04D2 | flicker LCG seed |
| 1984.. | "Copyright (C) 1988 by MicroProse Software, All Rights Reserved" | |

Thunk loaders (identical code in each EXE): VGAME `func_0FAE_0002`, START 0000:8626, END 0000:45C5,
PLAYER 0000:0F84, SETUP 0000:0BBA, DSWAP 0000:0872. Each copies vector i to `[base+5i+1]`=offset,
`[base+5i+3]`=code seg. Thunk bases (DGROUP offsets): **VGAME 1E42:011A, START 0A95:69B8, END 05FA:23FA,
SETUP 024C:08A6, DSWAP 0225:08DC, PLAYER 02A3:11C0** -> thunk(i) = base + 5*i (MGRAPHIC slot base is 0).

F117.COM (0000:01F7..021C) reads vector[0] (DATA:0024) and vector[2] (DATA:0028), calls #0 with (0,0,0)
and at exit (0000:03C2) calls **#2 - which in this driver is a register-ABI text routine, not a shutdown**
(F117.COM evidently assumes a generic driver layout; with MCGA it is a harmless/garbage call (?)).
#0 with arg 0 just returns 0xA000. Video mode 13h is set by #60 (START 0000:73FF).

## 2. Calling conventions

* **C** = far C call, args right-to-left, caller cleans; arg1 at `[sp+4]` on entry (or `[bp+6]` after `push bp`).
* **R** = register ABI (only called from VGAME assembly modules 0FB2/1058/11D8 with `lcall` thunks).
* Text routines take `bp` = near pointer (SS) to a **viewport/text struct** and `bx` = near pointer (SS) to a NUL-terminated string.

### Viewport / text struct (`VP`, used by #1-#10, #22, #41; game examples VGAME [0x344], [0x4070], [0x4040])
| off | field | used by |
|---|---|---|
| +0 | page index (into page table cs:0787) | text, sprite (#22), recolor (#41: first word only) |
| +2 | text flags: low byte ==1 -> opaque; bit0 -> height += font.extra | text |
| +4 | text colour (updated on return to last colour code) | text |
| +6 | text background colour (opaque mode) | text |
| +8 | text x (absolute); **updated to end x on return** | text |
| +A | text y (absolute, 0..255 byte maths) | text |
| +C | font index 0..6 | text |
| +E | clip top (y min) | text, #22 |
| +10 | clip bottom (y max) | text, #22 |
| +12 | clip left (x min) | text, #22 |
| +14 | clip right (x max) | text, #22 |

### Blit struct (`BS`, for #17-#20/#71-#74; VGAME uses ds:28A4)
| off | field |
|---|---|
| +0 | **source segment** (raw segment, 320-byte rows) |
| +2 / +4 | src x / src y |
| +6 | destination page index |
| +8 / +A | dst x / dst y |
| +C / +E | width / height |
| +10/+12/+14/+16 | clip top / bottom / left / right (clipped variant only) |

## 3. Pages and state in the CODE segment (cs:)

| cs: | init | meaning |
|---|---|---|
| 0004..0193 | y*320 | row-offset table, 200 words |
| 0194 | 0 | **draw segment** (target of line/fill/plot/tick/#48) |
| 0196 | 0 | **draw origin offset** added to every line/fill/plot address (viewport origin, set via #62->#26) |
| 0198 | 1 | "render page" byte returned by #45 (set 1 by #44) |
| 0472..047E | FA00,FA00,0,1,1,1,0 | constants returned by getters #23,#49,#66,#67 (+dead 0495/049A/049F) |
| 0787 | A000,0,0,0,0 | **page segment table** (5 pages). Game: page0=A000 screen, page1=#0(1) back buffer, page2=F117.COM shared block +0x20 (VGAME 0000:02C4) |
| 082A..083C | | sprite arena (far ptr 082A:082C, start 082E, end 0830, limit 0832, encoder counters 0834/0836/0838, rows 083A, width 083C) |
| 083E..0866 | | scaled-sprite temporaries (sec. #22) |
| 0868..09A7 | | 320-byte row expansion buffer |
| 0DDB / 0DEC | | **self-modified opcodes** (cld/std, inc di/dec di) for horizontal flip; templates at 0DF8 = FC 47 FD 4F |
| 11DC | 0 | "direct mode" flag (never set; makes #44 a no-op) |
| 1250 | 0 | screen-shake frame counter (#79/#46) |

## 4. API table

Counts = call sites (`9A off seg` byte scan): V=VGAME S=START E=END Se=SETUP D=DSWAP (PLAYER uses none).
VGAME thunk = 1E42:(011A+5i); START thunk = 0A95:(69B8+5i).

| # | off | conv | proposed name | args | ret | behaviour (pixel-exact) | V/S/E/Se/D | thunks V / S |
|---|---|---|---|---|---|---|---|---|
| 0 | 04FE | C | `page_alloc(int n)` | n | AX=seg | n==0 -> return cs:0787 (0xA000). Else DOS 48h for cs:0474>>4 = 0xFA0 paragraphs (64000 B); fail -> mode 3, print DATA:180E, exit(0). Does not register the page (caller does #75). | 2/1/1/0/2 | 011A / 69B8 |
| 1 | 0224 | R | `text_vclip_r` | bp=VP, bx=str, cx=x, dx=y | AX=end x | text (sec. 6) with vertical clip only | 3 | 011F / 69BD |
| 2 | 020E | R | `text_lclip_r` | same | AX | text with left clip only (also called by F117.COM at exit, see sec. 1) | 1 | 0124 / 69C2 |
| 3 | 0219 | R | `text_rclip_r` | same | AX | text with right clip only | 1 | 0129 / 69C7 |
| 4 | 022F | R | `text_noclip_r` | same | AX | text, no clipping | 3 | 012E / 69CC |
| 5 | 019A | C | `text_draw(VP*, char*)` | x,y from VP+8/+A | AX=end x, VP+8=end x | text, no clipping | 1/4/2/4/0 | 0133 / 69D1 |
| 6 | 0203 | R | `text_clip_r` | bp=VP, bx=str | AX | text with full clip (right, left, vertical: 019C:02A1) | 2 | 0138 / 69D6 |
| 7 | 01C7 | C | `text_draw_vclip(VP*, char*)` | | AX | C wrapper of #1 | 0 | 013D / 69DB |
| 8 | 01DB | C | `text_draw_lclip(VP*, char*)` | | AX | C wrapper of #2 | 0 | 0142 / 69E0 |
| 9 | 01B3 | C | `text_draw_clip(VP*, char*)` | | AX | C wrapper of #6 | 0 | 0147 / 69E5 |
| 10 | 01EF | C | `text_draw_rclip(VP*, char*)` | | AX | C wrapper of #3 | 0 | 014C / 69EA |
| 11 | 071A | R | `hud_tick_tape_r` | bx=y, si=0 left/2 right, cl=alt set (0/1), dl>=1 -> y+=20 | - | draws HUD scale ticks into draw page in colour [1866]: y0=bx-1(+20)(+1 if cl); x=tab1966[si/2 (+2 if cl)] (71,248 / 120,200); ymin=tab196E (22,22/34,34), ymax=tab1976 (82,82/74,74). Rows y0, y0-2, ... while y>=ymin; rows >ymax skipped. Tick k (counter 10,1..10,1..): k==10 -> 2 px (+1 more if cl==0), k==5 -> 2 px, else 1 px. si==0 draws leftwards (std: x, x-1, ...), else rightwards. No draw-origin offset (cs:0196 not added). | 2 (1058:00D4, 026E) | 0151 / 69EF |
| 12 | 07A3 | - | `set_draw_page1()` | | | cs:0194 = cs:0789 (page 1) | 1 | 0156 / 69F4 |
| 13 | 07B2 | R | `set_draw_page_r` | ax=page | | cs:0194 = page table[ax] | 2/2/2/0/0 | 015B / 69F9 |
| 14 | 07AC | C | `set_draw_page(int page)` | page | | same as #13 | 4/1/1/0/1 | 0160 / 69FE |
| 15 | 07C3 | R | `set_draw_seg_r` | ax=segment | | cs:0194 = ax (used to restore a saved value from #16) | 2/2/2 | 0165 / 6A03 |
| 16 | 07C8 | - | `get_draw_seg()` | | AX=cs:0194 | | 2/2/2 | 016A / 6A08 |
| 17 | 0ED5 | C | `blit_transp(BS*)` | | | C wrapper of #18 | 0 | 016F / 6A0D |
| 18 | 0EE6 | R | `blit_transp_r` | bp=BS | | copy w x h from BS.srcSeg (rows of 320) at (sx,sy) to page BS+6 at (dx,dy); **source colour 0 = transparent**; no clipping | 2 (1058:0381,04A0) | 0174 / 6A12 |
| 19 | 0E30 | C | `blit_transp_clip(BS*)` | | | C wrapper of #20 | 0 | 0179 / 6A17 |
| 20 | 0E41 | R | `blit_transp_clip_r` | bp=BS | | clip dst rect to BS+10..+16 (inclusive), adjusting dst x/y **and src x/y in the struct permanently** (w/h restored on exit); fully outside -> nothing; then #18 | 0 | 017E / 6A1C |
| 21 | 0C95 | R | `sprite_draw_core_r` | internal | | body of #22 after clipping; never called by the game | 0 | 0183 / 6A21 |
| 22 | 0B70 | C | `sprite_draw(VP*, int x, int y, int w, int h, off, seg)` | x,y relative to VP clip origin (left,top); w,h = destination size, **negative = mirror** (w<0 horizontal, h<0 vertical) | DX:AX = far ptr cs:084E -> {x,y,w,h} visible rect (relative), zeros if invisible | draws an RLE sprite (sec. 7) scaled nearest-neighbour from (srcW,srcH) to (abs w, abs h), colour 0 transparent, clipped to VP. Game calls with w,h = sprite header (unscaled) e.g. START 0000:36BB | 5/1/1 | 0188 / 6A26 |
| 23 | 0480 | - | `page_bytes()` | | 0xFA00 | | 0 | 018D / 6A2B |
| 24 | 07CD | - | `reset_draw_origin()` | | | cs:0196 = 0 | 1 | 0192 / 6A30 |
| 25 | 07CD | - | (dup of #24) | | | | 1 (1058:09D2) | 0197 / 6A35 |
| 26 | 07D5 | C | `set_draw_origin(int off)` | byte offset | | cs:0196 = off. Game: `set_draw_origin(pixel_offset(vp.left, vp.top))` (VGAME 0000:11D0) | 9 | 019C / 6A3A |
| 27 | 07DB | R | `set_draw_origin_r` | ax | | same | 1 | 01A1 / 6A3F |
| 28 | 07E0 | - | `const_5580()` | | 0x5580 (=68*320+128) (?) | constant | 0 | 01A6 / 6A44 |
| 29 | 07E4 | - | `const_1450()` | | 0x1450 (=16*320+80) (?) | constant, stored in HUD layout table (VGAME 1058:0BC4 -> [0x2942]) | 1 | 01AB / 6A49 |
| 30 | 07E8 | - | `get_draw_origin()` | | AX=cs:0196 | | 0 | 01B0 / 6A4E |
| 31 | 0599 | R | `line_r` | ax=x1, bx=y1, cx=x2, dx=y2 | | line in colour [1866] on draw seg + origin, **no clipping**. Endpoints swapped so x1<=x2, stored at DATA:185A..1860. Single point if equal. Bresenham: major=max(|dx|,|dy|), minor=other; err=-((major+1)>>1); plot major+1 pixels; after each pixel step major axis, err+=minor, if err>=0 {step minor; err-=major}. Both endpoints drawn. | 21 (0FB2, 1058) | 01B5 / 6A53 |
| 32 | 0561 | R | `set_color_r` | ah=colour | | DATA:1866 = ah | 11/2/2 | 01BA / 6A58 |
| 33 | 055B | C | `set_color(int c)` | c (low byte) | | DATA:1866 = c | 4 | 01BF / 6A5D |
| 34 | 056D | - | nop | | | retf | 0 | 01C4 |
| 35 | 056D | - | nop | | | retf | 0 | 01C9 |
| 36 | 056E | - | `replot()` | | | plots colour [1866] at last line start (DATA:185A,185C) + origin | 0 | 01CE / 6A6C |
| 37 | 0F3D | R | `fill_spans_r` | ax=ytop, cx=ybot, bx=near ptr (SS) to int left[] , right[] at bx+0x1B8 (220 entries), dx=mode | | for y = ybot down to ytop (ax<0 -> nothing): L=left[y], R=right[y]; skip if R<L, or R==L and (R==0 or R==319); fill x=L..R inclusive at row y (draw seg + origin). mode 0: =colour; 1: OR colour; 2: AND colour; >=3: **shade** p = 0x98 \| ((p & 0x0E)>>1) (maps to 0x98..0x9F, ignores colour). | 4 (0FB2) | 01D3 / 6A71 |
| 38 | 07F3 | R | `set_cc_r` | ax | | DATA:00CC = ax (never read) | 0 | 01D8 |
| 39 | 0804 | R | `set_ce_r` | ax | | DATA:00CE = ax (never read) | 0 | 01DD |
| 40 | 0F3B | R | `fill_spans_solid_r` | as #37, dx forced 0 | | solid fill | 2/2/2 | 01E2 / 6A80 |
| 41 | 1188 | C | `recolor_rect(VP*, x1, y1, x2, y2, from, to)` | page = *VP, inclusive absolute rect | | every pixel == from becomes to (e.g. VGAME 0000:01FA highlight boxes) | 9 | 01E7 / 6A85 |
| 42 | 1131 | C | `blit(srcPage, sx, sy, dstPage, dx, dy, w, h)` | page indices | | opaque rect copy (rep movsb per row), no clipping, no overlap handling | 26/88/48/0/3 | 01EC / 6A8A |
| 43 | 1122 | - | `clear_screen()` | | | zero 64000 bytes at A000 | 0 | 01F1 |
| 44 | 11F1 | R(ax) | `present(ax=words)` | AX = word count (VGAME passes rows*160) | | if cs:11DC==0: cs:0198=1, copy AX words page1 -> page0 from offset 0 (top AX/160 rows). Else cs:0198=0, nothing | 1 (0000:1BF5) | 01F6 / 6A94 |
| 45 | 080F | - | `get_render_page()` | | AL=cs:0198 (1) | game stores it as VP.page -> draw to back buffer | 4 | 01FB / 6A99 |
| 46 | 125C | - | `flicker_tick()` | | | seed=seed*5+1 (16-bit, DATA:1982); DAC colour 13 := palette0[tab197E[seed&3]] (colours 12,4,12,14 -> 3F1515 / 2A0000 / 3F1515 / 3F3F15, 6-bit) via port 3C8/3C9. If shake counter cs:1250 != 0: counter--, CRTC reg 0Dh (start addr low) := (seed>>8)&3, or 0 when counter reaches 0 -> horizontal screen shake (?: 4-px units in mode 13h) | 1 (0000:1E85) | 0200 / 6A9E |
| 47 | 023A | C | `char_width(int ch, int font)` | | AX = width+spacing (sign-extended), 0 if ch>=0x80, font>7 or ch outside font | fixed fonts: fixed+spacing | 0/2/2/3/0 | 0205 / 6AA3 |
| 48 | 11DE | C | `copy_seg_to_draw(seg)` | | | copy 64000 bytes seg:0 -> draw seg:0 | 0 | 020A / 6AA8 |
| 49 | 0486 | - | `alloc_bytes()` | | 0xFA00 | | 0 | 020F |
| 50 | 04A4 | - | `dos_max_free()` | | AX = largest free DOS block (paragraphs) or 0 | int 21h/48h BX=FFFF | 1 | 0214 / 6AB2 |
| 51 | 12E0 | R | `copy_row_r` | ss:bp -> es:di | | copy 320 bytes (picture decoder 11D8 writes each decoded row) | 2/3/3/0/3 | 0219 / 6AB7 |
| 52 | 12E0 | R | (dup of #51) | | | | 1/1/1/0/1 | 021E / 6ABC |
| 53 | 12DD | - | nop (row hook) | | | retf | 1/1/1/0/1 | 0223 / 6AC1 |
| 54 | 12DE | - | nop (row hook) | | | retf | 1/1/1/0/1 | 0228 / 6AC6 |
| 55 | 12DF | - | nop (row hook) | | | retf | 1/2/2/0/2 | 022D / 6ACB |
| 56 | 12D5 | R | `page_seg_r` | si=page | ES=page seg | | 1/1/1/0/1 | 0232 / 6AD0 |
| 57 | 12C2 | C | `set_page_seg(idx, seg)` | | | page table[idx]=seg | 0 | 0237 |
| 58 | 12BA | R | `row_offset_r` | di=y | AX=y*320 | | 3/4/4/0/4 | 023C / 6ADA |
| 59 | 1118 | R | `clear_seg_r` | es=segment | | zero 64000 bytes es:0 (di, ax, cx clobbered) | 3/4/4/0/4 | 0241 / 6ADF |
| 60 | 04B6 | - | `set_mode13()` | | | int10 AX=0013; verify AH=0F returns 13h else mode 3 + DATA:1834 + exit | 0/1/0 | 0246 / 6AE4 |
| 61 | 12D4 | - | nop | | | | 0 | 024B |
| 62 | 0814 | C | `pixel_offset(x, y)` | | AX = y*320 + x | | 6 | 0250 / 6AEE |
| 63 | 0826 | - | `driver_id()` | | 3 | MCGA id (?) | 1 (0000:CA10) | 0255 / 6AF3 |
| 64 | 07ED | C | `set_cc(int)` | | | DATA:00CC | 0 | 025A |
| 65 | 07FE | C | `set_ce(int)` | | | DATA:00CE (write-only, no visible effect) | 1 (0000:D912) | 025F / 6AFD |
| 66 | 048B | - | `const0()` | | 0 (cs:0476) | | 0 | 0264 |
| 67 | 0490 | - | `const1()` | | 1 (cs:0478) | | 0 | 0269 |
| 68 | 0536 | C | `load_ega_palette(int k)` | k 0..4 | | int10 AX=1012 DAC 0..15 from DATA:1867[k] (6-bit), then #70 | 0 | 026E |
| 69 | 04CA | - | `screen_off()` | | | wait vretrace start (3DA bit3), out 3D8<-02, Sequencer reg1 bit5 = 1 (blank) | 6/2/1/0/2 | 0273 / 6B11 |
| 70 | 04E4 | - | `screen_on()` | | | wait vretrace, out 3D8<-0A, SR1 bit5 = 0 | 5/1/3/0/1 | 0278 / 6B16 |
| 71 | 0E30 | C | = #19 `blit_transp_clip(BS*)` | | | | 2 (114A:03F5,0449) | 027D / 6B1B |
| 72 | 0E41 | R | = #20 | | | | 0 | 0282 |
| 73 | 0ED5 | C | = #17 `blit_transp(BS*)` | | | | 1 (114A:0459) | 0287 / 6B25 |
| 74 | 0EE6 | R | = #18 | | | | 0 | 028C |
| 75 | 0791 | C | `set_page_seg2(seg, idx)` | note arg order (seg first) vs #57 | | page table[idx]=seg (VGAME 0000:02E0: page1 = #0(1)) | 2/1/1/0/1 | 0291 / 6B2F |
| 76 | 09A8 | - | `arena_init()` | | AX = arena seg (0 on fail) | allocate the largest free DOS block as sprite arena | 1/1/1 | 0296 / 6B34 |
| 77 | 0B0C | C | `sprite_grab(page, x, y, w, h)` | | AX = segment of new sprite (offset 0), 0 if no room | encode rect into arena (sec. 7) | 1/10/7 | 029B / 6B39 |
| 78 | 09D4 | - | `arena_shrink()` | | AX = arena seg (0 if freed/failed) | DOS 4Ah resize to used paragraphs (49h free if empty); arena closed | 1/1/1 | 02A0 / 6B3E |
| 79 | 1251 | C | `set_shake(int frames)` | | | cs:1250 = frames (used by #46) | 2 | 02A5 / 6B43 |
| 80-83 | 046F/0470/0471/07C2 | - | nop | | | retf | 0 | 02AA.. |

Unexported dead code in seg 019C: 0288 (C `text_draw_clip(VP*, x, y, str)`), 0495/049A/049F (getters of
cs:047A/047C/047E), 1223 (C `fizzle_copy(seg)`: LFSR bx = (bx>>1) ^ (carry ? 0xB400 : 0), values <= 0xFA00,
copies byte bx-1 from seg to draw seg -> random-dissolve of 64000 pixels).

## 5. Fonts (DATA:00D0 table, render `re/out/mgraphic/font.png` [verified])

Header bytes before the font pointer F (019C:03E8, 019C:023A):
`F-9-(last-first)..F-9` width table (one byte per char, first..last), `F-8` first, `F-7` last,
`F-6` n (glyph row = 2^(n-1) bytes; all fonts n=1 -> 8 px max), `F-5` fixed width (0 = proportional),
`F-4` height, `F-3` spacing, `F-2` extra rows (added when VP flags bit0), `F-1` 0.
Bitmap is row-major: row r of char c at `F + r*stride + (c-first)`, stride = last-first+1; MSB = leftmost.

| font | F | chars | width | height | spacing | extra | notes |
|---|---|---|---|---|---|---|---|
| 0 | 0370 | 00-7F | fixed 3 | 5 | 1 | 1 | tiny caps/digits 3x5, valid 20-5F (other cells garbage) |
| 1 | 06F8 | 00-7F | prop. (<=7) | 8 | 1 | 0 | large 8-row font, upper+lower case |
| 2 | 00E8 | 00-7F | fixed 3 | 4 | 1 | 1 | 3x4 tiny, valid 20-5F; its width table overlaps the vector table (unused, fixed) |
| 3 | 0E88 | 00-7F | prop. | 6 | 1 | 0 | 6-row font; two arrow glyphs in the 00-1F range (see PNG), rest of 00-1F blank |
| 4 | 0B60 | 20-7F | prop. | 7 | 1 | 0 | 7-row font |
| 5 | 11F0 | 20-7F | prop. | 6 | 1 | 0 | 6-row font (narrow) |
| 6 | 1498 | 20-7F | prop. | 8 | 1 | 1 | 8-row tall narrow font |
Extra rows read the bytes after the bitmap, which are zero for every font -> blank padding row.

## 6. Text rendering (019C:03E8 setup, 061A draw, 02B9/031D/037F clip)

| step | rule |
|---|---|
| string | bytes read from SS:bx; 0 ends; **byte >= 0x80 sets colour = byte & 0x7F** (no advance); chars outside first..last ignored (no advance) |
| colour | start colour = VP+4; also copied to global colour DATA:1866 (side effect); final colour written back to VP+4 |
| advance | per char: fixed ? fixed+spacing : width[c]+spacing |
| transparent (VP+2 low byte != 1) | for each glyph row: draw `adv - spacing` columns (full `adv` for the last char of the string), set bits -> colour, 0 bits untouched |
| opaque (low byte == 1) | draw `adv` columns: set bit -> colour, clear bit -> VP+6 (spacing column painted bg) |
| rows | font height (+extra if VP+2 bit0) |
| left clip (02B9) | if x < clip.left: skip whole chars until the one crossing left; skip its first (left - start) columns; cursor starts at clip.left |
| right clip (031D) | if x >= clip.right+1: nothing drawn. Else last char whose end passes right+1 is cut by (end-(right+1)) columns; string temporarily truncated after it |
| vertical (037F) | byte maths. y > bottom or y+h-1 < top -> nothing. y < top -> skip rows, y=top. y+h-1 > bottom -> rows = bottom-y+1 (uses original y; (?) wrong when both clips apply) |
| return | AX = VP+8 = x after last drawn char |

## 7. Sprite (RLE) format - produced by #77, drawn by #22

| field | size | meaning |
|---|---|---|
| header | word w, word h | at seg:0 |
| row record x h | word n, word lead, n bytes | `lead` = leading zero pixels; n = bytes from first non-zero to last non-zero (inner zeros kept); trailing zeros dropped; row of only zeros: n=0. Next row = this + 4 + n |

Encoder (019C:0A6A): arena write ptr cs:082A:082C; overflow (di+w+4 > min(free paragraphs,0xFFF)*16) -> header h decremented, arena marked full. Each sprite is paragraph aligned at offset 0 of its segment.

Draw (#22, 019C:0B70/0BC0/0C95): rows expanded into cs:0868 (lead zeros, data, zero pad to w).
Destination rows: errV starts -|dh|; after each row errV += srcH, while errV>=0 {next src row, errV -= |dh|}.
Columns: errH starts -|dw| (advanced over clipped-off left columns); per dest pixel: write if src!=0, errH += srcW,
while errH>=0 {src++, errH -= |dw|}. Hflip: start at right edge, step -1 (self-modified std/dec di); Vflip: start at
bottom row, row step -320. Clip: y in 0..(bottom-top), x in 0..(right-left) relative to VP, then + (left, top).

## 8. Palette / DAC

Driver only touches the DAC in #46 (colour 13) and #68 (colours 0-15, unused). Values are VGA 6-bit (0..3F).
DATA:1871 palettes (16 x RGB): 0 = EGA default (000000 00002A 002A00 002A2A 2A0000 2A002A 2A1500 2A2A2A 151515 15153F 153F15 153F3F 3F1515 3F153F 3F3F15 3F3F3F);
1 = same with colour 5 black; 2 = colour 13 black; 3 = all black; 4 = colours 2 and 10 black.
No fade routine exists in the driver (fades, if any, are in the game).

## 9. Unused entries (no call site in VGAME/START/END/SETUP/DSWAP/PLAYER) - port may skip

7, 8, 9, 10, 17, 19, 20, 21, 23, 28, 30, 34, 35, 36, 38, 39, 43, 48, 49, 57, 61, 64, 66, 67, 68, 72, 74, 80, 81, 82, 83.
(#17/#19/#20 bodies are still needed through #71/#73; #2 is also invoked by F117.COM at exit.)
Note: register-ABI entries (#1-#4, #6, #11, #18, #31, #37, ...) are invisible in the generic listings because VGAME's
0FB2/1058/11D8 modules are mis-disassembled - counts above come from a byte scan for `9A off seg`.

## 10. Port checklist

| driver concept | canvas port |
|---|---|
| pages 0..4 | Uint8Array(64000) per page; page 0 = screen, blit to canvas through the 256-entry palette |
| draw seg / origin | current target page + integer origin offset (line/fill/plot/tick only) |
| present(#44) | copy first N*320 bytes page1->page0 then render |
| text | implement sec. 6 exactly using `fonts.json` |
| sprites | sec. 7 RLE + nearest scaling with the exact DDA |
| lines/spans | sec. #31 Bresenham, #37 span rules incl. shade mode |
| #46 | colour-13 flicker + shake counter |
