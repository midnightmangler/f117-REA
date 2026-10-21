// PAN animation decoder (task 1.3). Source: PLAYER.EXE, re/docs/format-pan.md, reference re/tools/pan.py.
// A .PAN file = one LZEXE-0.91-token LZ stream (PLAYER 0000:0BE2) of cels; each cel is a RunSkipDump delta
// (PLAYER 0000:1006..1095) applied to the 320x200 screen (A000:0000, 64000 bytes; di wraps at 16 bits).
// createPanPlayer(bytes) -> { rate, ticksPerFrame, palette(768, 6-bit), count, index, screen(65536), step() }
(function (root) {
  'use strict';

  // PLAYER 0000:0BE2 lz_segment: 16-bit LE control words, LSB first, next word fetched when the 16th bit is used
  // (0C2E..0C43). 1 = literal; 00 b1 b0 = short match (len 2*b1+b0+2, dist 0xFF00|byte); 01 = long match (0CB4):
  // word lo,hi: dist = 0xE000|(hi>>3)<<8|lo, n = hi&7, n!=0 -> len n+2 else byte c: 0 = EOF, 1 = segment end, else c+1.
  // Segment ends are only flush points (stream and window continue), so they are recorded, not acted on.
  function lzUnpack(src) {
    var p = 2, buf = src[0] | (src[1] << 8), cnt = 16;
    var out = new Uint8Array(Math.max(1024, src.length * 8)), n = 0;
    var segs = [];
    function bit() {
      var b = buf & 1;
      buf >>= 1;
      if (--cnt === 0) { buf = src[p] | (src[p + 1] << 8); p += 2; cnt = 16; }
      return b;
    }
    function room(k) {
      if (n + k <= out.length) return;
      var o = new Uint8Array(Math.max(out.length * 2, n + k));
      o.set(out.subarray(0, n));
      out = o;
    }
    for (;;) {
      var span, ln;
      if (bit()) { room(1); out[n++] = src[p++]; continue; }                // 0C50 literal
      if (!bit()) {                                                         // 0C54 short match
        ln = ((bit() << 1) | bit()) + 2;
        span = src[p++] - 0x100;
      } else {                                                              // 0CB4 long match
        var lo = src[p], hi = src[p + 1]; p += 2;
        span = ((((hi >> 3) | 0xE0) << 8) | lo) - 0x10000;
        ln = hi & 7;
        if (ln) ln += 2;
        else {
          ln = src[p++];
          if (ln === 0) break;                                              // 0CE2..0CFE end of file
          if (ln === 1) { segs.push(n); continue; }                         // end of segment
          ln += 1;
        }
      }
      room(ln);
      for (var i = 0; i < ln; i++) { out[n] = out[n + span]; n++; }
    }
    return { data: out.subarray(0, n), segs: segs, used: p };
  }

  // PLAYER 0000:1006 RunSkipDump: dump 1..7F, run (00 n v), skip 81..FF, long op 80 w:
  // w=0 end, 1..7FFF skip, 8000.. dump, C000.. run. Returns the pointer after the end op.
  function runSkipDump(d, p, scr) {
    var di = 0, i, c, w, n, v;
    for (;;) {
      c = d[p++];
      if (c === 0) {
        n = d[p]; v = d[p + 1]; p += 2;
        for (i = 0; i < n; i++) scr[(di + i) & 0xFFFF] = v;
        di += n;
      } else if (c < 0x80) {
        for (i = 0; i < c; i++) scr[(di + i) & 0xFFFF] = d[p + i];
        p += c; di += c;
      } else if (c > 0x80) {
        di += c - 0x80;
      } else {
        w = d[p] | (d[p + 1] << 8); p += 2;
        if (w === 0) break;
        if (w < 0x8000) di += w;
        else if (w < 0xC000) {
          n = w - 0x8000;
          for (i = 0; i < n; i++) scr[(di + i) & 0xFFFF] = d[p + i];
          p += n; di += n;
        } else {
          n = w - 0xC000; v = d[p++];
          for (i = 0; i < n; i++) scr[(di + i) & 0xFFFF] = v;
          di += n;
        }
      }
      di &= 0xFFFF;
    }
    return p;
  }

  // PLAYER 0000:07EA draw_cel: optional 'Z' header (rate, N, size table, 768-byte palette; ticks/frame = 60/rate,
  // idiv 0821..082D), then 'B' 00 01 00 + RunSkipDump. A later cel may carry a new 'Z' (none of the 6 files does).
  function createPanPlayer(bytes) {
    var lz = lzUnpack(bytes), data = lz.data;
    var pl = {
      rate: 0, ticksPerFrame: 0, palette: new Uint8Array(768), table: [], count: 0, index: 0,
      screen: new Uint8Array(65536), unpacked: data.length, segments: lz.segs.length + 1,
      lastCelSize: 0, paletteChanged: false, pos: 0,
      step: function () {                       // draw next cel onto screen; false at end of stream
        if (pl.index >= pl.count && pl.count) return false;
        var p = pl.pos, start = p;
        if (p >= data.length) return false;
        pl.paletteChanged = false;
        if (data[p] === 0x5A) {
          pl.rate = data[p + 1];
          pl.ticksPerFrame = pl.rate ? Math.trunc(60 / pl.rate) : 0;
          var n = data[p + 2] | (data[p + 3] << 8);
          pl.count = n;
          pl.table = [];
          for (var i = 0; i < n; i++) pl.table.push(data[p + 4 + 2 * i] | (data[p + 5 + 2 * i] << 8));
          var pp = p + 4 + 2 * n;
          pl.palette.set(data.subarray(pp, pp + 768));
          pl.paletteChanged = true;
          p = pp + 768;
        }
        if (data[p] !== 0x42 || data[p + 1] !== 0 || data[p + 2] !== 1 || data[p + 3] !== 0)
          throw new Error('PAN: bad cel header at ' + p);
        p = runSkipDump(data, p + 4, pl.screen);
        pl.lastCelSize = p - start;
        pl.pos = p;
        pl.index++;
        return true;
      },
    };
    return pl;
  }

  var api = { lzUnpack: lzUnpack, runSkipDump: runSkipDump, createPanPlayer: createPanPlayer };
  if (typeof module !== 'undefined' && module.exports) module.exports = api;
  else { root.F117 = root.F117 || {}; root.F117.pan = api; }
})(typeof window !== 'undefined' ? window : globalThis);
