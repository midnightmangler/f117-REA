"""Per-segment capstone disassembly of the VGAME.EXE assembly modules (and code islands).

usage:
  py -3 vgame_asm.py [EXE] --segs 0FB2,1058,... [--out DIR] [--vtab SEG:OFF:N ...] [--seed SEG:OFF[:kind] ...] [--bytes]
      (quote the --segs list in PowerShell: 130D parses as a decimal literal otherwise)
      one listing per segment: DIR/SEG.asm (default DIR = re/disasm/vgame-asm next to this file's re/)
      plus DIR/index.txt (every entry point, size, frame type, callers from C / from asm)
  py -3 vgame_asm.py [EXE] --range SEG:OFF LEN [--bytes]
      linear disassembly of a byte range to stdout (code islands inside C functions)

EXE defaults to Dropbox re/unpacked/VGAME.EXE (override with env F117_RE = re/ dir, or give the path).
Seeds for a segment: every far call/jmp in the image whose relocated segment word is this segment, far pointers in
data that land on code, --vtab tables of near offsets, --seed entries, a sweep for C prologues after decoded code,
then near calls/jumps/jump tables found while descending. Gaps are dumped as data (full hex), never guessed as code.
Segment paragraph values are the first far-called entry of each module rounded down, so a module's last bytes sit in
the next "segment"; near transfers may follow code past that boundary and the listing extends to cover them.
Needs capstone.
"""
import os, re, struct, sys
from collections import defaultdict
from capstone import Cs, CS_ARCH_X86, CS_MODE_16
from capstone.x86 import X86_OP_IMM, X86_OP_MEM, X86_REG_BX, X86_REG_CS, X86_REG_DS, X86_REG_SI, X86_REG_DI

HERE = os.path.dirname(os.path.abspath(__file__))
RE_DIR = os.environ.get('F117_RE', r'C:\Dropbox\Game Projects\F117-REA\re')
DEFAULT_EXE = os.path.join(RE_DIR, 'unpacked', 'VGAME.EXE')
DEFAULT_OUT = os.path.join(HERE, '..', 'disasm', 'vgame-asm')
THUNK_BASE, THUNK_END = 0x11A, 0x322            # DGROUP driver thunks, 5 bytes each (vgame-map.md §4)

# ---------------- args ----------------
args = sys.argv[1:]
exe = DEFAULT_EXE
if args and not args[0].startswith('--'):
    exe = args.pop(0)
opt = {'segs': None, 'out': DEFAULT_OUT, 'vtab': [], 'seed': [], 'bytes': False, 'range': None}
i = 0
while i < len(args):
    a = args[i]
    if a == '--segs':
        opt['segs'] = [int(x, 16) for x in args[i + 1].split(',')]; i += 2
    elif a == '--out':
        opt['out'] = args[i + 1]; i += 2
    elif a == '--vtab':
        opt['vtab'].append(args[i + 1]); i += 2
    elif a == '--bytes':
        opt['bytes'] = True; i += 1
    elif a == '--seed':
        opt['seed'].append(args[i + 1]); i += 2
    elif a == '--range':
        opt['range'] = (args[i + 1], int(args[i + 2], 0)); i += 3
    else:
        sys.exit('unknown option ' + a)

# ---------------- image ----------------
src = open(exe, 'rb').read()
h = struct.unpack_from('<14H', src, 0)
hsize = h[4] * 16
img = src[hsize:]
N = len(img)
relocs = sorted(set(((s << 4) + o) for o, s in (struct.unpack_from('<HH', src, h[12] + 4 * k) for k in range(h[3]))))
reloc_set = set(relocs)

def w16(a):
    return img[a] | (img[a + 1] << 8) if 0 <= a + 1 < N else 0

seg_values = sorted(set(w16(a) for a in relocs) | {h[11]})
# DGROUP: most common "mov ax,SEG / mov ds|es,ax"
cands = defaultdict(int)
for a in relocs:
    if a >= 1 and img[a - 1] == 0xB8 and img[a + 2] == 0x8E and img[a + 3] in (0xD8, 0xC0):
        cands[w16(a)] += 1
