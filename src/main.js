// F117-REA entry point (task 2.3): builds the host (framebuffer, input, assets, sound) and runs the F117.COM flow.
// Implemented programs: setup, logo, player. START / VGAME / END are stubs that quit (not ported yet).
// Needs assets/ next to the page when unbundled; the bundled build carries them inline.
(function () {
  'use strict';
  var F = window.F117;
  var fb = F.fb.createFramebuffer();
  var display = F.fb.createDisplay(document.getElementById('screen'), fb);
  var input = F.input.createInput();
  input.attach(window);

  // 70 Hz frame tick + 60 Hz sound tick; the sound driver is initialised once SETUP has chosen it.
  var cb = { frame: function () {} };
  var ticker = F.timer.createTicker(cb);
  var h = F.sound.hooks(ticker);
  cb.sound = h.sound; cb.noise = h.noise;
  F.timer.startLoop(ticker);

  // Overlay UI: the SETUP question. Its click is the first user gesture (audio unlock, fullscreen).
  var ui = document.createElement('div');
  ui.style.cssText = 'position:fixed;left:0;top:0;right:0;bottom:0;display:none;align-items:center;justify-content:center;' +
    'flex-direction:column;gap:14px;color:#9f9;font:20px monospace;background:#000;z-index:5;text-align:center';
  document.body.appendChild(ui);
  function gesture() { F.sound.unlock(); display.enterFullscreen(); }
  function choose(title, labels) {
    return new Promise(function (resolve) {
      ui.innerHTML = '';
      var t = document.createElement('div'); t.textContent = 'Night Hawk F-117A Stealth Fighter 2.0'; ui.appendChild(t);
      var q = document.createElement('div'); q.textContent = title; ui.appendChild(q);
      labels.forEach(function (l, i) {
        var btn = document.createElement('button');
        btn.textContent = (i + 1) + ') ' + l;
        btn.style.cssText = 'font:20px monospace;padding:12px 28px;background:#020;color:#9f9;border:1px solid #9f9;min-width:300px';
        var done = false;
        function pick(e) { if (done) return; done = true; e.preventDefault(); gesture(); ui.style.display = 'none'; resolve(i); }
        btn.addEventListener('touchend', pick); btn.addEventListener('click', pick);
        ui.appendChild(btn);
      });
      ui.style.display = 'flex';
    });
  }
  function message(text) {
    ui.innerHTML = ''; var m = document.createElement('div'); m.textContent = text; ui.appendChild(m); ui.style.display = 'flex';
  }

  // Any tap (outside the SETUP buttons) or key press skips the intro: tapped() is consumed by the running program.
  var tap = false;
  document.addEventListener('pointerdown', function () { tap = true; gesture(); });

  var host = {
    fb: fb, assets: F.assets,
    present: function () { display.present(); },
    now: function () { return performance.now(); },
    raf: function (f) { requestAnimationFrame(f); },
    pollKey: function () { return input.keyReady() ? input.getKey() : 0; },
    tapped: function () { var t = tap; tap = false; return t; },
    choose: choose
  };

  function startSound(sndName) {
    if (sndName.charAt(0).toUpperCase() !== 'A') return Promise.resolve();
    var keys = ['41', '42', '43a', '43b', '44', '45'];
    return Promise.all([F.assets.bytes('sound/ASOUND.117')].concat(keys.map(function (k) { return F.assets.bytes('sound/speech/speech_' + k + '.wav'); })))
      .then(function (r) { var wavs = {}; keys.forEach(function (k, i) { wavs[k] = r[i + 1]; }); F.sound.init(r[0], wavs); })
      .catch(function () { /* sound stays off */ });
  }

  var intro = F.intro.createIntroPrograms(host);
  var quit = function () { return 0; };
  var setup = F.setup.createSetupProgram(host);
  var programs = {
    setup: function (ctx) { return setup(ctx).then(function (code) { return startSound(ctx.block.getString('sndName')).then(function () { return code; }); }); },
    logo: function (ctx) { tap = false; input.flush(); return intro.logo(ctx); },
    player: function (ctx) { tap = false; input.flush(); return intro.player(ctx); },
    start: quit, vgame: quit, end: quit,       // START / VGAME / END are not ported yet
    shutdown: function () { F.sound.play && F.sound.play(0); }
  };

  F.flow.runFlow(programs, F.block.createBlock()).then(function (res) {
    window.F117.last = res;
    message('Front end not ported yet (flow ended: ' + res.reason + ')');
  });
  window.F117.demo = { fb: fb, display: display, ticker: ticker, input: input };
})();
