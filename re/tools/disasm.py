"""Recursive-descent 16-bit disassembler for unpacked MZ executables (MS C 6 / MASM).
usage: py -3 disasm.py IN.EXE OUTDIR
Writes OUTDIR/NAME.asm, NAME.funcs.txt, NAME.segs.txt, NAME.data.txt
Needs capstone.
"""
import os, re, struct, sys
from collections import defaultdict
from capstone import Cs, CS_ARCH_X86, CS_MODE_16
from capstone.x86 import X86_OP_IMM, X86_OP_MEM, X86_OP_REG, X86_REG_BX, X86_REG_CS, X86_REG_DS

src = open(sys.argv[1], 'rb').read()
outdir = sys.argv[2]
name = os.path.splitext(os.path.basename(sys.argv[1]))[0].upper()
os.makedirs(outdir, exist_ok=True)

h = struct.unpack_from('<14H', src, 0)
is_com = src[:2] != b'MZ'
if is_com:
    img = bytearray(src)
    relocs = []
    e_ip, e_cs, e_ss, e_sp = 0x100, 0, 0, 0
    img = bytearray(b'\0' * 0x100) + img
else:
    hsize = h[4] * 16
    img = bytearray(src[hsize:])
    relocs = [struct.unpack_from('<HH', src, h[12] + 4 * i) for i in range(h[3])]
    e_ip, e_cs, e_ss, e_sp = h[10], h[11], h[7], h[8]
N = len(img)

# relocation targets: linear addresses of segment words
reloc_lin = sorted(set((s << 4) + o for o, s in relocs))
reloc_set = set(reloc_lin)
seg_values = set()
for a in reloc_lin:
    if a + 1 < N:
        seg_values.add(img[a] | (img[a + 1] << 8))
seg_values.add(e_cs)
segs = sorted(seg_values)

def w16(a): return img[a] | (img[a + 1] << 8) if a + 1 < N else 0

# DGROUP detection: "mov ax, SEG" (B8 reloc) followed by "mov ds,ax"(8E D8) or "mov es,ax"(8E C0)
dgroup = None
cands = defaultdict(int)
for a in reloc_lin:
    if a >= 1 and img[a - 1] == 0xB8 and a + 2 < N and img[a + 2] == 0x8E and img[a + 3] in (0xD8, 0xC0):
        cands[w16(a)] += 1
if cands:
    dgroup = max(cands, key=cands.get)
elif not is_com:
    dgroup = e_ss
if is_com:
    dgroup = 0
dg_lin = dgroup << 4

md = Cs(CS_ARCH_X86, CS_MODE_16)
md.detail = True

def seg_of(lin):
    """best segment for a linear address: largest seg value with seg*16 <= lin"""
    best = 0
    for s in segs:
        if s * 16 <= lin:
            best = s
        else:
            break
    return best

def fmt(lin, seg=None):
    if seg is None:
        seg = seg_of(lin)
    return '%04X:%04X' % (seg, lin - seg * 16)

# ---------------- strings in image ----------------
strings = {}
for m in re.finditer(rb'[\x20-\x7e\r\n\t]{4,}\x00', bytes(img)):
    strings[m.start()] = m.group()[:-1].decode('ascii')
def str_at(lin):
    s = strings.get(lin)
    if s is None:
        return None
    s = s.replace('\r', '\\r').replace('\n', '\\n').replace('\t', '\\t')
    return s[:60] + ('...' if len(s) > 60 else '')

# ---------------- recursive descent ----------------
insns = {}        # lin -> (size, text, mnemonic, op_str, insn)
code = bytearray(N)   # 1 = code
func_starts = set()
queue = []
labels = defaultdict(set)   # target lin -> set of (from lin, kind)
calls = defaultdict(set)    # func -> callees  (computed later)
jmptabs = {}

def add(lin, kind, frm=None, func=False):
    if 0 <= lin < N:
        if func:
            func_starts.add(lin)
        if frm is not None:
            labels[lin].add((frm, kind))
        if not code[lin]:
            queue.append(lin)

add(e_cs * 16 + e_ip, 'entry', func=True)
# extra seeds: argv[3] = "vtab:HEXOFF:COUNT" (table of near offsets in segment 0) or comma list of hex linear addrs
if len(sys.argv) > 3:
    for spec in sys.argv[3].split(','):
        if spec.startswith('vtab:'):
            _, off, cnt = spec.split(':')
            off, cnt = int(off, 16), int(cnt)
            for k in range(cnt):
                add(w16(off + 2 * k), 'vtab%d' % k, off + 2 * k, func=True)
        else:
            add(int(spec, 16), 'seed', func=True)