DGROUP = max(cands, key=cands.get)
DG_LIN = DGROUP << 4

def seg_end(seg):
    later = [s for s in seg_values if s > seg]
    return min(later) << 4 if later else N

md = Cs(CS_ARCH_X86, CS_MODE_16)
md.detail = True

# far call / jmp sites anywhere in the image: reloc at lin+3 of a 9A/EA opcode
far_sites = []                       # (from_lin, target_lin, is_call)
far_ptrs = []                        # (at_lin, target_lin) data far pointers
for a in relocs:
    seg = w16(a)
    if a >= 3 and img[a - 3] in (0x9A, 0xEA):
        far_sites.append((a - 3, (seg << 4) + w16(a - 2), img[a - 3] == 0x9A))
    elif a >= 2:
        far_ptrs.append((a, (seg << 4) + w16(a - 2)))

# ---------------- helpers ----------------
def fmt(seg, off):
    return '%04X:%04X' % (seg, off & 0xFFFF)

def thunk_note(seg, off):
    if seg == DGROUP and THUNK_BASE <= off <= THUNK_END and (off - THUNK_BASE) % 5 == 0:
        return 'T:%04X slot %d' % (off, (off - THUNK_BASE) // 5)
    return None

def decode_at(seg, off):
    lin = (seg << 4) + off
    for ins in md.disasm(bytes(img[lin:lin + 15]), off):
        return ins
    return None

# ---------------- per-segment recursive descent ----------------
def disasm_segment(seg, vtabs, seeds):
    base = seg << 4
    end = seg_end(seg)
    nominal = end - base
    size = min(nominal + 64, N - base)      # a module's tail may run a few bytes past the next paragraph value
    insns = {}
    code = bytearray(size)
    funcs = {}                       # off -> set(kinds)
    labels = defaultdict(set)        # off -> set(kind:from)
    queue = []
    jmptabs = {}
    unresolved = []

    NEAR = ('call', 'jmp', 'jcc', 'case')

    def add(off, kind, frm=None, func=False):
        off &= 0xFFFF
        # only near transfers may reach past the next paragraph value (a module's tail); seeds stay inside
        if off >= (size if kind in NEAR else nominal):
            return
        if func:
            funcs.setdefault(off, set()).add(kind)
        if frm is not None:
            labels[off].add('%s:%s' % (kind, frm))
        if not code[off]:
            queue.append(off)

    for frm, tgt, is_call in far_sites:
        if base <= tgt < end:
            add(tgt - base, 'far' if is_call else 'farjmp', fmt_lin(frm), func=True)
    for at, tgt in far_ptrs:
        if base <= tgt < end:
            add(tgt - base, 'farptr', fmt_lin(at), func=True)
    for spec in vtabs:
        s, o, n = spec.split(':')
        if int(s, 16) != seg:
            continue
        o, n = int(o, 16), int(n)
        for k in range(n):
            t = w16(base + o + 2 * k)
            if t < size and decode_at(seg, t) is not None:
                add(t, 'vtab', fmt(seg, o + 2 * k), func=True)

    for spec in seeds:                      # SEG:OFF[:kind]  e.g. ISR entries reached only through vectors
        parts = spec.split(':')
        if int(parts[0], 16) == seg:
            add(int(parts[1], 16), parts[2] if len(parts) > 2 else 'seed', 'arg', func=True)

    def jmptab(ins, off):
        op = ins.operands[0]
        if op.type != X86_OP_MEM:
            unresolved.append((off, ins.mnemonic + ' ' + ins.op_str))
            return
        disp = op.mem.disp & 0xFFFF
        if op.mem.base != X86_REG_BX or op.mem.index != 0:
            unresolved.append((off, ins.mnemonic + ' ' + ins.op_str))
            return
        tab = base + disp if op.mem.segment == X86_REG_CS else DG_LIN + disp
        n = 0
        while n < 256:
            a = tab + 2 * n
            if a + 1 >= N:
                break
            if base <= a < end and code[a - base]:
                break
            t = w16(a)
            if t >= size or t == 0 or decode_at(seg, t) is None:
                break
            add(t, 'case', fmt(seg, off))
            n += 1
        jmptabs[off] = (tab, n)

    def run_queue():
        while queue:
            off = queue.pop()
            if code[off]:
                continue
            prev = None
            while off < size and not code[off]:
                ins = decode_at(seg, off)
                if ins is None:
                    break
                for k in range(off, min(off + ins.size, size)):
                    code[k] = 1
                insns[off] = ins
                m = ins.mnemonic
                b0 = ins.bytes[0]
                if m == 'int' and ins.operands[0].imm == 0x21 and prev is not None and prev.mnemonic == 'mov' and (
                        prev.op_str in ('ax, 0x4c00', 'ah, 0x4c')):
                    break                                      # DOS terminate: nothing follows
                prev = ins
                if m in ('call', 'lcall'):
                    op = ins.operands[0]
                    if b0 == 0x9A:
                        pass                                   # far call: seeds come from far_sites
                    elif op.type == X86_OP_IMM:
                        add(op.imm, 'call', fmt(seg, off), func=True)
                    else:
                        unresolved.append((off, m + ' ' + ins.op_str))
                elif m in ('jmp', 'ljmp'):
                    op = ins.operands[0]
                    if b0 == 0xEA:
                        pass
                    elif op.type == X86_OP_IMM:
                        add(op.imm, 'jmp', fmt(seg, off))
                    else:
                        jmptab(ins, off)
                    break
                elif m.startswith('j') or m.startswith('loop'):
                    op = ins.operands[0]
                    if op.type == X86_OP_IMM:
                        add(op.imm, 'jcc', fmt(seg, off))
                elif m in ('ret', 'retf', 'iret', 'iretw', 'hlt'):
                    break
                off += ins.size

    run_queue()
    # sweep: a gap that begins with a C-style prologue right after decoded code is a function nobody calls directly
    changed = True
    while changed:
        changed = False
        for a in range(1, nominal):
            if not code[a] and code[a - 1] and img[base + a: base + a + 3] in (b'\x55\x8b\xec', b'\xc8\x00\x00'):
                add(a, 'sweep', 'gap', func=True)
                run_queue()
                changed = True

    # listing extent: the nominal segment, extended to cover any code reached beyond it
    last = max(insns) if insns else 0
    size = nominal if last < nominal else (last + insns[last].size)
    # function ranges: from each entry up to the next entry or the end of contiguous code
    starts = sorted(f for f in funcs if f in insns)
    ranges = []
    for idx, f in enumerate(starts):
        lim = starts[idx + 1] if idx + 1 < len(starts) else size
        a = f
        while a < lim and code[a]:
            a += 1
        ranges.append((f, a))
    func_of = {}
    for f, e in ranges:
        for k in range(f, e):
            func_of[k] = f

    def frame_kind(f):
        b = img[base + f: base + f + 4]
        if b[:3] == b'\x55\x8b\xec' or b[:1] == b'\xc8':
            return 'bp-frame'
        if b[:2] in (b'\x56\x57', b'\x57\x56', b'\x1e\x06', b'\x06\x1e') or b[:1] in (b'\x50', b'\x53', b'\x51', b'\x52', b'\x56', b'\x57', b'\x1e', b'\x06'):
            return 'reg(saves)'
        if b[:1] in (b'\xe8', b'\xe9', b'\xeb'):
            return 'jump/call stub'
        return 'reg'

    callers = defaultdict(lambda: [0, 0])      # off -> [from C seg 0000, from other]
    for frm, tgt, is_call in far_sites:
        if base <= tgt < end and (tgt - base) in funcs:
            callers[tgt - base][0 if frm < (seg_values[1] << 4) else 1] += 1

    def ann(ins, off):
        notes = []
        for k in range(off, off + ins.size):
            if (base + k) in reloc_set:
                notes.append('seg %04X' % w16(base + k))
        if ins.bytes[0] in (0x9A, 0xEA):
            tseg, toff = w16(base + off + 3), w16(base + off + 1)
            t = thunk_note(tseg, toff)
            notes = [n for n in notes if not n.startswith('seg')]
            notes.append(t if t else '-> ' + fmt(tseg, toff))
        for op in ins.operands:
            if op.type == X86_OP_MEM and op.mem.base == 0 and op.mem.index == 0:
                d = op.mem.disp & 0xFFFF
                if op.mem.segment == X86_REG_CS:
                    notes.append('cs:%04X' % d)
                elif op.mem.segment in (0, X86_REG_DS):
                    notes.append('ds:%04X' % d)
        if off in jmptabs:
            tab, n = jmptabs[off]
            notes.append('jumptable @%s x%d' % (fmt_lin(tab), n))
        return notes

    out = ['; VGAME segment %04X  lin %05X..%05X  size %d%s  dgroup=%04X  (vgame_asm.py; capstone recursive descent)'
           % (seg, base, base + size, size, '' if size == nominal else ' (code runs past the next paragraph value; listed here)', DGROUP),
           '; entries: %d   far-call sites into this segment: %d   unresolved indirect jumps/calls: %d'
           % (len(starts), sum(1 for _, t, _ in far_sites if base <= t < end), len(unresolved))]
    a = 0
    while a < size:
        if a in insns:
            ins = insns[a]
            if a in funcs and func_of.get(a) == a:
                c = callers[a]
                out.append('')
                out.append('; ===== func_%04X_%04X  %s  callers: C=%d asm=%d  seeds=%s =====' % (
                    seg, a, frame_kind(a), c[0], c[1], ','.join(sorted(funcs[a]))))
                out.append('func_%04X_%04X:' % (seg, a))
            elif a in labels:
                out.append('loc_%04X_%04X:    ; <- %s' % (seg, a, ' '.join(sorted(labels[a])[:5])))
            txt = ins.mnemonic + ' ' + ins.op_str
            op = ins.operands[0] if ins.operands else None
            if op is not None and op.type == X86_OP_IMM and ins.bytes[0] not in (0x9A, 0xEA) and (
                    ins.mnemonic in ('call', 'jmp') or ins.mnemonic.startswith('j') or ins.mnemonic.startswith('loop')):
                t = op.imm & 0xFFFF
                pre = 'func' if func_of.get(t) == t else 'loc'
                txt = '%s %s_%04X_%04X' % (ins.mnemonic, pre, seg, t)
            if ins.bytes[0] in (0x9A, 0xEA):
                tseg, toff = w16(base + a + 3), w16(base + a + 1)
                txt = '%s %s' % ('call far' if ins.bytes[0] == 0x9A else 'jmp far', 'func_%04X_%04X' % (tseg, toff))
            notes = ann(ins, a)
            if opt['bytes']:
                line = '  %s  %-20s %-36s' % (fmt(seg, a), ' '.join('%02X' % b for b in ins.bytes), txt)
            else:
                line = '  %s  %-36s' % (fmt(seg, a), txt)
            if notes:
                line += ' ; ' + ' | '.join(notes)
            out.append(line.rstrip())
            a += ins.size
        else:
            s = a
            while a < size and a not in insns:
                a += 1
            out.append('')
            out.append('; ----- data %s .. %s (%d bytes) -----' % (fmt(seg, s), fmt(seg, a - 1), a - s))
            for k in range(s, a, 16):
                chunk = img[base + k: base + min(k + 16, a)]
                asc = ''.join(chr(b) if 32 <= b < 127 else '.' for b in chunk)
                out.append(';   %s  %-48s %s' % (fmt(seg, k), ' '.join('%02X' % b for b in chunk), asc))
            relp = [fmt(seg, r - base - 2) for r in relocs if base + s <= r < base + a]
            if relp:
                out.append(';   far pointers (offset,seg) at: ' + ' '.join(relp))
    if unresolved:
        out.append('')
        out.append('; unresolved indirect transfers:')
        for off, t in unresolved:
            out.append(';   %s  %s' % (fmt(seg, off), t))
    index = []
    for f, e in ranges:
        c = callers[f]
        index.append('%s %5d  %-12s C=%-3d asm=%-3d %s' % (fmt(seg, f), e - f, frame_kind(f), c[0], c[1],
                                                           ','.join(sorted(funcs[f]))))
    return '\n'.join(out) + '\n', index, len(insns), sum(code[:size]), size

def fmt_lin(lin):
    seg = 0
    for s in seg_values:
        if (s << 4) <= lin:
            seg = s
        else:
            break
    return fmt(seg, lin - (seg << 4))

# ---------------- range mode (linear) ----------------
def disasm_range(spec, length):
    s, o = spec.split(':')
    seg, off = int(s, 16), int(o, 16)
    base = seg << 4
    lines = ['; VGAME linear disassembly %s len %d (vgame_asm.py --range)' % (fmt(seg, off), length)]
    stop = off + length
    while off < stop:
        ins = decode_at(seg, off)
        if ins is None:
            lines.append('  %s  db %02X' % (fmt(seg, off), img[base + off]))
            off += 1
            continue
        txt = ins.mnemonic + ' ' + ins.op_str
        notes = []
        if ins.bytes[0] in (0x9A, 0xEA):
            tseg, toff = w16(base + off + 3), w16(base + off + 1)
            t = thunk_note(tseg, toff)
            txt = '%s func_%04X_%04X' % ('call far' if ins.bytes[0] == 0x9A else 'jmp far', tseg, toff)
            if t:
                notes.append(t)
        for op in ins.operands:
            if op.type == X86_OP_MEM and op.mem.base == 0 and op.mem.index == 0 and op.mem.segment in (0, X86_REG_DS):
                notes.append('ds:%04X' % (op.mem.disp & 0xFFFF))
            if op.type == X86_OP_IMM and (ins.mnemonic in ('call', 'jmp') or ins.mnemonic.startswith('j') or ins.mnemonic.startswith('loop')) and ins.bytes[0] not in (0x9A, 0xEA):
                txt = '%s %s' % (ins.mnemonic, fmt(seg, op.imm))
        if opt['bytes']:
            line = '  %s  %-20s %-36s' % (fmt(seg, off), ' '.join('%02X' % b for b in ins.bytes), txt)
        else:
            line = '  %s  %-36s' % (fmt(seg, off), txt)
        if notes:
            line += ' ; ' + ' | '.join(notes)
        lines.append(line.rstrip())
        off += ins.size
    return '\n'.join(lines)

if opt['range']:
    print(disasm_range(*opt['range']))
    sys.exit(0)

if not opt['segs']:
    sys.exit('give --segs or --range')
os.makedirs(opt['out'], exist_ok=True)
index_all = ['# VGAME asm-module entry points (vgame_asm.py). addr size frame callers(C seg 0000 / other asm) seed kinds']
for seg in opt['segs']:
    text, index, ninsn, ncode, size = disasm_segment(seg, opt['vtab'], opt['seed'])
    path = os.path.join(opt['out'], '%04X.asm' % seg)
    open(path, 'w', encoding='utf-8').write(text)
    index_all.append('')
    index_all.append('## %04X  (%d insns, %d/%d bytes code)' % (seg, ninsn, ncode, size))
    index_all.extend(index)
    print('%04X: %d insns, %d entries, code %d/%d bytes -> %s' % (seg, ninsn, len(index), ncode, size, path))
open(os.path.join(opt['out'], 'index.txt'), 'w', encoding='utf-8').write('\n'.join(index_all) + '\n')
