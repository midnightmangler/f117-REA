// Checks assets/manifest.json against the files on disk (sha1 + size) and the expected counts
// from task card 0.2. Fails if an asset was edited, lost, or exceeds 2 MB.
'use strict';
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const ASSETS = path.join(__dirname, '..', 'assets');
const m = JSON.parse(fs.readFileSync(path.join(ASSETS, 'manifest.json'), 'utf8'));
let fail = 0;
function check(cond, msg) { if (!cond) { console.error('FAIL ' + msg); fail++; } }

for (const f of m.files) {
  const p = path.join(ASSETS, f.path);
  if (!fs.existsSync(p)) { check(false, 'missing ' + f.path); continue; }
  const buf = fs.readFileSync(p);
  check(buf.length === f.bytes, f.path + ' size ' + buf.length + ' != ' + f.bytes);
  check(buf.length <= 2 * 1024 * 1024, f.path + ' over 2 MB');
  check(crypto.createHash('sha1').update(buf).digest('hex') === f.sha1, f.path + ' sha1 mismatch');
}
const count = (re) => m.files.filter((f) => re.test(f.path)).length;
check(count(/^pic\/.*\.png$/) === 52, 'expected 52 PIC PNGs');
check(m.pics.length === 52, 'manifest.pics should list 52 entries');
check(count(/^world\/.*\.json$/) === 11, 'expected 11 world JSONs');
check(count(/^pan\/.*\.PAN$/) === 6, 'expected 6 PAN files');
check(count(/^sound\/speech\/.*\.wav$/) === 6, 'expected 6 speech WAVs');

const pals = JSON.parse(fs.readFileSync(path.join(ASSETS, 'palettes.json'), 'utf8')).palettes;
check(Object.keys(pals).length === 21, 'expected 21 palettes (12 PAL + 9 in PALETTES.PAL)');
check(Object.values(pals).every((p) => p.length === 768 && p.every((v) => v < 64)), 'palettes must be 768 6-bit values');
const fonts = JSON.parse(fs.readFileSync(path.join(ASSETS, 'fonts.json'), 'utf8')).fonts;
check(fonts.length === 7, 'expected 7 fonts');
const snd = JSON.parse(fs.readFileSync(path.join(ASSETS, 'sound', 'asound.json'), 'utf8'));
check(snd.ids.length === 46, 'expected 46 sound ids');
check(snd.fnumTable.length === 12, 'expected 12 F-numbers');

if (!fail) console.log('assets ok: ' + m.files.length + ' files, ' + (m.totalBytes >> 10) + ' KB');
process.exit(fail ? 1 : 0);