# seed: far pointers in data (reloc'd segment preceded by an offset word) pointing into code-ish area
far_ptrs = []
for a in reloc_lin:
    seg = w16(a)
    off = w16(a - 2) if a >= 2 else 0
    tgt = seg * 16 + off
    far_ptrs.append((a, tgt))

def is_prologue(lin):
    b = img[lin:lin + 3]
    return b[:1] == b'\x55' or b[:3] == b'\xc8\x00\x00' or b[:2] == b'\x56\x57' or b[:1] == b'\xc8'

def decode(lin):
    for i in md.disasm(bytes(img[lin:lin + 15]), lin):
        return i
    return None

def resolve_jmptab(i, lin, cur_seg):
    """jmp word ptr [bx+disp] / cs:[bx+disp] : MS C switch tables"""
    op = i.operands[0]
    if op.type != X86_OP_MEM or op.mem.base != X86_REG_BX or op.mem.index != 0:
        return
    base = (cur_seg * 16 if op.mem.segment == X86_REG_CS else dg_lin) + (op.mem.disp & 0xffff)
    jmptabs[lin] = base
    n = 0
    while n < 512:
        a = base + 2 * n
        if a + 1 >= N or code[a]:
            break
        t = cur_seg * 16 + w16(a)
        if t >= N or t < cur_seg * 16 or t == 0:
            break
        # sanity: target must decode
        d = decode(t)
        if d is None:
            break
        add(t, 'case', lin)
        n += 1
    jmptabs[lin] = (base, n)

work_sweep = True
while queue:
    lin = queue.pop()
    if code[lin]:
        continue
    cur_seg = seg_of(lin)
    while lin < N and not code[lin]:
        i = decode(lin)
        if i is None:
            break
        for k in range(lin, lin + i.size):
            code[k] = 1
        insns[lin] = i
        m = i.mnemonic
        grp = i.groups
        if m in ('call', 'lcall'):
            op = i.operands[0]
            if op.type == X86_OP_IMM:
                if m == 'lcall' or i.bytes[0] == 0x9A:
                    t = (i.bytes[4] | (i.bytes[3] << 8)) if False else 0
                    seg = w16(lin + 3); off = w16(lin + 1)
                    add(seg * 16 + off, 'call', lin, func=True)
                else:
                    add(cur_seg * 16 + (op.imm & 0xffff), 'call', lin, func=True)
        elif m in ('jmp', 'ljmp'):
            op = i.operands[0]
            if op.type == X86_OP_IMM:
                if i.bytes[0] == 0xEA:
                    seg = w16(lin + 3); off = w16(lin + 1)
                    add(seg * 16 + off, 'jmp', lin)
                else:
                    add(cur_seg * 16 + (op.imm & 0xffff), 'jmp', lin)
            else:
                resolve_jmptab(i, lin, cur_seg)
            break
        elif m.startswith('j') or m in ('loop', 'loope', 'loopne', 'jcxz'):
            op = i.operands[0]
            if op.type == X86_OP_IMM:
                add(cur_seg * 16 + (op.imm & 0xffff), 'jcc', lin)
        elif m in ('ret', 'retf', 'iret', 'iretd', 'hlt'):
            break
        elif m == 'int' and i.operands[0].imm in (0x20, 0x21) and False:
            break
        lin += i.size
    # also sweep: after a function ends, if next bytes look like a prologue, continue (handles noreturn calls)
    if not queue and work_sweep:
        # seed far pointers once
        work_sweep = False
        for a, t in far_ptrs:
            if t < N and not code[t] and is_prologue(t):
                add(t, 'farptr', a, func=True)
        # seed unexplored gaps that start with a prologue after a ret
        for s in range(N):
            pass

