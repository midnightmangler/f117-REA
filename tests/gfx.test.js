// Task 1.2: MGRAPHIC API port (src/platform/gfx*.js): text metrics/pixels vs the font goldens, span fill, lines,
// sprites (grab/draw/scale/mirror/clip), blits, recolor, present, flicker, tick tape, dissolve.
'use strict';
const fs = require('fs');
const path = require('path');
const FB = require('../src/platform/fb.js');
const { createGfx } = require('../src/platform/gfx.js');

let fail = 0;
function check(c, m) { if (!c) { console.error('FAIL ' + m); fail++; } }
const root = path.join(__dirname, '..');
const fontsRt = JSON.parse(fs.readFileSync(path.join(root, 'assets', 'fonts.json'), 'utf8')).fonts;
const golden = JSON.parse(fs.readFileSync(path.join(__dirname, 'golden', 'mgraphic', 'fonts.json'), 'utf8'));
check(JSON.stringify(fontsRt) === JSON.stringify(golden), 'assets/fonts.json == golden fonts.json');

function fresh() { const fb = FB.createFramebuffer(); return { fb, g: createGfx(fb, fontsRt) }; }
function vp(o) { return Object.assign({ page: 2, flags: 0, color: 7, bg: 3, x: 10, y: 10, font: 1, top: 0, bottom: 199, left: 0, right: 319 }, o); }
const copy = (a) => Uint8Array.from(a);

// ---- 1. char_width against the golden width tables
let widthsChecked = 0;
{
  const { g } = fresh();
  for (const f of golden) {
    for (let c = 0; c < 256; c++) {
      const exp = (c >= f.first && c <= f.last && c < 0x80) ? (f.fixed || f.widths[c - f.first]) + f.spacing : 0;
      if (g.charWidth(c, f.index) !== exp) { check(false, `charWidth font ${f.index} ch ${c}`); break; }
      widthsChecked++;
    }
  }
  check(g.charWidth(65, 7) === 0 && g.charWidth(65, 9) === 0 && g.charWidth(65, -1) === 0, 'charWidth bad font');
}

// ---- 2. glyph pixels: every char of every font, transparent and opaque, against bits of the golden rows
{
  let bad = 0;
  for (const f of golden) {
    const { g } = fresh();
    for (let c = Math.max(f.first, 1); c <= Math.min(f.last, 0x7F); c++) {   // char 0 terminates a string
      const adv = g.charWidth(c, f.index);
      for (const opq of [false, true]) {
        const pg = g.pageTable[2];
        pg.fill(0);
        const v = vp({ font: f.index, flags: opq ? 1 : 0, x: 20, y: 30 });
        const end = g.textDraw(v, String.fromCharCode(c));
        // last char of the string: transparent draws all `adv` columns too, opaque draws adv columns
        const rows = f.height + (opq ? f.extra : 0);
        for (let r = 0; r < rows + 2; r++) for (let x = 0; x < adv + 2; x++) {
          const bit = (r < f.height && x < adv) ? (f.rows[c - f.first][r] >> (15 - x)) & 1 : 0;
          const want = opq ? (x < adv && r < rows ? (bit ? 7 : 3) : 0) : (bit ? 7 : 0);
          if (pg[(30 + r) * 320 + 20 + x] !== want) bad++;
        }
        if (end !== 20 + adv || v.x !== end) bad++;
      }
    }
  }
  check(bad === 0, 'glyph pixels vs golden (' + bad + ' differences)');
}

