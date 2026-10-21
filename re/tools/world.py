"""F-117A 2.0 world/3D data dumper.  See re/docs/format-3d.md.

usage: py -3 -I world.py FILE [FILE...] [--render N]
  FILE  = XX.WLD | XX.3DX (also PHOTO.3DX, STFLT.3DX) | XX.3DG | XX.3DT
  --render N  : also render 3DX object N (first LOD) to a PNG (needs PIL)
Output goes to re/out/world/<FILE>.txt (and <FILE>_objNN.png).
"""
import os, struct, sys

_DROP = r'C:\Dropbox\Game Projects\F117-REA'
OUT = os.path.join(os.environ.get('F117_RE', os.path.join(_DROP, 're')), 'out', 'world')
GAME = os.environ.get('F117_REF', os.path.join(_DROP, 'reference', 'F-117A', 'F-117A'))


def u16(d, o): return struct.unpack_from('<H', d, o)[0]
def s16(d, o): return struct.unpack_from('<h', d, o)[0]


# ---------------------------------------------------------------- WLD
def parse_wld(d):
    """Layout per START func_0000_54BB (file) / VGAME func_0000_4D5D (memory copy)."""
    w = {}
    w['side_shape0'], w['side_shape1'] = d[0], d[1]      # VGAME ded0 / c0d8
    w['h2'], w['h3'] = u16(d, 4), u16(d, 6)              # VGAME 992c / e56c
    n = u16(d, 2); p = 8
    w['objs'] = [struct.unpack_from('<HHHHHHHH', d, p + 16 * i) for i in range(n)]
    p += 16 * n
    n = u16(d, p); p += 2
    w['units'] = [d[p + 36 * i:p + 36 * i + 36] for i in range(n)]
    p += 36 * n
    w['typeflags'] = d[p:p + 128]; w['tab2'] = d[p + 128:p + 256]; w['tab3'] = d[p + 256:p + 384]
    p += 384
    w['grid'] = d[p:p + 256]; p += 256
    w['strings'] = [s.decode('latin1') for s in d[p:p + 750].split(b'\0')]
    w['pool_len'] = len(d) - p
    return w


def dump_wld(d):
    w = parse_wld(d); S = w['strings']; L = []
    nm = lambda i: S[i] if i < len(S) else '?'
    L.append('WLD  side shapes 0x%02X 0x%02X  h2=%d h3=%d  objects=%d units=%d  stringpool=%d bytes'
             % (w['side_shape0'], w['side_shape1'], w['h2'], w['h3'], len(w['objs']), len(w['units']), w['pool_len']))
    L.append('\n# world objects (16 bytes): idx name | x y (WLD units; world = x<<5, z = (0x8000-y)<<5) | w6 w8 wA wC | shape (bank:obj) type-name')
    for i, r in enumerate(w['objs']):
        L.append('%3d %-14s %5d %5d  %04X %04X %04X %04X  %d:%02X %s'
                 % (i, nm(r[0]) if r[0] else '-', r[1], r[2], r[3], r[4], r[5], r[6], r[7] >> 8, r[7] & 0xFF,
                    nm(r[7] & 0x7F) if r[7] else ''))
    L.append('\n# mobile units (36 bytes; +2 x, +4 y)')
    for i, u in enumerate(w['units']):
        L.append('%2d %s' % (i, u.hex(' ')))
    for k in ('typeflags', 'tab2', 'tab3'):
        L.append('\n# %s (128 bytes, indexed by shape & 0x7F)' % k)
        L.append(' '.join('%02X:%02X' % (i, b) for i, b in enumerate(w[k]) if b))
    L.append('\n# 16x16 sector grid (cell = WLD coord >> 11), row = y')
    for y in range(16):
        L.append(' '.join('%02X' % b for b in w['grid'][16 * y:16 * y + 16]))
    L.append('\n# string pool (index = name index; also object-type name for shape index)')
    for i, s in enumerate(S[:128]):
        if s: L.append('%3d 0x%02X %s' % (i, i, s))
    return L


# ---------------------------------------------------------------- 3DX
class Obj:
    pass