# second pass: gap sweep — bytes after a decoded function that begin with push bp/mov bp,sp
changed = True
while changed:
    changed = False
    a = 0
    while a < N:
        if code[a]:
            a += 1
            continue
        if a > 0 and code[a - 1] and a < dg_lin and img[a:a + 3] == b'\x55\x8b\xec':
            add(a, 'sweep', func=True)
            changed = True
            # run queue
            while queue:
                lin = queue.pop()
                if code[lin]:
                    continue
                cur_seg = seg_of(lin)
                while lin < N and not code[lin]:
                    i = decode(lin)
                    if i is None:
                        break
                    for k in range(lin, lin + i.size):
                        code[k] = 1
                    insns[lin] = i
                    m = i.mnemonic
                    if m in ('call', 'lcall'):
                        op = i.operands[0]
                        if op.type == X86_OP_IMM:
                            if i.bytes[0] == 0x9A:
                                add(w16(lin + 3) * 16 + w16(lin + 1), 'call', lin, func=True)
                            else:
                                add(cur_seg * 16 + (op.imm & 0xffff), 'call', lin, func=True)
                    elif m in ('jmp', 'ljmp'):
                        op = i.operands[0]
                        if op.type == X86_OP_IMM:
                            if i.bytes[0] == 0xEA:
                                add(w16(lin + 3) * 16 + w16(lin + 1), 'jmp', lin)
                            else:
                                add(cur_seg * 16 + (op.imm & 0xffff), 'jmp', lin)
                        else:
                            resolve_jmptab(i, lin, cur_seg)
                        break
                    elif m.startswith('j') or m in ('loop', 'loope', 'loopne', 'jcxz'):
                        op = i.operands[0]
                        if op.type == X86_OP_IMM:
                            add(cur_seg * 16 + (op.imm & 0xffff), 'jcc', lin)
                    elif m in ('ret', 'retf', 'iret', 'hlt'):
                        break
                    lin += i.size
        a += 1

# ---------------- function ranges ----------------
fstarts = sorted(f for f in func_starts if f in insns)
func_of = {}
franges = []
for idx, f in enumerate(fstarts):
    end = fstarts[idx + 1] if idx + 1 < len(fstarts) else N
    # function extends over contiguous code until next func start
    a = f
    while a < end and code[a]:
        a += 1
    franges.append((f, a))
    for k in range(f, a):
        func_of[k] = f

callees = defaultdict(set)
callers = defaultdict(set)
for lin, i in insns.items():
    if i.mnemonic in ('call', 'lcall') and i.operands[0].type == X86_OP_IMM:
        if i.bytes[0] == 0x9A:
            t = w16(lin + 3) * 16 + w16(lin + 1)
        else:
            t = seg_of(lin) * 16 + (i.operands[0].imm & 0xffff)
        f = func_of.get(lin)
        if f is not None and t in func_of:
            callees[f].add(t)
            callers[t].add(f)

# ---------------- annotations ----------------
def annotate(lin, i):
    notes = []
    # relocated segment immediates inside this instruction
    for k in range(lin, lin + i.size):
        if k in reloc_set:
            notes.append('seg %04X' % w16(k))
    for op in i.operands:
        if op.type == X86_OP_IMM:
            v = op.imm & 0xffff
            if i.mnemonic in ('push', 'mov', 'add', 'cmp', 'sub', 'lea') and dgroup is not None:
                s = str_at(dg_lin + v)
                if s is not None:
                    notes.append('ds:%04X "%s"' % (v, s))
                elif (dg_lin + v) in func_of and False:
                    pass
        elif op.type == X86_OP_MEM and op.mem.base == 0 and op.mem.index == 0 and dgroup is not None:
            v = op.mem.disp & 0xffff
            if op.mem.segment in (0, X86_REG_DS):
                s = str_at(dg_lin + v)
                if s is not None:
                    notes.append('"%s"' % s)
    # far pointer operand targets
    if i.bytes[0] in (0x9A, 0xEA):
        t = w16(lin + 3) * 16 + w16(lin + 1)
        notes.append('-> %s' % fmt(t))
    return notes

# ---------------- write asm ----------------
out = []
out.append('; %s  image=%d bytes  entry=%s  dgroup=%04X  segs=%s' % (
    name, N, fmt(e_cs * 16 + e_ip, e_cs), dgroup or 0, ' '.join('%04X' % s for s in segs)))
