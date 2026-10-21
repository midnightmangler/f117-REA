# MGRAPHIC decompilation notes (task 1.2)

Source: `re/out/mgraphic/MGRAPHIC_code.asm` (019C:xxxx). Ported in `src/platform/gfx*.js`; addresses are in the JS comments.
Everything below is behaviour that differs from, or is missing in, `re/docs/mgraphic-api.md` sec. 6/7.

## Text (03E8 setup, 031D right, 02B9 left, 037F vertical, 061A draw)
Order for the full-clip entry (02A1): setup, right, left, vertical, draw. Every `pop ax; jmp 03D1` exit stores x to VP+8 and returns.
```
setup:   x=cx, y=dx (words); string empty or font > 7 -> exit; rows = height (+extra if flags&1);
         fixedAdv = fixed ? fixed+spacing : 0; stride = (last-first+1) << (shift-1)
right:   if (x >= clip.right) exit            // unsigned; doc said right+1, the code compares with right
         d = x; for c in string (skip >=0x80, outside first..last): d += adv; if d >= right+1 { cut = d-(right+1); str[i+1]=0; break }
left:    if (right-left < 0) exit; if (x < left /*unsigned*/) { x_saved = x; x = left;
           for c in string (colour codes skipped, i.e. lost): x_saved += adv; if x_saved > left { skip = adv-(x_saved-left); start here; break }
           string end -> exit }
vertical (byte maths): top,bot,y,h-1: yb = y+h-1; if (y > bot || yb < top) exit;
           if (y < top) { rows = yb-top+1; y = top; font base += (top-y)*stride }
           if (yb > bot) rows = bot-y_original+1          // y_original: wrong when both clips apply
draw:    colour = VP+4 -> global DATA:1866; per char: cl = adv; if (next byte == 0) cl -= cut; cl -= skip; skip = 0
         transparent (flags low byte != 1): n = cl; if (n && next != 0) n -= spacing; draw n columns (set bits only)
         opaque: draw cl columns (set -> colour, clear -> bg) // no zero check: cl == 0 would loop 256 times
         x += cl; end: VP+4 = last colour
```
Glyph row word = `[F + r*stride + c]` big-endian (this char's byte, then the next char's byte); column k = bit 15-k after `shl bx,skip`.

## Sprite (0A6A encoder, 0B70 draw, 0BC0 clip, 0C95/0D7D core)
```
clip:    dest rect (x,y,|w|,|h|) vs VP size (right-left, bottom-top); top = max(0,-y), left = max(0,-x),
         bottom = max(0, y+h-1-(vp.bottom-vp.top)), right likewise; fully outside -> rect {0,0,0,0}
core:    rows: errV=-dh; per dest row (skipped ones first: clipTop, or clipBot when vflip): errV += srcH; while (errV>=0) { src row++; errV -= dh }
         cols: errH=-dw; skip src columns the same way for the clipped left (right when hflip) columns; per dest pixel:
               write if src != 0; errH += srcW; while (errH>=0) { src col++; errH -= dw }
         row = {n, lead, data}; n == 0 or lead+n <= skippedSrcCols -> row not drawn (but the row DDA still advances)
```
Return value points at cs:084E = {x,y,w,h} visible rect relative to the VP.

## Spans (0F3D) - do-while
`for y = ybot; ...; y-- while y >= ytop`: the first row (ybot) is processed even when ybot < ytop; ytop < 0 exits first.
Skip if `right < left` (unsigned), or `right == left` and it is 0 or 319. Mode 1 OR, 2 AND, 0 colour, others shade (`0x98 | (p & 0x0E) >> 1`).

## Others
* Flicker 125C: `seed = seed*5+1`; colour index `[12,4,12,14][seed&3]` of EGA palette 0 -> DAC 13; if shake != 0: CRTC 0Dh = (seed>>8)&3 (0 on the last frame).
* Tick tape 071A: tables x {71,248,120,200}, ymin {22,22,34,34}, ymax {82,82,74,74}; counter 10,1..10; ch==5: 2 px, ch==10: 3 px (2 if large HUD), else 1 px; rows above ymax skipped; no draw origin.
* Dissolve 1223 (dead code): `bx=1; repeat 64000: { do { c=bx&1; bx>>=1; if (c) bx^=0xB400 } while (bx > 0xFA00); dst[bx-1]=src[bx-1] }`.
* Port deviations: segments are `Uint8Array` buffers (`pageTable`, `drawSeg`); sprite arena replaced by returned `Uint8Array`s (per-sprite limit 0xFFF0 kept);
  `dosMaxFree`/`arenaInit`/`arenaShrink` are stubs; shake exposes `hscroll` (CRTC start units, 4 px each in mode 13h (?)); font 7 (garbage pointer) is rejected.
