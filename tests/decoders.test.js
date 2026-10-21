// Task 1.3: PAN / SS decoders vs the Python decoder goldens (per-frame sha1 in assets json, final screens in tests/golden).
'use strict';
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const PAN = require('../src/platform/pan.js');
const SS = require('../src/platform/ss.js');
const WORLD = require('../src/platform/world.js');

let fail = 0;
function check(c, m) { if (!c) { console.error('FAIL ' + m); fail++; } }
const sha1 = (b) => crypto.createHash('sha1').update(b).digest('hex');
const root = path.join(__dirname, '..');
const rd = (p) => fs.readFileSync(path.join(root, p));

// PAN: every cel's screen = golden sha1, cel sizes = size table, header fields = pan.json, final screen = golden bin.
const pj = JSON.parse(rd('assets/pan/pan.json'));
for (const [name, g] of Object.entries(pj.files)) {
  const pl = PAN.createPanPlayer(new Uint8Array(rd('assets/pan/' + name + '.PAN')));
  let i = 0, ok = true, sizes = true;
  while (pl.step()) {
    if (sha1(pl.screen.subarray(0, 64000)) !== g.frameSha1[i]) ok = false;
    if (pl.table[i] !== pl.lastCelSize) sizes = false;
    i++;
  }
  check(i === g.cels && pl.count === g.cels, name + ' cel count ' + i);
  check(ok, name + ' frame sha1 mismatch');
  check(sizes, name + ' cel size table mismatch');
  check(pl.rate === g.rate && pl.ticksPerFrame === g.ticksPerFrame, name + ' rate');
  check(pl.unpacked === g.unpacked && pl.segments === g.segments, name + ' unpacked/segments');
  const fin = path.join('tests', 'golden', 'pan', name, 'screen_final.bin');
  if (fs.existsSync(path.join(root, fin))) check(Buffer.compare(Buffer.from(pl.screen.subarray(0, 64000)), rd(fin)) === 0, name + ' final screen');
}

// SS: palette/header, per-sprite cumulative screens, final screen.
const sj = JSON.parse(rd('assets/ss/labslogo.json'));
const s = SS.parseSs(new Uint8Array(rd('assets/ss/LABSLOGO.SS')));
check(s.name === sj.name && s.count === sj.count && s.type === sj.type && s.base === sj.base, 'SS header');
check(JSON.stringify(s.palette) === JSON.stringify(sj.palette), 'SS palette');
check(s.dataOffset === sj.dataOffset && s.data.length === sj.dataSize, 'SS data');
const scr = new Uint8Array(64000);
s.frames.forEach((f, i) => {
  SS.drawSprite(s, i, scr);
  check(f.off === sj.frames[i].off && f.delay === sj.frames[i].delay && f.x === sj.frames[i].x && f.y === sj.frames[i].y &&
    f.w === sj.frames[i].w && f.h === sj.frames[i].h, 'SS record ' + i);
  check(sha1(scr) === sj.frames[i].screenSha1, 'SS screen sha1 after sprite ' + (i + 1));
});
check(Buffer.compare(Buffer.from(scr), rd('tests/golden/ss/screen_final.bin')) === 0, 'SS final screen');
let bad = false;
try { SS.parseSs(new Uint8Array(32)); } catch (e) { bad = true; }
check(bad, 'SS rejects bad magic');

// world loader: all 11 files load and carry the documented keys.
(async () => {
  const rj = (p) => JSON.parse(rd(p));
  for (const c of WORLD.REGIONS) {
    const w = await WORLD.loadWorld(c.toLowerCase(), rj);
    check(['region', 'wld', 'x3d', 'grid', 'props'].every((k) => k in w), 'world ' + c + ' keys');
  }
  for (const c of WORLD.EXTRA) check((await WORLD.loadWorld(c, rj)) != null, 'world ' + c);
  let rejected = false;
  await WORLD.loadWorld('XX', rj).catch(() => { rejected = true; });
  check(rejected, 'world rejects unknown region');
  if (fail) { console.error(fail + ' failure(s)'); process.exit(1); }
  console.log('decoders: ok');
})();
