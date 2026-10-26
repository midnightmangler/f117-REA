// Task 2.4: START menu machinery + roster / pilot screens, driven headless with a scripted pointer and key queue.
// Run: node tests/start.test.js
'use strict';
const assert = require('assert');
const fs = require('fs');
const path = require('path');
const zlib = require('zlib');
const FB = require('../src/platform/fb.js');
const GFX = require('../src/platform/gfx.js');
const PNG = require('../src/platform/png.js');
const IN = require('../src/platform/input.js');
const { createBlock } = require('../src/block.js');
const R = require('../src/roster.js');
const M = require('../src/frontend/menu.js');
const S = require('../src/frontend/roster-screen.js');
const ST = require('../src/frontend/start.js');

const A = path.join(__dirname, '..', 'assets');
const assets = {
  bytes: async (p) => new Uint8Array(fs.readFileSync(path.join(A, p))),
  json: async (p) => JSON.parse(fs.readFileSync(path.join(A, p), 'utf8'))
};
const seed = new Uint8Array(fs.readFileSync(path.join(A, 'roster', 'ROSTER.FIL')));
const fonts = JSON.parse(fs.readFileSync(path.join(A, 'fonts.json'), 'utf8'));

function memStorage() { const m = {}; return { getItem: (k) => (k in m ? m[k] : null), setItem: (k, v) => { m[k] = v; }, m }; }

// Scripted host: every host.frame() runs the next script step whose condition holds.
function makeHost(steps) {
  const fb = FB.createFramebuffer(), gfx = GFX.createGfx(fb, fonts), input = IN.createInput({ ticks: () => 0 });
  const ptr = { present: true, x: 0, y: 0, down: false, right: false };
  const sounds = [], frames = { n: 0 }, i = { v: 0 };
  const host = {
    fb, gfx, assets, input, sounds, frames, storage: memStorage(), ptr,
    png: { decodeIndexedPng: (b) => PNG.decodeIndexedPng(b, (d) => zlib.inflateSync(d)) },
    present() {}, ticksMs: () => frames.n * (1000 / 70), sound: (id) => sounds.push(id), random: () => 0,
    keyReady: () => input.keyReady(), pollKey: () => input.getKey(),
    pointer: { present: true, set(x, y) { ptr.x = x; ptr.y = y; }, get x() { return ptr.x; }, get y() { return ptr.y; },
      get b0() { return ptr.down; }, get b1() { return ptr.right; } },
    frame: async () => {
      frames.n++;
      const s = steps[i.v];
      if (!s) { if (frames.n > 200000) throw new Error('script ran out'); return; }
      if (s.wait !== undefined) { s.wait--; if (s.wait <= 0) { i.v++; } return; }
      if (s.when ? s.when() : true) { s.do(); i.v++; }
    },
    done: () => i.v >= steps.length
  };
  return host;
}
const wait = (n) => ({ wait: n });
const click = (host, x, y) => [{ do: () => { host.ptr.x = x; host.ptr.y = y; host.ptr.down = true; } }, wait(3), { do: () => { host.ptr.down = false; } }, wait(2)];
const rowY = (n) => 43 + 10 * (n - 1) + 4;                    // centre of roster row n (1..10)
const key = (host, w) => ({ do: () => host.input.pushKey(w) });

function newCtx(host) {
  const block = createBlock(); block.set('clearance', 1);
  const roster = R.createRoster({ storage: host.storage, seed });
  const bios = { firstEntry: 1 };
  roster.sync(block, bios);
  const ui = M.createUi(host);
  return { block, roster, bios, ui, state: { planeSel: 0 } };
}

let passed = 0;
async function t(name, fn) { await fn(); passed++; }

