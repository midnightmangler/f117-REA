"""Dump the 7 bitmap fonts embedded in MGRAPHIC.EXE (data segment 0000) to PNG + JSON.

Font table: DATA:00D0 = word maxIndex (7), DATA:00D2 + 2*i = near pointer F to font i.
Header lives BEFORE F (read by 019C:03E8 / 019C:023A):
  F-9-(last-first) .. F-9 : width table, one byte per char (first..last)
  F-8 first char, F-7 last char, F-6 bytesPerGlyphRow shift (glyph row = 2^(n-1) bytes),
  F-5 fixed width (0 = proportional), F-4 height, F-3 spacing, F-2 extra rows (flag bit0), F-1 unused
Glyph bitmap: row-major, row r of char c at F + r*stride + ((c-first) << (n-1)),
  stride = (last-first+1) << (n-1); bits MSB first (word read big-endian).

usage: py -3 -I re/tools/mgraphic_font.py <re-dir>
"""
import sys, os, struct, json
from PIL import Image

re_dir = sys.argv[1]
d = open(os.path.join(re_dir, 'unpacked', 'MGRAPHIC.EXE'), 'rb').read()[0x200:]
w16 = lambda o: struct.unpack('<H', d[o:o + 2])[0]
outdir = os.path.join(re_dir, 'out', 'mgraphic')
os.makedirs(outdir, exist_ok=True)
fonts = []
for i in range(7):
    F = w16(0xD2 + 2 * i)
    first, last, sh, fixed, h, sp, extra = d[F - 8], d[F - 7], d[F - 6], d[F - 5], d[F - 4], d[F - 3], d[F - 2]
    n = last - first + 1
    bpg = 1 << (sh - 1)
    stride = n << (sh - 1)
    wt = F - 9 - (last - first)
    widths = [fixed if fixed else d[wt + k] for k in range(n)]
    glyphs = {}
    for k in range(n):
        rows = []
        for r in range(h):
            o = F + r * stride + k * bpg
            v = (d[o] << 8) | d[o + 1]
            rows.append(v)
        glyphs[first + k] = rows
    fonts.append(dict(index=i, ptr=F, first=first, last=last, shift=sh, fixed=fixed, height=h,
                      spacing=sp, extra=extra, widthTable=wt, dataEnd=F + h * stride,
                      widths=widths, rows=[glyphs[c] for c in range(first, last + 1)]))

# sheet: per font a block of 16 columns x (n/16) rows, each cell 9x(h+2) scaled x3
S = 3
cellw = 10
blocks = []
for f in fonts:
    n = f['last'] - f['first'] + 1
    ch = f['height'] + 3
    img = Image.new('RGB', (16 * cellw, ((n + 15) // 16) * ch), (40, 40, 60))
    px = img.load()
    for k in range(n):
        cx, cy = (k % 16) * cellw, (k // 16) * ch
        wdt = f['widths'][k]
        for x in range(wdt):
            for y in range(f['height']):
                px[cx + x, cy + y] = (70, 70, 100)
        for y, v in enumerate(f['rows'][k]):
            for x in range(8 * (1 << (f['shift'] - 1))):
                if v & (0x8000 >> x) and cx + x < img.width:
                    px[cx + x, cy + y] = (255, 255, 255) if x < wdt else (255, 80, 80)
    blocks.append(img)
W = max(b.width for b in blocks)
H = sum(b.height + 4 for b in blocks)
sheet = Image.new('RGB', (W, H), (0, 0, 0))
y = 0
for b in blocks:
    sheet.paste(b, (0, y))
    y += b.height + 4
sheet = sheet.resize((W * S, H * S), Image.NEAREST)
sheet.save(os.path.join(outdir, 'font.png'))
json.dump(fonts, open(os.path.join(outdir, 'fonts.json'), 'w'))
for f in fonts:
    print('font %d F=%04X chars %02X-%02X shift=%d fixed=%d h=%d sp=%d extra=%d widths@%04X data %04X-%04X' % (
        f['index'], f['ptr'], f['first'], f['last'], f['shift'], f['fixed'], f['height'], f['spacing'], f['extra'],
        f['widthTable'], f['ptr'], f['dataEnd'] - 1))