def parse_lod(d, o):
    """One LOD block, walk order of VGAME 120A:00CF (+0x317, +0x561, +0x6B5, +0xA33, +0xC76)."""
    b = Obj(); b.off = o
    b.radius = u16(d, o); nparts = s16(d, o + 2); o += 4
    b.nparts = nparts
    b.part_anim = []
    for _ in range(max(nparts - 1, 0)):            # 120A:0355
        b.part_anim.append((d[o], d[o + 1])); o += 2
    b.part_pivot = []
    for _ in range(max(nparts - 1, 0)):            # 120A:043C reads, 120A:0402 re-reads then si+=6
        b.part_pivot.append(struct.unpack_from('<3h', d, o)); o += 6
    b.nverts = s16(d, o); o += 2                   # -> [7d5c]
    b.nplanes = s16(d, o); o += 2                  # -> [7d5a]
    b.planes = []
    k = 0
    while k < abs(b.nplanes):                      # 120A:0589
        w = u16(d, o); o += 2
        if w >> 8 == 0x80:
            b.planes.append(('part', w & 0xFF)); continue
        if w == 0x8100:
            b.planes.append(('cond', d[o] & 0x1F, struct.unpack_from('b', d, o + 1)[0])); o += 2; continue
        n = (s16(d, o - 2), s16(d, o), s16(d, o + 2)); dd = struct.unpack_from('<i', d, o + 4)[0]; o += 8
        b.planes.append(('plane', n, dd)); k += 1
    b.usage = []
    for _ in range(abs(b.nplanes)):                # 120A:0612
        c = d[o]; b.usage.append(list(d[o + 1:o + 1 + c])); o += 1 + c
    b.bsp = None
    if b.nplanes < 0:                              # 120A:063C -> 0E5B ; si += 2n+1
        b.bsp = d[o:o + 2 * (-b.nplanes) + 1]; o += 2 * (-b.nplanes) + 1
    b.verts = []; b.vref = []; part = 0
    if b.nverts >= 0:                              # 120A:072C
        i = 0
        while i < b.nverts:
            w = u16(d, o)
            if 0x8000 <= w < 0x8010:
                part = w & 0xF; o += 2; continue
            b.verts.append(struct.unpack_from('<3h', d, o) + (part,)); o += 6; i += 1
    else:                                          # 120A:0764 : byte index into vector table (object N)
        b.vref = list(d[o:o - b.nverts]); o += -b.nverts
    ne = u16(d, o); o += 2                         # 120A:0A37
    b.edges = [(d[o + 2 * i], d[o + 2 * i + 1]) for i in range(ne)]; o += 2 * ne
    b.lists = []
    if b.nplanes == 0:                             # 120A:0C80 : one list inline
        lst, o = parse_list(d, o); b.lists.append((None, lst))
        b.end = o
    else:                                          # 120A:0CB9 : table of per-plane list offsets
        offs = [u16(d, o + 2 * i) for i in range(abs(b.nplanes))]; o += 2 * abs(b.nplanes)
        end = o
        for i, lo in enumerate(offs):
            lst, e = parse_list(d, lo); b.lists.append((i, lst)); end = max(end, e)
        b.end = end
    return b


def parse_list(d, o):
    """Draw list, VGAME 120A:0CE9. Returns list of (kind, ...)."""
    out = []
    while True:
        a = d[o]; o += 1
        if a == 0xFF: return out, o
        if a & 0x80:                               # conditional on anim slot
            out.append(('if', a & 0x7F, struct.unpack('b', d[o:o + 1])[0])); o += 1; continue
        if a & 0x20:                               # dots (draw call stubbed in 1991 code)
            n = a & 0x1F; out.append(('dots', d[o], list(d[o + 1:o + 1 + n]))); o += 1 + n; continue
        if a & 0x40:                               # lines: n=a&1f, colour, n edge indices
            n = a & 0x1F; out.append(('lines', d[o], list(d[o + 1:o + 1 + n]))); o += 1 + n; continue
        n = a                                      # polygon: n edge indices then colour
        out.append(('poly', d[o + n], list(d[o:o + n]))); o += n + 1


