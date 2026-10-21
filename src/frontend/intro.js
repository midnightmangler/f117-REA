// Intro (task 2.2): MPS_LOGO.EXE and PLAYER.EXE as flow programs. Docs: format-ss.md "Playback", format-pan.md sec. 3-5.
// Both are driven by a stepper (advance(nowMs) -> exit code or null) so the timing is testable on a fake clock;
// drive() pumps a stepper with requestAnimationFrame. Host = { fb, present(), assets:{bytes}, now(), raf(fn), pollKey(), tapped() }.
(function (root) {
  'use strict';
  var BIOS_HZ = 18.2065;          // 0040:006C tick used by MPS_LOGO
  var TICK_HZ = 60;               // PLAYER animation clock (026B:0336: 70 Hz refresh drops 1 call in 7)
  var FADE_SECONDS = 5;           // PLAYER 0E0C(5)

  function ss() { return (typeof module !== 'undefined' && module.exports) ? require('../platform/ss.js') : root.F117.ss; }
  function pan() { return (typeof module !== 'undefined' && module.exports) ? require('../platform/pan.js') : root.F117.pan; }

  // ---- MPS_LOGO main (0006:0072; sprites 006D:05BE) ----
  // Sprite i is drawn once the BIOS tick counter reaches t0 + sum(delay[0..i]); drawn sprites accumulate (no clearing).
  // A key press (or a tap) draws the remaining sprites without waiting. Result: none 0, Esc 1, Alt-Q 2, other 3.
  function createLogoRun(series, o) {
    var fb = o.fb, t0 = null, next = 0, due = [], acc = 0, result = 0, skipping = false;
    for (var i = 0; i < series.frames.length; i++) { acc += series.frames[i].delay; due.push(acc); }
    return {
      get drawn() { return next; },
      advance: function (nowMs) {
        var S = ss();
        if (t0 === null) {                                   // series_load + DAC write, screen black (mode 13h)
          t0 = Math.floor(nowMs * BIOS_HZ / 1000);
          fb.clear(0, 0);
          for (var c = 0; c < 256; c++) fb.setDacEntry(c, series.dac[3 * c], series.dac[3 * c + 1], series.dac[3 * c + 2]);
        }
        var tick = Math.floor(nowMs * BIOS_HZ / 1000) - t0;
        if (!skipping) {
          var k = o.pollKey ? o.pollKey() : 0;
          if (!k && o.tapped && o.tapped()) k = 0xFFFF;
          if (k) { skipping = true; result = k === 0x011B ? 1 : k === 0x1000 ? 2 : 3; }
        }
        while (next < series.frames.length && (skipping || due[next] <= tick)) {
          S.drawSprite(series, next, fb.pages[0]); next++;
          if (o.present) o.present();
        }
        return next >= series.frames.length ? result : null;
      }
    };
  }

  // ---- PLAYER fade (0E0C / 0E65 / 0EE3) with the whole palette per step (step = 0x100) ----
  // One step per tick while ds:13D4 != 0: write the previously computed block to the DAC, compute the next one, 13D4--.
  // scale (ds:13D6) is a 16-bit fraction, += inc after every full pass; inc = 0x10000 / (step*ticks/256 - 1).
  function createFade(fb, seconds) {
    var n = seconds * 60;                                    // ds:13D4
    var cx = ((256 * n) >> 8) & 0xFFFF;
    var inc = Math.floor(0x10000 / (cx - 1)), scale = inc;
    var shadow = new Uint8Array(768), block = new Uint8Array(768);
    function compute() {                                     // 0E65
      for (var i = 0; i < 768; i++) {
        var p = shadow[i] * scale;
        block[i] = ((p >>> 16) + ((p >>> 15) & 1)) & 0xFF;
      }
      scale += inc; if (scale > 0xFFFF) scale = 0xFFFF;
    }
    compute();                                               // 0E0C ends with 0E65 (shadow still empty = black)
    return {
      get active() { return n !== 0; },
      get remaining() { return n; },
      get scale() { return scale; },
      setPalette: function (pal) {                           // set_dac 0D0C while fading: keep palette, show black
        shadow.set(pal.subarray(0, 768));
        for (var i = 0; i < 256; i++) fb.setDacEntry(i, 0, 0, 0);
      },
      step: function () {                                    // 0EE3
        for (var i = 0; i < 256; i++) fb.setDacEntry(i, block[3 * i], block[3 * i + 1], block[3 * i + 2]);
        compute(); n--;
      }
    };
  }

  // ---- PLAYER main: files = [{name, bytes}], argc includes the program name (usage: argc > 2 waits for the music) ----
  function createPanRun(files, o) {
    var fb = o.fb, P = pan();
    var screen = new Uint8Array(65536);                      // VRAM persists across files
    var fade = createFade(fb, FADE_SECONDS);
    var fi = -1, pl = null, countdown = 0, time = 0, done = false, dirty = false, result = 0, frames = 0;
    var acc = 0, last = null;

    function openNext() {
      fi++;
      if (fi >= files.length) return false;
      pl = P.createPanPlayer(files[fi].bytes); pl.screen = screen;
      return true;
    }
    function tick() {                                        // frame callback 0000:0738
      time++;
      if (countdown !== 0 && fade.active) { fade.step(); return; }
      if (countdown !== 0 && --countdown !== 0) return;
      if (!pl || pl.index >= pl.count) { if (!openNext()) { done = true; return; } }
      pl.step(); frames++;
      if (pl.paletteChanged) {
        if (fade.active) fade.setPalette(pl.palette);
        else for (var i = 0; i < 256; i++) fb.setDacEntry(i, pl.palette[3 * i], pl.palette[3 * i + 1], pl.palette[3 * i + 2]);
      }
      fb.pages[0].set(screen.subarray(0, 64000));
      dirty = true;
      countdown = pl.ticksPerFrame;
      if (pl.index >= pl.count && fi >= files.length - 1) done = true;     // tail == head: finish() proceeds
    }
    if (!files.length) done = true;
    return {
      get time() { return time; }, get frames() { return frames; }, get fade() { return fade; },
      get done() { return done; }, tick: tick,
      advance: function (nowMs) {
        if (done) return result;
        if (last === null) last = nowMs;
        acc += (nowMs - last) * TICK_HZ / 1000; last = nowMs;
        var n = Math.min(Math.floor(acc), 30); acc -= Math.floor(acc);
        var k = o.pollKey ? o.pollKey() : 0;                 // poll 0696: key -> quit(key), button/tap -> quit(0x1B)
        if (k) { result = k & 0xFF; done = true; }
        else if (o.tapped && o.tapped()) { result = 0x1B; done = true; }
        while (!done && n-- > 0) tick();
        if (dirty && o.present) { o.present(); dirty = false; }
        return done ? result : null;
      }
    };
  }

  function drive(stepper, host) {
    return new Promise(function (resolve) {
      function pump() {
        var r = stepper.advance(host.now());
        if (r !== null) resolve(r); else host.raf(pump);
      }
      host.raf(pump);
    });
  }

  // Programs for flow.js. host.assets.bytes(path) -> Promise<Uint8Array>.
  function createIntroPrograms(host) {
    return {
      logo: async function () {
        var series = ss().parseSs(await host.assets.bytes('ss/LABSLOGO.SS'));
        return drive(createLogoRun(series, host), host);
      },
      player: async function (ctx) {
        var names = String(ctx.args || '').split(/\s+/).filter(Boolean);
        var files = [];
        for (var i = 0; i < names.length; i++) {             // play_file: missing file ("-.PAN") is skipped silently (02D4)
          try { files.push({ name: names[i], bytes: await host.assets.bytes('pan/' + names[i].toUpperCase() + '.PAN') }); } catch (e) { /* skipped */ }
        }
        return drive(createPanRun(files, Object.assign({ argc: names.length + 1 }, host)), host);
      }
    };
  }

  var api = { createLogoRun: createLogoRun, createPanRun: createPanRun, createFade: createFade, createIntroPrograms: createIntroPrograms,
    drive: drive, BIOS_HZ: BIOS_HZ, TICK_HZ: TICK_HZ };
  if (typeof module !== 'undefined' && module.exports) module.exports = api;
  else { root.F117 = root.F117 || {}; root.F117.intro = api; }
})(typeof window !== 'undefined' ? window : globalThis);
