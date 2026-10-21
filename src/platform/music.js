// ASOUND.117 (AdLib driver) port, task 1.4: play() ids, sequencer, noise voices, engine, speech via OPL.
// Decompiled in re/decomp/asound/sequencer.md; addresses are ASOUND code-segment offsets (cs = image + 0x1B60).
// The driver's data segment is kept as a byte copy of the image (mem), so voice records, the register shadow and the
// self-modifying streams (F6 RANDPATCH, ids 28/33) live at their original offsets. Card 0 (plain AdLib, mono).
// sink(reg, val, dtSec): every OPL register write; dtSec > 0 only for the speech writes (offset from the call).
(function (root) {
  'use strict';
  var CS = 0x1B60, VOICES = 0x190A, VSIZE = 0x1E, SHADOW = 0x1A06, NOISEP = 0x1B06;
  var FNUM = 0x187A, CHOPS = 0x1896, SLOTREG = 0x18A8, INSTR = 0x002E, LOGTAB = CS + 0x0018;
  var TICKRET = 0x17DC, NSTATE = 0x17DE, RNG = 0x17E4, LASTTHR = 0x17E6, ENGFNUM = 0x17E8, ENGTL = 0x17EA;
  var LOCK = 0x17EC, SAVA = 0x17F0, SAVB = 0x17F1, THR = 0x17F4, ENGON = 0x17F6, SPEECHPARA = 0x17E2;
  var CNTA = 0x19DC, CNTB = 0x19FC, MASKA = 0x19FE, MASKB = 0x1A00, BASEA = 0x1902, BASEB = 0x1904;
  var STEPA = 0x1906, STEPB = 0x1908, NEXTB = 0x1A03, CHA = 0x1A04, CHB = 0x1A05;
  var PIT = 1193182, SPEECH_PIT = 0x96, SPEECH_SETTLE = 0x988;   // cs:0A1C, cs:0AE9

  function sx8(b) { return (b << 24) >> 24; }
  function sx16(w) { return (w << 16) >> 16; }

  // Image bytes of ASOUND.117 (the MZ header stripped).
  function asoundImage(file) {
    var hdr = (file[8] | (file[9] << 8)) * 16;
    return file.subarray(hdr);
  }

  function createAsound(image, sink) {
    var mem = new Uint8Array(image);            // ds = image start
    var tickCount = 0;                          // cs:000E
    var volFlag = 0;                            // [bp-4] of cs:1360, a fixed stack slot (persists)
    var speech = null;                          // last speech request: {key, sec}
    var trace = null;                           // test hook: trace(voice, addr) per event read

    function rw(a) { return mem[a] | (mem[a + 1] << 8); }
    function ww(a, v) { mem[a] = v & 0xFF; mem[a + 1] = (v >> 8) & 0xFF; }
    function V(v) { return VOICES + VSIZE * v; }

    // cs:036B: shadow + port 0x388
    function wr(reg, val) { reg &= 0xFF; val &= 0xFF; mem[SHADOW + reg] = val; sink(reg, val, 0); }
    function sh(reg) { return mem[SHADOW + (reg & 0xFF)]; }

    // cs:03C4 / inline at cs:0562
    function rng() {
      var r = (rw(RNG) + 0x9248) & 0xFFFF;
      r = ((r >>> 3) | (r << 13)) & 0xFFFF;
      ww(RNG, r);
      return r;
    }

    // cs:0210
    function resetRegs() {
      var r;
      for (r = 0x5F; r >= 0x40; r--) wr(r, 0x3F);
      for (r = 0xFF; r >= 0x60; r--) wr(r, 0);
      for (r = 0x3F; r >= 0x01; r--) wr(r, 0);
      wr(0x01, 0x20);
    }

    // cs:018F
    function silence() {
      var save = rw(LOCK); ww(LOCK, 0xFFFF);
      for (var v = 0; v < 7; v++) { var b = V(v); mem[b] = mem[b + 1] = mem[b + 2] = mem[b + 3] = 0; }
      mem[CNTA] = 0; mem[CNTB] = 0; ww(MASKA, 0); ww(MASKB, 0);
      ww(BASEA, 0); ww(BASEB, 0); ww(STEPA, 0); ww(STEPB, 0);
      resetRegs();
      ww(LOCK, save);
    }

    // cs:030B
    function setFreq(ch, w) { wr(0xA0 + ch, w & 0xFF); wr(0xB0 + ch, ((w >> 8) & 0xFF) | 0x20); }

    // cs:05A5
    function noiseStarted() { if (rw(NSTATE) !== 1) { ww(NSTATE, 1); ww(TICKRET, 1); } }

    // cs:05E7 (entries 05E3 v0 .. 05B9 v6)
    function voiceStart(v, seq, ax) {
      var b = V(v), save = rw(LOCK);
      ww(LOCK, 0);
      mem[b + 1] = 0; mem[b + 0x0A] = 0xFF; mem[b + 2] = 0; mem[b + 3] = 0;
      mem[b + 0x1C] = 0; mem[b + 0x1D] = 0; mem[b + 0x0D] = 0x40;
      ww(b + 0x0E, seq); ww(b + 0x10, seq); ww(b + 0x12, seq); ww(b + 0x14, seq);
      ww(b + 0x16, 0); ww(b + 0x18, 0); mem[b + 7] = 0; ww(b + 0x1A, ax || 0); mem[b] = 1;
      ww(LOCK, save);
    }

    // cs:03D5 (03D8 = entry with the value in BX)
    function setThrottle(t) {
      t = sx16(t);
      if (t > 0x301) t = 0x301;
      ww(THR, t);
      if (t === 0) { ww(LASTTHR, 0); return; }
      ww(ENGFNUM, (t & 0xFFFE) + 0x883);
    }

    // cs:03FB
    function engineTL(v) {
      if (mem[ENGON] === 0 || rw(THR) === 0) return;
      wr(0x50, (0x3F - v) & 0xFF);
      wr(0x53, v & 0xFF);
    }

    // ---- per-channel helpers (ch = ds:1A02, b = ds:1B62) ----
    function carrierReg(ch) { return 0x40 + mem[SLOTREG + sx8(mem[CHOPS + 2 * ch + 1])]; }

    // cs:0C2E, card 0 path cs:0D00
    function setVolume(ch, b) {
      var reg = carrierReg(ch);
      var lvl = 0x3F - ((mem[b + 6] + sx8(mem[b + 0x1D])) & 0x3F);
      wr(reg, (sh(reg) & 0xC0) | lvl);
    }

    // cs:0D1C
    function setPitch(ch, b) {
      var note = mem[b + 4], blk = (note / 12) | 0;
      var f = (sx8(mem[b + 0x1C]) + rw(FNUM + 2 * (note % 12))) & 0xFFFF;
      wr(0xA0 + ch, f & 0xFF);
      wr(0xB0 + ch, (sh(0xB0 + ch) & 0x20) | (((f >> 8) | (blk << 2)) & 0xFF));
    }

    // cs:0DCE
    function slide(ch, b) {
      var w = (((sh(0xB0 + ch) & 0x1F) << 8) + sh(0xA0 + ch) + sx8(mem[b + 1])) & 0xFFFF;
      wr(0xA0 + ch, w & 0xFF);
      wr(0xB0 + ch, (sh(0xB0 + ch) & 0x20) | ((w >> 8) & 0xFF));
    }

    // cs:0E5E
    function keyOff(ch) { wr(0xB0 + ch, sh(0xB0 + ch) & 0xDF); }

    // cs:0E8A
    function noteOn(ch, b) {
      setVolume(ch, b);
      var np = NOISEP + 8 * ch;
      if (mem[np] === 0) { setPitch(ch, b); wr(0xB0 + ch, sh(0xB0 + ch) | 0x20); return; }
      if (ch === mem[CHA]) mem[NEXTB] = 0;
      if (ch === mem[CHB]) mem[NEXTB] = 1;
      if (mem[NEXTB] === 0) {
        mem[NEXTB] = 1;
        if (mem[CNTA]) wr(0xB0 + mem[CHA], sh(0xB0 + mem[CHA]) & 0xDF);
        mem[CHA] = ch; mem[CNTA] = mem[np];
        ww(MASKA, rw(np + 2)); ww(BASEA, rw(np + 4)); ww(STEPA, rw(np + 6));
      } else {
        mem[NEXTB] = 0;
        if (mem[CNTA]) wr(0xB0 + mem[CHB], sh(0xB0 + mem[CHB]) & 0xDF);   // tests slot A's count (original)
        mem[CHB] = ch; mem[CNTB] = mem[np];
        ww(MASKB, rw(np + 2)); ww(BASEB, rw(np + 4)); ww(STEPB, rw(np + 6));
      }
      noiseStarted();
    }

    // cs:1048
    function opLoad(ch, off, op) {
      wr(0x40 + off, 0x3F);
      wr(0xBD, (sh(0xBD) & 0x3F) | (mem[0x1892] ? 0x80 : 0) | (mem[0x1893] ? 0x40 : 0));
      wr(0x08, mem[0x1894] ? 0x40 : 0);
      wr(0xC0 + ch, (mem[op + 0x0A] << 1) | (mem[op + 0x0D] ? 0 : 1));
      wr(0x60 + off, (mem[op] << 4) | (mem[op + 1] & 0x0F));
      wr(0x80 + off, (mem[op + 2] << 4) | (mem[op + 3] & 0x0F));
      wr(0x20 + off, (mem[op + 0x0B] ? 0x80 : 0) + (mem[op + 0x0C] ? 0x40 : 0) + (mem[op + 4] ? 0x20 : 0) +
        (mem[op + 5] ? 0x10 : 0) + (mem[op + 9] & 0x0F));
      wr(0xE0 + off, mem[op + 8] & 3);
      wr(0x40 + off, (0x3F - (mem[op + 6] & 0x3F)) | (mem[op + 7] << 6));
    }

    // cs:123E
    function loadInstr(ch, n) {
      keyOff(ch);
      var rec = INSTR + 0x2C * n, np = NOISEP + 8 * ch;
      opLoad(ch, mem[SLOTREG + sx8(mem[CHOPS + 2 * ch])], rec);
      mem[np] = mem[rec + 0x0E];
      ww(np + 2, rw(rec + 0x10)); ww(np + 4, rw(rec + 0x12)); ww(np + 6, rw(rec + 0x14));
      opLoad(ch, mem[SLOTREG + sx8(mem[CHOPS + 2 * ch + 1])], rec + 0x16);
    }

    // cs:1360: one voice, one tick
    function interpret(v) {
      var ch = v, b = V(v), p, n;
      if (mem[b] === 0) return;
      if (mem[b + 8] && --mem[b + 8] === 0) keyOff(ch);
      if (--mem[b] === 0) {
        for (;;) {                                                       // cs:13A5
          p = rw(b + 0x10);
          if (trace) trace(v, p);
          var c = mem[p];
          if (c < 0xF3) break;
          volFlag = 0;                                                   // cs:13C8
          switch (c) {
            case 0xF3: mem[b + 0x0C] = mem[p + 1]; mem[b + 3] = mem[p + 2]; mem[b + 0x0B] = 1; ww(b + 0x10, p + 3); break;
            case 0xF4: mem[b + 0x0D] = mem[p + 1]; ww(b + 0x10, p + 2); volFlag = 1; break;
            case 0xF5: mem[b + 0x1D] = mem[p + 1]; ww(b + 0x10, p + 2); break;
            case 0xF6:                                                   // cs:165E
              n = sx8(mem[p + 1]);
              var r = rng(), q = p + 2;
              var val = mem[(q + ((n - 1) & r)) & 0xFFFF];
              mem[(q + n + 1 + sx8(mem[(q + n) & 0xFFFF])) & 0xFFFF] = val;
              ww(b + 0x10, p + n + 3);
              break;
            case 0xF7: mem[b + 0x1C] = mem[p + 1]; ww(b + 0x10, p + 2); break;
            case 0xF8: mem[b + 0x0A] = mem[p + 1]; mem[b + 2] = mem[p + 2]; mem[b + 9] = 1; ww(b + 0x10, p + 3); break;
            case 0xF9: mem[b + 6] = mem[p + 1]; ww(b + 0x10, p + 2); volFlag = 1; break;
            case 0xFA: mem[b + 1] = mem[p + 1]; ww(b + 0x10, p + 2); break;
            case 0xFB: mem[b + 7] = mem[p + 1]; ww(b + 0x10, p + 2); break;
            case 0xFC: mem[b + 5] = mem[p + 1]; ww(b + 0x10, p + 2); loadInstr(ch, mem[b + 5]); break;
            case 0xFD:                                                   // cs:153E
              n = rw(b + 0x1A);
              if (n === 0) ww(b + 0x10, rw(b + 0x0E));
              else { ww(b + 0x0E, n); ww(b + 0x10, n); ww(b + 0x12, n); ww(b + 0x14, n); }
              break;
            case 0xFE:                                                   // cs:146A
              if (rw(b + 0x18) === 0) {
                n = sx8(mem[p + 1]);
                if (n === 0) { ww(b + 0x10, p + 2); ww(b + 0x14, p + 2); ww(b + 0x12, p + 2); ww(b + 0x16, 0); ww(b + 0x18, 0); }
                else { ww(b + 0x18, n); ww(b + 0x12, rw(b + 0x14)); ww(b + 0x10, rw(b + 0x14)); }
              } else {
                ww(b + 0x18, rw(b + 0x18) - 1);
                ww(b + 0x12, rw(b + 0x14));
                if (rw(b + 0x18) === 0) { ww(b + 0x10, p + 2); ww(b + 0x14, p + 2); }
                ww(b + 0x10, rw(b + 0x14));
              }
              break;
            case 0xFF:                                                   // cs:13D6
              if (rw(b + 0x16) === 0) {
                n = sx8(mem[p + 1]);
                if (n === 0) { ww(b + 0x10, p + 2); ww(b + 0x12, p + 2); ww(b + 0x16, 0); }
                else { ww(b + 0x16, n); ww(b + 0x10, rw(b + 0x12)); }
              } else {
                ww(b + 0x16, rw(b + 0x16) - 1);
                if (rw(b + 0x16) === 0) { ww(b + 0x10, p + 2); ww(b + 0x12, p + 2); }
                else ww(b + 0x10, rw(b + 0x12));
              }
              break;
          }
        }
        if (volFlag) setVolume(ch, b);                                   // cs:1758
        mem[b + 4] = mem[p]; mem[b] = mem[p + 1]; ww(b + 0x10, p + 2);
        if (mem[b + 4] === 0 || mem[b] === 0) keyOff(ch);
        else { mem[b + 8] = (mem[b] - sx8(mem[b + 7])) & 0xFF; noteOn(ch, b); }
      }
      // cs:17D1 per-tick effects
      if (mem[b + 1]) slide(ch, b);
      volFlag = 0;
      if (mem[b + 9] === 0 && mem[b + 0x0B] === 0) return;
      mem[b + 9] = (mem[b + 9] - 1) & 0xFF;
      if (mem[b + 9] === 0) {
        mem[b + 9] = mem[b + 0x0A];
        if (mem[b + 2]) { mem[b + 0x1D] = (mem[b + 0x1D] + mem[b + 2]) & 0xFF; volFlag = 1; }
      }
      mem[b + 0x0B] = (mem[b + 0x0B] - 1) & 0xFF;
      if (mem[b + 0x0B] === 0) {
        mem[b + 0x0B] = mem[b + 0x0C];
        if (mem[b + 3]) { mem[b + 0x0D] = (mem[b + 0x0D] + mem[b + 3]) & 0xFF; volFlag = 1; }
      }
      if (volFlag) setVolume(ch, b);
    }

    // cs:0C08 -> cs:0430. Returns +1 (noise started), -1 (all noise ended) or 0.
    function tick() {
      ww(TICKRET, 0);
      tickCount = (tickCount + 1) & 0xFFFF;
      rng();
      if (rw(LOCK) !== 0) return sx16(rw(TICKRET));                     // cs:0441
      var b6 = V(6);
      if (mem[ENGON] && rw(THR)) {                                       // cs:045C
        if (mem[b6] === 0) { ww(b6 + 0x10, 0x0E94); mem[b6] = 1; }
        else { mem[b6] = 2; mem[b6 + 8] = 2; }
      }
      for (var v = 0; v < 7; v++) interpret(v);                          // cs:1882
      if (mem[ENGON] && rw(THR) && rw(THR) !== rw(LASTTHR)) {           // cs:048F
        ww(LASTTHR, rw(THR));
        setFreq(6, rw(ENGFNUM));
        var t = rw(THR), ax = ((((t % 0x55) & 0xFF) << 8) | (((t / 0x55) | 0) & 0xFF)) + 0x36;
        ww(ENGTL, ax);
        engineTL(ax);
      }
      // cs:04CE noise voices
      if (mem[CNTA] === 0 && mem[CNTB] === 0) {
        if (rw(NSTATE) !== 0xFFFF) { ww(NSTATE, 0xFFFF); ww(TICKRET, 0xFFFF); }
        return sx16(rw(TICKRET));
      }
      if (mem[CNTA]) {
        ww(BASEA, rw(BASEA) + rw(STEPA));
        if (--mem[CNTA] === 0 && !(mem[CNTB] && mem[CHA] === mem[CHB])) { wr(0xA0 + mem[CHA], 0); wr(0xB0 + mem[CHA], 0); }
      }
      if (mem[CNTB]) {
        ww(BASEB, rw(BASEB) + rw(STEPB));
        if (--mem[CNTB] === 0 && !(mem[CNTA] === 0 && mem[CHB] === mem[CHA])) { wr(0xA0 + mem[CHB], 0); wr(0xB0 + mem[CHB], 0); }
      }
      return sx16(rw(TICKRET));
    }

    // cs:0C1C -> cs:0562
    function noise() {
      var r = rng();
      if (mem[CNTA]) setFreq(mem[CHA], ((~r & rw(MASKA)) + rw(BASEA)) & 0xFFFF);
      if (mem[CNTB]) setFreq(mem[CHB], ((r & rw(MASKB)) + rw(BASEB)) & 0xFFFF);
      return 0;
    }

    // cs:025A: prepare speech (fast release, stop voices 0..5); the busy wait at cs:02CA is one tick here (?)
    function speechStop() {
      ww(LOCK, 0xFFFF);
      for (var r = 0x80; r < 0x96; r++) wr(r, 0x0E);
      mem[CNTA] = 0; mem[CNTB] = 0; ww(MASKA, 0); ww(MASKB, 0);
      ww(BASEA, 0); ww(BASEB, 0); ww(STEPA, 0); ww(STEPB, 0);
      for (var v = 0; v < 6; v++) { mem[V(v)] = 1; ww(V(v) + 0x10, 0x0E9A); }
      ww(LOCK, 0);
      var guard = 0;
      while ((mem[V(0)] | mem[V(1)] | mem[V(2)] | mem[V(3)] | mem[V(4)] | mem[V(5)]) && guard++ < 4) tick();
    }

    // cs:0A09 card-0 speech: OPL ch0 held at DC, carrier TL = log table[sample >> 2] at 7954.5 Hz (blocking)
    function speechPlay(key, samples) {
      speechStop();
      var regs = [0x20, 0x23, 0x23, 0x28, 0x40, 0x3F, 0x43, 0x3F, 0x60, 0xAF, 0x63, 0xAF, 0x80, 0x0D, 0x83, 0x0F,
        0xC0, 0x05, 0xE0, 0x00, 0xE3, 0x02, 0xB0, 0x01, 0xA0, 0x8F, 0xB0, 0x2E];          // cs:0A5B
      for (var i = 0; i < regs.length; i += 2) wr(regs[i], regs[i + 1]);
      var t = SPEECH_SETTLE / PIT;
      mem[SHADOW + 0xA0] = 0; sink(0xA0, 0, t);
      mem[SHADOW + 0xB0] = 0x20; sink(0xB0, 0x20, t);
      var per = SPEECH_PIT / PIT, n = samples ? samples.length : 0;
      for (i = 0; i < n; i++) sink(0x43, mem[LOGTAB + (samples[i] >> 2)], t + (i + 1) * per);   // cs:0B01, not shadowed
      t += (n + 1) * per;
      mem[SHADOW + 0xB0] = 0; sink(0xB0, 0, t);                          // cs:0A33
      mem[SHADOW + 0xB1] = 0; sink(0xB1, 0, t);
      speech = { key: key, sec: t };
    }

    var SONGS = {
      3: [0x0FE0, 0x11AC, 0x121A, 0x12FC, 0x1448, 0x154C], 36: [0x0876, 0x0992, 0x0A9A, 0x0B2E],
      37: [0x0B66, 0x0BA0, 0x0BDE, 0x0C1C, 0x0B5E, 0x0B5E], 38: [0x0C76, 0x0D10, 0x0DB2, 0x0E24],
      39: [0x0766, 0x07B4, 0x07CE, 0x07EE, 0x0830, 0x085C]
    };
    var SIMPLE = {                     // id: [voice, seq]
      6: [4, 0x0F28], 7: [3, 0x0F52], 8: [3, 0x0F4A], 10: [5, 0x0F94], 12: [3, 0x0FB4], 13: [0, 0x0F34],
      14: [5, 0x0F8A], 15: [0, 0x0F78], 16: [0, 0x0F70], 17: [1, 0x0F68], 18: [5, 0x0F80], 20: [5, 0x0F5A],
      26: [5, 0x0E9C], 27: [0, 0x0EB4], 29: [0, 0x0ED2], 30: [0, 0x0ECA], 31: [2, 0x0EE4], 32: [2, 0x0EEC],
      34: [5, 0x0EAC], 35: [5, 0x0EA4]
    };
    var PAUSE_REGS = [0x43, 0x44, 0x45, 0x4B, 0x4C, 0x4D, 0x53];

    // cs:0B98: play(id, a2); getSpeech(key) -> Uint8Array of the phrase's unsigned 8-bit samples
    function play(id, a2, getSpeech) {
      id = sx16(id);
      if (id > 0x2D) return 0;
      var v, s, r;
      if (SIMPLE[id]) { voiceStart(SIMPLE[id][0], SIMPLE[id][1], 0); return 0; }
      if (SONGS[id]) {
        s = SONGS[id];
        for (v = 0; v < s.length; v++) voiceStart(v, s[v], 0);
        if (id === 37) { ww(V(4) + 0x1A, 0x0B6A); ww(V(5) + 0x1A, 0x0BA6); }      // cs:074A
        return 0;
      }
      switch (id) {
        case 0: silence(); return 0;
        case 1: for (v = 0; v < 7; v++) ww(V(v) + 0x12, 0x0E9A); return 0;          // cs:0761
        case 2: for (r = 0, v = 0; v < 7; v++) r |= mem[V(v)]; return r;            // cs:0839
        case 4: voiceStart(1, rw(CS + 0x086E + (((2 * id) >> 3) & 6)), 0); return 0;
        case 5: voiceStart(0, rw(CS + 0x0857 + (((2 * id) >> 2) & 6)), 0); return 0;
        case 9: if (rw(V(3) + 0x0E) === 0x0F3C && mem[V(3)]) return 0; voiceStart(3, 0x0F3C, 0); return 0;
        case 11: if (rw(THR) === 0) setThrottle(1); voiceStart(3, 0x0FA2, 0); return 0;
        case 19: voiceStart(3, 0x0FC8, 0); voiceStart(2, 0x0FD4, 0); return 0;
        case 21:                                                                     // cs:0782
          mem[SAVA] = mem[CNTA]; mem[CNTA] = 0; mem[SAVB] = mem[CNTB]; mem[CNTB] = 0;
          ww(LOCK, 0xFFFF);
          for (v = 0; v < 7; v++) wr(PAUSE_REGS[v], sh(PAUSE_REGS[v]) | 0x3F);
          return 0;
        case 22:                                                                     // cs:07C7
          for (v = 0; v < 7; v++) wr(PAUSE_REGS[v], (sh(PAUSE_REGS[v]) & 0xC0) | (mem[V(v) + 6] ^ 0x3F));
          mem[CNTA] = mem[SAVA]; mem[CNTB] = mem[SAVB];
          if (mem[CNTA] | mem[CNTB]) noiseStarted();
          ww(LOCK, 0);
          return 0;
        case 23: setThrottle(a2 | 0); return 0;
        case 24: mem[ENGON] = 0xFF; return 0;
        case 25: mem[ENGON] = 0; ww(LASTTHR, 0xFFFF); return 0;
        case 28: r = (rng() & 3) + 0x21; mem[0x0EC6] = r; voiceStart(0, 0x0EC0, r); return 0;   // cs:064D
        case 33: r = (rng() & 3) + 1; mem[0x0EE0] = r; voiceStart(0, 0x0EDA, r); return 0;     // cs:0670
        case 40: ww(SPEECHPARA, a2 | 0); return 0;
        case 41: case 42: case 44: case 45: case 43:                                  // cs:096D..09A1
          s = id === 43 ? ((tickCount & 1) ? '43b' : '43a') : String(id);
          speechPlay(s, getSpeech ? getSpeech(s) : null);
          return 0;
      }
      return 0;
    }

    // cs:0B76 (card 0): detection writes regs 4/2 directly (not shadowed), then silence
    function init() {
      sink(0x04, 0x60, 0); sink(0x04, 0x80, 0); sink(0x02, 0xFF, 0); sink(0x04, 0x21, 0);
      sink(0x04, 0x60, 0); sink(0x04, 0x80, 0);
      ww(0x17F2, 0);
      silence();
      return 0;
    }

    return {
      init: init, play: play, tick: tick, noise: noise, shutdown: silence, mem: mem,
      get tickCount() { return tickCount; },
      get lastSpeech() { return speech; },
      set trace(fn) { trace = fn; }
    };
  }

  // ---- static stream dump, same text as re/tools/sound.py (asound_sequences.txt) ----
  var CMDS = { 0xF3: ['PANSWEEP', 2], 0xF4: ['PAN', 1], 0xF5: ['VOLOFS', 1], 0xF6: ['RANDPATCH', 0], 0xF7: ['DETUNE', 1],
    0xF8: ['VOLSWEEP', 2], 0xF9: ['VOLUME', 1], 0xFA: ['SLIDE', 1], 0xFB: ['GAP', 1], 0xFC: ['INSTR', 1],
    0xFD: ['LOOP', 0], 0xFE: ['REPEAT2', 1], 0xFF: ['REPEAT1', 1] };
  var NOTES = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
  function hex(v, n) { var s = v.toString(16).toUpperCase(); while (s.length < n) s = '0' + s; return s; }
  function pad(s, n, right) { while (s.length < n) s = right ? s + ' ' : ' ' + s; return s; }
  function roundEven(x) { var f = Math.floor(x), d = x - f; return d > 0.5 || (d === 0.5 && (f & 1)) ? f + 1 : f; }

  function dumpSequence(img, start) {
    var out = [], a = start, fnum = function (i) { return img[FNUM + 2 * i] | (img[FNUM + 2 * i + 1] << 8); };
    for (var k = 0; k < 600; k++) {
      var b = img[a];
      if (b >= 0xF3) {
        var name = CMDS[b][0], n = CMDS[b][1], args, i;
        if (b === 0xF6) {
          n = img[a + 1];
          var vals = [];
          for (i = 0; i < n; i++) vals.push(img[a + 2 + i]);
          out.push('  ' + hex(a, 4) + '  F6 RANDPATCH values=[' + vals.join(', ') + '] -> byte ' +
            hex(a + 3 + n + sx8(img[a + 2 + n]), 4));
          a += n + 3; continue;
        }
        args = [];
        for (i = 0; i < n; i++) args.push(img[a + 1 + i]);
        if (b === 0xF7 || b === 0xFA) args = args.map(sx8);
        if (b === 0xF5) { var d = ((args[0] + 32) % 64) - 32; args = [args[0] + '(=' + (d >= 0 ? '+' : '') + d + ' mod 64)']; }
        if (b === 0xF8 || b === 0xF3) args = [args[0], sx8(args[1])];
        out.push('  ' + hex(a, 4) + '  ' + hex(b, 2) + ' ' + pad(name, 9, true) + ' ' + args.join(' '));
        if (b === 0xFD) break;
        a += (b === 0xF3 || b === 0xF8) ? 3 : 2;
        continue;
      }
      var note = img[a], dur = img[a + 1];
      if (note === 0 || dur === 0) {
        out.push('  ' + hex(a, 4) + '  ' + hex(note, 2) + ' ' + hex(dur, 2) + '     ' + (dur === 0 ? 'END (voice off)' : 'rest ' + dur));
        if (dur === 0) break;
      } else {
        var blk = (note / 12) | 0, f = fnum(note % 12);
        var hz = f * 49716.0 / Math.pow(2, 20 - (blk & 7));
        var midi = roundEven(69 + 12 * Math.log2(hz / 440.0));
        out.push('  ' + hex(a, 4) + '  ' + hex(note, 2) + ' ' + hex(dur, 2) + '     note blk' + blk + ' fnum' + hex(f, 3) +
          ' = ' + pad(hz.toFixed(1), 7) + ' Hz (~' + NOTES[((midi % 12) + 12) % 12] + (Math.floor(midi / 12) - 1) + ') dur ' + dur);
      }
      a += 2;
    }
    return out;
  }

  var api = { createAsound: createAsound, asoundImage: asoundImage, dumpSequence: dumpSequence };
  if (typeof module !== 'undefined' && module.exports) module.exports = api;
  else { root.F117 = root.F117 || {}; root.F117.music = api; }
})(typeof window !== 'undefined' ? window : globalThis);
