// Task 2.3: SETUP port. Run: node tests/setup.test.js
'use strict';
const assert = require('assert');
const { createBlock } = require('../src/block.js');
const { createSetupProgram, SETUP_EXIT_OK } = require('../src/frontend/setup.js');
const { runFlow } = require('../src/flow.js');

(async () => {
  let passed = 0;
  async function run(choice) {
    const asked = [];
    const prog = createSetupProgram({ choose: async (title, labels) => { asked.push([title, labels]); return choice; } });
    const block = createBlock();
    const code = await prog({ block, bios: {} });
    return { block, code, asked };
  }

  let r = await run(0);
  assert.strictEqual(r.code, 0x24); assert.strictEqual(SETUP_EXIT_OK, 0x24); passed++;
  assert.deepStrictEqual(r.asked[0], ['Select Sound Driver:', ['Ad Lib Sound Board', 'No Sound']]); passed++;
  const b = r.block;
  assert.strictEqual(b.getString('sndName'), 'Asound.117');
  assert.strictEqual(b.getString('gfxName'), 'Mgraphic.exe');
  assert.strictEqual(b.get('clearance'), 1);
  assert.strictEqual(b.get('endState'), 1);
  assert.strictEqual(b.get('sndArg'), 0); assert.strictEqual(b.get('unk2A'), 0); assert.strictEqual(b.get('unk70'), 0);
  assert.strictEqual(b.get('inputFlags'), 0);
  assert.strictEqual(b.get('drvKind'), 3);
  assert.strictEqual(b.bytes[0x0D], 'A'.charCodeAt(0)); passed++;

  r = await run(1);
  assert.strictEqual(r.block.getString('sndName'), 'Nsound.117'); passed++;

  // inside the flow: SETUP result feeds the logo argument (first letter, upper-cased)
  const calls = [];
  const progs = {
    setup: createSetupProgram({ choose: async () => 0 }),
    logo: async (ctx) => { calls.push('logo ' + ctx.args); return 1; },
    start: async () => 0, vgame: async () => 0, end: async () => 0
  };
  const res = await runFlow(progs, createBlock());
  assert.deepStrictEqual(calls, ['logo A']); assert.strictEqual(res.reason, 'start'); passed++;

  console.log('setup.test.js: ' + passed + ' passed');
})().catch((e) => { console.error(e); process.exit(1); });
