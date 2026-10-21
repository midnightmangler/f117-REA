// Task 1.4: ASOUND port (music.js) + OPL2 emulator (opl2.js).
'use strict';
const fs = require('fs');
const path = require('path');
const M = require('../src/platform/music.js');
const O = require('../src/platform/opl2.js');

let fail = 0;
function check(c, m) { if (!c) { console.error('FAIL ' + m); fail++; } }

const file = fs.readFileSync(path.join(__dirname, '..', 'assets', 'sound', 'ASOUND.117'));
const img = M.asoundImage(new Uint8Array(file));
check(img.length === 0x382A, 'image size ' + img.length);

// 1. Static stream dump equals sound.py's asound_sequences.txt (every sequence, every line).
const gold = fs.readFileSync(path.join(__dirname, 'golden', 'sound', 'asound_sequences.txt'), 'utf8').split(/\r?\n/);
const seqs = [];
for (let i = 0; i < gold.length; i++) {
  const m = /^seq ([0-9A-F]{4})  \(voices ([0-9,]+)\)$/.exec(gold[i]);
  if (!m) continue;
  const body = [];
  for (let j = i + 1; j < gold.length && gold[j] !== ''; j++) body.push(gold[j]);
  seqs.push({ addr: parseInt(m[1], 16), voice: +m[2].split(',')[0], body });
}
check(seqs.length === 55, 'golden sequence count ' + seqs.length);
let lines = 0;
for (const s of seqs) {
  const got = M.dumpSequence(img, s.addr);
  for (let k = 0; k < Math.max(got.length, s.body.length); k++) {
    if (got[k] !== s.body[k]) { check(false, 'dump ' + s.addr.toString(16) + ' line ' + k + ': "' + got[k] + '" vs "' + s.body[k] + '"'); break; }
    lines++;
  }
}

// 2. The running interpreter reads each stream's events in the order of the static decode (command lengths,
//    repeats and loops); first visits only.
for (const s of seqs) {
  const want = s.body.map((l) => parseInt(l.slice(2, 6), 16));
  const seen = [], set = new Set();
  const d = M.createAsound(img, () => {});
  d.init();
  d.trace = (v, a) => { if (v === s.voice && !set.has(a)) { set.add(a); seen.push(a); } };
  // start the stream on its voice through a fake id: reuse voiceStart via the song/sfx tables is not exposed,
  // so poke the voice record the way cs:05E7 does
  const b = 0x190A + 0x1E * s.voice, mem = d.mem;
  mem[b + 1] = 0; mem[b + 0x0A] = 0xFF; mem[b + 2] = mem[b + 3] = mem[b + 0x1C] = mem[b + 0x1D] = mem[b + 7] = 0; mem[b + 0x0D] = 0x40;
  for (const o of [0x0E, 0x10, 0x12, 0x14]) { mem[b + o] = s.addr & 0xFF; mem[b + o + 1] = s.addr >> 8; }
  for (const o of [0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B]) mem[b + o] = 0;
  mem[b] = 1;
  for (let t = 0; t < 20000 && mem[b]; t++) d.tick();
  const ok = seen.length === want.length && seen.every((a, k) => a === want[k]);
  check(ok, 'runtime order ' + s.addr.toString(16) + ': ' + seen.length + ' vs ' + want.length);
}