// ---- 3. string layout, colour codes, colour write-back
{
  const { g } = fresh();
  const pg = g.pageTable[2];
  const f = golden[1], v = vp({ x: 5, y: 5, color: 4 });
  const end = g.textDraw(v, 'A\x82B');
  const wA = g.charWidth(65, 1), wB = g.charWidth(66, 1);
  check(end === 5 + wA + wB, 'string end x');
  check(v.color === 2 && g.color === 4, 'VP colour = last colour code, global colour = start colour');
  let a = 0, b = 0;
  for (let r = 0; r < f.height; r++) for (let x = 0; x < 20; x++) {
    const p = pg[(5 + r) * 320 + 5 + x];
    if (p === 4) a++; else if (p === 2) b++; else if (p) a += 1000;
  }
  check(a > 0 && b > 0 && a < 1000, 'colour code switches colour');
  check(g.textDraw(vp({ x: 7 }), '') === 7, 'empty string returns x');
}

// ---- 4. clipping = unclipped picture masked to the clip rect (left/right/vertical)
{
  const text = 'Nighthawk 2.0 HUD', f = golden[4];
  const ref = fresh().g, pgRef = ref.pageTable[2];
  const v0 = vp({ font: 4, x: 40, y: 60 });
  ref.textDraw(v0, text);
  const full = copy(pgRef), fullEnd = v0.x;
  function masked(x0, x1, y0, y1) {
    const m = new Uint8Array(64000);
    for (let y = y0; y <= y1; y++) for (let x = x0; x <= x1; x++) m[y * 320 + x] = full[y * 320 + x];
    return m;
  }
  const same = (a, b) => { for (let i = 0; i < 64000; i++) if (a[i] !== b[i]) return false; return true; };
  for (const [name, fn, rect, opts] of [
    ['left', 'textDrawLClip', [60, 319, 0, 199], { left: 60 }],
    ['right', 'textDrawRClip', [0, 90, 0, 199], { right: 90 }],
    ['vert top', 'textDrawVClip', [0, 319, 62, 199], { top: 62 }],
    ['vert bottom', 'textDrawVClip', [0, 319, 0, 63], { bottom: 63 }],
    ['full', 'textDrawClip', [55, 100, 62, 65], { left: 55, right: 100, top: 62, bottom: 65 }],
  ]) {
    const { g } = fresh();
    const v = vp(Object.assign({ font: 4, x: 40, y: 60 }, opts));
    g[fn](v, text);
    check(same(g.pageTable[2], masked(...rect)), 'clip ' + name + ' == masked picture');
  }
  { // clipped away entirely: nothing drawn, x unchanged
    const { g } = fresh(), v = vp({ font: 4, x: 40, y: 60, top: 100, bottom: 120 });
    g.textDrawClip(v, text);
    check(v.x === 40 && g.pageTable[2].every((p) => p === 0), 'vertical clip-out draws nothing');
  }
  { // right clip quirk: x >= right draws nothing
    const { g } = fresh(), v = vp({ font: 4, x: 90, y: 60, right: 90 });
    g.textDrawRClip(v, text);
    check(g.pageTable[2].every((p) => p === 0), 'right clip: x == right draws nothing');
  }
  check(fullEnd === 40 + Array.from(text).reduce((s, ch) => s + ref.charWidth(ch.charCodeAt(0), 4), 0), 'unclipped end x');
  void f;
}

