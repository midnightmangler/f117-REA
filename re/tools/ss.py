"""Decode MicroProse/MPS Labs "MADSS1" sprite series (.SS), as loaded by MPS_LOGO.EXE.
usage: py -3 -I ss.py IN.SS OUTDIR
Writes OUTDIR/sprite_NNN.png (each sprite alone, transparent), OUTDIR/screen_NNN.png
(cumulative 320x200 screen after drawing sprite N at its own x,y, as MPS_LOGO does),
OUTDIR/frames.txt. See re/docs/format-ss.md.  Stdlib + PIL only.
"""
import os, struct, sys
from PIL import Image

TYPE_BASE = {0: 0x01, 1: 0x51, 2: 0x1F, 3: 0x38, 4: 0x1F, 5: 0x01}  # DGROUP ds:004A (MPS_LOGO)


def load(path):
    d = open(path, 'rb').read()
    if d[:7] != b'MADSS1\x1a':
        raise SystemExit('not MADSS1')
    name = d[7:16].split(b'\0')[0].decode('ascii', 'replace')
    alloc, count, datasize, f0c, f0e, typ = struct.unpack_from('<IHIHHB', d, 16)
    p = 0x1F
    frames = []
    for i in range(count):
        off, f4, x, y, w, h = struct.unpack_from('<I5H', d, p)
        frames.append(dict(off=off, delay=f4, x=x, y=y, w=w, h=h))
        p += 14
    ncol = d[p]; p += 1
    pal = [tuple(d[p + 4 * i:p + 4 * i + 4]) for i in range(ncol)]
    p += 4 * ncol
    data = d[p:p + datasize]
    return dict(name=name, alloc=alloc, count=count, datasize=datasize, f0c=f0c, f0e=f0e, type=typ,
                frames=frames, pal=pal, data=data, data_off=p, total=len(d), end=p + datasize)


def draw(data, off, put):
    """006D:05BE inner loop (lin 0x0D60..0x0DAD). put(x, y, v) for opaque pixels. Returns stats."""
    p = off
    x = y = 0
    maxx = 0

    def run(n, v):
        nonlocal x
        if v != 0xFC:
            for i in range(n):
                put(x + i, y, v)
        x += n

    while True:
        m = data[p]; p += 1
        if m == 0xFE:
            maxx = max(maxx, x); y += 1; x = 0; continue
        if m == 0xFF:
            break
        if m == 0xFA:                        # literal row
            while True:
                b = data[p]; p += 1
                if b == 0xFE:
                    break
                if b == 0xFD:
                    run(data[p], data[p + 1]); p += 2
                elif b == 0xFC:
                    x += 1
                else:
                    put(x, y, b); x += 1
        else:                                # 0xF9 (any other marker): count,value pairs
            while True:
                n = data[p]; p += 1
                if n == 0xFE:
                    break
                run(n, data[p]); p += 1
        maxx = max(maxx, x); y += 1; x = 0
    return dict(end=p, rows=y, maxw=maxx)


def main():
    src, outdir = sys.argv[1], sys.argv[2]
    os.makedirs(outdir, exist_ok=True)
    s = load(src)
    base = TYPE_BASE.get(s['type'], 1)
    rgb = [0] * 768
    for i, (r, g, b, _f) in enumerate(s['pal']):
        rgb[3 * (base + i):3 * (base + i) + 3] = [(c & 63) << 2 | (c & 63) >> 4 for c in (r, g, b)]
    rgbb = bytes(rgb)
    screen = Image.new('P', (320, 200), 0)
    screen.putpalette(rgbb)
    sp = screen.load()
    lines = ['# %s name=%r alloc=%d count=%d datasize=%d hdr0C=%d hdr0E=%d type=%d colours=%d '
             'data@0x%X end=%d/%d base=0x%02X' % (os.path.basename(src), s['name'], s['alloc'], s['count'],
             s['datasize'], s['f0c'], s['f0e'], s['type'], len(s['pal']), s['data_off'], s['end'], s['total'], base)]
    lines += ['# palette entry %2d -> DAC %3d: %s' % (i, base + i, ' '.join('%02X' % c for c in e))
              for i, e in enumerate(s['pal'])]
    t = 0
    for i, f in enumerate(s['frames']):
        spr = Image.new('RGBA', (max(1, f['w'] + 1), max(1, f['h'] + 1)), (0, 0, 0, 0))
        px = spr.load()

        def put(x, y, v, f=f):
            c = base + v - 1
            if 0 <= x < spr.width and 0 <= y < spr.height:
                px[x, y] = tuple(rgb[3 * c:3 * c + 3]) + (255,)
            X, Y = f['x'] + x, f['y'] + y
            if 0 <= X < 320 and 0 <= Y < 200:
                sp[X, Y] = c & 255
        st = draw(s['data'], f['off'], put)
        t += f['delay']
        nxt = s['frames'][i + 1]['off'] if i + 1 < len(s['frames']) else s['datasize']
        lines.append('%3d off=%5d delay=%d (t=%3d ticks) x=%3d y=%3d w=%3d h=%3d | decoded rows=%d maxw=%d '
                     'end=%d next=%d %s' % (i + 1, f['off'], f['delay'], t, f['x'], f['y'], f['w'], f['h'],
                     st['rows'], st['maxw'], st['end'], nxt, 'OK' if st['end'] == nxt else 'GAP'))
        spr.save(os.path.join(outdir, 'sprite_%03d.png' % (i + 1)))
        screen.save(os.path.join(outdir, 'screen_%03d.png' % (i + 1)))
    open(os.path.join(outdir, 'frames.txt'), 'w').write('\n'.join(lines) + '\n')
    print('\n'.join(lines[:1] + lines[-3:]))


if __name__ == '__main__':
    main()
