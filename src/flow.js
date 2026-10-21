// Program flow (task 2.1; decomp re/decomp/flow/flow.md): F117.COM 0000:0100..03C9 as a state machine over "programs".
// A program is async (ctx) -> exit code, standing in for one EXE (SETUP, MPS_LOGO, PLAYER, START, VGAME, END).
// ctx = { block, bios, args }. DSWAP (floppy swap prompt) is optional and defaults to exit 1 = disk present.
(function (root) {
  'use strict';
  var SETUP_OK = 0x24, LOGO_ABORT = 2, END_AGAIN = 0x23, START_TITLE2 = 0x0C;
  var INTRO_ARGS = '- title-1 title-2 title-3a credit c-pit bunker';   // 0000:06A2
  var TITLE2_ARGS = ' title-2';                                         // 0000:06D2

  // programs: {setup, logo, player, start, vgame, end, dswap?, shutdown?}; blk: createBlock()
  // resolves {reason, trace[], bios}  reason: 'setup' | 'logo' | 'dswap' | 'start' | 'vgame' | 'end' | 'maxLoops'
  async function runFlow(programs, blk, opts) {
    opts = opts || {};
    var bios = { firstEntry: 1, soundInit: 0 };          // 0:04F2 = 1, 0:04F4 = 0 (loader)
    var trace = [];
    var maxLoops = opts.maxLoops || Infinity;

    async function exec(name, args) {
      trace.push(args === undefined ? name : name + ' ' + args);
      return (await programs[name]({ block: blk, bios: bios, args: args })) & 0xFF;
    }
    async function dswap(n) {
      if (!programs.dswap) { trace.push('dswap ' + n); return 1; }
      return exec('dswap', String(n));
    }
    async function finish(reason) {                       // 03C2: shutdown vector, DOS exit
      trace.push('exit');
      if (programs.shutdown) await programs.shutdown({ block: blk, bios: bios });
      return { reason: reason, trace: trace, bios: bios };
    }

    blk.reset();
    if (await exec('setup') !== SETUP_OK) return finish('setup');                 // 0150..0178
    var logoArg = String.fromCharCode(blk.bytes[0x0D] & 0x5F);              // 017F: sound driver initial, upper-cased
    var lc = await exec('logo', logoArg);                                          // 019B..01C1
    if (lc === LOGO_ABORT) return finish('logo');
    if (lc === 0) await exec('player', INTRO_ARGS);                                // 0265: [0x6F9] == 0 -> intro

    for (var n = 0; n < maxLoops; n++) {                                           // 0285
      if (await dswap(0) === 0) return finish('dswap');
      var startExit = await exec('start');                                         // 02C0, saved in [0x6F8]
      if (startExit === 0) return finish('start');
      if (await dswap(1) === 0) return finish('dswap');
      if (startExit === START_TITLE2) await exec('player', TITLE2_ARGS);           // 031B (0x0D carrier: no animation)
      if (await exec('vgame') === 0) return finish('vgame');                       // 0337
      if (await dswap(2) === 0) return finish('dswap');
      if (await exec('end') !== END_AGAIN) return finish('end');                   // 0395; 0x23 -> loop (intro not replayed)
    }
    return finish('maxLoops');
  }

  var api = { runFlow: runFlow, SETUP_OK: SETUP_OK, LOGO_ABORT: LOGO_ABORT, END_AGAIN: END_AGAIN, START_TITLE2: START_TITLE2,
    INTRO_ARGS: INTRO_ARGS, TITLE2_ARGS: TITLE2_ARGS };
  if (typeof module !== 'undefined' && module.exports) module.exports = api;
  else { root.F117 = root.F117 || {}; root.F117.flow = api; }
})(typeof window !== 'undefined' ? window : globalThis);
