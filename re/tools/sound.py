"""F-117A sound data dumper.

usage: py -3 -I sound.py [UNPACKED_DIR] [ORIG_GAME_DIR] [OUT_DIR]
defaults: re/unpacked, reference/F-117A/F-117A, re/out/sound

Writes
  OUT/asound_ids.txt         play(id) dispatch table of ASOUND.117 -> voices / sequences
  OUT/asound_instruments.txt  OPL2 instrument bank (44-byte records at image+0x2E)
  OUT/asound_sequences.txt    every referenced event stream, decoded
  OUT/speech_<id>_<n>.wav     SPEECH.117 segments (8-bit unsigned mono, 8000 Hz)
  OUT/speech_phrases.txt      segment table per speech id (41..45)
All addresses are ASOUND image offsets (code segment 01B6 = image 0x1B60); see re/docs/sound.md.
"""
import math, os, struct, sys, wave

HERE = os.path.dirname(os.path.abspath(__file__))
RE = os.path.dirname(HERE)
UNP = sys.argv[1] if len(sys.argv) > 1 else os.path.join(RE, 'unpacked')
ORIG = sys.argv[2] if len(sys.argv) > 2 else os.path.join(os.path.dirname(RE), 'reference', 'F-117A', 'F-117A')
OUT = sys.argv[3] if len(sys.argv) > 3 else os.path.join(RE, 'out', 'sound')
os.makedirs(OUT, exist_ok=True)


def load_117(path):
    d = open(path, 'rb').read()
    hdr = struct.unpack_from('<H', d, 8)[0] * 16
    img = d[hdr:]
    cs = struct.unpack_from('<H', img, 0x18)[0]
    n = struct.unpack_from('<H', img, 0x22)[0]
    vec = struct.unpack_from('<%dH' % n, img, 0x24)
    return img, cs * 16, vec


img, CB, VEC = load_117(os.path.join(UNP, 'ASOUND.117'))
code = img[CB:]
w = lambda a: struct.unpack_from('<H', img, a)[0]       # DS-relative (image) word
cw = lambda a: struct.unpack_from('<H', code, a)[0]     # CS-relative word

# ---- dispatch: entry1 = mov bx,[bp+6]; cmp bx,2D; ... call cs:[bx+TABLE] ----
e1 = VEC[1]
assert code[e1 + 0x15:e1 + 0x18] == b'\x2e\xff\x97', 'unexpected entry1 layout'
TABLE = cw(e1 + 0x18)
NIDS = code[e1 + 8] + 1                                  # cmp bx,imm8 (0x2D) -> 46 ids
handlers = [cw(TABLE + 2 * i) for i in range(NIDS)]

# voice starters: lea bx,[voice] ; jmp common   (05B9..05E3) -> voice index
VOICE_BASE, VOICE_SIZE, NVOICES = 0x190A, 0x1E, 7
starter = {}
a = 0
while a < len(code) - 4:
    if code[a:a + 2] == b'\x8d\x1e':
        v = cw(a + 2)
        if VOICE_BASE <= v < VOICE_BASE + NVOICES * VOICE_SIZE and (v - VOICE_BASE) % VOICE_SIZE == 0 \
                and code[a + 4] in (0xEB, 0x8B):
            starter[a] = (v - VOICE_BASE) // VOICE_SIZE
    a += 1


def rel_target(a):
    op = code[a]
    if op == 0xEB:
        return a + 2 + struct.unpack_from('<b', code, a + 1)[0], 2
    if op in (0xE8, 0xE9):
        return (a + 3 + struct.unpack_from('<h', code, a + 1)[0]) & 0xFFFF, 3
    return None, 0