def parse_3dx(d):
    n = u16(d, 0)
    offs = [u16(d, 2 + 2 * i) for i in range(n + 1)]
    attrs = d[4 + 2 * n:4 + 3 * n]
    objs = []
    for i in range(n):
        o = offs[i]; lods = []
        while True:
            t, lo = u16(d, o), u16(d, o + 2); o += 4
            lods.append((t, lo))
            if t >= 0x8000: break
        objs.append(lods)
    vo = offs[n]; vc = u16(d, vo)
    vec = [struct.unpack_from('<3h', d, vo + 2 + 6 * i) for i in range(vc)]
    return n, offs, attrs, objs, vec


def names_for(path):
    base = os.path.basename(path).upper()
    wp = os.path.join(os.path.dirname(path), base[:2] + '.WLD')
    if base[2:] == '.3DX' and os.path.exists(wp):
        return parse_wld(open(wp, 'rb').read())['strings']
    return []


def dump_3dx(d, path):
    n, offs, attrs, objs, vec = parse_3dx(d)
    S = names_for(path); L = []
    L.append('3DX  objects=%d  vector-table@%04X (%d vectors)  data@%04X size=%d' % (n, offs[n], len(vec), offs[0], len(d)))
    L.append('# idx off  attr  LODs (maxdepth->block)  | block: radius parts verts planes edges lists  [WLD name(?)]')
    seen = {}
    for i in range(n):
        lods = objs[i]
        L.append('%3d %04X  %02X  %s  %s' % (i, offs[i], attrs[i],
                 ' '.join('%s->%04X' % ('inf' if t >= 0x8000 else '%d' % t, lo) for t, lo in lods),
                 ('[%s]' % S[i]) if i < len(S) and S[i] else ''))
        for t, lo in lods:
            if lo in seen: continue
            try:
                b = parse_lod(d, lo); seen[lo] = b
                np_ = sum(1 for _, l in b.lists for c in l if c[0] == 'poly')
                cols = sorted(set(c[1] for _, l in b.lists for c in l if c[0] != 'if'))
                L.append('      @%04X r=%d parts=%d verts=%d planes=%d edges=%d polys=%d end=%04X cols=%s'
                         % (lo, b.radius, b.nparts, b.nverts, b.nplanes, len(b.edges), np_, b.end,
                            ' '.join('%02X' % c for c in cols)))
            except Exception as e:
                L.append('      @%04X parse error %r' % (lo, e)); seen[lo] = None
    return L, seen


# ---------------------------------------------------------------- 3DG / 3DT
def dump_3dg(d):
    L = ['3DG  w0=%04X (VGAME [075e])  skipped16=%s' % (u16(d, 0), d[2:18].hex(' '))]
    L.append('# level-3 grid 16x16 (VGAME 9f98): tile index into level-2 tiles')
    for y in range(16): L.append(' '.join('%02X' % b for b in d[18 + 16 * y:34 + 16 * y]))
    for name, base in (('level-2 tiles (9d40)', 274), ('level-1 tiles (9b38)', 786), ('level-0 tiles (9934)', 1298)):
        L.append('# %s: 32 tiles x 4x4' % name)
        for t in range(32):
            q = d[base + 16 * t:base + 16 * t + 16]
            L.append('%2d  %s' % (t, ' | '.join(q[4 * r:4 * r + 4].hex(' ') for r in range(4))))
    return L


def dump_3dt(d):
    L = ['3DT  w0=%04X (VGAME [0612])' % u16(d, 0)]
    cnt = struct.unpack_from('<5H', d, 2); p = 12; m = []
    for i in range(5):
        m.append(struct.unpack_from('<%dH' % cnt[i], d, p)); p += 2 * cnt[i]
    for lv in range(5):
        L.append('# level %d (%d tile codes)' % (lv, cnt[lv]))
        for t in range(cnt[lv]):
            if not m[lv][t]: continue
            recs = []
            for _ in range(m[lv][t]):
                x, y, z, s = struct.unpack_from('<3hH', d, p); p += 8
                recs.append('(%d,%d,%d %s%02X)' % (x, y, z, '*' if s & 0x80 else '', s & 0x7F))
            L.append(' t%02X: %s' % (t, ' '.join(recs)))
    L.append('end %d / %d' % (p, len(d)))
    return L


