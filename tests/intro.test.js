// Task 2.2: intro (MPS logo + PAN player timing, fade). Run: node tests/intro.test.js
'use strict';
const assert = require('assert');
const fs = require('fs');
const path = require('path');
const FB = require('../src/platform/fb.js');
const SS = require('../src/platform/ss.js');
const INTRO = require('../src/frontend/intro.js');

const rd = (p) => new Uint8Array(fs.readFileSync(path.join(__dirname, '..', 'assets', p)));
let passed = 0;
async function t(name, fn) { await fn(); passed++; }

(async () => {
  const series = SS.parseSs(rd('ss/LABSLOGO.SS'));
  const total = series.frames.reduce((a, f) => a + f.delay, 0);

  await t('logo: total 146 BIOS ticks, sprites appear on schedule and accumulate', () => {
    assert.strictEqual(total, 146);
    const fb = FB.createFramebuffer();
    const run = INTRO.createLogoRun(series, { fb });
    const ms = (ticks) => ticks * 1000 / INTRO.BIOS_HZ + 1;
    assert.strictEqual(run.advance(1000), null);                         // t0 = that tick
    const d0 = series.frames[0].delay;
    assert.ok(d0 > 0);
    run.advance(1000 + ms(d0 - 1)); assert.strictEqual(run.drawn, 0);   // first sprite not before t0 + delay
    run.advance(1000 + ms(d0 + 1)); assert.ok(run.drawn >= 1);
    run.advance(1000 + ms(total - 1));
    assert.ok(run.drawn < series.frames.length);                         // last sprite (delay 34 hold) not yet
    const r = run.advance(1000 + ms(total + 1));
    assert.strictEqual(r, 0);
    assert.strictEqual(run.drawn, series.frames.length);
    // final screen = golden of the SS decoder
    const gold = path.join(__dirname, 'golden', 'ss');
    if (fs.existsSync(gold)) {
      const f = fs.readdirSync(gold).find((n) => /final/i.test(n));
      if (f) assert.strictEqual(Buffer.compare(Buffer.from(fb.pages[0]), fs.readFileSync(path.join(gold, f))), 0);
    }
  });
  await t('logo: key or tap draws the rest at once; result 1 Esc, 2 Alt-Q, 3 other', () => {
    for (const [key, code] of [[0x011B, 1], [0x1000, 2], [0x1C0D, 3]]) {
      let polls = 0;
      const run = INTRO.createLogoRun(series, { fb: FB.createFramebuffer(), pollKey: () => (polls++ >= 1 ? key : 0) });
      assert.strictEqual(run.advance(0), null);
      assert.ok(run.drawn < series.frames.length);
      const r = run.advance(10);
      assert.strictEqual(r, code);
      assert.strictEqual(run.drawn, series.frames.length);
    }
    const tap = INTRO.createLogoRun(series, { fb: FB.createFramebuffer(), tapped: () => true });
    assert.strictEqual(tap.advance(0), 3);
  });
  await t('logo: DAC gets the series palette at base 0x1F', () => {
    const fb = FB.createFramebuffer(), seen = {};
    fb.setDacEntry = (i, r, g, b) => { seen[i] = [r, g, b]; };
    INTRO.createLogoRun(series, { fb }).advance(0);
    assert.strictEqual(series.base, 0x1F);
    const e = series.palette[0];
    assert.deepStrictEqual(seen[0x1F], [e[0], e[1], e[2]]);
    assert.deepStrictEqual(seen[0], [0, 0, 0]);
  });

  await t('fade: 300 steps, step 1 black, step k scale 219k, ends at full palette', () => {
    const fb = FB.createFramebuffer();
    const f = INTRO.createFade(fb, 5);
    const pal = new Uint8Array(768); for (let i = 0; i < 768; i++) pal[i] = i % 64;
    f.setPalette(pal);
    assert.strictEqual(f.remaining, 300);
    const seen = [];
    fb.setDacEntry = (i, r, g, b) => { if (i === 63) seen.push([r, g, b]); };   // watch entry 63 = (63,0,1)
    const scales = [];
    for (let k = 1; k <= 300; k++) { scales.push(f.scale); f.step(); }
    assert.strictEqual(f.active, false);
    assert.strictEqual(seen.length, 300);
    assert.deepStrictEqual(seen[0], [0, 0, 0]);                           // block 0 was computed before the palette arrived
    const r = (c, s) => { const p = c * s; return (p >>> 16) + ((p >>> 15) & 1); };
    assert.deepStrictEqual(seen[1], [r(pal[189], 438), r(pal[190], 438), r(pal[191], 438)]);
    assert.deepStrictEqual(seen[298], [r(pal[189], 219 * 299), r(pal[190], 219 * 299), r(pal[191], 219 * 299)]);
    assert.deepStrictEqual(seen[299], [pal[189], pal[190], pal[191]]);   // clamped 0xFFFF rounds to full value
    assert.strictEqual(f.scale, 0xFFFF);
  });

  await t('player TITLE-1: cel 0 at tick 1, fade freezes the animation for 300 ticks, then 3 ticks per cel', () => {
    const fb = FB.createFramebuffer();
    const run = INTRO.createPanRun([{ name: 'title-1', bytes: rd('pan/TITLE-1.PAN') }], { fb, argc: 8 });
    run.tick();
    assert.strictEqual(run.frames, 1);
    for (let i = 0; i < 300; i++) { run.tick(); assert.strictEqual(run.frames, 1); }
    assert.strictEqual(run.fade.active, false);
    assert.strictEqual(run.time, 301);
    run.tick(); run.tick(); assert.strictEqual(run.frames, 1);
    run.tick(); assert.strictEqual(run.frames, 2);                        // tick 304
    while (!run.done) run.tick();
    assert.strictEqual(run.frames, 111);
    assert.strictEqual(run.time, 301 + 3 * 110);                          // last cel drawn -> finish() proceeds, no hold
  });
  await t('player: pixels equal the PAN decoder golden, DAC holds the faded-in palette', () => {
    const fb = FB.createFramebuffer();
    const run = INTRO.createPanRun([{ name: 'title-1', bytes: rd('pan/TITLE-1.PAN') }], { fb, argc: 2 });
    while (!run.done) run.tick();
    const pj = JSON.parse(fs.readFileSync(path.join(__dirname, '..', 'assets', 'pan', 'pan.json'), 'utf8'));
    const sha = require('crypto').createHash('sha1').update(fb.pages[0]).digest('hex');
    const g = pj.files['TITLE-1'].frameSha1;
    assert.strictEqual(sha, g[g.length - 1]);
  });
  await t('player: second file draws its palette directly (no fade) and keeps the screen', () => {
    const fb = FB.createFramebuffer();
    const run = INTRO.createPanRun([{ name: 'a', bytes: rd('pan/TITLE-1.PAN') }, { name: 'b', bytes: rd('pan/TITLE-2.PAN') }], { fb, argc: 3 });
    while (run.frames < 111) run.tick();
    assert.strictEqual(run.done, false);
    run.tick(); run.tick(); run.tick();
    assert.strictEqual(run.frames, 112);                                  // TITLE-2 cel 0, 3 ticks after the last TITLE-1 cel
    while (!run.done) run.tick();
    assert.strictEqual(run.frames, 311);
  });
  await t('player: advance() uses a 60 Hz clock; key quits with the key code, tap with 0x1B', () => {
    const fb = FB.createFramebuffer();
    const run = INTRO.createPanRun([{ name: 'title-1', bytes: rd('pan/TITLE-1.PAN') }], { fb, argc: 2 });
    run.advance(0); run.advance(500);
    assert.strictEqual(run.time, 30);
    let key = 0;
    const r2 = INTRO.createPanRun([{ name: 'title-1', bytes: rd('pan/TITLE-1.PAN') }], { fb, argc: 2, pollKey: () => key });
    r2.advance(0); key = 0x0D;
    assert.strictEqual(r2.advance(16), 0x0D);
    const r3 = INTRO.createPanRun([{ name: 'title-1', bytes: rd('pan/TITLE-1.PAN') }], { fb, argc: 2, tapped: () => true });
    assert.strictEqual(r3.advance(0), 0x1B);
  });

  await t('programs: args are split, "-" is skipped silently, names map to pan/NAME.PAN', async () => {
    const asked = [];
    const host = {
      fb: FB.createFramebuffer(), present() {}, now: () => 0, raf: (f) => setImmediate(f),
      assets: { bytes: async (p) => { asked.push(p); if (p.includes('-.PAN')) throw new Error('missing'); return rd(p); } },
      tapped: () => true
    };
    const progs = INTRO.createIntroPrograms(host);
    assert.strictEqual(await progs.player({ args: '- title-1 title-2' }), 0x1B);
    assert.deepStrictEqual(asked, ['pan/-.PAN', 'pan/TITLE-1.PAN', 'pan/TITLE-2.PAN']);
    asked.length = 0;
    assert.strictEqual(await progs.logo({ args: 'A' }), 3);
    assert.deepStrictEqual(asked, ['ss/LABSLOGO.SS']);
  });

  console.log('intro.test.js: ' + passed + ' passed');
})().catch((e) => { console.error(e); process.exit(1); });