def analyse_handler(idx, h):
    """Follow 'lea cx,seq ; call/jmp starter' chains. Returns list of (voice, seq) + notes."""
    out, notes = [], []
    a, cx, steps = h, None, 0
    while steps < 40:
        steps += 1
        op = code[a]
        if code[a:a + 2] == b'\x8d\x0e':                  # lea cx,[imm]
            cx = cw(a + 2); a += 4; continue
        if code[a:a + 2] == b'\x8d\x1e':                  # lea bx,[imm]
            a += 4; continue
        if code[a:a + 3] == b'\x2e\x8b\x8f':              # mov cx,cs:[bx+tbl]  (ids 4/5)
            tbl = cw(a + 3)
            # preceding shifts: bx = (id*2) >> k & 6
            k = sum(1 for b in range(h, a, 2) if code[b:b + 2] == b'\xd1\xeb')
            cx = cw(tbl + (((idx * 2) >> k) & 6)); a += 5
            notes.append('seq picked from cs:%04X[(id*2>>%d)&6]' % (tbl, k)); continue
        if op in (0xE8, 0xE9, 0xEB):
            t, ln = rel_target(a)
            if t in starter:
                out.append((starter[t], cx))
                if op == 0xE8:
                    a += ln; continue
                break
            if op == 0xE8:
                a += ln; continue
            a = t; continue
        if op == 0x9A:
            notes.append('calls rand'); a += 5; continue
        if code[a:a + 2] == b'\xd1\xeb':                  # shr bx,1
            a += 2; continue
        if code[a:a + 3] == b'\x83\xe3\x06':              # and bx,6
            a += 3; continue
        if code[a:a + 2] == b'\x39\x0e':                  # cmp [imm],cx  (id 9: don't restart)
            notes.append('not restarted while already playing'); a += 4; continue
        if code[a:a + 2] == b'\x80\x3e':                  # cmp byte [imm],imm8
            a += 5; continue
        if op == 0x75:                                    # jne -> take the 'start' branch
            a = a + 2 + struct.unpack_from('<b', code, a + 1)[0]; continue
        if code[a:a + 2] == b'\x83\x3e':                  # cmp word [imm],imm8 (id 11)
            a += 5; continue
        if code[a:a + 3] == b'\xbb\x01\x00':              # mov bx,1 ; call 03D8 (id 11: throttle=1 if 0)
            notes.append('sets engine throttle 1 if it was 0'); a += 6; continue
        if op == 0xC3:
            break
        # unknown instruction: stop (handled manually in docs)
        break
    return out, notes


SPECIAL = {0: 'stop: silence all voices (018F)',
           1: 'set REPEAT1 mark (+12) of every voice to 0E9A (?) -> music ends at next repeat',
           2: 'query: returns OR of the 7 voice-active bytes (0 = nothing playing)',
           21: 'pause: mute carriers of ch0-6, freeze sequencer, suspend noise',
           22: 'resume after 21',
           23: 'engine throttle = arg2 (0..0x301), fnum word = (arg2&~1)+0x883',
           24: 'engine sound on', 25: 'engine sound off',
           40: 'speech: [17E2] = arg2 (paragraph of SPEECH.117 buffer)',
           41: 'speech phrase', 42: 'speech phrase', 43: 'speech phrase (alternates by tick parity)',
           44: 'speech phrase', 45: 'speech phrase',
           28: 'v0<-0EC0 after byte 0EC6 := 0x21 + (rand & 3)',
           33: 'v0<-0EDA after byte 0EE0 := 1 + (rand & 3)'}
lines = ['ASOUND.117 play(id) dispatch: jump table cs:%04X (image %04X), %d ids' % (TABLE, CB + TABLE, NIDS),
         'id  handler  voices <- sequence (image offsets)']
seqs = {}
for i, h in enumerate(handlers):
    res, notes = analyse_handler(i, h)
    for v, s in res:
        if s is not None:
            seqs.setdefault(s, set()).add(v)
    txt = ', '.join('v%d<-%04X' % (v, s) for v, s in res) if res else SPECIAL.get(i, '(special, see sound.md)')
    lines.append('%2d  %04X     %s %s' % (i, h, txt, ('; ' + '; '.join(notes)) if notes else ''))
seqs.setdefault(0x0EC0, set()).add(0)                     # id 28 (byte 0EC6 randomised)
seqs.setdefault(0x0EDA, set()).add(0)                     # id 33 (byte 0EE0 randomised)
seqs.setdefault(0x0E94, set()).add(6)                   # engine loop, started by tick (0430)
seqs.setdefault(0x0E9A, set()).update(range(6))           # 'end' sequence used by 025A / id 1
open(os.path.join(OUT, 'asound_ids.txt'), 'w').write('\n'.join(lines) + '\n')

