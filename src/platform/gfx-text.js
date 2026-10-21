// MGRAPHIC text (task 1.2): entries #1-#6 (register ABI) and #5,#7-#10 (C wrappers), #47 char_width.
// Original code: setup 019C:03E8, right clip 031D, left clip 02B9, vertical clip 037F, draw 061A (mgraphic-api.md sec. 5, 6).
// Strings are JS strings or byte arrays; bytes >= 0x80 set the colour (byte & 0x7F), 0 / end of array terminates.
// The viewport struct (VP) is a plain object: {page, flags, color, bg, x, y, font, top, bottom, left, right};
// x is updated to the end x on return, color to the last colour used (VP+8, VP+4 in the original).
(function (root) {
  'use strict';
  var RIGHT = 1, LEFT = 2, VERT = 4;

  function i16(v) { return (v << 16) >> 16; }
  function u16(v) { return v & 0xFFFF; }

  function toBytes(s) {
    var n = s.length, b = new Uint8Array(n + 2);
    for (var i = 0; i < n; i++) b[i] = typeof s === 'string' ? s.charCodeAt(i) & 255 : s[i] & 255;
    return b;                                   // trailing zeros = terminator
  }

  function install(g) {
    // 019C:023A char_width(ch, font): glyph advance incl. spacing; 0 for ch >= 0x80, bad font or char outside first..last.
    g.charWidth = function (ch, fontIdx) {
      ch &= 255;
      if (ch >= 0x80 || fontIdx < 0 || fontIdx > 6) return 0;   // font 7 reads garbage in the original
      var f = g.fonts[fontIdx];
      if (ch < f.first || ch > f.last) return 0;
      return (f.fixed ? f.fixed : f.widths[ch - f.first]) + f.spacing;
    };

    // Shared body of all text entries; mode = OR of RIGHT/LEFT/VERT, applied in the order setup, right, left, vertical, draw.
    function run(vp, str, mode) {
      var bytes = toBytes(str), st = { x: u16(vp.x), y: u16(vp.y), skip: 0, cut: 0, rowSkip: 0 };
      function finish() { vp.x = i16(st.x); return vp.x; }              // 019C:03D1 / 03DF
      var fontIdx = vp.font;
      if (bytes[0] === 0 || fontIdx < 0 || fontIdx > 6) return finish();     // 03E8: empty string, font > max (7 = garbage)
      var f = g.fonts[fontIdx], first = f.first, last = f.last, spacing = f.spacing;
      var fixedAdv = f.fixed ? f.fixed + spacing : 0;
      var rows = f.height + ((vp.flags & 1) ? f.extra : 0);
      function adv(c) { return fixedAdv ? fixedAdv : f.widths[c] + spacing; }
      var i, c, d;

      if (mode & RIGHT) {                                               // 031D
        var lim = u16(vp.right) + 1;
        if (st.x >= u16(vp.right)) return finish();                     // jae: x >= right draws nothing
        d = st.x;
        for (i = 0; ; i++) {
          c = bytes[i];
          if (c === 0) break;
          if (c & 0x80 || c > last) continue;
          c -= first;
          if (c < 0) continue;
          d = u16(d + adv(c));
          if (d < lim) continue;
          st.cut = (d - lim) & 255;                                     // columns cut off the crossing char
          bytes[i + 1] = 0;                                             // string truncated after it
          break;
        }
      }

      var start = 0;
      if (mode & LEFT) {                                                // 02B9
        if (i16(vp.right - vp.left) < 0) return finish();
        var left = u16(vp.left);
        if (st.x < left) {
          var cx = st.x;
          st.x = left;
          for (i = 0; ; i++) {
            c = bytes[i];
            if (c === 0) return finish();
            if (c & 0x80 || c > last) continue;                         // colour codes before the clip point are lost
            c -= first;
            if (c < 0) continue;
            var a = adv(c);
            cx = i16(cx + a);
            if (cx <= i16(st.x)) continue;
            st.skip = (a - (cx - i16(st.x))) & 255;                     // columns of this char left of the clip
            start = i;
            break;
          }
        }
      }

      if (mode & VERT) {                                                // 037F, byte arithmetic
        var top = vp.top & 255, bot = vp.bottom & 255, h = rows & 255;
        var dl = st.y & 255, dh = (h - 1 + dl) & 255;
        if (dl > bot || dh < top) return finish();
        if (dl < top) {
          rows = (dh - top + 1) & 255;
          st.y = (st.y & 0xFF00) | top;
          st.rowSkip = top - dl;
        }
        if (dh > bot) rows = (bot - dl + 1) & 255;                      // uses the original y (as the original does)
      }

      // 061A draw
      var seg = g.pageTable[vp.page];
      var col = vp.color & 255, bg = vp.bg & 255, opaque = (vp.flags & 255) === 1;
      g.color = col;
      var di = u16(u16(st.y * 320) + st.x), skip = st.skip;
      for (i = start; ; ) {
        c = bytes[i];
        var next = bytes[i + 1];
        i++;
        if (c === 0) break;
        if (c & 0x80) { col = c & 0x7F; continue; }
        if (c > last) continue;
        c -= first;
        if (c < 0) continue;
        var cl = adv(c);
        if (next === 0) cl -= st.cut;
        cl = (cl - skip) & 255;
        var n = cl;
        if (opaque) {
          if (n === 0) n = 256;                                         // no zero check in the original
          drawGlyph(f.rows[c], skip, n, true);
        } else if (cl !== 0) {
          if (next !== 0) n = (n - spacing) & 255;
          if (n !== 0) drawGlyph(f.rows[c], skip, n, false);
        }
        skip = 0;
        di = u16(di + cl);
        st.x = u16(st.x + cl);
      }
      vp.color = col;
      return finish();

      function drawGlyph(glyph, sk, n, opq) {
        var rowDi = di;
        for (var r = 0; r < rows; r++) {
          var gr = r + st.rowSkip, bx = ((gr < f.height ? glyph[gr] : 0) << sk) & 0xFFFF;
          for (var k = 0; k < n; k++) {
            var bit = (bx >> 15) & 1;
            bx = (bx << 1) & 0xFFFF;
            if (bit) seg[u16(rowDi + k)] = col;
            else if (opq) seg[u16(rowDi + k)] = bg;
          }
          rowDi = u16(rowDi + 320);
        }
      }
    }

    g.textDraw = function (vp, str) { return run(vp, str, 0); };                           // #5, #4
    g.textDrawVClip = function (vp, str) { return run(vp, str, VERT); };                   // #7, #1
    g.textDrawLClip = function (vp, str) { return run(vp, str, LEFT); };                   // #8, #2
    g.textDrawRClip = function (vp, str) { return run(vp, str, RIGHT); };                  // #10, #3
    g.textDrawClip = function (vp, str) { return run(vp, str, RIGHT | LEFT | VERT); };     // #9, #6
    return g;
  }

  var api = { install: install };
  if (typeof module !== 'undefined' && module.exports) module.exports = api;
  else { root.F117 = root.F117 || {}; root.F117.gfxText = api; }
})(typeof window !== 'undefined' ? window : globalThis);
