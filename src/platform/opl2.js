// YM3812 (OPL2) emulator, task 1.4. Hardware emulation, not game logic: a port of the Nuked-OPL3 algorithm
// (Alexey Khokholov, LGPL-2.1) reduced to OPL2: 9 two-operator channels, waveforms 0-3 (reg 01 WSE), AM/VIB,
// KSL/KSR, feedback. Rhythm mode and the timers are not emulated (ASOUND never enables them; sound.md 5).
// createOpl2(): write(reg, val), sample() -> int (one 49716 Hz output sample).
// createRenderer(outRate): timed register queue + linear resampler, runs in the AudioWorklet (sound.js) or Node.
// Both factories are self-contained (no outer references) so sound.js can ship them to the worklet as source text.
(function (root) {
  'use strict';

  function createOpl2() {
    var i, logsin = new Uint16Array(256), exprom = new Uint16Array(256);
    for (i = 0; i < 256; i++) {
      logsin[i] = Math.round(-Math.log(Math.sin((i + 0.5) * Math.PI / 512)) / Math.LN2 * 256);
      exprom[i] = Math.round(Math.pow(2, (255 - i) / 256) * 1024);
    }
    var KSLROM = [0, 32, 40, 45, 48, 51, 53, 55, 56, 58, 59, 60, 61, 62, 63, 64];
    var KSLSHIFT = [8, 1, 2, 0];
    var MT = [1, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 20, 24, 24, 30, 30];
    var INCSTEP = [[0, 0, 0, 0], [1, 0, 0, 0], [1, 0, 1, 0], [1, 1, 1, 0]];
    var AD_SLOT = [0, 1, 2, 3, 4, 5, -1, -1, 6, 7, 8, 9, 10, 11, -1, -1, 12, 13, 14, 15, 16, 17, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1];
    var CH_SLOT = [0, 1, 2, 6, 7, 8, 12, 13, 14];
    var ATTACK = 0, DECAY = 1, SUSTAIN = 2, RELEASE = 3;

    // slot state (18)
    var S = 18;
    var sOut = new Int32Array(S), sFbmod = new Int32Array(S), sProut = new Int32Array(S);
    var egRout = new Int32Array(S), egOut = new Int32Array(S), egGen = new Uint8Array(S), egKsl = new Int32Array(S);
    var key = new Uint8Array(S), pgReset = new Uint8Array(S), pgPhase = new Float64Array(S), pgOut = new Int32Array(S);
    var rTrem = new Uint8Array(S), rVib = new Uint8Array(S), rType = new Uint8Array(S), rKsr = new Uint8Array(S);
    var rMult = new Uint8Array(S), rKsl = new Uint8Array(S), rTl = new Uint8Array(S), rAr = new Uint8Array(S);
    var rDr = new Uint8Array(S), rSl = new Uint8Array(S), rRr = new Uint8Array(S), rWf = new Uint8Array(S);
    var sCh = new Uint8Array(S), sCar = new Uint8Array(S);
    // channel state (9)
    var cFnum = new Int32Array(9), cBlock = new Int32Array(9), cKsv = new Int32Array(9), cFb = new Int32Array(9), cCon = new Int32Array(9);
    // chip state
    var nts = 0, wse = 0, tremShift = 4, vibShift = 1, tremolo = 0, tremPos = 0, vibPos = 0, timer = 0;
    var egState = 0, egTimer = 0, egAdd = 0, egTimerLo = 0;

    for (i = 0; i < 9; i++) { sCh[CH_SLOT[i]] = i; sCh[CH_SLOT[i] + 3] = i; sCar[CH_SLOT[i] + 3] = 1; }
    for (i = 0; i < S; i++) { egRout[i] = 0x1FF; egOut[i] = 0x1FF; egGen[i] = RELEASE; }

    function calcExp(level) {
      if (level > 0x1FFF) level = 0x1FFF;
      return (exprom[level & 0xFF] << 1) >> (level >> 8);
    }
    function wave(wf, phase, env) {
      phase &= 0x3FF;
      var out, neg = 0, e = env << 3;
      switch (wf) {
        case 0:
          if (phase & 0x200) neg = 0xFFFF;
          out = (phase & 0x100) ? logsin[(phase & 0xFF) ^ 0xFF] : logsin[phase & 0xFF];
          return neg ? ~calcExp(out + e) : calcExp(out + e);
        case 1:
          if (phase & 0x200) out = 0x1000;
          else out = (phase & 0x100) ? logsin[(phase & 0xFF) ^ 0xFF] : logsin[phase & 0xFF];
          return calcExp(out + e);
        case 2:
          out = (phase & 0x100) ? logsin[(phase & 0xFF) ^ 0xFF] : logsin[phase & 0xFF];
          return calcExp(out + e);
        default:
          out = (phase & 0x100) ? 0x1000 : logsin[phase & 0xFF];
          return calcExp(out + e);
      }
    }
    function updateKsl(s) {
      var c = sCh[s], k = (KSLROM[cFnum[c] >> 6] << 2) - ((8 - cBlock[c]) << 5);
      egKsl[s] = k < 0 ? 0 : k;
    }
    function updateChannelFreq(c) {
      cKsv[c] = (cBlock[c] << 1) | ((cFnum[c] >> (9 - nts)) & 1);
      updateKsl(CH_SLOT[c]); updateKsl(CH_SLOT[c] + 3);
    }

    function envelope(s) {
      var c = sCh[s], regRate = 0, reset = 0, shift = 0;
      var o = egRout[s] + (rTl[s] << 2) + (egKsl[s] >> KSLSHIFT[rKsl[s]]) + (rTrem[s] ? tremolo : 0);
      egOut[s] = o > 0x1FF ? 0x1FF : o;
      if (key[s] && egGen[s] === RELEASE) { reset = 1; regRate = rAr[s]; }
      else switch (egGen[s]) {
        case ATTACK: regRate = rAr[s]; break;
        case DECAY: regRate = rDr[s]; break;
        case SUSTAIN: if (!rType[s]) regRate = rRr[s]; break;
        default: regRate = rRr[s];
      }
      pgReset[s] = reset;
      var ks = cKsv[c] >> ((rKsr[s] ^ 1) << 1);
      var rate = ks + (regRate << 2), rateHi = rate >> 2, rateLo = rate & 3;
      if (rateHi & 0x10) rateHi = 0x0F;
      var egShift = rateHi + egAdd;
      if (regRate !== 0) {
        if (rateHi < 12) {
          if (egState) {
            if (egShift === 12) shift = 1;
            else if (egShift === 13) shift = (rateLo >> 1) & 1;
            else if (egShift === 14) shift = rateLo & 1;
          }
        } else {
          shift = (rateHi & 3) + INCSTEP[rateLo][egTimerLo];
          if (shift & 4) shift = 3;
          if (!shift) shift = egState;
        }
      }
      var rout = egRout[s], inc = 0, off = 0;
      if (reset && rateHi === 0x0F) rout = 0;
      if ((egRout[s] & 0x1F8) === 0x1F8) off = 1;
      if (egGen[s] !== ATTACK && !reset && off) rout = 0x1FF;
      switch (egGen[s]) {
        case ATTACK:
          if (!egRout[s]) egGen[s] = DECAY;
          else if (key[s] && shift > 0 && rateHi !== 0x0F) inc = (~egRout[s]) >> (4 - shift);
          break;
        case DECAY:
          if ((egRout[s] >> 4) === rSl[s]) egGen[s] = SUSTAIN;
          else if (!off && !reset && shift > 0) inc = 1 << (shift - 1);
          break;
        default:
          if (!off && !reset && shift > 0) inc = 1 << (shift - 1);
      }
      egRout[s] = (rout + inc) & 0x1FF;
      if (reset) egGen[s] = ATTACK;
      if (!key[s]) egGen[s] = RELEASE;
    }

    function phaseGen(s) {
      var c = sCh[s], f = cFnum[c];
      if (rVib[s]) {
        var range = (f >> 7) & 7;
        if (!(vibPos & 3)) range = 0;
        else if (vibPos & 1) range >>= 1;
        range >>= vibShift;
        if (vibPos & 4) range = -range;
        f += range;
      }
      var base = (f << cBlock[c]) >> 1;
      var ph = Math.floor(pgPhase[s] / 512) & 0x3FF;
      if (pgReset[s]) pgPhase[s] = 0;
      pgPhase[s] = (pgPhase[s] + ((base * MT[rMult[s]]) >> 1)) % 4294967296;
      pgOut[s] = ph;
    }

    function sample() {
      var s, c, acc = 0;
      for (s = 0; s < S; s++) {
        c = sCh[s];
        var mod;
        if (!sCar[s]) {                                   // modulator: feedback input
          sFbmod[s] = cFb[c] ? (sProut[s] + sOut[s]) >> (9 - cFb[c]) : 0;
          sProut[s] = sOut[s];
          mod = sFbmod[s];
        } else mod = cCon[c] ? 0 : sOut[s - 3];
        envelope(s);
        phaseGen(s);
        sOut[s] = wave(wse ? rWf[s] : 0, pgOut[s] + mod, egOut[s]);
      }
      for (c = 0; c < 9; c++) {
        s = CH_SLOT[c];
        acc += cCon[c] ? sOut[s] + sOut[s + 3] : sOut[s + 3];
      }
      // chip timers (OPL3_Generate)
      if ((timer & 0x3F) === 0x3F) tremPos = (tremPos + 1) % 210;
      tremolo = (tremPos < 105 ? tremPos : 210 - tremPos) >> tremShift;
      if ((timer & 0x3FF) === 0x3FF) vibPos = (vibPos + 1) & 7;
      timer = (timer + 1) & 0xFFFF;
      if (egState) {
        var sh = 0;
        while (sh < 13 && ((egTimer / Math.pow(2, sh)) & 1) === 0) sh++;
        egAdd = sh > 12 ? 0 : sh + 1;
        egTimerLo = egTimer & 3;
      }
      if (egState) egTimer = egTimer >= 0xFFFFFFFFF ? 0 : egTimer + 1;
      egState ^= 1;
      return acc > 32767 ? 32767 : acc < -32768 ? -32768 : acc;
    }

    function write(reg, v) {
      reg &= 0xFF; v &= 0xFF;
      var hi = reg & 0xF0, s, c;
      if (reg === 0x01) { wse = (v >> 5) & 1; return; }
      if (reg === 0x08) { nts = (v >> 6) & 1; return; }
      if (reg === 0xBD) { tremShift = (((v >> 7) ^ 1) << 1) + 2; vibShift = ((v >> 6) & 1) ^ 1; return; }
      if (hi >= 0x20 && hi <= 0x90 || hi === 0xE0 || hi === 0xF0) {
        s = AD_SLOT[reg & 0x1F];
        if (s < 0 || (reg & 0x1F) >= 0x16) return;
        switch (reg & 0xE0) {
          case 0x20:
            rTrem[s] = (v >> 7) & 1; rVib[s] = (v >> 6) & 1; rType[s] = (v >> 5) & 1; rKsr[s] = (v >> 4) & 1; rMult[s] = v & 0x0F;
            break;
          case 0x40: rKsl[s] = (v >> 6) & 3; rTl[s] = v & 0x3F; break;
          case 0x60: rAr[s] = (v >> 4) & 0x0F; rDr[s] = v & 0x0F; break;
          case 0x80: rSl[s] = (v >> 4) & 0x0F; if (rSl[s] === 0x0F) rSl[s] = 0x1F; rRr[s] = v & 0x0F; break;
          case 0xE0: rWf[s] = v & 3; break;
        }
        return;
      }
      c = reg & 0x0F;
      if (c > 8) return;
      if (hi === 0xA0) { cFnum[c] = (cFnum[c] & 0x300) | v; updateChannelFreq(c); return; }
      if (hi === 0xB0) {
        cFnum[c] = (cFnum[c] & 0xFF) | ((v & 3) << 8); cBlock[c] = (v >> 2) & 7; updateChannelFreq(c);
        var on = (v >> 5) & 1;
        key[CH_SLOT[c]] = on; key[CH_SLOT[c] + 3] = on;
        return;
      }
      if (hi === 0xC0) { cFb[c] = (v >> 1) & 7; cCon[c] = v & 1; }
    }

    return { write: write, sample: sample, RATE: 49716 };
  }

  // Timed queue + resampler. Writes carry a time in seconds (renderer clock). The original's ISA write delay
  // (30 + 5 status reads, about 37 us) is kept: consecutive writes land at least WRITE_GAP OPL samples apart.
  function createRenderer(outRate, makeOpl) {
    var opl = makeOpl(), RATE = 49716, WRITE_GAP = 2;
    var q = [], qHead = 0, pos = 0, nextOk = 0, prev = 0, cur = 0, frac = 1, step = RATE / outRate, gain = 1 / 12288;
    function push(t, reg, val) { q.push(t * RATE, reg, val); }
    function oplStep() {
      while (qHead < q.length && q[qHead] <= pos && pos >= nextOk) {
        opl.write(q[qHead + 1], q[qHead + 2]); qHead += 3; nextOk = pos + WRITE_GAP;
      }
      if (qHead > 3000) { q = q.slice(qHead); qHead = 0; }
      pos++;
      prev = cur; cur = opl.sample();
    }
    // Fill out (Float32Array) starting at renderer time t0 (seconds); the first call sets the clock.
    // The card's output is AC-coupled: a one-pole DC blocker (~5 Hz) removes the speech DC level.
    var dcX = 0, dcY = 0, dcR = 1 - 2 * Math.PI * 5 / outRate;
    function render(out, n, t0) {
      if (pos === 0 && t0 !== undefined) { pos = Math.floor(t0 * RATE); nextOk = pos; }
      for (var i = 0; i < n; i++) {
        frac += step;
        while (frac >= 1) { frac -= 1; oplStep(); }
        var x = (prev + (cur - prev) * frac) * gain;
        dcY = x - dcX + dcR * dcY; dcX = x;
        out[i] = dcY;
      }
    }
    function writeNow(reg, val) { q.push(pos, reg, val); }
    return {
      push: push, writeNow: writeNow, render: render, opl: opl,
      get time() { return pos / RATE; },
      set gain(g) { gain = g; }, get pending() { return (q.length - qHead) / 3; }
    };
  }

  var api = { createOpl2: createOpl2, createRenderer: createRenderer,
    source: 'var createOpl2 = ' + createOpl2.toString() + ';\nvar createRenderer = ' + createRenderer.toString() + ';\n' };
  if (typeof module !== 'undefined' && module.exports) module.exports = api;
  else { root.F117 = root.F117 || {}; root.F117.opl2 = api; }
})(typeof window !== 'undefined' ? window : globalThis);
