// START.EXE program shell (task 2.4; start-map.md 1.1, 2.2): main 0000:0010 -> init, roster_sync, frontend_loop 020F.
// Only the roster state (4) is ported; the home screen (0) is the real picture with its 5 hotspots but no info panel (008D).
// Returns the exit code for flow.js: 0 = quit (Alt-Q). Later cards add orders (1), briefing (2), armament (3) and launch (5).
(function (root) {
  'use strict';
  function mods() {
    if (typeof module !== 'undefined' && module.exports)
      return { R: require('../roster.js'), M: require('./menu.js'), S: require('./roster-screen.js') };
    return { R: root.F117.roster, M: root.F117.menu, S: root.F117.rosterScreen };
  }
  var HOME_RECTS = [[3, 40, 54, 128], [256, 11, 299, 95], [203, 38, 225, 105], [69, 45, 132, 80], [149, 53, 187, 104]];   // ds:6F42

  // host: see menu.js; plus host.storage (localStorage-like) and host.assets
  function createStartProgram(host) {
    return async function (ctx) {
      var X = mods(), ui = X.M.createUi(host), block = ctx.block, bios = ctx.bios;
      var seed = null;
      try { seed = await host.assets.bytes('roster/ROSTER.FIL'); } catch (e) { seed = null; }
      var roster = X.R.createRoster({ storage: host.storage || null, seed: seed });
      var state = { planeSel: 0 };
      try {
        await ui.picLoad(11, 2); ui.initCursor();                                                    // 74B1: requestr -> page 2, cursor sprite
        roster.sync(block, bios);                                                                    // 6D07 (first entry copies roster[hdr] -> PR)
        var screens = X.S.createRosterScreens({ ui: ui, host: host, block: block, bios: bios, roster: roster, state: state });
        var pr = block.pilot, st = (bios.firstEntry !== 0 || X.R.pilotGet(pr, 'status') !== 0) ? 4 : 0;
        for (;;) {
          if (st === 4) { await screens.rosterScreen(); st = 0; }
          else {
            await ui.screenEnter(5, null);                                                           // home: homescrn, hotspots 1..5
            var r;
            do { r = await ui.menuWait({ hover: null, hotkey: 0, rects: HOME_RECTS }); } while (r === 0x63);
            if (r === 4) st = 4;
          }
        }
      } catch (e) {
        if (e instanceof X.M.StartExit) return e.code;
        throw e;
      }
    };
  }

  var api = { createStartProgram: createStartProgram, HOME_RECTS: HOME_RECTS };
  if (typeof module !== 'undefined' && module.exports) module.exports = api;
  else { root.F117 = root.F117 || {}; root.F117.start = api; }
})(typeof window !== 'undefined' ? window : globalThis);
