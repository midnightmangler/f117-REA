// Framebuffer, VGA DAC and canvas scaler (task 1.1). Mirrors MGRAPHIC's model (mgraphic-api.md sec. 3):
// 5 pages of 64000 palette-index bytes; page 0 = screen (A000), page 1 = back buffer, page 2 = cockpit art.
// The 256-entry DAC holds raw 6-bit values (0..63); rgb8 = (v*255+31)/63 as in assets/palettes.json.
(function (root) {
  'use strict';
  var W = 320, H = 200, PAGE_BYTES = 64000, NPAGES = 5;
  var LITTLE = new Uint8Array(new Uint32Array([1]).buffer)[0] === 1;

  function dac8(v) { return (((v & 63) * 255 + 31) / 63) | 0; }
  function pack(r6, g6, b6) {   // RGBA bytes in memory order R,G,B,A as one Uint32
    var r = dac8(r6), g = dac8(g6), b = dac8(b6);
    return LITTLE ? (((255 << 24) | (b << 16) | (g << 8) | r) >>> 0) : (((r << 24) | (g << 16) | (b << 8) | 255) >>> 0);
  }

  function createFramebuffer() {
    var pages = [];
    for (var i = 0; i < NPAGES; i++) pages.push(new Uint8Array(PAGE_BYTES));
    var dac = new Uint8Array(768), lut = new Uint32Array(256);
    for (var c = 0; c < 256; c++) lut[c] = pack(0, 0, 0);

    var fb = {
      width: W, height: H, pageBytes: PAGE_BYTES, pages: pages, dac: dac, lut: lut,
      // One DAC entry from 6-bit components (VGA port 3C8/3C9 semantics: values are masked to 6 bits).
      setDacEntry: function (i, r, g, b) {
        i &= 255; dac[i * 3] = r & 63; dac[i * 3 + 1] = g & 63; dac[i * 3 + 2] = b & 63;
        lut[i] = pack(r, g, b);
      },
      // Load `count` entries from a flat 6-bit RGB array (palettes.json layout), starting at DAC index `first`.
      setPalette: function (rgb6, first, count) {
        first = first || 0; count = count === undefined ? 256 : count;
        for (var k = 0; k < count && first + k < 256; k++) fb.setDacEntry(first + k, rgb6[k * 3], rgb6[k * 3 + 1], rgb6[k * 3 + 2]);
      },
      clear: function (page, colour) { pages[page].fill(colour || 0); },
      // MGRAPHIC #42 blit, whole-width helper: copy page `src` onto page `dst`.
      copyPage: function (src, dst) { pages[dst].set(pages[src]); },
      // MGRAPHIC #44 present(ax=words): copy the first `words` 16-bit words (VGAME passes rows*160) page 1 -> page 0.
      presentWords: function (words) {
        var n = Math.min(words * 2, PAGE_BYTES);
        pages[0].set(pages[1].subarray(0, n));
      },
      // Convert page 0 through the DAC LUT into a Uint32Array(64000) (the ImageData pixel buffer).
      toRGBA: function (out32, page) {
        var src = pages[page || 0];
        for (var p = 0; p < PAGE_BYTES; p++) out32[p] = lut[src[p]];
      },
      // Draw a decoded image ({width,height,pixels}) at the top-left of a page (demo/loader convenience).
      putImage: function (page, img) {
        var dst = pages[page], w = Math.min(img.width, W), h = Math.min(img.height, H);
        for (var y = 0; y < h; y++) dst.set(img.pixels.subarray(y * img.width, y * img.width + w), y * W);
      }
    };
    return fb;
  }

  // Integer scale in *device* pixels, centred (letterboxed). Returns CSS-pixel size/offset for the canvas.
  function computeLayout(winW, winH, dpr) {
    dpr = dpr || 1;
    var s = Math.max(1, Math.floor(Math.min(winW * dpr / W, winH * dpr / H)));
    var cssW = W * s / dpr, cssH = H * s / dpr;
    return { scale: s, cssWidth: cssW, cssHeight: cssH,
             left: Math.max(0, (winW - cssW) / 2), top: Math.max(0, (winH - cssH) / 2) };
  }

  // Binds a framebuffer to a <canvas> (browser only). present() repaints page 0.
  function createDisplay(canvas, fb, win) {
    win = win || window;
    var ctx = canvas.getContext('2d', { alpha: false });
    var image = ctx.createImageData(W, H), px32 = new Uint32Array(image.data.buffer);
    canvas.width = W; canvas.height = H;
    canvas.style.imageRendering = 'pixelated';
    var d = {
      layout: null,
      present: function () { fb.toRGBA(px32, 0); ctx.putImageData(image, 0, 0); },
      fit: function () {
        var L = computeLayout(win.innerWidth, win.innerHeight, win.devicePixelRatio || 1);
        canvas.style.position = 'absolute'; canvas.style.transform = 'none';
        canvas.style.width = L.cssWidth + 'px'; canvas.style.height = L.cssHeight + 'px';
        canvas.style.left = L.left + 'px'; canvas.style.top = L.top + 'px';
        d.layout = L;
      },
      // Map a client (CSS px) point to framebuffer coordinates; null if outside the picture.
      toScreen: function (cx, cy) {
        var L = d.layout, x = Math.floor((cx - L.left) * W / L.cssWidth), y = Math.floor((cy - L.top) * H / L.cssHeight);
        return (x < 0 || y < 0 || x >= W || y >= H) ? null : { x: x, y: y };
      },
      // Fullscreen + landscape lock. Must be called from a user gesture; iPad Safari ignores both for
      // pages (use Add to Home Screen, apple-mobile-web-app-capable is set), so every call is guarded.
      enterFullscreen: function () {
        var el = win.document.documentElement;
        try { var p = (el.requestFullscreen || el.webkitRequestFullscreen); if (p) { var r = p.call(el); if (r && r.catch) r.catch(function () {}); } } catch (e) {}
        try { var o = win.screen && win.screen.orientation; if (o && o.lock) o.lock('landscape').catch(function () {}); } catch (e) {}
      }
    };
    win.addEventListener('resize', function () { d.fit(); d.present(); });
    win.addEventListener('orientationchange', function () { d.fit(); d.present(); });
    d.fit();
    return d;
  }

  var api = { WIDTH: W, HEIGHT: H, PAGE_BYTES: PAGE_BYTES, NPAGES: NPAGES, dac8: dac8,
              createFramebuffer: createFramebuffer, computeLayout: computeLayout, createDisplay: createDisplay };
  if (typeof module !== 'undefined' && module.exports) module.exports = api;
  else { root.F117 = root.F117 || {}; root.F117.fb = api; }
})(typeof window !== 'undefined' ? window : globalThis);
