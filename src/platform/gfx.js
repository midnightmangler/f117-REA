// MGRAPHIC API port (task 1.2): createGfx(fb, fonts) -> object with one method per driver entry (mgraphic-api.md sec. 4).
// Segments become Uint8Array(64000) buffers: pageTable[0..4] (cs:0787) holds them, drawSeg is cs:0194, origin cs:0196,
// color is DATA:1866. Original addresses are 019C:xxxx. Text lives in gfx-text.js, sprites in gfx-sprite.js.
(function (root) {
  'use strict';
  var PB = 64000;

  function i16(v) { return (v << 16) >> 16; }
  function u16(v) { return v & 0xFFFF; }
  function rowOff(y) { return u16(y * 320); }                 // cs:0004 table (y*320); beyond 200 rows the original reads code

  function load(name, glob) {
    return typeof module !== 'undefined' && module.exports ? require('./' + name + '.js') : root.F117[glob];
  }

  // EGA palette 0 (DATA:1871), 6-bit; the flicker picks colours 12,4,12,14 for DAC entry 13 (DATA:197E).
  var EGA = { 4: [0x2A, 0, 0], 12: [0x3F, 0x15, 0x15], 14: [0x3F, 0x3F, 0x15] };
  var FLICKER = [12, 4, 12, 14];
  // HUD tick tape tables (DATA:1966/196E/1976), indexed by si/2 (+2 for the large HUD).
  var TAPE_X = [71, 248, 120, 200], TAPE_YMIN = [22, 22, 34, 34], TAPE_YMAX = [82, 82, 74, 74];

  function createGfx(fb, fontData) {
    var g = {
      fb: fb, fonts: (fontData && fontData.fonts) || fontData,
      pageTable: fb.pages.slice(0, 5), drawSeg: fb.pages[0], origin: 0, color: 0, renderPage: 1,
      seed: 0x04D2, shake: 0, hscroll: 0, lastX: 0, lastY: 0
    };
    var pt = g.pageTable;

    // --- pages / draw target ---
    g.pageAlloc = function (n) { return n === 0 ? pt[0] : new Uint8Array(PB); };     // #0 (page 0 = A000)
    g.setPageSeg = function (idx, buf) { pt[idx] = buf; };                           // #57
    g.setPageSeg2 = function (buf, idx) { pt[idx] = buf; };                          // #75 (seg first)
    g.pageSeg = function (idx) { return pt[idx]; };                                  // #56
    g.setDrawPage1 = function () { g.drawSeg = pt[1]; };                             // #12
    g.setDrawPage = function (idx) { g.drawSeg = pt[idx]; };                         // #13, #14
    g.setDrawSeg = function (buf) { g.drawSeg = buf; };                              // #15
    g.getDrawSeg = function () { return g.drawSeg; };                                // #16
    g.pageBytes = function () { return 0xFA00; };                                    // #23, #49
    g.resetDrawOrigin = function () { g.origin = 0; };                               // #24, #25
    g.setDrawOrigin = function (off) { g.origin = u16(off); };                       // #26, #27
    g.getDrawOrigin = function () { return g.origin; };                              // #30
    g.const5580 = function () { return 0x5580; };                                    // #28
    g.const1450 = function () { return 0x1450; };                                    // #29
    g.getRenderPage = function () { return g.renderPage; };                          // #45
    g.rowOffset = function (y) { return rowOff(y); };                                // #58
    g.pixelOffset = function (x, y) { return u16(x + rowOff(y)); };                  // #62
    g.pageSegIsScreen = function (buf) { return buf === pt[0]; };
    g.driverId = function () { return 3; };                                          // #63
    g.setCe = function () {};                                                        // #65 (write-only word)
    g.setMode13 = function () {};                                                    // #60 (canvas is always 320x200x256)
    g.dosMaxFree = function () { return 0x8000; };                                   // #50 (paragraphs; port has no DOS heap)
    g.arenaInit = function () { return 1; };                                         // #76 (non-zero = ok; sprites are JS arrays)
    g.arenaShrink = function () { return 1; };                                       // #78
    g.setColor = function (c) { g.color = c & 255; };                                // #33, #32 (ah)
    g.screenOff = function () { fb.blank = true; };                                  // #69
    g.screenOn = function () { fb.blank = false; };                                  // #70
    g.setShake = function (frames) { g.shake = frames & 255; };                      // #79
    g.clearSeg = function (buf) { buf.fill(0); };                                    // #59
    g.clearScreen = function () { pt[0].fill(0); };                                  // #43
    g.copySegToDraw = function (buf) { g.drawSeg.set(buf.subarray(0, PB)); };        // #48
    g.copyRow = function (src, srcOff, dst, dstOff) {                                // #51, #52: 320 bytes
      for (var i = 0; i < 320; i++) dst[dstOff + i] = src[srcOff + i];
    };

    // #44 present(words): page1 -> page0 for the first `words` 16-bit words; sets the render page to 1.
    g.present = function (words) {
      g.renderPage = 1;
      pt[0].set(pt[1].subarray(0, Math.min(u16(words) * 2, PB)));
    };

    // #46 flicker_tick: seed = seed*5+1; DAC 13 := EGA colour 12/4/12/14; optional horizontal shake (CRTC 0Dh = hscroll).
    g.flickerTick = function () {
      g.seed = u16(g.seed * 5 + 1);
      var c = EGA[FLICKER[g.seed & 3]];
      fb.setDacEntry(13, c[0], c[1], c[2]);
      if (g.shake !== 0) {
        var ah = (g.seed >> 8) & 3;
        g.shake--;
        if (g.shake === 0) ah = 0;
        g.hscroll = ah;                    // start-address units; mode 13h shifts the picture by 4 px per unit (?)
      }
    };

    // --- lines ---
    function plot(x, y, seg) {
      var di = u16(rowOff(y) + g.origin + x);
      seg[di] = g.color;
    }
    // #31 line_r: Bresenham, endpoints inclusive, no clipping; coordinates are 16-bit like the registers.
    g.line = function (x1, y1, x2, y2) {
      var seg = g.drawSeg, t;
      x1 = u16(x1); y1 = u16(y1); x2 = u16(x2); y2 = u16(y2);
      if (x1 > x2) { t = x1; x1 = x2; x2 = t; t = y1; y1 = y2; y2 = t; }
      g.lastX = x1; g.lastY = y1;
      if (x1 === x2 && y1 === y2) { plot(x1, y1, seg); return; }
      var major = x2 - x1, minor = u16(y2 - y1), minorStep = 320, majorStep = 1;
      if (i16(minor) < 0) { minorStep = -320; minor = u16(-minor); }
      if (major < minor) { t = minorStep; minorStep = majorStep; majorStep = t; t = major; major = minor; minor = t; }
      var di = u16(rowOff(y1) + g.origin + x1), err = -((major + 1) >> 1), col = g.color;
      for (var cx = major; cx >= 0; cx--) {
        seg[di] = col;
        di = u16(di + majorStep);
        err += minor;
        if (err >= 0) { err -= major; di = u16(di + minorStep); }
      }
    };
    g.replot = function () { plot(g.lastX, g.lastY, g.drawSeg); };                   // #36

    // #37 fill_spans_r: rows ybot..ytop (inclusive, do-while like the original), left[y]..right[y] inclusive.
    // mode 0 colour, 1 OR, 2 AND, anything else = shade 0x98 | ((p & 0x0E) >> 1).
    g.fillSpans = function (ytop, ybot, left, right, mode) {
      if (i16(ytop) < 0) return;
      var seg = g.drawSeg, col = g.color, y = i16(ybot);
      do {
        var L = u16(left[y]), R = u16(right[y]);
        if (R > L || (R === L && R !== 0 && R !== 319)) {
          var di = u16(rowOff(y) + g.origin + L), cnt = R - L + 1;
          for (var k = 0; k < cnt; k++, di = u16(di + 1)) {
            var p = seg[di];
            seg[di] = mode === 0 ? col : mode === 1 ? p | col : mode === 2 ? p & col : 0x98 | ((p & 0x0E) >> 1);
          }
        }
        y--;
      } while (y >= i16(ytop));
    };
    g.fillSpansSolid = function (ytop, ybot, left, right) { g.fillSpans(ytop, ybot, left, right, 0); };   // #40

    // #11 hud_tick_tape_r: si 0 = left tape (draws leftwards), 2 = right; cl large-HUD set; dl >= 1 shifts y by 20.
    g.hudTickTape = function (y, si, cl, dl) {
      var seg = g.drawSeg, col = g.color, step = si === 0 ? -1 : 1, bx = i16(y) - 1;
      if (dl >= 1) bx += 20;
      if (cl) { si += 4; bx++; }
      var k = si >> 1, x = TAPE_X[k], ymin = TAPE_YMIN[k], ymax = TAPE_YMAX[k], ch = 10;
      for (;;) {
        if (u16(bx) < ymin) return;
        if (u16(bx) <= ymax) {
          var di = u16(rowOff(bx) + x), n = ch === 5 ? 2 : ch === 10 ? (cl ? 2 : 3) : 1;
          for (var i = 0; i < n; i++, di = u16(di + step)) seg[di] = col;
        }
        bx -= 2;
        ch = ch === 10 ? 1 : ch + 1;
      }
    };

    // #41 recolor_rect(vp, x1, y1, x2, y2, from, to): inclusive absolute rect on the VP's page.
    g.recolorRect = function (vp, x1, y1, x2, y2, from, to) {
      var seg = pt[vp.page];
      for (var y = y1; y <= y2; y++) {
        var di = u16(rowOff(y) + x1);
        for (var x = x1; x <= x2; x++, di = u16(di + 1)) if (seg[di] === from) seg[di] = to;
      }
    };

    // #42 blit(srcPage, sx, sy, dstPage, dx, dy, w, h): opaque copy, no clipping, forward byte order.
    g.blit = function (sp, sx, sy, dp, dx, dy, w, h) {
      var src = pt[sp], dst = pt[dp];
      for (var r = 0; r < h; r++) {
        var s = u16(rowOff(sy + r) + sx), d = u16(rowOff(dy + r) + dx);
        for (var k = 0; k < w; k++) dst[u16(d + k)] = src[u16(s + k)];
      }
    };

    // #18 blit_transp_r(bs): bs = {seg, sx, sy, page, dx, dy, w, h}; source colour 0 is transparent.
    g.blitTransp = function (bs) {
      var src = bs.seg, dst = pt[bs.page];
      for (var r = 0; r < bs.h; r++) {
        var s = u16(rowOff(bs.sy + r) + bs.sx), d = u16(rowOff(bs.dy + r) + bs.dx);
        for (var k = 0; k < bs.w; k++) {
          var p = src[u16(s + k)];
          if (p) dst[u16(d + k)] = p;
        }
      }
    };

    // #20 blit_transp_clip_r(bs): + {top, bottom, left, right} (inclusive). dx,dy,sx,sy are adjusted in bs for good;
    // w,h are restored. 019C:0E41.
    g.blitTranspClip = function (bs) {
      var w0 = bs.w, h0 = bs.h;
      if (clipAxis(bs, 'dx', 'sx', 'w', bs.left, bs.right) && clipAxis(bs, 'dy', 'sy', 'h', bs.top, bs.bottom)) g.blitTransp(bs);
      bs.w = w0; bs.h = h0;
    };
    function clipAxis(bs, d, s, len, lo, hi) {
      var a = bs[d], bx = a + bs[len] - 1;
      if (a < lo) {
        if (bx < lo) return false;
        var c = lo - a;
        bs[d] += c; bs[s] += c; bs[len] -= c;
      }
      if (bx > hi) {
        if (a > hi) return false;
        bs[len] -= bx - hi;
      }
      return true;
    }

    // dead code at 019C:1223 (the task text lists it): LFSR random dissolve of 64000 pixels from buf onto the draw seg.
    g.fizzleCopy = function (buf, onStep) {
      var bx = 1, dst = g.drawSeg;
      for (var n = 0; n < PB; n++) {
        do { var carry = bx & 1; bx >>= 1; if (carry) bx ^= 0xB400; } while (bx > PB);
        dst[bx - 1] = buf[bx - 1];
        if (onStep) onStep(n);
      }
    };

    load('gfx-text', 'gfxText').install(g);
    load('gfx-sprite', 'gfxSprite').install(g);
    return g;
  }

  var api = { createGfx: createGfx };
  if (typeof module !== 'undefined' && module.exports) module.exports = api;
  else { root.F117 = root.F117 || {}; root.F117.gfx = api; }
})(typeof window !== 'undefined' ? window : globalThis);