a = 0
cur_func = None
while a < N:
    if a in insns:
        i = insns[a]
        if a in func_of and func_of[a] == a:
            out.append('')
            out.append('; ===== func_%s  callers=%d callees=%d =====' % (
                fmt(a).replace(':', '_'), len(callers[a]), len(callees[a])))
            out.append('func_%s:' % fmt(a).replace(':', '_'))
        elif a in labels:
            kinds = set(k for _, k in labels[a])
            out.append('loc_%s:    ; <- %s' % (fmt(a).replace(':', '_'),
                        ' '.join(sorted('%s:%s' % (k, fmt(f)) for f, k in labels[a])[:6])))
        notes = annotate(a, i)
        txt = '%s %s' % (i.mnemonic, i.op_str)
        # rewrite near call/jmp targets with labels
        if i.mnemonic in ('call', 'jmp') or i.mnemonic.startswith('j') or i.mnemonic.startswith('loop'):
            op = i.operands[0]
            if op.type == X86_OP_IMM and i.bytes[0] not in (0x9A, 0xEA):
                t = seg_of(a) * 16 + (op.imm & 0xffff)
                pre = 'func_' if t in func_of and func_of[t] == t else 'loc_'
                txt = '%s %s%s' % (i.mnemonic, pre, fmt(t).replace(':', '_'))
        if i.bytes[0] in (0x9A, 0xEA):
            t = w16(a + 3) * 16 + w16(a + 1)
            txt = '%s func_%s' % ('call far' if i.bytes[0] == 0x9A else 'jmp far', fmt(t).replace(':', '_'))
            notes = [n for n in notes if not n.startswith('->') and not n.startswith('seg')]
        if a in jmptabs:
            base, n = jmptabs[a]
            notes.append('jumptable @%s x%d' % (fmt(base), n))
        bs = ' '.join('%02X' % b for b in i.bytes)
        line = '  %s  %-22s %-40s' % (fmt(a), bs, txt)
        if notes:
            line += ' ; ' + ' | '.join(notes)
        out.append(line.rstrip())
        a += i.size
    else:
        # data run
        s = a
        while a < N and a not in insns:
            a += 1
        out.append('')
        out.append('; ----- data %s .. %s (%d bytes) -----' % (fmt(s), fmt(a - 1), a - s))
        # print strings & far pointers within the run
        for k in range(s, a):
            if k in strings:
                out.append(';   %s  "%s"' % (fmt(k), str_at(k)))
        k = s
        while k < min(a, s + 64):
            out.append(';   %s  %s' % (fmt(k), ' '.join('%02X' % b for b in img[k:min(k + 16, a)])))
            k += 16
        if a - s > 64:
            out.append(';   ...')

open(os.path.join(outdir, name + '.asm'), 'w', encoding='utf-8').write('\n'.join(out) + '\n')

# ---------------- function table ----------------
fo = ['# %s functions: %d   (addr size callers callees strings)' % (name, len(franges))]
for f, e in franges:
    strs = []
    for k in range(f, e):
        if k in insns:
            for n in annotate(k, insns[k]):
                if '"' in n:
                    strs.append(n.split('"')[1][:30])
    strs = list(dict.fromkeys(strs))[:6]
    fo.append('%s %5d  callers=%-3d callees=%-3d %s' % (fmt(f), e - f, len(callers[f]), len(callees[f]),
              (' | '.join(strs))))
open(os.path.join(outdir, name + '.funcs.txt'), 'w', encoding='utf-8').write('\n'.join(fo) + '\n')

# ---------------- segment table ----------------
so = ['# %s segments (paragraph values seen in relocations + entry). dgroup=%04X' % (name, dgroup or 0)]
for idx, s in enumerate(segs):
    start = s * 16
    end = segs[idx + 1] * 16 if idx + 1 < len(segs) else N
    ncode = sum(1 for f, _ in franges if start <= f < end)
    so.append('%04X  lin=%06X..%06X  size=%6d  funcs=%d' % (s, start, end, end - start, ncode))
open(os.path.join(outdir, name + '.segs.txt'), 'w', encoding='utf-8').write('\n'.join(so) + '\n')

# ---------------- data xrefs: which functions reference each string ----------------
dx = defaultdict(set)
for lin, i in insns.items():
    for n in annotate(lin, i):
        if '"' in n and lin in func_of:
            dx[n.split('"')[1]].add(fmt(func_of[lin]))
do = ['# %s string -> referencing functions' % name]
for s in sorted(dx):
    do.append('%-50s %s' % (s[:50], ' '.join(sorted(dx[s]))))
open(os.path.join(outdir, name + '.data.txt'), 'w', encoding='utf-8').write('\n'.join(do) + '\n')

print('%s: %d insns, %d funcs, %d segs, dgroup=%04X, code bytes=%d/%d' % (
    name, len(insns), len(franges), len(segs), dgroup or 0, sum(code), N))
