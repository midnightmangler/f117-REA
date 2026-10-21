// Shared block (task 2.1): the 0x140-paragraph (5120 byte) area F117.COM allocates and every EXE finds through 0:04F0.
// Layout = start-map.md sec. 1.3 (F117.asm 0000:0100, SETUP, START main, END). Little-endian like the 8086.
// Fields are accessed by name: block.get('clearance'), block.set('endState', 3); arrays/strings via getArray/getString.
(function (root) {
  'use strict';
  var SIZE = 0x140 * 16;
  var PILOT_OFF = 0x1272, PILOT_SIZE = 0x50, WORLD_OFF = 0x7A;

  // name: [offset, kind, count]  kind: 'w' word, 'b' byte, 'str' char[count], 'wa' word array, 'ba' byte array
  var FIELDS = {
    gfxName: [0x00, 'str', 13],          // SETUP: graphics driver file name
    sndName: [0x0D, 'str', 13],          // SETUP: sound driver file name
    sndSeg: [0x1A, 'w'], gfxSeg: [0x1C, 'w'], miscSeg: [0x1E, 'w'],   // loader (unused here)
    sndRet: [0x20, 'w'],                 // sound init return; VGAME reuses it as the cockpit-art page segment
    clearance: [0x22, 'w'],              // SETUP=1; 0 -> only Libya, training forced
    sndArg: [0x24, 'w'],                 // argument of the sound driver init (?)
    endState: [0x26, 'w'],               // 1 crashed/killed, 2 ejected, 3 landed
    deathCause: [0x28, 'w'],             // 0 alive, 1..6
    unk2A: [0x2A, 'w'],
    barTalk: [0x2C, 'w'],                // END bar-talk count (?)
    fuel: [0x2E, 'w'],                   // 12 x route length
    training: [0x30, 'w'],
    drvKind: [0x32, 'b'],                // 3 if graphics driver name starts with 'M' else 2
    night: [0x33, 'b'],
    flags: [0x34, 'w'], damage: [0x36, 'w'],
    bayWeapon: [0x38, 'wa', 4],          // weapon index per bay, 0x13 = empty
    bayQty: [0x40, 'wa', 4],
    joyCal: [0x48, 'ba', 40],            // joystick calibration, 0x14 words
    unk70: [0x70, 'w'],
    inputFlags: [0x72, 'w'],             // bit0 joystick, bit1 mouse
    finalX: [0x74, 'w'], finalY: [0x76, 'w']
  };

  function createBlock(buffer) {
    var buf = buffer || new ArrayBuffer(SIZE);
    if (buf.byteLength !== SIZE) throw new Error('shared block must be ' + SIZE + ' bytes');
    var dv = new DataView(buf), u8 = new Uint8Array(buf);
    function f(name) { var d = FIELDS[name]; if (!d) throw new Error('unknown block field ' + name); return d; }
    var b = {
      buffer: buf, bytes: u8, SIZE: SIZE,
      get: function (name, i) {
        var d = f(name), o = d[0];
        switch (d[1]) {
          case 'w': return dv.getUint16(o, true);
          case 'b': return u8[o];
          case 'wa': return dv.getUint16(o + 2 * i, true);
          case 'ba': return u8[o + i];
          case 'str': return b.getString(name);
        }
      },
      set: function (name, v, i) {
        var d = f(name), o = d[0];
        switch (d[1]) {
          case 'w': dv.setUint16(o, v & 0xFFFF, true); break;
          case 'b': u8[o] = v & 0xFF; break;
          case 'wa': dv.setUint16(o + 2 * i, v & 0xFFFF, true); break;
          case 'ba': u8[o + i] = v & 0xFF; break;
          case 'str': b.setString(name, v); break;
        }
      },
      getString: function (name) {
        var d = f(name), s = '';
        for (var k = 0; k < d[2] && u8[d[0] + k]; k++) s += String.fromCharCode(u8[d[0] + k]);
        return s;
      },
      setString: function (name, s) {                    // far strcpy: copies the terminator, rest untouched
        var d = f(name);
        if (s.length + 1 > d[2]) throw new Error(name + ' too long');
        for (var k = 0; k < s.length; k++) u8[d[0] + k] = s.charCodeAt(k) & 0xFF;
        u8[d[0] + s.length] = 0;
      },
      getArray: function (name) {
        var d = f(name), out = [];
        for (var k = 0; k < d[2]; k++) out.push(b.get(name, k));
        return out;
      },
      // current pilot record (80 bytes, same layout as a ROSTER.FIL record), a live view into the block
      get pilot() { return u8.subarray(PILOT_OFF, PILOT_OFF + PILOT_SIZE); },
      // serialised mission world (START 5625 -> VGAME/END) from +0x7A to the pilot record
      get world() { return u8.subarray(WORLD_OFF, PILOT_OFF); },
      reset: function () { u8.fill(0); }
    };
    return b;
  }

  var api = { createBlock: createBlock, FIELDS: FIELDS, SIZE: SIZE, PILOT_OFF: PILOT_OFF, PILOT_SIZE: PILOT_SIZE, WORLD_OFF: WORLD_OFF };
  if (typeof module !== 'undefined' && module.exports) module.exports = api;
  else { root.F117 = root.F117 || {}; root.F117.block = api; }
})(typeof window !== 'undefined' ? window : globalThis);
