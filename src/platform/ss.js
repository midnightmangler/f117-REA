// "MADSS1" sprite-series decoder (task 1.3). Source: MPS_LOGO.EXE SPRITES.C, re/docs/format-ss.md, ref re/tools/ss.py.
// parseSs(bytes) -> series; drawSprite(series, i, screen) draws sprite i (0-based) at its own x,y onto a 320x200
// page (64000 bytes) without clearing, as MPS_LOGO does (006D:05BE inner loop 0650..06DD). Pixel value v -> DAC base+v-1.
(function (root) {
  'use strict';

  var TYPE_BASE = [0x01, 0x51, 0x1F, 0x38, 0x1F, 0x01];   // MPS_LOGO ds:004A, indexed by series type 0..5

  function u16(b, o) { return b[o] | (b[o + 1] << 8); }
  function u32(b, o) { return (b[o] | (b[o + 1] << 8) | (b[o + 2] << 16) | (b[o + 3] << 24)) >>> 0; }

  // series_load 006D:0112: header 0x00..0x1E, 14-byte records, ncol, 4-byte palette entries (R,G,B,flag), RLE data.
  function parseSs(b) {
    var magic = String.fromCharCode.apply(null, b.subarray(0, 6));
    if (magic !== 'MADSS1' || b[6] !== 0x1A) throw new Error('SS: not MADSS1');   // error 2
    var name = '';
    for (var k = 7; k < 16 && b[k]; k++) name += String.fromCharCode(b[k]);
    var count = u16(b, 0x14), dataSize = u32(b, 0x16), type = b[0x1E];
    if (type < 1 || type > 5) throw new Error('SS: bad type ' + type);            // error 7 (02C0..02D6)
    var p = 0x1F, frames = [];
    for (var i = 0; i < count; i++, p += 14)
      frames.push({ off: u32(b, p), delay: u16(b, p + 4), x: u16(b, p + 6), y: u16(b, p + 8),
                    w: u16(b, p + 10), h: u16(b, p + 12) });                       // w,h stored minus one
    var ncol = b[p++], palette = [];
    for (i = 0; i < ncol; i++, p += 4) palette.push([b[p], b[p + 1], b[p + 2], b[p + 3]]);
    var base = TYPE_BASE[type];
    var dac = new Uint8Array(768);            // 6-bit DAC values, entry i at index base+i (04D2..0519)
    for (i = 0; i < ncol; i++) { dac[3 * (base + i)] = palette[i][0]; dac[3 * (base + i) + 1] = palette[i][1]; dac[3 * (base + i) + 2] = palette[i][2]; }
    return { name: name, count: count, type: type, base: base, frames: frames, palette: palette, dac: dac,
             data: b.subarray(p, p + dataSize), dataOffset: p };
  }

  // Row RLE: FE = end of row, FF = end of sprite, FA = literal row (FC skip 1, FD n v run, else pixel),
  // any other mode byte = run row of (n v) pairs until FE; v = FC means transparent (skip n).
  function drawSprite(s, i, screen) {
    var f = s.frames[i], d = s.data, p = f.off, x = 0, y = 0, m, n, v, b, k;
    var ox = f.x, oy = f.y, base = s.base - 1;
    function put(px, py, val) {
      var X = ox + px, Y = oy + py;
      if (X >= 0 && X < 320 && Y >= 0 && Y < 200) screen[Y * 320 + X] = (base + val) & 255;
    }
    function run(cnt, val) {
      if (val !== 0xFC) for (k = 0; k < cnt; k++) put(x + k, y, val);
      x += cnt;
    }
    for (;;) {
      m = d[p++];
      if (m === 0xFE) { y++; x = 0; continue; }
      if (m === 0xFF) break;
      if (m === 0xFA) {
        for (;;) {
          b = d[p++];
          if (b === 0xFE) break;
          if (b === 0xFD) { n = d[p]; v = d[p + 1]; p += 2; run(n, v); }
          else if (b === 0xFC) x++;
          else { put(x, y, b); x++; }
        }
      } else {
        for (;;) {
          n = d[p++];
          if (n === 0xFE) break;
          v = d[p++]; run(n, v);
        }
      }
      y++; x = 0;
    }
  }

  var api = { parseSs: parseSs, drawSprite: drawSprite, TYPE_BASE: TYPE_BASE };
  if (typeof module !== 'undefined' && module.exports) module.exports = api;
  else { root.F117 = root.F117 || {}; root.F117.ss = api; }
})(typeof window !== 'undefined' ? window : globalThis);
