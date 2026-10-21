// 70 Hz frame tick + 60 Hz sound tick model (task 1.1; sound.md sec. 3, VGAME 0000:1E79).
// The original reprograms the PIT to one video frame (70 Hz in VGA mode 13h) and runs the game tick from
// that IRQ. snd_tick is called on 6 of every 7 game ticks (counter ds:264B mod 7) = 60 Hz. When snd_tick
// reports a noise voice (+1) the PIT runs 4x faster and snd_noise is called every IRQ (280 Hz) until it returns -1.
// Verified against the code (VGAME 0000:1E79..1EAE, ISR 1C9B, timer_fast 1C6D, timer_normal 1C85, resync 1D01):
//  - ds:264B is incremented first, sound runs only while it is < 7, so ticks 1..6 of each 7 run snd_tick and every 7th
//    tick (counter reaches 7, reset to 0) skips it and acts as "no change".
//  - snd_tick > 0: ds:2636 = 4 at once, but the faster PIT rate only starts at the next game tick (resync flag ds:2638),
//    so the next game tick still arrives one normal period later. snd_noise runs after the frame tick whenever ds:2636 != 1.
//    Steady state: 4 IRQs per game tick, noise on each, so 3 noise calls before the frame tick and 1 after it.
//  - snd_tick < 0: ds:2636 = 1 at once, no noise calls after that tick; the PIT rate returns at the next game tick.
// Noise calls get their offset in ms from the frame tick (negative = before) for sub-tick audio timing.
(function (root) {
  'use strict';
  var FRAME_HZ = 70, SOUND_PER = 7;
  var MAX_CATCHUP = 5;   // ticks run per advance(); longer stalls are dropped, not replayed

  // Pure model, driven by a caller-supplied clock in ms. cb: {frame(n), sound() -> -1|0|1, noise(offsetMs)}
  function createTicker(cb) {
    var period = 1000 / FRAME_HZ, last = null, acc = 0, paused = false;
    var frameNo = 0, sctr = 0;      // sctr = ds:264B
    var mode = 0;                   // 0 normal, 1 noise mode just entered, 2 noise steady (PIT x4 running)
    var t = {
      get frameCount() { return frameNo; },
      get paused() { return paused; },
      get fast() { return mode !== 0; },
      pause: function () { paused = true; },
      resume: function (nowMs) { paused = false; last = nowMs; acc = 0; },   // no catch-up burst after a pause
      advance: function (nowMs) {
        if (paused) return 0;
        if (last === null) { last = nowMs; return 0; }
        acc += nowMs - last; last = nowMs;
        var ran = 0;
        while (acc >= period && ran < MAX_CATCHUP) {
          acc -= period; ran++;
          var startMode = mode, q = period / 4;
          if (mode === 2 && cb.noise) { cb.noise(-3 * q); cb.noise(-2 * q); cb.noise(-q); }   // 3 IRQs before the tick
          frameNo++;
          if (cb.frame) cb.frame(frameNo);                      // 0000:1E79 (incl. gfx flicker/shake T:0200)
          if (++sctr < SOUND_PER) {                             // 0000:1E8A..1E9D
            if (cb.sound) { var r = cb.sound(); if (r > 0) mode = (mode === 0) ? 1 : mode; else if (r < 0) mode = 0; }
          } else sctr = 0;                                      // 7th tick: skipped, "no change"
          if (mode !== 0 && cb.noise) cb.noise(0);              // ISR 1CCD: ds:2636 != 1 -> snd_noise
          if (startMode === 1 && mode === 1) mode = 2;          // PIT x4 starts at the next game tick
        }
        if (acc >= period) acc = 0;   // fell behind by more than MAX_CATCHUP ticks
        return ran;
      }
    };
    return t;
  }

  // Browser driver: requestAnimationFrame pump; pauses while the page is hidden.
  function startLoop(ticker, win) {
    win = win || window;
    var raf = win.requestAnimationFrame.bind(win), running = true;
    function pump(ts) { if (!running) return; ticker.advance(ts); raf(pump); }
    function vis() {
      if (win.document.hidden) ticker.pause(); else ticker.resume(win.performance.now());
    }
    win.document.addEventListener('visibilitychange', vis);
    raf(pump);
    return { stop: function () { running = false; win.document.removeEventListener('visibilitychange', vis); } };
  }

  var api = { FRAME_HZ: FRAME_HZ, SOUND_HZ: FRAME_HZ * 6 / 7, createTicker: createTicker, startLoop: startLoop };
  if (typeof module !== 'undefined' && module.exports) module.exports = api;
  else { root.F117 = root.F117 || {}; root.F117.timer = api; }
})(typeof window !== 'undefined' ? window : globalThis);