// ---- 5. span fill
{
  const { g } = fresh();
  const L = new Int16Array(220), R = new Int16Array(220), pg = g.pageTable[0];
  g.setDrawPage(0);
  g.setColor(9);
  L[5] = 10; R[5] = 14;          // fills 10..14
  L[6] = 20; R[6] = 20;          // single pixel, filled
  L[7] = 30; R[7] = 29;          // R < L: skipped
  L[8] = 0; R[8] = 0;            // R == L == 0: skipped
  L[9] = 319; R[9] = 319;        // R == L == 319: skipped
  L[10] = 318; R[10] = 319;
  g.fillSpans(5, 10, L, R, 0);
  const row = (y) => Array.from(pg.subarray(y * 320, y * 320 + 320)).map((p, x) => (p ? x : -1)).filter((x) => x >= 0);
  check(JSON.stringify(row(5)) === '[10,11,12,13,14]', 'span solid');
  check(JSON.stringify(row(6)) === '[20]', 'span single pixel');
  check(row(7).length === 0 && row(8).length === 0 && row(9).length === 0, 'span skip rules');
  check(JSON.stringify(row(10)) === '[318,319]', 'span at right edge');
  pg.fill(0b0101); g.setColor(0b0011); g.fillSpans(5, 5, L, R, 1);
  check(pg[5 * 320 + 10] === 0b0111 && pg[5 * 320 + 9] === 0b0101, 'span OR');
  pg.fill(0b0101); g.fillSpans(5, 5, L, R, 2);
  check(pg[5 * 320 + 12] === 0b0001 && pg[5 * 320 + 9] === 0b0101, 'span AND');
  for (let i = 0; i < 16; i++) { pg.fill(i); g.fillSpans(5, 5, L, R, 3); if (pg[5 * 320 + 11] !== (0x98 | ((i & 0x0E) >> 1))) check(false, 'span shade ' + i); }
  // origin offset applies; ytop > ybot still processes ybot once; ytop < 0 does nothing
  pg.fill(0); g.setDrawOrigin(320); g.setColor(4); g.fillSpans(5, 5, L, R, 0);
  check(pg[6 * 320 + 10] === 4 && pg[5 * 320 + 10] === 0, 'span draw origin');
  g.resetDrawOrigin(); pg.fill(0); g.fillSpans(6, 5, L, R, 0);
  check(pg[5 * 320 + 10] === 4, 'span do-while with ybot < ytop');
  pg.fill(0); g.fillSpans(-1, 10, L, R, 0);
  check(pg.every((p) => p === 0), 'span ytop < 0');
}

// ---- 6. lines
{
  const { g } = fresh(), pg = g.pageTable[0];
  g.setDrawPage(0); g.setColor(5);
  const pts = () => { const o = []; for (let i = 0; i < 64000; i++) if (pg[i]) o.push([i % 320, (i / 320) | 0]); return JSON.stringify(o); };
  g.line(0, 0, 4, 2);
  check(pts() === JSON.stringify([[0, 0], [1, 1], [2, 1], [3, 2], [4, 2]]), 'line (0,0)-(4,2): ' + pts());
  pg.fill(0); g.line(9, 7, 3, 7);
  check(pts() === JSON.stringify([3, 4, 5, 6, 7, 8, 9].map((x) => [x, 7])), 'horizontal line, endpoints swapped');
  pg.fill(0); g.line(6, 2, 6, 5);
  check(pts() === JSON.stringify([2, 3, 4, 5].map((y) => [6, y])), 'vertical line');
  pg.fill(0); g.line(8, 8, 8, 8);
  check(pts() === JSON.stringify([[8, 8]]), 'single point');
  pg.fill(0); g.line(10, 10, 14, 6);
  check(pts() === JSON.stringify([[14, 6], [13, 7], [12, 8], [11, 9], [10, 10]]) || (pg[10 * 320 + 10] && pg[6 * 320 + 14] && Array.from(pg).filter(Boolean).length === 5), 'rising diagonal has 5 pixels');
  for (const [a, b, c, d] of [[3, 3, 40, 17], [100, 50, 20, 90], [5, 5, 5, 60], [60, 70, 10, 70]]) {
    pg.fill(0); g.line(a, b, c, d);
    check(Array.from(pg).filter(Boolean).length === Math.max(Math.abs(c - a), Math.abs(d - b)) + 1, `line pixel count ${a},${b}-${c},${d}`);
    check(pg[b * 320 + a] === 5 && pg[d * 320 + c] === 5, 'line endpoints drawn');
  }
}

