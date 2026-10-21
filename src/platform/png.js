// Indexed-PNG reader for assets/pic/*.png (task 1.1 decision: PICs ship as indexed PNGs).
// Browsers decode PNG to RGBA and lose the palette indices, so we parse the chunks ourselves and
// only borrow the inflate step: DecompressionStream('deflate') in browsers, zlib.inflateSync in Node tests.
// decodeIndexedPng(bytes, inflate?) -> Promise<{width, height, pixels: Uint8Array(w*h), palette: Uint8Array(768) 8-bit RGB}>
(function (root) {
  'use strict';

  function u32(b, o) { return ((b[o] << 24) | (b[o + 1] << 16) | (b[o + 2] << 8) | b[o + 3]) >>> 0; }

  async function browserInflate(data) {
    var ds = new DecompressionStream('deflate');   // zlib wrapper, as in PNG IDAT
    var stream = new Blob([data]).stream().pipeThrough(ds);
    return new Uint8Array(await new Response(stream).arrayBuffer());
  }

  function paeth(a, b, c) {
    var p = a + b - c, pa = Math.abs(p - a), pb = Math.abs(p - b), pc = Math.abs(p - c);
    return (pa <= pb && pa <= pc) ? a : (pb <= pc ? b : c);
  }

  // Undo PNG row filters in place-free fashion. bpp is bytes per pixel (1 for indexed, rounded up).
  function unfilter(raw, w, h, bitDepth) {
    var rowBytes = Math.ceil(w * bitDepth / 8), out = new Uint8Array(rowBytes * h);
    var pos = 0;
    for (var y = 0; y < h; y++) {
      var ft = raw[pos++], o = y * rowBytes, up = o - rowBytes;
      for (var x = 0; x < rowBytes; x++) {
        var v = raw[pos++], a = x > 0 ? out[o + x - 1] : 0;
        var b = y > 0 ? out[up + x] : 0, c = (x > 0 && y > 0) ? out[up + x - 1] : 0;
        switch (ft) {
          case 0: break;
          case 1: v += a; break;
          case 2: v += b; break;
          case 3: v += (a + b) >> 1; break;
          case 4: v += paeth(a, b, c); break;
          default: throw new Error('png: bad filter ' + ft);
        }
        out[o + x] = v & 255;
      }
    }
    return out;
  }

  function unpack(rows, w, h, bitDepth) {
    if (bitDepth === 8) return rows;
    var px = new Uint8Array(w * h), rowBytes = Math.ceil(w * bitDepth / 8), mask = (1 << bitDepth) - 1;
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        var bit = x * bitDepth, byte = rows[y * rowBytes + (bit >> 3)];
        px[y * w + x] = (byte >> (8 - bitDepth - (bit & 7))) & mask;   // MSB first
      }
    }
    return px;
  }

  async function decodeIndexedPng(bytes, inflate) {
    inflate = inflate || browserInflate;
    var sig = [137, 80, 78, 71, 13, 10, 26, 10];
    for (var i = 0; i < 8; i++) if (bytes[i] !== sig[i]) throw new Error('png: bad signature');
    var pos = 8, w = 0, h = 0, depth = 0, ctype = -1, interlace = 0, plte = null, idat = [], idatLen = 0;
    while (pos + 8 <= bytes.length) {
      var len = u32(bytes, pos), type = String.fromCharCode(bytes[pos + 4], bytes[pos + 5], bytes[pos + 6], bytes[pos + 7]);
      var d = pos + 8;
      if (type === 'IHDR') { w = u32(bytes, d); h = u32(bytes, d + 4); depth = bytes[d + 8]; ctype = bytes[d + 9]; interlace = bytes[d + 12]; }
      else if (type === 'PLTE') plte = bytes.subarray(d, d + len);
      else if (type === 'IDAT') { idat.push(bytes.subarray(d, d + len)); idatLen += len; }
      else if (type === 'IEND') break;
      pos = d + len + 4;   // skip CRC
    }
    if (ctype !== 3) throw new Error('png: not indexed (colour type ' + ctype + ')');
    if (interlace) throw new Error('png: interlaced not supported');
    if (depth !== 1 && depth !== 2 && depth !== 4 && depth !== 8) throw new Error('png: bit depth ' + depth);
    var comp = new Uint8Array(idatLen), o = 0;
    idat.forEach(function (c) { comp.set(c, o); o += c.length; });
    var raw = await inflate(comp);
    var pixels = unpack(unfilter(raw, w, h, depth), w, h, depth);
    var palette = new Uint8Array(768);
    if (plte) palette.set(plte.subarray(0, Math.min(768, plte.length)));
    return { width: w, height: h, pixels: pixels, palette: palette };
  }

  var api = { decodeIndexedPng: decodeIndexedPng };
  if (typeof module !== 'undefined' && module.exports) module.exports = api;
  else { root.F117 = root.F117 || {}; root.F117.png = api; }
})(typeof window !== 'undefined' ? window : globalThis);