# ---------------------------------------------------------------- render
def load_pal():
    for nm in ('FLIGHT.PAL', 'ADV.PAL'):
        p = os.path.join(GAME, nm)
        if os.path.exists(p):
            raw = open(p, 'rb').read()[:768]
            sc = 4 if max(raw) < 64 else 1
            return [tuple(min(255, c * sc) for c in raw[3 * i:3 * i + 3]) for i in range(256)]
    return [(i, i, i) for i in range(256)]


def render(d, idx, png, lod_i=0):
    from PIL import Image, ImageDraw
    n, offs, attrs, objs, vec = parse_3dx(d)
    b = parse_lod(d, objs[idx][lod_i][1])
    V = b.verts if b.nverts >= 0 else [vec[i] + (0,) for i in b.vref]
    pal = load_pal()
    W = 512; img = Image.new('RGB', (W, W), (40, 40, 60)); dr = ImageDraw.Draw(img)
    import math
    ca, sa, ce, se = math.cos(0.6), math.sin(0.6), math.cos(0.5), -math.sin(0.5)
    def prj(v):  # yaw about Y, then pitch so the camera looks down; +Y is up (objects stand on y=0)
        x, y, z = v[0], v[1], v[2]
        x, z = x * ca - z * sa, x * sa + z * ca
        y, z = y * ce - z * se, y * se + z * ce
        return x, -y, z
    P = [prj(v) for v in V]
    ext = max(1, max(max(abs(p[0]), abs(p[1])) for p in P))
    sc = (W / 2 - 20) / ext
    S2 = lambda p: (W / 2 + p[0] * sc, W / 2 + p[1] * sc)
    polys = []
    for _, lst in b.lists:
        for c in lst:
            if c[0] == 'poly' and c[1] != 0xFF:
                loop = chain(b.edges, c[2])
                if len(loop) >= 3 and all(i < len(P) for i in loop):
                    polys.append((sum(P[i][2] for i in loop) / len(loop), c[1], loop))
            elif c[0] == 'lines':
                for e in c[2]:
                    a, bb = b.edges[e]
                    if a < len(P) and bb < len(P): polys.append((-1e9, c[1], [a, bb]))
    for z, col, loop in sorted(polys, key=lambda t: -t[0]):
        pts = [S2(P[i]) for i in loop]
        if len(pts) == 2: dr.line(pts, fill=pal[col], width=2)
        else: dr.polygon(pts, fill=pal[col], outline=(0, 0, 0))
    img.save(png)
    return len(polys)


def chain(edges, el):
    """Polygon given as edge indices -> ordered vertex loop."""
    segs = [edges[e] for e in el if e < len(edges)]
    if not segs: return []
    loop = list(segs[0]); rest = segs[1:]
    while rest:
        for k, (a, b) in enumerate(rest):
            if a == loop[-1]: loop.append(b); break
            if b == loop[-1]: loop.append(a); break
        else:
            a, b = rest[0]; loop.append(a); k = 0
        rest.pop(k)
    if loop[0] == loop[-1]: loop.pop()
    return loop


def main():
    args = sys.argv[1:]; rnd = None
    if '--render' in args:
        i = args.index('--render'); rnd = int(args[i + 1], 0); del args[i:i + 2]
    os.makedirs(OUT, exist_ok=True)
    for f in args:
        d = open(f, 'rb').read(); ext = os.path.splitext(f)[1].upper(); base = os.path.basename(f)
        if ext == '.WLD': L = dump_wld(d)
        elif ext == '.3DX':
            L, _ = dump_3dx(d, f)
            if rnd is not None:
                png = os.path.join(OUT, '%s_obj%02d.png' % (base, rnd))
                L.append('rendered obj %d -> %s (%d prims)' % (rnd, png, render(d, rnd, png)))
        elif ext == '.3DG': L = dump_3dg(d)
        elif ext == '.3DT': L = dump_3dt(d)
        else: print('unknown', f); continue
        out = os.path.join(OUT, base + '.txt')
        open(out, 'w', encoding='utf-8').write('\n'.join(L) + '\n')
        print(out, len(L), 'lines')


if __name__ == '__main__':
    main()
