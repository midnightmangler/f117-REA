"""Unpack LZEXE 0.90/0.91 compressed DOS executables.
Port of the classic unlzexe algorithm (Kurizono/Bontchev). Standard library only.
usage: py -3 unlzexe.py IN.EXE OUT.EXE
"""
import struct, sys


class Bits:
    def __init__(self, data, pos):
        self.d, self.p = data, pos
        self.buf = 0
        self.count = 0
        self._fill()

    def _fill(self):
        self.buf = self.d[self.p] | (self.d[self.p + 1] << 8)
        self.p += 2
        self.count = 16

    def bit(self):
        b = self.buf & 1
        self.buf >>= 1
        self.count -= 1
        if self.count == 0:
            self._fill()
        return b

    def byte(self):
        v = self.d[self.p]
        self.p += 1
        return v


def unpack(src):
    h = struct.unpack_from('<14H', src, 0)
    if src[:2] != b'MZ' or src[0x1c:0x20] not in (b'LZ91', b'LZ90'):
        raise SystemExit('not an LZEXE 0.90/0.91 file')
    ver = 91 if src[0x1c:0x20] == b'LZ91' else 90
    hdr_paras, e_cs = h[4], h[11]
    base = (hdr_paras + e_cs) << 4
    inf = struct.unpack_from('<8H', src, base)
    ip, cs, sp, ss, csize, incsize, ldrsize, chk = inf

    # ---- relocations ----
    rel = []
    if ver == 91:
        p = base + 0x158
        rel_seg = rel_off = 0
        while True:
            span = src[p]; p += 1
            if span == 0:
                span = src[p] | (src[p + 1] << 8); p += 2
                if span == 0:
                    rel_seg += 0x0fff
                    continue
                if span == 1:
                    break
            rel_off += span
            rel_seg += (rel_off & ~0x0f) >> 4
            rel_off &= 0x0f
            rel.append((rel_off, rel_seg))
    else:
        p = base + 0x19d
        rel_seg = 0
        while rel_seg != 0xf000:
            c = src[p] | (src[p + 1] << 8); p += 2
            for _ in range(c):
                o = src[p] | (src[p + 1] << 8); p += 2
                rel.append((o, rel_seg))
            rel_seg += 0x1000

    # ---- decompress ----
    fpos = (e_cs - csize + hdr_paras) << 4
    bits = Bits(src, fpos)
    out = bytearray()
    while True:
        if bits.bit():
            out.append(bits.byte())
            continue
        if not bits.bit():
            ln = bits.bit() << 1
            ln |= bits.bit()
            ln += 2
            span = bits.byte() | 0xff00
        else:
            span = bits.byte()
            ln = bits.byte()
            span |= ((ln & ~0x07) << 5) | 0xe000
            ln = (ln & 0x07) + 2
            if ln == 2:
                ln = bits.byte()
                if ln == 0:
                    break
                if ln == 1:
                    continue
                ln += 1
        span -= 0x10000  # negative offset
        for _ in range(ln):
            out.append(out[len(out) + span])

    # ---- rebuild MZ header ----
    relpos = 0x1c
    hsize = (relpos + 4 * len(rel) + 15) & ~15
    total = hsize + len(out)
    newh = struct.pack('<2s13H',
                       b'MZ', total % 512, (total + 511) // 512, len(rel), hsize // 16,
                       incsize, 0xffff, ss, sp, 0, ip, cs, relpos, 0)
    img = bytearray(newh)
    for o, s in rel:
        img += struct.pack('<HH', o, s)
    img += b'\0' * (hsize - len(img))
    img += out
    return bytes(img), dict(ip=ip, cs=cs, ss=ss, sp=sp, image=len(out), relocs=len(rel), hdr=hsize)


if __name__ == '__main__':
    data = open(sys.argv[1], 'rb').read()
    img, info = unpack(data)
    open(sys.argv[2], 'wb').write(img)
    print(sys.argv[1], info)
