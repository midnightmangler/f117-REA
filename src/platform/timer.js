// 70 Hz frame tick + 60 Hz sound tick model (task 1.1; sound.md sec. 3, VGAME 0000:1E79).
// The original reprograms the PIT to one video frame (70 Hz in VGA mode 13h) and runs the game tick from
// that IRQ. snd_tick is called on 6 of every 7 game ticks (counter ds:264B mod 7) = 60 Hz. When snd_tick
// reports a noise voice (+1) the PIT runs 4x faster and snd_noise is called every IRQ (280 Hz) until it returns -1.
// Which of the 7 phases is skipped is not documented (?): SOUND_SKIP_PHASE below; it only shifts the audio phase.
(function (root) {
  'use strict';
  var FRAME_HZ = 70, SOUND_SKIP_PHASE = 6, NOISE_MULT = 4;
  var MAX_CATCHUP = 5;   // ticks run per advance(); longer stalls are dropped, not replayed

  // Pure model, driven by a caller-supplied clock in ms. cb: {frame(n), sound(), noise()}
  function createTicker(cb) {
    var period = 1000 / FRAME_HZ, last = null, acc = 0, paused = false;
    var frameNo = 0, soundCtr = 0, fast = false;
    var t = {
      get frameCount() { return frameNo; },
      get paused() { return paused; },
      get fast() { return fast; },
      // snd_tick return value handling: >0 noise on (PIT x4), <0 noise off.
      setNoise: function (on) { fast = !!on; },
      pause: function () { paused = true; },
      resume: function (nowMs) { paused = false; last = nowMs; acc = 0; },   // no catch-up burst after a pause
      advance: function (nowMs) {
        if (paused) return 0;
        if (last === null) { last = nowMs; return 0; }
        acc += nowMs - last; last = nowMs;
        var ran = 0;
        while (acc >= period && ran < MAX_CATCHUP) {
          acc -= period; ran++;
          if (fast) for (var k = 0; k < NOISE_MULT && cb.noise; k++) cb.noise();   // 4 IRQs per game tick, 280 Hz
          frameNo++;
          if (cb.frame) cb.frame(frameNo);
          if (cb.sound && (soundCtr++ % 7) !== SOUND_SKIP_PHASE) {
            var r = cb.sound();   // snd_tick
            if (r > 0) fast = true; else if (r < 0) fast = false;
          }
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
