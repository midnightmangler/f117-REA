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
    return Promise.all([F.assets.bytes('pic/' + name + '.png'), F.assets.json('palettes.json')]).then(function (res) {
      return F.png.decodeIndexedPng(res[0]).then(function (img) {
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
  var bin = function (p) { return F.assets.bytes('sound/' + p); };
  var keys = ['41', '42', '43a', '43b', '44', '45'];
  Promise.all([bin('ASOUND.117')].concat(keys.map(function (k) { return bin('speech/speech_' + k + '.wav'); }))).then(function (r) {
    var wavs = {};
    keys.forEach(function (k, i) { wavs[k] = r[i + 1]; });
    F.sound.init(r[0], wavs);
  }).catch(function (e) { assetError = String(e); });
  var demoIds = [39, 36, 37, 38, 5, 4, 15, 41, 43, 44, 45, 7, 9, 32], demoNext = 0, lastTouch = 0, assetError = '';
  // WebKit only starts audio from touchend/click (not pointerdown); the click after a touch is ignored.
  function tap(e) {
    if (e.type === 'touchend') lastTouch = Date.now();
    else if (Date.now() - lastTouch < 800) return;
    F.sound.unlock();
    F.sound.play(0);
    F.sound.play(demoIds[demoNext++ % demoIds.length]);
  }
  document.addEventListener('touchend', tap);
  document.addEventListener('click', tap);

  // Demo diagnostic line (bottom left): audio path / context state / driver / errors, and the id last played.
  var info = document.createElement('div');
  info.style.cssText = 'position:fixed;left:4px;bottom:4px;color:#8f8;font:12px monospace;z-index:9;pointer-events:none';
  document.body.appendChild(info);
  setInterval(function () {
    info.textContent = F.sound.status() + (assetError ? ' / assets: ' + assetError : '') +
      ' / tap ' + demoNext + (demoNext ? ' (id ' + demoIds[(demoNext - 1) % demoIds.length] + ')' : '');
  }, 500);

  // First user gesture: go fullscreen / lock landscape where the browser allows it.
  document.addEventListener('pointerdown', function once() {
    document.removeEventListener('pointerdown', once);
    display.enterFullscreen();
  });
  window.F117.demo = { fb: fb, display: display, ticker: ticker };
})();
