"""Cross-reference MGRAPHIC API entries to call sites in the game EXEs.

Each game EXE copies the overlay vector table into DGROUP as 5-byte `jmp far` thunks:
thunk(i) = base + 5*(overlay[+0x1C] + i)  (loader e.g. VGAME func_0FAE_0002, START 0000:8626).
MGRAPHIC's +0x1C word is 0, so thunk(i) = base + 5*i.

Call sites are found by scanning the unpacked EXE for the bytes `9A off seg` (call far thunk),
because the generic listings mis-disassemble parts of the assembly modules.
Address shown as SEG:OFF using the segment list from the listing header.

usage: py -3 -I re/tools/mgraphic_xref.py <re-dir>   -> prints table, writes re/out/mgraphic/xref.txt
"""
import re, sys, os, struct

re_dir = sys.argv[1]
EXES = {  # name: (dgroup seg, thunk base, header bytes)
    'VGAME': (0x1E42, 0x011A, 2352), 'START': (0x0A95, 0x69B8, 784), 'END': (0x05FA, 0x23FA, 592),
    'SETUP': (0x024C, 0x08A6, 176), 'DSWAP': (0x0225, 0x08DC, 176), 'PLAYER': (0x02A3, 0x11C0, 128),
}
N = 84
rows = {i: [] for i in range(N)}
for name, (seg, base, hdr) in EXES.items():
    d = open(os.path.join(re_dir, 'unpacked', name + '.EXE'), 'rb').read()
    first = open(os.path.join(re_dir, 'disasm', name + '.asm')).readline()
    m = re.search(r'segs=([0-9A-F ]+)', first)
    segs = sorted(int(s, 16) for s in m.group(1).split()) if m else [0]
    for i in range(N):
        pat = b'\x9a' + struct.pack('<HH', base + 5 * i, seg)
        sites = []
        p = d.find(pat)
        while p >= 0:
            lin = p - hdr
            s = max(x for x in segs if x * 16 <= lin)
            sites.append('%04X:%04X' % (s, lin - s * 16))
            p = d.find(pat, p + 1)
        if sites:
            rows[i].append('%s %04X:%04X x%d [%s]' % (name, seg, base + 5 * i, len(sites),
                           ' '.join(sites[:8]) + (' ...' if len(sites) > 8 else '')))
out = ['#%-2d %s' % (i, '; '.join(rows[i]) if rows[i] else 'UNUSED') for i in range(N)]
txt = '\n'.join(out)
print(txt)
os.makedirs(os.path.join(re_dir, 'out', 'mgraphic'), exist_ok=True)
open(os.path.join(re_dir, 'out', 'mgraphic', 'xref.txt'), 'w').write(txt + '\n')
