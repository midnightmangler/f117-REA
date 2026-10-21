// MGRAPHIC row-compressed sprites (task 1.2): #77 sprite_grab (019C:0B0C, row encoder 0A6A) and #22 sprite_draw
// (019C:0B70 clip 0BC0, core 0C95/0D7D). Sprite = Uint8Array: word w, word h, then per row {word n, word lead, n bytes}
// (n = bytes from the first to the last non-zero pixel, lead = zero pixels before it; colour 0 = transparent).
(function (root) {
  'use strict';
  var SPRITE_LIMIT = 0xFFF0;   // arena limit per sprite: min(free paragraphs, 0xFFF) * 16 (0A02)

  function i16(v) { return (v << 16) >> 16; }
  function u16(v) { return v & 0xFFFF; }

  function install(g) {
    // #77 sprite_grab(page, x, y, w, h): encode a page rectangle. Rows that overflow the 64K arena window are dropped
    // (the header height is decremented per dropped row, as in 0A90).
    g.spriteGrab = function (page, x, y, w, h) {
      var src = g.pageTable[Math.abs(page)], si = u16(u16(y * 320) + x), out = [w & 255, w >> 8, h & 255, h >> 8], hh = h;
      if (w !== 0 && h !== 0) {
        for (var r = 0; r < h; r++, si = u16(si + 320)) {
          if (out.length + w + 4 > SPRITE_LIMIT) { hh--; continue; }
          var lead = 0, stored = 0, trail = 0, data = [];
          for (var k = 0; k < w; k++) {
            var p = src[u16(si + k)] || 0;
            if (p === 0) {
              if (stored === 0) { lead++; continue; }
              trail++;
            } else trail = 0;
            stored++;
            data.push(p);
          }
          var n = stored - trail;
          out.push(n & 255, n >> 8, lead & 255, lead >> 8);
          for (var j = 0; j < n; j++) out.push(data[j]);
        }
        out[2] = hh & 255; out[3] = hh >> 8;
      }
      return Uint8Array.from(out);
    };

    // #22 sprite_draw(vp, x, y, w, h, data, off): x,y relative to the VP clip origin; w,h = destination size,
    // negative = mirrored. Returns {x,y,w,h}, the visible rectangle relative to the VP (zeros if nothing is visible).
    g.spriteDraw = function (vp, x, y, w, h, data, off) {
      off = off || 0;
      var rd = function (o) { return data[o] | (data[o + 1] << 8); };
      var dw = Math.abs(i16(w)), dh = Math.abs(i16(h)), hflip = i16(w) < 0, vflip = i16(h) < 0;
      var none = { x: 0, y: 0, w: 0, h: 0 };
      x = i16(x); y = i16(y);
      var srcW = rd(off), srcH = rd(off + 2);
      if (!data || srcW === 0 || srcH === 0) return none;                       // 0C5D
      var clipTop = 0, clipBot = 0, clipL = 0, clipR = 0, ax, bx;               // 856, 85a, 858, 85c
      if (y < 0) { ax = -y; if (ax >= dh) return none; clipTop = ax; }          // 0BC0
      ax = y + dh - 1;
      bx = i16(vp.bottom - vp.top);
      if (bx < 0 || y > bx) return none;
      ax -= bx; if (ax > 0) clipBot = ax;
      if (x < 0) { ax = -x; if (ax >= dw) return none; clipL = ax; }
      ax = x + dw - 1;
      bx = i16(vp.right - vp.left);
      if (bx < 0 || x > bx) return none;
      ax -= bx; if (ax > 0) clipR = ax;
      var rect = { x: clipL + x, y: clipTop + y, w: dw - clipL - clipR, h: dh - clipTop - clipBot };

      // 0C95 core
      var seg = g.pageTable[vp.page];
      var dx = x + vp.left, row = y + vp.top;
      var visW = rect.w, visH = rect.h;
      if (visW <= 0 || visH <= 0) return rect;
      var si = off + 4, stride = 320, cx;
      row += clipTop;
      if (vflip) { stride = -320; cx = clipBot; row += visH - 1; } else cx = clipTop;
      var errV = -dh;                                                           // skip the clipped rows (D06)
      while (--cx >= 0) {
        errV += srcH;
        while (errV >= 0) { si += rd(si) + 4; errV -= dh; }
      }
      cx = clipL; dx += cx;
      var step = 1;
      if (hflip) { step = -1; cx = clipR; dx += visW - 1; }
      var errH = -dw, skipCols = 0;                                             // D52
      while (--cx >= 0) {
        errH += srcW;
        while (errH >= 0) { skipCols++; errH -= dw; }
      }
      var di = u16(u16(row * 320) + dx), buf = new Uint8Array(srcW + 4);
      for (var rowsLeft = visH; ; ) {                                           // D7D
        var n = rd(si), lead = rd(si + 2);
        if (n !== 0 && lead + n > skipCols) {
          buf.fill(0);
          for (var q = 0; q < n; q++) buf[lead + q] = data[si + 4 + q];
          var sp = skipCols, e = errH, d = di;
          for (var px = 0; px < visW; px++) {                                   // D3 .. DE9 column DDA
            var v = buf[sp];
            if (v) seg[d] = v;
            d = u16(d + step);
            e += srcW;
            while (e >= 0) { sp++; e -= dw; }
          }
        }
        if (--rowsLeft === 0) break;
        di = u16(di + stride);
        errV += srcH;                                                           // E13
        while (errV >= 0) { si += rd(si) + 4; errV -= dh; }
      }
      return rect;
    };
    return g;
  }

  var api = { install: install };
  if (typeof module !== 'undefined' && module.exports) module.exports = api;
  else { root.F117 = root.F117 || {}; root.F117.gfxSprite = api; }
})(typeof window !== 'undefined' ? window : globalThis);