# ---- sequence decoder (event interpreter func 1360) ----
CMDS = {0xF3: ('PANSWEEP', 2), 0xF4: ('PAN', 1), 0xF5: ('VOLOFS', 1), 0xF6: ('RANDPATCH', None),
        0xF7: ('DETUNE', 1), 0xF8: ('VOLSWEEP', 2), 0xF9: ('VOLUME', 1), 0xFA: ('SLIDE', 1),
        0xFB: ('GAP', 1), 0xFC: ('INSTR', 1), 0xFD: ('LOOP', 0), 0xFE: ('REPEAT2', 1), 0xFF: ('REPEAT1', 1)}
FNUM = [struct.unpack_from('<H', img, 0x187A + 2 * i)[0] for i in range(12)]   # func 0D1C
NOTE = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']
sb = lambda x: x - 256 if x > 127 else x


def decode(start, limit=600):
    out, a, instrs = [], start, set()
    for _ in range(limit):
        b = img[a]
        if 0xF3 <= b:
            name, n = CMDS[b]
            if b == 0xF6:
                n = img[a + 1]
                vals = list(img[a + 2:a + 2 + n]); off = sb(img[a + 2 + n])
                tgt = a + 3 + n + off
                out.append('  %04X  F6 RANDPATCH values=%s -> byte %04X' % (a, vals, tgt))
                a += n + 3; continue
            args = list(img[a + 1:a + 1 + n])
            if b in (0xF7, 0xFA):
                args = [sb(x) for x in args]
            if b == 0xF5:                                 # added to VOLUME modulo 64
                args = ['%d(=%+d mod 64)' % (args[0], ((args[0] + 32) % 64) - 32)]
            if b == 0xF8:                                 # period, signed step added to VOLOFS
                args = [args[0], sb(args[1])]
            if b == 0xF3:                                 # period, signed step added to PAN
                args = [args[0], sb(args[1])]
            if b == 0xFC:
                instrs.add(args[0])
            # length: every command advances ptr by 2 except F3/F8 (3) and F6 (n+3); FD by 0 (jump)
            out.append('  %04X  %02X %-9s %s' % (a, b, name, ' '.join(str(x) for x in args)))
            if b == 0xFD:
                break
            a += 3 if b in (0xF3, 0xF8) else 2
            continue
        n, dur = img[a], img[a + 1]
        if n == 0 or dur == 0:
            out.append('  %04X  %02X %02X     %s' % (a, n, dur, 'END (voice off)' if dur == 0 else 'rest %d' % dur))
            if dur == 0:
                break
        else:
            hz = FNUM[n % 12] * 49716.0 / (1 << (20 - (n // 12 & 7)))
            midi = 69 + 12 * math.log2(hz / 440.0)
            out.append('  %04X  %02X %02X     note blk%d fnum%03X = %7.1f Hz (~%s%d) dur %d' % (
                a, n, dur, n // 12, FNUM[n % 12], hz, NOTE[round(midi) % 12], round(midi) // 12 - 1, dur))
        a += 2
    return out, instrs


all_instr = set()
slines = []
for s in sorted(seqs):
    body, ins = decode(s)
    all_instr |= ins
    slines.append('seq %04X  (voices %s)' % (s, ','.join(str(v) for v in sorted(seqs[s]))))
    slines += body
    slines.append('')
open(os.path.join(OUT, 'asound_sequences.txt'), 'w').write('\n'.join(slines))

# ---- instruments (loader func 123E/1048): 44-byte records at 0x2E + n*0x2C ----
OPF = ['AR', 'DR', 'SL', 'RR', 'EG', 'KSR', 'LEVEL', 'KSL', 'WS', 'MULT', 'FB', 'AM', 'VIB', 'FM', 'NOISE']
ilines = ['ASOUND instrument bank: record n at image 0x2E + n*0x2C; two 22-byte operator halves',
          '(op1 = modulator slot of the channel, op2 = carrier). LEVEL is written as TL = 0x3F - LEVEL.',
          'NOISE (op1 only) = noise-channel duration in ticks; when non-zero the note is played on a',
          'random-frequency "noise" channel: mask/base/step words at +0x10/+0x12/+0x14.',
          'Writes per op: 20=AM<<7|VIB<<6|EG<<5|KSR<<4|MULT  40=KSL<<6|(3F-LEVEL)  60=AR<<4|DR',
          '80=SL<<4|RR  E0=WS  C0=FB<<1|(FM?0:1) (FM=1: FM synthesis, 0: additive; op2 call overwrites C0)', '']
for n in range(max(all_instr) + 1 if all_instr else 0):
    base = 0x2E + n * 0x2C
    row = ['%2d @%04X%s' % (n, base, '' if n in all_instr else ' (unreferenced)')]
    for k in range(2):
        r = img[base + k * 0x16: base + k * 0x16 + 0x16]
        row.append('   op%d: ' % (k + 1) + ' '.join('%s=%d' % (f, r[j]) for j, f in enumerate(OPF)))
    r = img[base:base + 0x16]
    if r[0xE]:
        row.append('   noise: mask=%04X base=%04X step=%d' % (struct.unpack_from('<H', r, 0x10)[0],
                   struct.unpack_from('<H', r, 0x12)[0], struct.unpack_from('<h', r, 0x14)[0]))
    ilines += row
fn = [w(0x187A + 2 * i) for i in range(12)]
ilines += ['', 'F-number table image 0x187A (C..B): ' + ' '.join('%03X' % x for x in fn),
           'channel->operator slots image 0x1896: ' + ' '.join('%d' % b for b in img[0x1896:0x18A8]),
           'slot->register offset image 0x18A8: ' + ' '.join('%02X' % b for b in img[0x18A8:0x18BA])]
open(os.path.join(OUT, 'asound_instruments.txt'), 'w').write('\n'.join(ilines) + '\n')

# ---- speech: ids 41..45 = mov ax,1F40 ; mov bx,TABLE (or two tables picked by tick parity) ----
sp = open(os.path.join(ORIG, 'SPEECH.117'), 'rb').read()
plines = ['SPEECH.117 %d bytes; segment tables (end, start, segoff) in ASOUND code segment' % len(sp)]
for i in range(41, NIDS):
    # walk: mov ax,imm / mov bx,imm / mov bx,cs:[imm] / and bx,imm / jne / jmp common
    tabs, work, seen = [], [handlers[i]], set()
    while work:
        a = work.pop(0)
        while a not in seen:
            seen.add(a)
            op = code[a]
            if op == 0xB8: a += 3
            elif op == 0xBB:
                tabs.append(cw(a + 1)); a += 3
            elif code[a:a + 3] == b'\x2e\x8b\x1e': a += 5
            elif code[a:a + 2] == b'\x83\xe3': a += 3
            elif op == 0x75:
                work.append(a + 2 + struct.unpack_from('<b', code, a + 1)[0]); a += 2
            else:
                break                                     # jmp to the common player (09F2)
    for k, t in enumerate(tabs):
        segs = []
        a = t
        while cw(a):
            end, start, sg = cw(a), cw(a + 2), cw(a + 4)
            segs.append((start + sg * 16, end + sg * 16)); a += 6
        plines.append('id %d table cs:%04X: %s' % (i, t, ' + '.join('[%04X..%04X)' % s for s in segs)))
        pcm = b''.join(sp[s:e] for s, e in segs)
        name = 'speech_%d%s.wav' % (i, '' if len(tabs) == 1 else 'abcd'[k])
        with wave.open(os.path.join(OUT, name), 'wb') as wf:
            wf.setnchannels(1); wf.setsampwidth(1); wf.setframerate(8000); wf.writeframes(pcm)
        plines.append('   -> %s (%d samples, %.2f s)' % (name, len(pcm), len(pcm) / 8000))
open(os.path.join(OUT, 'speech_phrases.txt'), 'w').write('\n'.join(plines) + '\n')
print('wrote', OUT)