// 3. Driver behaviour pinned from the decompile.
{
  const w = [];
  const d = M.createAsound(img, (r, v, dt) => w.push([r, v, dt]));
  d.init();
  check(d.mem[0x1A06 + 1] === 0x20, 'reg 01 = 20 after init');
  check(d.play(2) === 0, 'nothing playing after init');
  // engine: id 24 on, id 23 throttle 0x100 -> fnum (0x100 & ~1) + 0x883 = 0x983, TL 50 = 9 - 3, 53 = 0x36 + 3
  d.play(24); d.play(23, 0x100); w.length = 0; d.tick();
  const reg = (r) => { let v; for (const x of w) if (x[0] === r) v = x[1]; return v; };
  check(reg(0xA6) === 0x83 && reg(0xB6) === 0x29, 'engine pitch ' + reg(0xA6) + ' ' + reg(0xB6));
  check(reg(0x50) === 6 && reg(0x53) === 0x39, 'engine TL ' + reg(0x50) + ' ' + reg(0x53));
  check(d.play(2) !== 0, 'engine voice active');
  d.play(25); for (let i = 0; i < 4; i++) d.tick();
  check(d.mem[0x19BE] === 0, 'engine voice idle after id 25');
  // noise: id 5 (instr 15 noise) -> +1 once, -1 once when both slots end
  d.play(5);
  const rs = [];
  for (let i = 0; i < 400; i++) rs.push(d.tick());
  check(rs[0] === 1 && rs.filter((x) => x === 1).length === 1, 'noise start +1');
  check(rs.filter((x) => x === -1).length === 1, 'noise end -1');
  w.length = 0; d.play(5); d.tick(); d.noise();
  check(w.some((x) => x[0] === 0xB0 && (x[1] & 0x20)), 'noise key-on on ch0');
  // speech 41 (9250 samples) on the AdLib path: one TL write per sample at 150 PIT counts
  w.length = 0;
  d.play(41, 0, () => new Uint8Array(9250).fill(0x80));
  const tl = w.filter((x) => x[0] === 0x43 && x[2] > 0);
  check(tl.length === 9250 && tl.every((x) => x[1] === d.mem[0x1B60 + 0x18 + 0x20]), 'speech TL writes ' + tl.length);
  const sec = d.lastSpeech.sec;
  check(Math.abs(sec - (0x988 + 9251 * 150) / 1193182) < 1e-9, 'speech duration ' + sec);
  // id 43 alternates 43a/43b by tick parity
  for (let i = 0; i < 2; i++) {
    const want = (d.tickCount & 1) ? '43b' : '43a';
    d.play(43, 0, () => null); check(d.lastSpeech.key === want, 'speech 43 by tick parity');
    d.tick(); d.tick(); d.tick();
  }
}

// 4. OPL2: a pure carrier tone has the programmed frequency (blk 4, fnum 0x244 = 440.0 Hz).
{
  const o = O.createOpl2();
  [[0x01, 0x20], [0x20, 0x01], [0x23, 0x01], [0x40, 0x3F], [0x43, 0x00], [0x60, 0xF0], [0x63, 0xF0],
    [0x80, 0x00], [0x83, 0x00], [0xC0, 0x01], [0xA0, 0x44], [0xB0, 0x20 | (4 << 2) | 2]].forEach(([r, v]) => o.write(r, v));
  let prev = 0, zc = 0, peak = 0;
  for (let i = 0; i < 49716 * 1.1; i++) {
    const s = o.sample();
    if (i >= 4972) { if ((s >= 0) !== (prev >= 0)) zc++; peak = Math.max(peak, Math.abs(s)); }
    prev = s;
  }
  check(Math.abs(zc / 2 - 440) <= 2, 'tone ' + zc / 2 + ' Hz');
  check(peak > 3000 && peak <= 4200, 'tone peak ' + peak);   // 4084 full scale + the TL 3F modulator (additive)
}

// 5. End to end: song 39 through the driver into the renderer, 3 s at 48 kHz, audible and finite.
{
  const r = O.createRenderer(48000, O.createOpl2);
  let t = 0;
  const d = M.createAsound(img, (reg, v, dt) => r.push(t + dt, reg, v));
  d.init(); d.play(39);
  const out = new Float32Array(800);
  let sum = 0, n = 0, bad = 0;
  for (let k = 0; k < 180; k++) {
    t = k / 60; d.tick();
    r.render(out, 800, k === 0 ? 0 : undefined);
    for (const x of out) { if (!isFinite(x)) bad++; sum += x * x; n++; }
  }
  check(bad === 0, 'non-finite samples');
  check(Math.sqrt(sum / n) > 0.01, 'song rms ' + Math.sqrt(sum / n));
}

console.log((fail ? 'FAIL' : 'ok') + ' sound: ' + seqs.length + ' sequences, ' + lines + ' dump lines');
process.exit(fail ? 1 : 0);