// ---- 7. sprites: grab encoding, 1:1 draw, scale, mirror, clip
{
  const { g } = fresh(), src = g.pageTable[1], dst = g.pageTable[2];
  const rows = [[0, 0, 5, 6, 0], [7, 0, 0, 8, 0], [0, 0, 0, 0, 0]];
  rows.forEach((r, y) => r.forEach((p, x) => { src[(20 + y) * 320 + 30 + x] = p; }));
  const sp = g.spriteGrab(1, 30, 20, 5, 3);
  check(JSON.stringify(Array.from(sp)) === JSON.stringify([5, 0, 3, 0, 2, 0, 2, 0, 5, 6, 4, 0, 0, 0, 7, 0, 0, 8, 0, 0, 5, 0]),
    'sprite_grab encoding: ' + Array.from(sp));
  const v = vp({ page: 2, left: 100, top: 50, right: 199, bottom: 99 });
  const rect = g.spriteDraw(v, 4, 6, 5, 3, sp, 0);
  check(JSON.stringify(rect) === '{"x":4,"y":6,"w":5,"h":3}', 'sprite rect');
  let ok = true;
  rows.forEach((r, y) => r.forEach((p, x) => { if (dst[(50 + 6 + y) * 320 + 100 + 4 + x] !== p) ok = false; }));
  check(ok, 'sprite 1:1 round trip');
  dst.fill(0); g.spriteDraw(v, 0, 0, -5, 3, sp, 0);       // mirror horizontally
  check(dst[50 * 320 + 100 + 4 - 0] === 0 && dst[50 * 320 + 100 + 2] === 5 && dst[50 * 320 + 100 + 1] === 6 && dst[51 * 320 + 100 + 4] === 7 && dst[51 * 320 + 100 + 1] === 8, 'sprite mirror x');
  dst.fill(0); g.spriteDraw(v, 0, 0, 5, -3, sp, 0);       // mirror vertically: row 1 lands on row 1, row 0 on row 2
  check(dst[52 * 320 + 100 + 2] === 5 && dst[51 * 320 + 100 + 0] === 7 && dst[50 * 320 + 100 + 2] === 0, 'sprite mirror y');
  dst.fill(0); g.spriteDraw(v, 0, 0, 10, 6, sp, 0);       // 2x: every source pixel doubled in both directions
  check(dst[50 * 320 + 104] === 5 && dst[50 * 320 + 105] === 5 && dst[51 * 320 + 104] === 5 && dst[52 * 320 + 100] === 7 && dst[53 * 320 + 101] === 7 && dst[50 * 320 + 106] === 6, 'sprite 2x scale');
  dst.fill(0); g.spriteDraw(v, 0, 0, 3, 3, sp, 0);        // 5 -> 3 columns: source columns 0,2,4... (DDA)
  check(dst[51 * 320 + 100] === 7, 'sprite downscale');
  dst.fill(0); const r2 = g.spriteDraw(v, -2, 0, 5, 3, sp, 0);   // clipped on the left: visible columns 2..4
  check(JSON.stringify(r2) === '{"x":0,"y":0,"w":3,"h":3}' && dst[50 * 320 + 100] === 5 && dst[50 * 320 + 101] === 6, 'sprite left clip');
  dst.fill(0); const r3 = g.spriteDraw(v, 0, 49, 5, 3, sp, 0);   // bottom clip at VP height 50
  check(r3.h === 1 && dst[99 * 320 + 100 + 0] === 0, 'sprite bottom clip rect: ' + JSON.stringify(r3));
  dst.fill(0); const r4 = g.spriteDraw(v, 200, 0, 5, 3, sp, 0);
  check(JSON.stringify(r4) === '{"x":0,"y":0,"w":0,"h":0}' && dst.every((p) => p === 0), 'sprite fully outside');
}

