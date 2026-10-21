// Task 2.1: program flow, shared block, roster. Run: node tests/flow.test.js
'use strict';
const assert = require('assert');
const fs = require('fs');
const path = require('path');
const { createBlock, FIELDS, SIZE } = require('../src/block.js');
const { createRoster, pilotGet, pilotSet, FILE_SIZE, KEY } = require('../src/roster.js');
const { runFlow, INTRO_ARGS, TITLE2_ARGS } = require('../src/flow.js');

const seed = new Uint8Array(fs.readFileSync(path.join(__dirname, '..', 'assets', 'roster', 'ROSTER.FIL')));
let passed = 0;
async function t(name, fn) { await fn(); passed++; }
function memStorage() { const m = {}; return { getItem: (k) => (k in m ? m[k] : null), setItem: (k, v) => { m[k] = v; }, m }; }

// scripted programs: exits = {name: [codes...]}
function progs(exits, hook) {
  const calls = [];
  const p = {};
  for (const name of ['setup', 'logo', 'player', 'start', 'vgame', 'end', 'dswap']) {
    p[name] = async (ctx) => {
      calls.push(name + (ctx.args !== undefined ? ' ' + ctx.args : ''));
      if (hook) hook(name, ctx);
      const q = exits[name];
      return q && q.length ? q.shift() : (name === 'setup' ? 0x24 : name === 'dswap' ? 1 : 0);
    };
  }
  p.calls = calls;
  return p;
}

