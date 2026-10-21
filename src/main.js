// F117-REA entry point. Phase 0 placeholder: sizes the canvas and clears it.
// The real framebuffer, palette and scaler arrive with Phase 1 (src/platform/*).
(function () {
  'use strict';
  var W = 320, H = 200;
  var canvas = document.getElementById('screen');
  var ctx = canvas.getContext('2d');

  function fit() {
    var sx = window.innerWidth / W, sy = window.innerHeight / H;
    var s = Math.max(1, Math.floor(Math.min(sx, sy)));   // integer scale, letterboxed
    canvas.style.width = (W * s) + 'px';
    canvas.style.height = (H * s) + 'px';
  }
  window.addEventListener('resize', fit);
  fit();

  ctx.fillStyle = '#000';
  ctx.fillRect(0, 0, W, H);
  ctx.fillStyle = '#aaa';
  ctx.font = '8px monospace';
  ctx.fillText('F117-REA phase 0', 8, 12);
})();