// ---- 8. blits, recolor, present, DAC flicker, tick tape, dissolve
{
  const { fb, g } = fresh();
  const p1 = g.pageTable[1], p0 = g.pageTable[0], p2 = g.pageTable[2];
  for (let i = 0; i < 64000; i++) p1[i] = (i * 7) & 255;
  g.blit(1, 10, 20, 2, 50, 60, 30, 5);
  check(p2[60 * 320 + 50] === p1[20 * 320 + 10] && p2[64 * 320 + 79] === p1[24 * 320 + 39] && p2[65 * 320 + 50] === 0 && p2[60 * 320 + 80] === 0, 'blit');
  g.present(2 * 160);
  check(p0[2 * 320 - 1] === p1[2 * 320 - 1] && p0[2 * 320] === 0 && g.getRenderPage() === 1, 'present first N rows');

  p2.fill(9);
  const sheet = new Uint8Array(64000);
  sheet[0] = 3; sheet[1] = 0; sheet[2] = 4; sheet[320] = 5; sheet[321] = 6;
  const bs = { seg: sheet, sx: 0, sy: 0, page: 2, dx: 10, dy: 10, w: 3, h: 2, top: 0, bottom: 199, left: 0, right: 319 };
  g.blitTransp(bs);
  check(p2[10 * 320 + 10] === 3 && p2[10 * 320 + 11] === 9 && p2[10 * 320 + 12] === 4 && p2[11 * 320 + 11] === 6, 'transparent blit');
  p2.fill(9);
  Object.assign(bs, { dx: -1, dy: 5, left: 0 });
  g.blitTranspClip(bs);
  check(p2[5 * 320 + 0] === 0 || p2[5 * 320 + 0] === 9, 'clip blit left (pixel at x=-1 not drawn)');
  check(p2[5 * 320 + 1] === 4 && bs.dx === 0 && bs.sx === 1 && bs.w === 3 && bs.h === 2, 'clip blit adjusts dx/sx, restores w/h');

  p2.fill(0); p2[5 * 320 + 5] = 1; p2[6 * 320 + 6] = 1; p2[7 * 320 + 9] = 1;
  g.recolorRect({ page: 2 }, 5, 5, 6, 6, 1, 14);
  check(p2[5 * 320 + 5] === 14 && p2[6 * 320 + 6] === 14 && p2[7 * 320 + 9] === 1, 'recolor rect');

  // flicker: seed 0x04D2 -> *5+1 -> colours 14,12,... and optional shake
  g.flickerTick();
  check(g.seed === 6171 && fb.dac[39] === 0x3F && fb.dac[40] === 0x3F && fb.dac[41] === 0x15, 'flicker tick 1 (EGA 14 into DAC 13)');
  g.flickerTick();
  check(fb.dac[39] === 0x3F && fb.dac[40] === 0x15 && fb.dac[41] === 0x15, 'flicker tick 2 (EGA 12)');
  g.setShake(2); g.flickerTick(); g.flickerTick();
  check(g.hscroll === 0, 'shake ends at 0');

  // tick tape: left airspeed tape at y=100
  p2.fill(0); g.setDrawPage(2); g.setColor(15);
  g.hudTickTape(100, 0, 0, 0);
  const px = (x, y) => p2[y * 320 + x];
  check(px(71, 79) && px(70, 79) && px(69, 79) && !px(68, 79) && px(71, 81) && !px(70, 81) && !px(71, 83) && !px(71, 89), 'tick tape ticks (major 3 px, minor 1 px, rows > 82 skipped)');
  check(px(71, 79 - 2 * 5) && px(70, 79 - 2 * 5) && !px(69, 79 - 2 * 5), 'tick tape mid tick (5th = 2 px)');
  check(!px(71, 21) && !px(71, 20), 'tick tape stops at ymin');

  // random dissolve touches each pixel exactly once
  const dstSeg = g.pageTable[3], srcSeg = new Uint8Array(64000).fill(1);
  g.setDrawPage(3);
  g.fizzleCopy(srcSeg);
  check(dstSeg.every((p) => p === 1), 'fizzle copies all 64000 pixels');
  g.screenOff(); check(fb.blank === true, 'screen_off');
  g.screenOn(); check(fb.blank === false, 'screen_on');
}

console.log(fail ? fail + ' failures' : 'gfx: all passed (' + widthsChecked + ' width checks)');
process.exit(fail ? 1 : 0);

