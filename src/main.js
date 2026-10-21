// F117-REA entry point. Task 1.1 demo: framebuffer + DAC + scaler + tick model, draws one PIC.
// Needs assets/ next to the page (served over http or opened from the clone); without them a test card is drawn.
(function () {
  'use strict';
  var F = window.F117;
  var fb = F.fb.createFramebuffer();
  var display = F.fb.createDisplay(document.getElementById('screen'), fb);

  function testCard() {
    for (var c = 0; c < 256; c++) fb.setDacEntry(c, c >> 2, (c * 3 >> 2) & 63, 63 - (c >> 2));
    var p = fb.pages[0];
    for (var y = 0; y < 200; y++) for (var x = 0; x < 320; x++) p[y * 320 + x] = (x * 256 / 320 + (y & 8 ? 16 : 0)) & 255;
  }

  function loadPic(name, palName) {
    return Promise.all([
      fetch('assets/pic/' + name + '.png').then(function (r) { if (!r.ok) throw new Error(r.status); return r.arrayBuffer(); }),
      fetch('assets/palettes.json').then(function (r) { return r.json(); })
    ]).then(function (res) {
      return F.png.decodeIndexedPng(new Uint8Array(res[0])).then(function (img) {
        fb.setPalette(res[1].palettes[palName]);
        fb.putImage(0, img);
      });
    });
  }

  loadPic('ADV', 'ADV.PAL').catch(testCard).then(function () { display.present(); });

  // Frame tick at 70 Hz, sound tick 60 Hz + noise 280 Hz into the ASOUND port. Pauses when the tab is hidden.
  var cb = { frame: function () {} };
  var ticker = F.timer.createTicker(cb);
  var h = F.sound.hooks(ticker);
  cb.sound = h.sound; cb.noise = h.noise;
  F.timer.startLoop(ticker);

  // Task 1.4 demo: each tap plays the next sound (songs, effects, speech).
  var bin = function (p) { return fetch('assets/sound/' + p).then(function (r) { return r.arrayBuffer(); }).then(function (b) { return new Uint8Array(b); }); };
  var keys = ['41', '42', '43a', '43b', '44', '45'];
  Promise.all([bin('ASOUND.117')].concat(keys.map(function (k) { return bin('speech/speech_' + k + '.wav'); }))).then(function (r) {
    var wavs = {};
    keys.forEach(function (k, i) { wavs[k] = r[i + 1]; });
    F.sound.init(r[0], wavs);
  }).catch(function (e) { console.warn('sound assets', e); });
  var demoIds = [39, 36, 37, 38, 5, 4, 15, 41, 43, 44, 45, 7, 9, 32], demoNext = 0;
  document.addEventListener('pointerdown', function () {
    F.sound.unlock();
    F.sound.play(0);
    F.sound.play(demoIds[demoNext++ % demoIds.length]);
  });

  // First user gesture: go fullscreen / lock landscape where the browser allows it.
  document.addEventListener('pointerdown', function once() {
    document.removeEventListener('pointerdown', once);
    display.enterFullscreen();
  });
  window.F117.demo = { fb: fb, display: display, ticker: ticker };
})();
