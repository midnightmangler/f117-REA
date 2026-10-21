// Input core (task 1.5; vgame-map.md sec. 7, VGAME 0000:1EB0 key drain, 0000:C89C, INT 9 hook 1132:006C).
// Everything the player does funnels through: one BIOS key word per frame (ds:DEBC), the stick bytes (0x80 = centre)
// and the two buttons. Key words are INT 16h AX = scan<<8 | ascii. This module is the BIOS keyboard buffer + the
// INT 9 hook; the game code (1EB0 / C8CA ports) reads it through frameKey(), stickX/stickY, button().
// Verified against the listing 1132:006C..0180 and the table at DS:2CDE (dumped from VGAME.EXE, 13 non-zero entries).
(function (root) {
  'use strict';
  var BUF_MAX = 15;            // BIOS ring of 16 words holds 15
  var TICK_HZ = 18.2065;       // BIOS tick (40:6C) used for the double-press window

  // DS:2CDE, scancodes 0x29..0x51 -> direction mask: 1 = Y low, 2 = Y high, 4 = X low, 8 = X high, 0x80 = KP5 (no axis)
  var STICK_MASK = {
    0x29: 1, 0x2B: 4, 0x47: 5, 0x48: 1, 0x49: 9, 0x4A: 2, 0x4B: 4, 0x4C: 0x80, 0x4D: 8, 0x4E: 8, 0x4F: 6, 0x50: 2, 0x51: 0xA
  };

  // KeyboardEvent.code -> [scan, ascii, shifted ascii]; letters get ascii from the code.
  var KEYS = { Escape: [1, 27, 27], Backspace: [0x0E, 8, 8], Tab: [0x0F, 9, 0], Enter: [0x1C, 13, 13], Space: [0x39, 32, 32],
    Minus: [0x0C, 45, 95], Equal: [0x0D, 61, 43], BracketLeft: [0x1A, 91, 123], BracketRight: [0x1B, 93, 125],
    Semicolon: [0x27, 59, 58], Quote: [0x28, 39, 34], Backquote: [0x29, 96, 126], Backslash: [0x2B, 92, 124],
    Comma: [0x33, 44, 60], Period: [0x34, 46, 62], Slash: [0x35, 47, 63] };
  var DIGIT_SHIFT = ')!@#$%^&*(';
  var LETTER_SCAN = 'QWERTYUIOP', LETTER_SCAN2 = 'ASDFGHJKL', LETTER_SCAN3 = 'ZXCVBNM';
  var i, c;
  for (i = 0; i < 10; i++) { c = (i + 1) % 10; KEYS['Digit' + c] = [0x02 + i, 48 + c, DIGIT_SHIFT.charCodeAt(c)]; }
  for (i = 0; i < 10; i++) KEYS['Key' + LETTER_SCAN[i]] = [0x10 + i, LETTER_SCAN.charCodeAt(i), 0];
  for (i = 0; i < 9; i++) KEYS['Key' + LETTER_SCAN2[i]] = [0x1E + i, LETTER_SCAN2.charCodeAt(i), 0];
  for (i = 0; i < 7; i++) KEYS['Key' + LETTER_SCAN3[i]] = [0x2C + i, LETTER_SCAN3.charCodeAt(i), 0];
  // Function keys: scan 0x3B.. ; shifted 0x54.., ctrl 0x5E.., alt 0x68..
  // Cursor block / keypad: [scan, ext, shifted ascii (BIOS gives scan<<8 only when NumLock is off and Shift is up)]
  var NAV = { ArrowUp: [0x48, 1, 0], ArrowDown: [0x50, 1, 0], ArrowLeft: [0x4B, 1, 0], ArrowRight: [0x4D, 1, 0],
    Home: [0x47, 1, 0], End: [0x4F, 1, 0], PageUp: [0x49, 1, 0], PageDown: [0x51, 1, 0], Insert: [0x52, 1, 0], Delete: [0x53, 1, 0],
    Numpad7: [0x47, 0, 55], Numpad8: [0x48, 0, 56], Numpad9: [0x49, 0, 57], Numpad4: [0x4B, 0, 52], Numpad5: [0x4C, 0, 53],
    Numpad6: [0x4D, 0, 54], Numpad1: [0x4F, 0, 49], Numpad2: [0x50, 0, 50], Numpad3: [0x51, 0, 51], Numpad0: [0x52, 0, 48],
    NumpadDecimal: [0x53, 0, 46] };
  var KPCHAR = { NumpadAdd: [0x4E, 43], NumpadSubtract: [0x4A, 45], NumpadMultiply: [0x37, 42], NumpadDivide: [0x35, 47, 1],
    NumpadEnter: [0x1C, 13, 1] };

  // Scancode + extended flag of a KeyboardEvent.code (what the INT 9 hook sees on port 0x60); null if not a key we model.
  function scanOf(code) {
    var k = KEYS[code]; if (k) return { scan: k[0], ext: 0 };
    var n = NAV[code]; if (n) return { scan: n[0], ext: n[1] };
    var p = KPCHAR[code]; if (p) return { scan: p[0], ext: p[2] || 0 };
    var f = /^F(\d+)$/.exec(code);
    if (f) { var m = +f[1]; if (m >= 1 && m <= 10) return { scan: 0x3A + m, ext: 0 }; }
    return null;
  }

  // BIOS INT 16h AH=0 word for a key event (NumLock is forced off by the game, so the keypad acts as a cursor block unless Shift).
  function wordOf(ev) {
    var code = ev.code, shift = !!ev.shiftKey, alt = !!ev.altKey, ctrl = !!ev.ctrlKey, k, n, p, f;
    if ((k = KEYS[code])) {
      var s = k[0];
      if (alt) return s << 8;
      var isLetter = /^Key/.test(code);
      if (isLetter) {
        if (ctrl) return (s << 8) | (k[1] & 0x1F);
        var caps = ev.getModifierState ? ev.getModifierState('CapsLock') : false;
        return (s << 8) | ((shift !== caps) ? k[1] : k[1] + 32);
      }
      if (ctrl && code === 'Backspace') return (s << 8) | 0x7F;
      return (s << 8) | (shift ? k[2] : k[1]);
    }
    if ((n = NAV[code])) {
      if (alt || ctrl) return 0;
      return (n[0] << 8) | ((!n[1] && shift) ? n[2] : 0);
    }
    if ((p = KPCHAR[code])) return (p[0] << 8) | p[1];
    if ((f = /^F(\d+)$/.exec(code))) {
      var m = +f[1]; if (m < 1 || m > 10) return 0;
      var base = alt ? 0x68 : ctrl ? 0x5E : shift ? 0x54 : 0x3B;
      return (base + m - 1) << 8;
    }
    return 0;
  }

  // opts: ticks() -> BIOS tick counter (default derived from performance.now), joystick -> start in joystick mode
  function createInput(opts) {
    opts = opts || {};
    var ticks = opts.ticks || function () {
      var now = (typeof performance !== 'undefined') ? performance.now() : Date.now();
      return Math.floor(now * TICK_HZ / 1000);
    };
    var buf = [];
    var joystick = !!opts.joystick;
    var virtX = 0x80, virtY = 0x80;       // ds:2CD6 / 2CD7
    var joyX = 0x80, joyY = 0x80;         // ds:2CD2 / 2CD3
    var held = 0, last = 0, lastTick = 0; // ds:2CD8 held mask, ds:2CDC last mask, ds:2CD9 tick of last accepted press
    var joyBtn = [0, 0], pseudo = [0, 0]; // joystick buttons; keyboard pseudo-buttons ds:43EE + 2n

    // 1132:0149..0178: before the BIOS stores a new key, a head run of identical words (typematic repeats) is collapsed.
    function dedupe() {
      if (!buf.length) return;
      var ax = buf[0], j = 1;
      while (j < buf.length && buf[j] === ax) j++;
      buf.splice(0, j - 1);
    }
    function store(word) { dedupe(); if (word && buf.length < BUF_MAX) buf.push(word & 0xFFFF); }

    // 1132:008D..0147 for one make (up=false) / break (up=true) of a scancode; shift = Shift held, ext = E0-prefixed key.
    function stickScan(scan, ext, up, shift) {
      if (joystick) return;                           // hook is only installed without a joystick (0235)
      if (!ext && shift) return;                      // 00A7..00C1: (Shift xor NumLock(off)) -> ignored; E0 keys skip this test
      var al = STICK_MASK[scan] || 0;
      if (!al) return;
      if (!up) {
        if (held !== 0) return;                       // 00DD: another key is still down
        held = al;
        var same = (last === al); last = al;
        var now = ticks() & 0xFFFF;
        var d = 0x5A;
        if (same && ((now - lastTick) & 0xFFFF) < 5) d = 0x7F;
        var lo = 0x80 - d, hi = 0x80 + d;
        if (al & 1) virtY = lo;
        if (al & 2) virtY = hi;
        if (al & 4) virtX = lo;
        if (al & 8) virtX = hi;
        lastTick = now;
      } else if (held === al) {                       // 0134: only the key that set it recentres
        held = 0; virtX = 0x80; virtY = 0x80;
      }
    }

    var api = {
      // ---- hardware keyboard (call from DOM events; returns true if the event was one we use) ----
      keyDown: function (ev) {
        var sc = scanOf(ev.code); if (!sc) return false;
        stickScan(sc.scan, sc.ext, false, !!ev.shiftKey);
        store(wordOf(ev));
        return true;
      },
      keyUp: function (ev) {
        var sc = scanOf(ev.code); if (!sc) return false;
        stickScan(sc.scan, sc.ext, true, !!ev.shiftKey);
        return true;
      },
      attach: function (win) {
        win = win || window;
        function dn(e) { if (api.keyDown(e)) e.preventDefault(); }
        function up(e) { if (api.keyUp(e)) e.preventDefault(); }
        win.addEventListener('keydown', dn); win.addEventListener('keyup', up);
        return { detach: function () { win.removeEventListener('keydown', dn); win.removeEventListener('keyup', up); } };
      },

      // ---- key words (BIOS buffer): touch overlay / tests inject here ----
      pushKey: store,
      flush: function () { buf.length = 0; },
      // misc driver T:02DC / T:02E1 (pause + quit prompts); assumed to read the same INT 16h buffer (?). 0 = none.
      keyReady: function () { return buf.length > 0; },
      getKey: function () { return buf.length ? buf.shift() : 0; },
      // 1EB0:1F08..1F2D: ds:DEBC = first key of this frame (0 if none), then the rest of the buffer is discarded.
      frameKey: function () { var w = buf.length ? buf[0] : 0; buf.length = 0; return w; },

      // ---- stick: bytes 0x80 = centre. Keyboard mode reads the virtual stick, joystick mode the joystick bytes ----
      get joystick() { return joystick; },
      setJoystick: function (on) { joystick = !!on; held = 0; virtX = virtY = 0x80; },
      setStick: function (x, y) { joyX = x & 0xFF; joyY = y & 0xFF; },     // touch overlay / gamepad (joystick mode)
      get stickX() { return joystick ? joyX : virtX; },
      get stickY() { return joystick ? joyY : virtY; },
      get virtualStick() { return { x: virtX, y: virtY, held: held }; },

      // ---- buttons: C89C(n) = joystick button (only in joystick mode) + keyboard pseudo-button ds:43EE+2n ----
      setJoyButton: function (n, v) { joyBtn[n] = v ? 1 : 0; },
      setPseudoButton: function (n, v) { pseudo[n] = v | 0; },              // written by the C8CA port (Backspace/Enter)
      button: function (n) { return ((joystick ? joyBtn[n] : 0) | pseudo[n]) & 0xFFFF; }
    };
    return api;
  }

  var apiOut = { createInput: createInput, wordOf: wordOf, scanOf: scanOf, STICK_MASK: STICK_MASK, BUF_MAX: BUF_MAX };
  if (typeof module !== 'undefined' && module.exports) module.exports = apiOut;
  else { root.F117 = root.F117 || {}; root.F117.input = apiOut; }
})(typeof window !== 'undefined' ? window : globalThis);
