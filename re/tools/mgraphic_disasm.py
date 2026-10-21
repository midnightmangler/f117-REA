"""Recursive-descent disassembly of the MGRAPHIC.EXE overlay (code segment 019C).

The generic disasm.py listing treats the whole image as code from 0000:0000, which is wrong:
segment 0000 (0x19C0 bytes) is the driver's DATA (header, vector table, fonts, tables, state),
segment 019C is the CODE. The 84 exported entries are near offsets into segment 019C.

usage: py -3 -I re/tools/mgraphic_disasm.py <re-dir>
writes re/out/mgraphic/MGRAPHIC_code.asm
"""
import struct, sys, os
from capstone import Cs, CS_ARCH_X86, CS_MODE_16

re_dir = sys.argv[1]
d = open(os.path.join(re_dir, 'unpacked', 'MGRAPHIC.EXE'), 'rb').read()
hdr = struct.unpack('<H', d[8:10])[0] * 16
im = d[hdr:]
CSEG = struct.unpack('<H', im[0x18:0x1A])[0]
cbase = CSEG * 16
code = im[cbase:]
n = struct.unpack('<H', im[0x22:0x24])[0]
vec = struct.unpack('<%dH' % n, im[0x24:0x24 + 2 * n])
nrel = struct.unpack('<H', d[6:8])[0]
reltab = struct.unpack('<H', d[0x18:0x1A])[0]
relocs = set()
for i in range(nrel):
    o, s = struct.unpack('<HH', d[reltab + 4 * i: reltab + 4 * i + 4])
    relocs.add(s * 16 + o)

md = Cs(CS_ARCH_X86, CS_MODE_16)
md.detail = False
insns = {}
labels = {}
entries = {}
for i, v in enumerate(vec):
    entries.setdefault(v, []).append(i)
    labels[v] = 'entry'
work = list(vec)
while work:
    a = work.pop()
    while a < len(code) and a not in insns:
        try:
            ins = next(md.disasm(code[a:a + 16], a))
        except StopIteration:
            break
        insns[a] = ins
        m = ins.mnemonic
        nxt = a + ins.size
        if m.startswith('j') or m in ('call', 'loop', 'loope', 'loopne', 'jcxz'):
            op = ins.op_str
            try:
                t = int(op, 16)
                labels.setdefault(t, 'loc' if m != 'call' else 'sub')
                if m == 'call':
                    labels[t] = 'sub'
                work.append(t)
            except ValueError:
                pass
            if m == 'jmp':
                break
        if m == 'lcall' and ins.op_str.startswith('0x19c,'):
            t = int(ins.op_str.split(',')[1], 16)
            labels[t] = 'sub'
            work.append(t)
        if m in ('ret', 'retf', 'iret', 'hlt'):
            break
        a = nxt

out = []
out.append('; MGRAPHIC code segment %04X (linear %05X), %d bytes; data segment 0000 = image start' % (CSEG, cbase, len(code)))
prev_end = None
for a in sorted(insns):
    ins = insns[a]
    if prev_end is not None and a != prev_end:
        out.append('; ----- gap %04X..%04X: %s' % (prev_end, a - 1, code[prev_end:a].hex(' ')))
    if a in entries:
        out.append('')
        out.append('; ===== ENTRY %s  %04X:%04X =====' % (','.join('#%d' % e for e in entries[a]), CSEG, a))
    elif a in labels and labels[a] == 'sub':
        out.append('')
        out.append('; ===== sub_%04X =====' % a)
    if a in labels:
        out.append('L%04X:' % a)
    rel = ''
    for k in range(ins.size):
        if cbase + a + k in relocs:
            rel = '   ; <reloc: segment word at +%d = DATA seg>' % k
    out.append('  %04X  %-14s %-6s %s%s' % (a, ins.bytes.hex(), ins.mnemonic, ins.op_str, rel))
    prev_end = a + ins.size
os.makedirs(os.path.join(re_dir, 'out', 'mgraphic'), exist_ok=True)
open(os.path.join(re_dir, 'out', 'mgraphic', 'MGRAPHIC_code.asm'), 'w').write('\n'.join(out) + '\n')
print(len(insns), 'insns; code bytes', len(code))