(async () => {
  await t('lastWord (6A7C) = the word after the last space', () => {
    assert.strictEqual(S.lastWord('Joe "Bear" Hellesen'), 'Hellesen');
    assert.strictEqual(S.lastWord('Hugo C. -BADGUY-'), '-BADGUY-');
    assert.strictEqual(S.lastWord('Madonna'), 'Madonna');
    assert.strictEqual(S.lastWord(''), '');
    assert.strictEqual(S.lastWord(' x'), ' x');            // a space at index 0 stops the scan without advancing
  });
  await t('descriptor tables equal the START data dump', () => {
    assert.strictEqual(S.ROSTER_RECTS.length, 11); assert.strictEqual(S.OPTION_RECTS.length, 10);
    assert.deepStrictEqual(S.ROSTER_RECTS[10], [269, 157, 302, 187]);
    assert.strictEqual(ST.HOME_RECTS.length, 5);
  });

  await t('menuWait: hit test, Selector edge, Esc, hotkey, arrow jump', async () => {
    const host = makeHost([]);
    const ui = M.createUi(host);
    const rects = [[10, 10, 50, 30], [100, 10, 140, 30], [10, 100, 50, 120]];
    ui.setCursor(0, 0);
    // pointer click inside rect 2
    host.ptr.x = 120; host.ptr.y = 20; host.ptr.down = true;
    const steps = host.frames; // keep reference
    let released = false;
    const origFrame = host.frame;
    host.frame = async () => { await origFrame(); if (steps.n === 4) host.ptr.down = false; };
    ui.initCursor.call(ui);   // needs page 2: not loaded -> sprite of zeros, fine for logic
    assert.strictEqual(await ui.menuWait({ hover: null, hotkey: 0, rects }), 2);
    assert.ok(host.sounds.includes(0x1A));
    // keyboard: arrows jump to the nearest rect centre in that direction, Enter selects (edge triggered)
    host.frame = origFrame; host.ptr.present = false; host.pointer.present = false; host.ptr.down = false;
    ui.setCursor(30, 20);
    host.input.pushKey(0x4D00);                                  // right -> rect 2 centre (120,20)
    host.input.pushKey(0x1C0D);
    assert.strictEqual(await ui.menuWait({ hover: null, hotkey: 0, rects }), 2);
    assert.deepStrictEqual([ui.cur.x, ui.cur.y], [120, 20]);
    ui.setCursor(30, 20); host.input.pushKey(0x5000); host.input.pushKey(0x1C0D);                   // down -> rect 3
    assert.strictEqual(await ui.menuWait({ hover: null, hotkey: 0, rects }), 3);
    host.input.pushKey(0x011B); assert.strictEqual(await ui.menuWait({ hover: null, hotkey: 0, rects }), 0x63);
    host.input.pushKey(0x5300); assert.strictEqual(await ui.menuWait({ hover: null, hotkey: 0x62, rects }), 0x162);
    host.input.pushKey(0x0E08); assert.strictEqual(await ui.menuWait({ hover: null, hotkey: 0x62, rects }), 0x162);
    host.input.pushKey(0x3920); assert.strictEqual(await ui.menuWait({ hover: null, hotkey: 0x20, rects }), 0x120);
  });

  await t('roster screen: pick pilot 10, change opponents, exit -> PR, roster file and header', async () => {
    const steps = [];
    const host = makeHost(steps);
    const ctx = newCtx(host);
    await ctx.ui.picLoad(11, 2); ctx.ui.initCursor();
    const screens = S.createRosterScreens({ ui: ctx.ui, host, block: ctx.block, bios: ctx.bios, roster: ctx.roster, state: ctx.state });
    steps.push(wait(120));                                                              // fade-in + first frames
    steps.push(...click(host, 150, rowY(10)));                                          // select pilot 10 (status 0)
    steps.push(wait(400));                                                              // name typing animation
    steps.push(...click(host, 270, 78));                                                // Veteran box (hotspot 3)
    steps.push(...click(host, 250, 131), ...click(host, 250, 180));                    // hotspot 7 (realistic) then 10 (Form Complete)
    steps.push(wait(10));
    steps.push(...click(host, 285, 170));                                               // Exit (hotspot 11)
    const code = await screens.rosterScreen();
    assert.strictEqual(code, 0);
    assert.strictEqual(ctx.bios.firstEntry, 0);
    const pr = ctx.block.pilot;
    assert.strictEqual(R.pilotGet(pr, 'slot'), 9);
    assert.strictEqual(R.pilotGet(pr, 'opponents'), 2);                                 // hotspot 3 = Veteran (index 2)
    assert.strictEqual(R.pilotGet(pr, 'landings'), 2);
    const saved = R.createRoster({ storage: host.storage }).load();
    assert.strictEqual(saved.header & 0xFF, 9);
    assert.strictEqual(R.pilotGet(saved.record(9), 'opponents'), 2);
    assert.ok(host.sounds.includes(0x21));                                              // typewriter
    assert.ok(ctx.state.planeSel === 0);
  });

  await t('Esc in the options panel discards the changes', async () => {
    const steps = [], host = makeHost(steps), ctx = newCtx(host);
    await ctx.ui.picLoad(11, 2); ctx.ui.initCursor();
    const screens = S.createRosterScreens({ ui: ctx.ui, host, block: ctx.block, bios: ctx.bios, roster: ctx.roster, state: ctx.state });
    steps.push(wait(120), ...click(host, 150, rowY(10)), wait(400), ...click(host, 270, 78), wait(5), key(host, 0x011B), wait(30),
      ...click(host, 285, 170));
    await screens.rosterScreen();
    assert.strictEqual(R.pilotGet(ctx.block.pilot, 'opponents'), R.pilotGet(seed.subarray(2 + 80 * 9, 2 + 80 * 10), 'opponents'));
    assert.strictEqual(R.pilotGet(ctx.block.pilot, 'slot'), 9);
  });

  await t('retired and deceased pilots open a requester and cannot be selected', async () => {
    const steps = [], host = makeHost(steps), ctx = newCtx(host);
    await ctx.ui.picLoad(11, 2); ctx.ui.initCursor();
    const screens = S.createRosterScreens({ ui: ctx.ui, host, block: ctx.block, bios: ctx.bios, roster: ctx.roster, state: ctx.state });
    // row 2 = retired (status 1): the dialog's OK button is at the cursor corner the requester sets; Enter confirms
    steps.push(wait(120), ...click(host, 150, rowY(2)), wait(40), key(host, 0x1C0D), wait(20),
      ...click(host, 150, rowY(1)), wait(40), key(host, 0x1C0D), wait(20), ...click(host, 285, 170));
    await screens.rosterScreen();
    assert.strictEqual(R.pilotGet(ctx.block.pilot, 'slot'), 3);                         // still Hugo (header 3)
    assert.ok(host.sounds.filter((s) => s === 0x1A).length >= 4);
  });

  await t('Delete -> name entry: Enter creates the pilot (2nd Lt, Strike Training), Esc leaves it', async () => {
    const steps = [], host = makeHost(steps), ctx = newCtx(host);
    await ctx.ui.picLoad(11, 2); ctx.ui.initCursor();
    const screens = S.createRosterScreens({ ui: ctx.ui, host, block: ctx.block, bios: ctx.bios, roster: ctx.roster, state: ctx.state });
    const typeKeys = [0x1E41, 0x3062, 0x0E08, 0x3063];                                // 'A','b',backspace,'c' -> "Ac"
    steps.push(wait(120), { do: () => { host.ptr.x = 150; host.ptr.y = rowY(3); } }, wait(5), key(host, 0x5300), wait(5),
      ...typeKeys.map((w) => [key(host, w), wait(3)]).flat(), key(host, 0x1C0D), wait(10), ...click(host, 285, 170));
    await screens.rosterScreen();
    const pr = ctx.block.pilot;
    assert.strictEqual(R.pilotGet(pr, 'name'), 'Ac');
    assert.strictEqual(R.pilotGet(pr, 'slot'), 2);
    assert.strictEqual(R.pilotGet(pr, 'war'), 2); assert.strictEqual(R.pilotGet(pr, 'type'), 3);
    assert.strictEqual(R.pilotGet(pr, 'status'), 0); assert.strictEqual(R.pilotGet(pr, 'rank'), 0);
    assert.strictEqual(R.pilotGet(pr, 'totalScore'), 0);
    const saved = R.createRoster({ storage: host.storage }).load();
    assert.strictEqual(R.pilotGet(saved.record(2), 'name'), 'Ac');
    assert.strictEqual(saved.header & 0xFF, 2);
  });

  await t('mission scheduled: choosing another pilot asks first; "No Way!" keeps the current pilot', async () => {
    const steps = [], host = makeHost(steps), ctx = newCtx(host);
    await ctx.ui.picLoad(11, 2); ctx.ui.initCursor();
    ctx.ui.missionScheduled = 1;
    const screens = S.createRosterScreens({ ui: ctx.ui, host, block: ctx.block, bios: ctx.bios, roster: ctx.roster, state: ctx.state });
    // the requester puts the cursor on button 1 (OK); move right to button 2 with an arrow key, then Enter
    steps.push(wait(120), ...click(host, 150, rowY(10)), wait(40), { do: () => { host.pointer.present = false; } },
      key(host, 0x4D00), wait(3), key(host, 0x1C0D), wait(30), { do: () => { host.pointer.present = true; } }, ...click(host, 285, 170));
    await screens.rosterScreen();
    assert.strictEqual(R.pilotGet(ctx.block.pilot, 'slot'), 3);
    assert.strictEqual(ctx.ui.missionScheduled, 1);
  });

  await t('Alt-Q opens the quit screen; N returns, Y exits START with code 0', async () => {
    const steps = [], host = makeHost(steps), ctx = newCtx(host);
    await ctx.ui.picLoad(11, 2); ctx.ui.initCursor();
    const screens = S.createRosterScreens({ ui: ctx.ui, host, block: ctx.block, bios: ctx.bios, roster: ctx.roster, state: ctx.state });
    steps.push(wait(120), key(host, 0x1000), wait(60), key(host, 0x316E), wait(60), key(host, 0x1000), wait(60), key(host, 0x1559));
    let err = null;
    try { await screens.rosterScreen(); } catch (e) { err = e; }
    assert.ok(err instanceof M.StartExit); assert.strictEqual(err.code, 0);
  });

  await t('requester word wrap (3776) fits every line in the width', () => {
    const host = makeHost([]), ui = M.createUi(host);
    const m = { page: -1, flags: 0, color: 0, bg: 8, x: 0, y: 0, font: 4, top: 0, bottom: 199, left: 0, right: 319 };
    for (const d of Object.values(S.DLG)) {
      const w = ui.wrapText(m, d.text, 0, 0, d.w - 12, 8, 0);
      assert.ok(w > 0 && w <= d.w - 12, d.text.slice(0, 20) + ' width ' + w);
      assert.ok(m.y >= 8 * 2);
    }
  });

  await t('START program: roster first when firstEntry is set, Alt-Q Y returns exit code 0', async () => {
    const steps = [], host = makeHost(steps);
    host.pointer.present = false;
    steps.push(wait(250), key(host, 0x1000), wait(60), key(host, 0x1559));
    const prog = ST.createStartProgram(host);
    const block = createBlock(); block.set('clearance', 1);
    const bios = { firstEntry: 1, soundInit: 0 };
    assert.strictEqual(await prog({ block, bios }), 0);
    assert.strictEqual(bios.firstEntry, 0);
    assert.strictEqual(R.pilotGet(block.pilot, 'slot'), 3);
  });

  console.log('start.test.js: ' + passed + ' passed');
})().catch((e) => { console.error(e); process.exit(1); });
