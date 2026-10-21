// Task 1.1: indexed-PNG loader vs the original PIC decoder (goldens), DAC/LUT, present, scaler, tick model.
'use strict';
const fs = require('fs');
const path = require('path');
const zlib = require('zlib');
const crypto = require('crypto');
const { decodeIndexedPng } = require('../src/platform/png.js');
const FB = require('../src/platform/fb.js');
const T = require('../src/platform/timer.js');

let fail = 0;
function check(c, m) { if (!c) { console.error('FAIL ' + m); fail++; } }
const sha1 = (b) => crypto.createHash('sha1').update(b).digest('hex');

(async () => {
  // 1. Every shipped PIC PNG decodes to exactly the palette indices re/tools/pic.py produced from the .PIC.
  const gold = JSON.parse(fs.readFileSync(path.join(__dirname, 'golden', 'pic', 'pic_sha1.json'), 'utf8')).pics;
  const dir = path.join(__dirname, '..', 'assets', 'pic');
  let n = 0;
  for (const f of fs.readdirSync(dir).filter((x) => x.endsWith('.png'))) {
    const name = f.slice(0, -4).toUpperCase();
    const img = await decodeIndexedPng(fs.readFileSync(path.join(dir, f)), (d) => zlib.inflateSync(d));
    check(img.width === 320 && img.height === 200, name + ' size');
    check(sha1(img.pixels) === gold[name], name + ' indices differ from pic.py');
    n++;
  }
  check(n === 52 && Object.keys(gold).length === 52, 'expected 52 PICs, got ' + n);

  // 2. DAC: 6-bit -> 8-bit expansion, masking, LUT byte order, palette load.
  check(FB.dac8(0) === 0 && FB.dac8(63) === 255 && FB.dac8(32) === 130 && FB.dac8(21) === 85, 'dac8 values');
  const fb = FB.createFramebuffer();
  check(fb.pages.length === 5 && fb.pages.every((p) => p.length === 64000), 'five 64000-byte pages');
  fb.setDacEntry(5, 63, 0, 32 + 64);   // 6-bit mask: 96 -> 32
  const px = new Uint8Array(new Uint32Array([fb.lut[5]]).buffer);
  check(px[0] === 255 && px[1] === 0 && px[2] === 130 && px[3] === 255, 'LUT RGBA bytes ' + Array.from(px));
  fb.setPalette([1, 2, 3, 4, 5, 6], 10, 2);
  check(fb.dac[30] === 1 && fb.dac[35] === 6, 'setPalette placement');

  // 3. Present: #44 copies the first N words of page 1 onto page 0, nothing else.
  fb.pages[1].fill(7); fb.presentWords(100 * 160);
  check(fb.pages[0][100 * 320 - 1] === 7 && fb.pages[0][100 * 320] === 0, 'presentWords row limit');
  const out = new Uint32Array(64000); fb.pages[0][0] = 5; fb.toRGBA(out);
  check(out[0] === fb.lut[5] && out[64000 - 1] === fb.lut[0], 'toRGBA via LUT');

  // 4. Scaler: integer scale in device pixels, letterbox centring.
  let L = FB.computeLayout(1024, 768, 1);
  check(L.scale === 3 && L.cssWidth === 960 && L.cssHeight === 600 && L.left === 32 && L.top === 84, '1024x768 layout');
  L = FB.computeLayout(1366, 1024, 2);     // iPad Pro-ish: 2732x2048 device px
  check(L.scale === 8 && L.cssWidth === 1280 && L.cssHeight === 800, 'dpr 2 layout ' + JSON.stringify(L));
  L = FB.computeLayout(200, 100, 1);
  check(L.scale === 1 && L.left === 0, 'never below 1x');

  // 5. Ticker: 70 Hz frames, sound on 6 of 7, catch-up cap, pause, noise mode.
  let frames = 0, sounds = 0;
  let t = T.createTicker({ frame: () => frames++, sound: () => { sounds++; return 0; } });
  t.advance(0);
  for (let ms = 1; ms <= 1000; ms++) t.advance(ms);
  check(frames >= 69 && frames <= 70, 'frames in 1 s: ' + frames);
  check(Math.abs(sounds - frames * 6 / 7) <= 1, 'sound 6/7 of frames: ' + sounds + '/' + frames);
  frames = 0; sounds = 0; t = T.createTicker({ frame: () => frames++, sound: () => { sounds++; return 0; } });
  t.advance(0); for (let i = 1; i <= 7; i++) t.advance(i * 1000 / 70 + 0.001);
  check(frames === 7 && sounds === 6, '7 frames -> 6 sound ticks, got ' + frames + '/' + sounds);
  frames = 0; t.advance(100000);                 // huge stall: capped, no burst
  check(frames <= 5, 'catch-up cap, ran ' + frames);
  t.pause(); frames = 0; t.advance(200000); check(frames === 0, 'no ticks while paused');
  t.resume(300000); t.advance(300000 + 1000 / 70 + 0.001); check(frames === 1, 'resume without burst: ' + frames);
  // Sound skip: ticks 1..6 call snd_tick, the 7th does not (VGAME 0000:1E8A..1E9D).
  const calls = []; let n7 = 0;
  t = T.createTicker({ frame: () => n7++, sound: () => { calls.push(n7); return 0; } });
  t.advance(0); for (let i = 1; i <= 14; i++) t.advance(i * 1000 / 70 + 0.001);
  check(calls.join() === '1,2,3,4,5,6,8,9,10,11,12,13', 'sound ticks skip every 7th: ' + calls);
  // Noise mode: snd_tick -> +1 on tick 1, -1 on tick 6. Entry tick and the next get 1 noise call after the frame tick,
  // then 3 before + 1 after each tick; the exit tick gets none.
  const log = []; let tick = 0, ret = { 1: 1, 6: -1 };
  t = T.createTicker({ frame: () => { tick++; log.push('F'); }, sound: () => ret[tick] || 0, noise: () => log.push('n') });
  t.advance(0); for (let i = 1; i <= 7; i++) t.advance(i * 1000 / 70 + 0.001);
  check(log.join('') === 'Fn' + 'Fn' + 'nnnFn' + 'nnnFn' + 'nnnFn' + 'nnnF' + 'F', 'noise sequence ' + log.join(''));

  if (!fail) console.log('platform ok (' + n + ' PICs)');
  process.exit(fail ? 1 : 0);
})().catch((e) => { console.error(e.stack || e); process.exit(1); });
