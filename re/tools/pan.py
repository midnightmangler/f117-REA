"""Decode F-117A .PAN animations (played by PLAYER.EXE).  See re/docs/format-pan.md.
usage: py -3 -I pan.py IN.PAN OUTDIR [--every N] [--all]
Writes OUTDIR/frame_NNNN.png (all frames, or every Nth when there are many),
OUTDIR/cels.txt (one line per cel record), OUTDIR/palette.png.
Stdlib + PIL only.

Pipeline (from PLAYER.EXE):
  1. whole file = one LZEXE-0.91-style LZ stream (func_0000_0BE2); the length-byte
     value 1 marks a "segment" end (decoder returns, stream continues), 0 = EOF.
  2. decompressed data = sequence of cels; a cel is  ['Z' header] 'B' 00 01 00 <RunSkipDump>
     (func_0000_07EA), drawn straight into A000:0000 as a delta on the previous screen.
"""
import os, struct, sys
from PIL import Image


def lz_unpack(src):
    """func_0000_0BE2: LSB-first 16-bit bit buffer, LZEXE 0.91 token set.
    Returns (data, segment_end_offsets)."""
    p = 0
    buf = src[0] | (src[1] << 8); p = 2; cnt = 16
    out = bytearray()
    segs = []

    def bit():
        nonlocal buf, cnt, p
        b = buf & 1
        buf >>= 1
        cnt -= 1
        if cnt == 0:
            buf = src[p] | (src[p + 1] << 8); p += 2; cnt = 16
        return b

    while True:
        if bit():
            out.append(src[p]); p += 1
            continue
        if not bit():
            ln = (bit() << 1) | bit()
            ln += 2
            span = src[p] - 0x100; p += 1
        else:
            lo, hi = src[p], src[p + 1]; p += 2
            span = (((hi >> 3) | 0xE0) << 8 | lo) - 0x10000
            ln = hi & 7
            if ln:
                ln += 2
            else:
                ln = src[p]; p += 1
                if ln == 0:
                    break           # EOF (0x11BE <- 1)
                if ln == 1:
                    segs.append(len(out))   # segment end, func returns bytes produced
                    continue
                ln += 1
        for _ in range(ln):
            out.append(out[len(out) + span])
    return bytes(out), segs, p


def run_skip_dump(d, p, scr):
    """func_0000_1006 (no name in listing; code at 0000:1006..1095). Returns pointer after end op
    and stats dict."""
    di = 0
    st = {'dump': 0, 'run': 0, 'skip': 0}
    while True:
        c = d[p]; p += 1
        if c == 0:                      # short run: count, value
            n = d[p]; v = d[p + 1]; p += 2
            for i in range(n):
                scr[(di + i) & 0xFFFF] = v
            di += n; st['run'] += n
        elif c < 0x80:                  # short dump
            for i in range(c):
                scr[(di + i) & 0xFFFF] = d[p + i]
            p += c; di += c; st['dump'] += c
        elif c > 0x80:                  # short skip
            di += c - 0x80; st['skip'] += c - 0x80
        else:                           # 0x80: long op
            w = d[p] | (d[p + 1] << 8); p += 2
            if w == 0:
                break
            if w < 0x8000:
                di += w; st['skip'] += w
            elif w < 0xC000:
                n = w - 0x8000
                for i in range(n):
                    scr[(di + i) & 0xFFFF] = d[p + i]
                p += n; di += n; st['dump'] += n
            else:
                n = w - 0xC000
                v = d[p]; p += 1
                for i in range(n):
                    scr[(di + i) & 0xFFFF] = v
                di += n; st['run'] += n
        di &= 0xFFFF
    return p, st


def decode(path):
    raw = open(path, 'rb').read()
    data, segs, used = lz_unpack(raw)
    scr = bytearray(65536)
    pal = None
    frames, log = [], []
    table = None
    rate = None
    p = 0
    idx = 0
    while p < len(data):
        start = p
        info = ''
        if data[p] == ord('Z'):
            rate = data[p + 1]
            n = struct.unpack_from('<H', data, p + 2)[0]
            table = struct.unpack_from('<%dH' % n, data, p + 4)
            pp = p + 4 + 2 * n
            pal = data[pp:pp + 768]
            info = 'Z rate=%d (ticks/frame=%d) cels=%d palette@%d' % (rate, 60 // rate, n, pp)
            p = pp + 768
        hdr = data[p:p + 4]
        if hdr != b'B\x00\x01\x00':
            log.append('%4d @%6d  BAD header %s' % (idx, start, hdr.hex()))
            break
        p, st = run_skip_dump(data, p + 4, scr)
        size = p - start
        tsz = table[idx] if table and idx < len(table) else None
        log.append('%4d @%6d size=%5d table=%5s %s dump=%d run=%d skip=%d %s' % (
            idx, start, size, tsz, 'OK ' if tsz == size else 'MISMATCH', st['dump'], st['run'],
            st['skip'], info))
        frames.append(bytes(scr[:64000]))
        idx += 1
    return dict(raw=len(raw), lz_used=used, unpacked=len(data), segs=segs, pal=pal, rate=rate,
                frames=frames, log=log, cels=len(table) if table else 0, tail=len(data) - p)


def to_img(pix, pal):
    im = Image.frombytes('P', (320, 200), pix)
    im.putpalette(bytes(((c & 63) << 2) | ((c & 63) >> 4) for c in pal))
    return im


def main():
    a = sys.argv[1:]
    every = None
    if '--every' in a:
        i = a.index('--every'); every = int(a[i + 1]); del a[i:i + 2]
    allf = '--all' in a
    a = [x for x in a if x != '--all']
    src, outdir = a[0], a[1]
    os.makedirs(outdir, exist_ok=True)
    r = decode(src)
    nf = len(r['frames'])
    if every is None:
        every = 1 if (allf or nf <= 120) else -(-nf // 100)
    with open(os.path.join(outdir, 'cels.txt'), 'w') as f:
        f.write('# %s  file=%d bytes  LZ input consumed=%d  unpacked=%d  segments=%d  '
                'cels(table)=%d decoded=%d  rate=%s  trailing=%d\n' % (
                    os.path.basename(src), r['raw'], r['lz_used'], r['unpacked'], len(r['segs']) + 1,
                    r['cels'], nf, r['rate'], r['tail']))
        f.write('# segment ends (unpacked offsets): %s\n' % r['segs'])
        f.write('\n'.join(r['log']) + '\n')
    if r['pal']:
        sw = Image.new('P', (256, 16))
        sw.putdata([x for _ in range(16) for x in range(256)])
        sw.putpalette(bytes(((c & 63) << 2) | ((c & 63) >> 4) for c in r['pal']))
        sw.convert('RGB').resize((512, 32), Image.NEAREST).save(os.path.join(outdir, 'palette.png'))
    for i, fr in enumerate(r['frames']):
        if i % every == 0 or i == nf - 1:
            to_img(fr, r['pal']).save(os.path.join(outdir, 'frame_%04d.png' % i))
    bad = sum('MISMATCH' in l or 'BAD' in l for l in r['log'])
    print('%s: %d cels (table %d), rate %s, unpacked %d, LZ used %d/%d, segments %d, '
          'size mismatches %d, wrote every %d' % (os.path.basename(src), nf, r['cels'], r['rate'],
          r['unpacked'], r['lz_used'], r['raw'], len(r['segs']) + 1, bad, every))


if __name__ == '__main__':
    main()
