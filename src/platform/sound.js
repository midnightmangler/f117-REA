// WebAudio front end, task 1.4: the ASOUND port (music.js) feeds an OPL2 emulator (opl2.js) running in an
// AudioWorklet (ScriptProcessor fallback). Register writes are stamped with game time (frame ticks, timer.js)
// and replayed in the audio thread a fixed latency later, so the 60 Hz / 280 Hz cadence survives rAF jitter.
// Speech (ids 41..45) is played the AdLib way: OPL carrier TL driven at 7954.5 Hz (music.js speechPlay).
// iOS: the context is resumed on the first touch/click (unlock()).
// Game API: init(asoundFile, phrases), unlock(), play(id, a2), sfx(id, prio), hooks(ticker), state.
(function (root) {
  'use strict';
  var LATENCY = 0.06;          // s between game time and audio time
  var FRAME_MS = 1000 / 70;

  var ctx = null, node = null, sp = null, renderer = null, drv = null, phrases = {};
  var clock = null, offset = null, ready = false;
  // VGAME globals read by sfx (VGAME 0000:D3F9 / D41F): ds:43F2 sound level, ds:C09A (ejected?), ds:2E0A throttle %
  var state = { level: 0, c09a: 0, throttlePct: 0 };

  function gameMs() { return clock ? clock() : (root.performance ? root.performance.now() : Date.now()); }

  // Map game time to audio-context time; resync after pauses or when we fall behind.
  function audioTime(ms) {
    var now = ctx ? ctx.currentTime : 0, t;
    if (offset === null) offset = now + LATENCY - ms / 1000;
    t = ms / 1000 + offset;
    if (t < now + 0.005 || t > now + LATENCY + 0.25) { offset = now + LATENCY - ms / 1000; t = ms / 1000 + offset; }
    return t;
  }

  var batch = [], batchMs = 0;
  function sink(reg, val, dt) {
    if (!ctx) return;
    batch.push(audioTime(batchMs) + dt, reg, val);
    if (batch.length >= 3000) flush();
  }
  function flush() {
    if (!batch.length) return;
    if (node) node.port.postMessage(batch);
    else if (renderer) for (var i = 0; i < batch.length; i += 3) renderer.push(batch[i], batch[i + 1], batch[i + 2]);
    batch = [];
  }

  function workletSource(opl) {
    return opl.source +
      'class Opl2Proc extends AudioWorkletProcessor {\n' +
      '  constructor() { super(); this.r = createRenderer(sampleRate, createOpl2);\n' +
      '    this.port.onmessage = (e) => { const b = e.data; for (let i = 0; i < b.length; i += 3) this.r.push(b[i], b[i + 1], b[i + 2]); }; }\n' +
      '  process(inputs, outputs) { const o = outputs[0][0]; this.r.render(o, o.length, currentTime); return true; }\n' +
      '}\nregisterProcessor("opl2", Opl2Proc);\n';
  }

  function startAudio() {
    var AC = root.AudioContext || root.webkitAudioContext;
    if (!AC || ctx) return Promise.resolve();
    ctx = new AC();
    var opl = root.F117.opl2;
    if (ctx.audioWorklet && root.Blob && root.URL) {
      var url = URL.createObjectURL(new Blob([workletSource(opl)], { type: 'application/javascript' }));
      return ctx.audioWorklet.addModule(url).then(function () {
        node = new AudioWorkletNode(ctx, 'opl2', { numberOfInputs: 0, outputChannelCount: [1] });
        node.connect(ctx.destination);
      }, function () { fallback(opl); });
    }
    fallback(opl);
    return Promise.resolve();
  }
  function fallback(opl) {
    renderer = opl.createRenderer(ctx.sampleRate, opl.createOpl2);
    sp = ctx.createScriptProcessor(2048, 0, 1);
    sp.onaudioprocess = function (e) {
      var o = e.outputBuffer.getChannelData(0);
      renderer.render(o, o.length, e.playbackTime !== undefined ? e.playbackTime : ctx.currentTime);
    };
    sp.connect(ctx.destination);
  }

  function parseWav(bytes) {
    for (var i = 12; i + 8 <= bytes.length;) {
      var id = String.fromCharCode(bytes[i], bytes[i + 1], bytes[i + 2], bytes[i + 3]);
      var len = bytes[i + 4] | (bytes[i + 5] << 8) | (bytes[i + 6] << 16) | (bytes[i + 7] << 24);
      if (id === 'data') return bytes.subarray(i + 8, i + 8 + len);
      i += 8 + len + (len & 1);
    }
    return new Uint8Array(0);
  }

  // asoundFile: bytes of ASOUND.117; wavs: {'41': bytes of speech_41.wav, ..., '43a', '43b', ...}
  function init(asoundFile, wavs) {
    var M = root.F117.music;
    drv = M.createAsound(M.asoundImage(asoundFile), sink);
    for (var k in wavs) phrases[k] = parseWav(wavs[k]);
    batchMs = gameMs();
    drv.init();
    drv.play(40, 2);                                     // F117.COM passes speech paragraph 2 (sound.md 2)
    ready = true;
  }

  // Call from a touchend/click handler (iOS needs a user gesture to start audio).
  function unlock() {
    if (!ctx) {
      startAudio().then(function () {          // bring the fresh chip up to the driver's register shadow
        offset = null; batchMs = gameMs();
        if (drv) for (var r = 1; r < 0x100; r++) sink(r, drv.mem[0x1A06 + r], 0);
        flush();
      });
    }
    if (ctx && ctx.state === 'suspended') ctx.resume();
  }

  function play(id, a2) {
    if (!ready) return 0;
    batchMs = gameMs();
    var r = drv.play(id, a2, function (k) { return phrases[k]; });
    flush();
    return r;
  }

  // VGAME 0000:D41F engine_sound_update
  function engineUpdate() {
    play(state.level === 0 && state.throttlePct !== 0 && state.c09a === 0 ? 24 : 25);
  }
  // VGAME 0000:D3F9 sfx(id, prio)
  function sfx(id, prio) {
    if (prio >= state.level && (state.c09a === 0 || prio > 1)) play(id);
    engineUpdate();
  }

  // Ticker callbacks for timer.createTicker: {sound, noise}. Uses the ticker's frame count as game time.
  function hooks(ticker) {
    clock = function () { return ticker.frameCount * FRAME_MS; };
    return {
      sound: function () {
        if (!ready) return 0;
        batchMs = ticker.frameCount * FRAME_MS;
        var r = drv.tick(); flush(); return r;
      },
      noise: function (offMs) {
        if (!ready) return;
        batchMs = ticker.frameCount * FRAME_MS + offMs;
        drv.noise(); flush();
      }
    };
  }

  var api = {
    init: init, unlock: unlock, play: play, sfx: sfx, hooks: hooks, state: state,
    get speechSec() { return drv && drv.lastSpeech ? drv.lastSpeech.sec : 0; },   // AdLib speech blocks the game
    get driver() { return drv; },
    get context() { return ctx; }, get output() { return node || sp; },
    setClock: function (fn) { clock = fn; }
  };
  if (typeof module !== 'undefined' && module.exports) module.exports = api;
  else { root.F117 = root.F117 || {}; root.F117.sound = api; }
})(typeof window !== 'undefined' ? window : globalThis);