(async () => {
  // ---- block ----
  await t('block size and field layout', () => {
    const b = createBlock();
    assert.strictEqual(b.bytes.length, 5120);
    b.set('clearance', 1); b.set('endState', 3); b.set('night', 1); b.set('drvKind', 3);
    assert.strictEqual(b.bytes[0x22], 1); assert.strictEqual(b.bytes[0x26], 3);
    assert.strictEqual(b.bytes[0x33], 1); assert.strictEqual(b.bytes[0x32], 3);
    b.set('bayWeapon', 0x13, 3); assert.strictEqual(b.bytes[0x38 + 6], 0x13);
    b.set('bayQty', 4, 0); assert.strictEqual(b.bytes[0x40], 4);
    b.set('fuel', 0x1234); assert.strictEqual(b.bytes[0x2E], 0x34); assert.strictEqual(b.bytes[0x2F], 0x12);
    b.set('inputFlags', 3); assert.strictEqual(b.get('inputFlags'), 3);
    b.set('joyCal', 0xAB, 39); assert.strictEqual(b.bytes[0x48 + 39], 0xAB);
    assert.strictEqual(b.pilot.byteOffset, 0x1272); assert.strictEqual(b.pilot.length, 80);
    assert.strictEqual(b.world.byteOffset, 0x7A);
    assert.ok(0x1272 + 80 <= SIZE);
  });
  await t('block strings', () => {
    const b = createBlock();
    b.setString('gfxName', 'Mgraphic.exe'); b.setString('sndName', 'Asound.117');
    assert.strictEqual(b.getString('gfxName'), 'Mgraphic.exe');
    assert.strictEqual(b.bytes[0x0D], 'A'.charCodeAt(0));
    assert.throws(() => b.setString('sndName', 'x'.repeat(13)));
    assert.throws(() => b.get('nope'));
  });
  await t('every field fits before the world and does not overlap', () => {
    const spans = Object.entries(FIELDS).map(([n, d]) => {
      const size = d[1] === 'w' ? 2 : d[1] === 'b' ? 1 : d[1] === 'wa' ? 2 * d[2] : d[2];
      return [d[0], d[0] + size, n];
    }).sort((a, b) => a[0] - b[0]);
    for (let i = 1; i < spans.length; i++) assert.ok(spans[i - 1][1] <= spans[i][0], spans[i - 1][2] + ' overlaps ' + spans[i][2]);
    assert.ok(spans[spans.length - 1][1] <= 0x7A);
  });

  // ---- roster ----
  await t('shipped ROSTER.FIL is 802 bytes and round-trips byte-exact', () => {
    assert.strictEqual(seed.length, FILE_SIZE);
    const r = createRoster({ seed }).load();
    assert.deepStrictEqual(Array.from(r.toBytes()), Array.from(seed));
    assert.strictEqual(r.header, 3);
    assert.strictEqual(pilotGet(r.record(0), 'name'), 'Joe "Bear" Hellesen');
    assert.strictEqual(pilotGet(r.record(1), 'rank'), 4);
    assert.strictEqual(pilotGet(r.record(0), 'status'), 2);
  });
  await t('save/load through storage keeps the bytes; header low byte = PR slot', () => {
    const st = memStorage();
    const r = createRoster({ storage: st, seed }).load();
    const pr = new Uint8Array(80); pr.set(r.record(7)); pilotSet(pr, 'slot', 7);
    assert.ok(r.save(pr));
    const r2 = createRoster({ storage: st, seed: new Uint8Array(FILE_SIZE) }).load();
    const exp = Uint8Array.from(seed); exp[0] = 7;
    assert.deepStrictEqual(Array.from(r2.toBytes()), Array.from(exp));
    assert.ok(KEY in st.m);
  });
  await t('storage failure is silent', () => {
    const st = { getItem() { throw new Error('x'); }, setItem() { throw new Error('x'); } };
    const r = createRoster({ storage: st, seed }).load();
    assert.strictEqual(r.header, 3);
    assert.strictEqual(r.save(new Uint8Array(80)), false);   // save still sets the header byte from PR.slot (0) like 7272
  });
  await t('sync on first entry: PR = roster[header low byte], plane bumps type, record 0 plane masked', () => {
    const b = createBlock(); b.set('clearance', 1);
    const f = Uint8Array.from(seed);
    // record 2 (empty): plane 1, type 0 -> 1 ; record 3: plane 2, type 2 -> 3 (plane stays 2) ; record 0 plane 3 -> masked to 1, type 0 -> 1
    const set = (i, n, v) => { f[2 + 80 * i + n] = v & 255; f[3 + 80 * i + n] = v >> 8; };
    set(2, 0x42, 1); set(2, 0x3C, 0);
    set(3, 0x42, 2); set(3, 0x3C, 2);
    set(0, 0x42, 3); set(0, 0x3C, 0);
    const r = createRoster({ seed: f });
    r.sync(b, { firstEntry: 1 });
    assert.strictEqual(pilotGet(r.record(2), 'type'), 1);
    assert.strictEqual(pilotGet(r.record(3), 'type'), 3);
    assert.strictEqual(pilotGet(r.record(3), 'plane'), 2);
    assert.strictEqual(pilotGet(r.record(0), 'plane'), 1);
    assert.strictEqual(pilotGet(r.record(0), 'type'), 1);
    assert.strictEqual(pilotGet(b.pilot, 'name'), 'Hugo C. -BADGUY-');     // header = 3
    assert.strictEqual(pilotGet(b.pilot, 'type'), 3);
  });
  await t('sync on return from END: roster[PR.slot] = PR, file saved', () => {
    const st = memStorage();
    const b = createBlock(); b.set('clearance', 1);
    const r = createRoster({ storage: st, seed });
    r.sync(b, { firstEntry: 1 });
    pilotSet(b.pilot, 'totalScore', 123456); pilotSet(b.pilot, 'missions', 5);
    r.sync(b, { firstEntry: 0 });
    const r2 = createRoster({ storage: st }).load();
    assert.strictEqual(pilotGet(r2.record(3), 'totalScore'), 123456);
    assert.strictEqual(pilotGet(r2.record(3), 'missions'), 5);
    assert.strictEqual(r2.header & 0xFF, 3);
  });
  await t('no clearance: theatre 0 and training bit set', () => {
    const b = createBlock(); b.set('clearance', 0);
    const f = Uint8Array.from(seed);
    f[2 + 80 * 3 + 0x38] = 4; f[2 + 80 * 3 + 0x3C] = 1;
    const r = createRoster({ seed: f });
    r.sync(b, { firstEntry: 1 });
    assert.strictEqual(pilotGet(b.pilot, 'theatre'), 0);
    assert.strictEqual(pilotGet(b.pilot, 'type'), 3);
  });

  // ---- flow ----
  await t('normal run: intro once, loop START -> VGAME -> END(0x23) -> START ... quit', async () => {
    const p = progs({ logo: [0], start: [0x0D, 0x0C, 0], vgame: [5, 5], end: [0x23, 0x23] });
    const res = await runFlow(p, createBlock());
    assert.deepStrictEqual(p.calls, [
      'setup', 'logo ' + String.fromCharCode(0), 'player ' + INTRO_ARGS,
      'dswap 0', 'start', 'dswap 1', 'vgame', 'dswap 2', 'end',
      'dswap 0', 'start', 'dswap 1', 'player' + ' ' + TITLE2_ARGS, 'vgame', 'dswap 2', 'end',
      'dswap 0', 'start']);
    assert.strictEqual(res.reason, 'start');
    assert.strictEqual(res.trace[res.trace.length - 1], 'exit');
  });
  await t('logo arg is the upper-cased first letter of the sound driver name', async () => {
    const p = progs({ logo: [1], start: [0] }, (name, ctx) => { if (name === 'setup') ctx.block.setString('sndName', 'Asound.117'); });
    await runFlow(p, createBlock());
    assert.strictEqual(p.calls[1], 'logo A');
    assert.ok(!p.calls.some((c) => c.startsWith('player')));      // intro flag != 0: no intro
  });
  await t('setup failure and logo abort quit immediately', async () => {
    let p = progs({ setup: [0x00] });
    assert.strictEqual((await runFlow(p, createBlock())).reason, 'setup');
    assert.deepStrictEqual(p.calls, ['setup']);
    p = progs({ logo: [2] });
    assert.strictEqual((await runFlow(p, createBlock())).reason, 'logo');
    assert.deepStrictEqual(p.calls, ['setup', 'logo \u0000'.replace('\u0000', String.fromCharCode(0))]);
  });
  await t('quit codes at each stage; END other than 0x23 ends the game', async () => {
    let p = progs({ logo: [1], start: [0x0D], vgame: [0] });
    assert.strictEqual((await runFlow(p, createBlock())).reason, 'vgame');
    assert.ok(!p.calls.includes('end'));
    p = progs({ logo: [1], start: [0x0D], vgame: [1], end: [0] });
    assert.strictEqual((await runFlow(p, createBlock())).reason, 'end');
    p = progs({ logo: [1], start: [0x0D], vgame: [1], end: [0x22] });
    assert.strictEqual((await runFlow(p, createBlock())).reason, 'end');
  });
  await t('DSWAP exit 0 quits; missing dswap defaults to disk present', async () => {
    let p = progs({ logo: [1], dswap: [0] });
    assert.strictEqual((await runFlow(p, createBlock())).reason, 'dswap');
    p = progs({ logo: [1], start: [0] }); delete p.dswap;
    assert.strictEqual((await runFlow(p, createBlock())).reason, 'start');
  });
  await t('bios words: 04F2 = 1, 04F4 = 0 at launch; the shared block is shared by all programs', async () => {
    let seen = null;
    const p = progs({ logo: [1], start: [0x0D, 0] }, (name, ctx) => {
      if (name === 'setup') { assert.deepStrictEqual(ctx.bios, { firstEntry: 1, soundInit: 0 }); ctx.block.set('clearance', 1); }
      if (name === 'start') seen = ctx.block.get('clearance');
    });
    await runFlow(p, createBlock());
    assert.strictEqual(seen, 1);
  });
  await t('maxLoops stops a never-ending loop', async () => {
    const p = progs({ logo: [1] });
    p.start = async () => 0x0D; p.vgame = async () => 1; p.end = async () => 0x23;
    assert.strictEqual((await runFlow(p, createBlock(), { maxLoops: 3 })).reason, 'maxLoops');
  });

  console.log('flow.test.js: ' + passed + ' passed');
})().catch((e) => { console.error(e); process.exit(1); });
