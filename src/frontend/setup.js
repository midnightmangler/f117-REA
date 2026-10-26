// SETUP (task 2.3): port equivalent of SETUP.EXE (setup-dswap-map.md, SETUP steps 6-12). The original asks for joystick, mouse
// detection, then the sound driver, and leaves the answers in the shared block; F117.COM requires exit code 0x24.
// Only sound is asked: AdLib (OPL2 emulation) or none. Joystick / mouse flags stay 0 (the touch stick is a later task; its
// calibration format at SB+0x48 is not needed until then). host.choose(title, labels) -> Promise<index>.
(function (root) {
  'use strict';
  var SETUP_EXIT_OK = 0x24;
  var DRIVERS = [
    { label: 'Ad Lib Sound Board', file: 'Asound.117' },    // original menu entry 2
    { label: 'No Sound', file: 'Nsound.117' }               // original menu entry 4
  ];                                                         // IBM (Isound) / Roland (Rsound) are not planned (decision 2026-10-21)

  function createSetupProgram(host) {
    return async function (ctx) {
      var b = ctx.block;
      // steps 6..7 (0191..01B2), joystick answer N
      b.set('clearance', 1); b.set('sndArg', 0); b.set('unk70', 0);
      b.bytes[0x32] = 0xFF; b.bytes[0x33] = 0xFF;            // SB+0x32 = 0xFFFF
      b.set('inputFlags', 0);                                // step 7/9: no joystick, no mouse
      // step 10 (0327..0340): graphics driver name, only recorded
      b.setString('gfxName', 'Mgraphic.exe');
      // step 11 (0367..047B): "Select Sound Driver:"
      var i = await host.choose('Select Sound Driver:', DRIVERS.map(function (d) { return d.label; }));
      b.setString('sndName', DRIVERS[i === 1 ? 1 : 0].file);
      // step 12 (049E..04F1)
      b.set('unk2A', 0); b.set('endState', 1); b.set('training', 0);
      if (b.bytes[0x32] === 0xFF && b.bytes[0x33] === 0xFF) {  // 'M'/'m' graphics name -> 3, else 2 (word write (?))
        var c = b.bytes[0] | 0x20;
        b.bytes[0x32] = c === 0x6D ? 3 : 2; b.bytes[0x33] = 0;
      }
      return SETUP_EXIT_OK;                                  // 04F7: exit(0x24)
    };
  }

  var api = { createSetupProgram: createSetupProgram, DRIVERS: DRIVERS, SETUP_EXIT_OK: SETUP_EXIT_OK };
  if (typeof module !== 'undefined' && module.exports) module.exports = api;
  else { root.F117 = root.F117 || {}; root.F117.setup = api; }
})(typeof window !== 'undefined' ? window : globalThis);
