// START front-end toolkit (task 2.4): the generic menu machinery of START.EXE (start-map.md 2.1) on top of the MGRAPHIC port.
// Addresses are START 0A95:0000 listing offsets. Pages: 0 screen, 1 clean picture + restored background, 2 requester art,
// 3 backup copy of the screen art, 4 sprite sheet of the current screen. DAC colour patches are queued (3517) and applied on the next
// frame (8427). host = {fb, gfx, assets, png, frame(), present(), pollKey(), keyReady(), pointer, sound(id), random(n), ticksMs()}.
(function (root) {
  'use strict';
  var PIC_NAMES = ['air_id', 'armsscrn', 'brefscrn', 'folder1', 'hangscrn', 'homescrn', 'ordrscrn', 'rostscrn', 'breficon', 'folder2',
    'ordrsprt', 'requestr', 'rostsprt', 'weapons1', 'weapons2', 'weapons3', 'libya', 'persian', 'n_cape', 'c_europe', 'vietnam',
    'mid_east', 'kuwait', 'cuba', 'korea', 'planes1', 'planes2', 'planes3', 'planes4', 'planes5', 'hangsprt', 'adv', 'climbin'];   // ds:0CBA
  var COL = { normal: [0x0A, 0x12, 0x0F], hover: [0x3F, 0x00, 0x00], selected: [0x3E, 0x29, 0x1B], option: [0x1F, 0x29, 0x24],
    btnNormal: [0x39, 0x3C, 0x3B], btnHover: [0x3F, 0x32, 0x2B] };                                   // ds:11CD 11C1 11C7 11D0 11C4 11BE
  var FADE_MS = 4 * 1000 / 18.2065;                                                                  // 30A0: ~4 BIOS ticks per speed unit

  function StartExit(code) { this.code = code; }

  function makeVp(page) { return { page: page, flags: 0, color: 0, bg: 0, x: 0, y: 0, font: 0, top: 0, bottom: 199, left: 0, right: 319 }; }   // 7417
  function i16(v) { return (v << 16) >> 16; }

  function createUi(host) {
    var fb = host.fb, g = host.gfx;
    var vp = [0, 1, 2, 3, 4].map(makeVp);
    var cur = { x: 0, y: 0, oldX: 0, oldY: 0, w: 0, h: 0, sprite: null };                           // ds:E08A/E08C, E08E/E090, E092/E093, E088
    var pal = new Uint8Array(768);                                                                  // ds:64E3 current palette (6-bit)
    var queue = [];                                                                                 // ds:64A6 colour patches
    var prevKey = 0;                                                                                // ds:B306
    var ui = { vp: vp, cur: cur, pal: pal, hoverPrev: 0, missionScheduled: 0, exitCode: null };     // hoverPrev = ds:D096, missionScheduled = ds:D2A2

    // ---- timing ----
    ui.frame = async function () {                                                                  // 8427: wait one 70 Hz tick, apply patches
      await host.frame();
      while (queue.length) { var q = queue.shift(); fb.setPalette(q.rgb, q.first, q.rgb.length / 3); }
    };
    ui.delay = async function (n) { while (n-- > 0) await ui.frame(); };                           // 2B06

    // ---- colours ----
    ui.setColour = function (index, rgb, count) {                                                   // 3517(index, ptr, count)
      var a = []; for (var i = 0; i < (count || 1); i++) a.push(rgb[0], rgb[1], rgb[2]);
      queue.push({ first: index & 255, rgb: Uint8Array.from(a) });
    };
    ui.setColours = function (index, rgbFlat) { queue.push({ first: index, rgb: Uint8Array.from(rgbFlat) }); };

    // ---- pictures (35FC / 826C / 3641) ----
    ui.picLoad = async function (pic, page) {                                                       // 35FC + 826C
      var bytes = await host.assets.bytes('pic/' + PIC_NAMES[pic].toUpperCase() + '.png');
      var img = await host.png.decodeIndexedPng(bytes);
      fb.clear(page, 0); fb.putImage(page, img);
      return img;
    };
    ui.palette = async function (pic) {                                                             // 826C: PALETTES.PAL:min(pic,8)
      var all = await host.assets.json('palettes.json');
      pal.set(all.palettes['PALETTES.PAL:' + Math.min(pic, 8)]);
    };
    function scaled(f) { var o = new Uint8Array(768); for (var i = 0; i < 768; i++) o[i] = Math.round(pal[i] * f); return o; }
    ui.fade = async function (dirIn, speed) {                                                       // 3070 / 3088 -> 30A0
      var dur = FADE_MS * (speed || 1), t0 = host.ticksMs(), f;
      do { f = Math.min(1, (host.ticksMs() - t0) / dur); fb.setPalette(scaled(dirIn ? f : 1 - f), 0, 256); host.present(); await host.frame(); } while (f < 1);
    };
    ui.screenEnter = async function (pic, drawcb) {                                                 // 3641
      await ui.fade(false, 1);
      await ui.picLoad(pic, 1); await ui.palette(pic);
      fb.copyPage(1, 0);
      if (drawcb) await drawcb();
      host.present();
      await ui.fade(true, 1);
    };

    // ---- cursor (3E20 / 3E84 / 3989 / 3C42..3C8D) ----
    ui.initCursor = function () {                                                                   // 74B1: sprite cut from requestr (page 2)
      cur.sprite = g.spriteGrab(2, 0x135, 0xB8, 11, 16);
      cur.w = cur.sprite[0]; cur.h = cur.sprite[2];                                                 // e092 = width byte, e093 = height byte
      cur.x = cur.y = cur.oldX = cur.oldY = 0;
    };
    ui.setCursor = function (x, y) {                                                                // 3E84 (+ INT 33h set position, 85A7)
      cur.x = x; cur.y = y;
      if (host.pointer && host.pointer.set) host.pointer.set(x, y);
    };
    ui.restoreCursorBg = function () { g.blit(1, cur.oldX, cur.oldY, 0, cur.oldX, cur.oldY, cur.w, cur.h); };   // 3989
    function drawCursor() {
      g.blit(1, cur.oldX, cur.oldY, 0, cur.oldX, cur.oldY, cur.w, cur.h);
      g.spriteDraw(vp[0], cur.x, cur.y, cur.sprite[0] | (cur.sprite[1] << 8), cur.sprite[2] | (cur.sprite[3] << 8), cur.sprite, 0);
      cur.oldX = cur.x; cur.oldY = cur.y;
    }

    // ---- hit test (393D) / descriptors ----
    // desc = {hover: fn|null, hotkey: byte, rects: [[x0,y0,x1,y1] ...]} (ds layout: +0 hover, +2 hotkey, +3 count, +4 rects)
    ui.hitTest = function (rects) {
      for (var i = 0; i < rects.length; i++) {
        var r = rects[i];
        if (r[0] <= cur.x && r[2] >= cur.x && r[1] <= cur.y && r[3] >= cur.y) return i + 1;       // unsigned compares in the original
      }
      return 0;
    };
    function dist(x1, y1, x2, y2) {                                                                 // 8BEA
      var a = Math.abs(x1 - x2), b = Math.abs(y1 - y2);
      return a < b ? (a >> 2) + b : a + (b >> 2);
    }
    function jumpCursor(desc, key) {                                                                // 39F7 3AE9..3BFE
      var best = 1000, bx = -1, by = 0;
      for (var i = 0; i < desc.rects.length; i++) {
        var r = desc.rects[i], cx = (r[0] + r[2]) >> 1, cy = (r[1] + r[3]) >> 1, ok = false;
        if (key === 0x4800 || key === 0x5000) {
          if (key === 0x4800 ? cur.y > cy : cur.y < cy) ok = Math.abs(cy - cur.y) >= Math.abs(cur.x - cx);
        } else if (key === 0x4B00 || key === 0x4D00) {
          if (key === 0x4B00 ? cur.x > cx : cur.x < cx) ok = Math.abs(cur.y - cy) <= Math.abs(cx - cur.x);
        }
        if (ok) { var d = dist(cur.x, cur.y, cx, cy); if (d < best) { best = d; bx = cx; by = cy; } }
      }
      if (bx !== -1) { cur.x = bx; cur.y = by; }
    }

    // misc driver get_key (T:02E1): the ASCII byte when there is one, else scan<<8 (Alt-Q 0x1000, arrows 0x4800.., Delete 0x5300)
    ui.getKey = function () { var k = host.pollKey(); return (k & 255) ? (k & 255) : k; };

    // ---- input (39F7): 0 none, 1 Selector, 2 Escape, 0x62 Delete/Backspace, else the key word ----
    async function readInput(desc) {
      var key = 0, p = host.pointer;
      if (p && p.present) { cur.x = p.x; cur.y = p.y; }
      if (host.keyReady()) key = ui.getKey();
      else if (p && p.present) { if (p.b0) key = 0x0D; else if (p.b1) key = 0x1B; }
      if (key === 0x1000) { await ui.quitScreen(); }
      else if (key === 0x4800 || key === 0x4B00 || key === 0x4D00 || key === 0x5000) jumpCursor(desc, key);
      cur.x = Math.max(0, Math.min(319, cur.x)); cur.y = Math.max(0, Math.min(199, cur.y));          // clamp to VP 1 (3C01..3C22)
      drawCursor();
      var ret = 0;
      if (key === 0x5300 || key === 0x08) ret = 0x62;
      else if (key === 0x0D && prevKey !== 0x0D) ret = 1;
      else if (key === 0x1B && prevKey !== 0x1B) ret = 2;
      prevKey = key;
      return ret || key;
    }
    ui.menuWait = async function (desc) {                                                           // 38AC
      var result = 0;
      while (result === 0) {
        await ui.frame();
        if (desc.hover) desc.hover();
        var k = await readInput(desc);
        host.present();
        var al = k & 255;
        if (al === 0) continue;
        if (al === 1) { result = ui.hitTest(desc.rects); host.sound(result ? 0x1A : 0x22); }
        else if (al === 2) { result = 0x63; host.sound(0x23); }
        else if (desc.hotkey && desc.hotkey === al) result = al + 0x100;
      }
      return result;
    };

    // ---- text (3567 / 36C4 / 373C / 2A84 / 3776) ----
    ui.text = function (v, str, x, y) { v.x = x; v.y = y; g.textDraw(v, str); };                    // 3567
    ui.textWidth = function (v, str) { var w = 0; for (var i = 0; i < str.length; i++) w += g.charWidth(str.charCodeAt(i), v.font); return w; };   // 373C
    ui.textShadow = function (v, str, x, y) {                                                       // 36C4: drop shadow in the bg colour unless bg == -1
      if (v.bg !== -1) {
        var l = { page: v.page, flags: v.flags, color: v.bg, bg: v.bg, x: 0, y: 0, font: v.font, top: v.top, bottom: v.bottom, left: v.left, right: v.right };
        ui.text(l, str, x + 1, y + 1); ui.text(l, str, x, y + 1); ui.text(l, str, x + 1, y);
      }
      ui.text(v, str, x, y);
    };
    ui.textCentered = function (v, str, cx, y) { ui.text(v, str, cx - (ui.textWidth(v, str) >> 1), y); };   // 2A84 (sar: floor)
    // 3776: word wrap into maxW; v.page === -1 only measures. Returns the widest line; v.y ends below the last line.
    ui.wrapText = function (v, str, x, y, maxW, adv, center) {
      var start = 0, widest = 0; v.y = y;
      for (;;) {
        var p = start, w = 0, n = 0, c;
        while (w <= maxW && p < str.length && str[p] !== '\n') { w += g.charWidth(str.charCodeAt(p), v.font); p++; n++; }
        var last = false;
        if (w > maxW) {
          p--; n--;
          while (str[p] !== ' ' && p < str.length && str[p] !== '\n' && str[p] !== '-' && p > 0) { p--; n--; }   // bound = string start (37F0)
        }
        c = str[p];
        if (c === '-') n++;
        if (p >= str.length) last = true;
        if (n !== 0) {
          var line = str.substr(start, n), lw = ui.textWidth(v, line);
          if (lw > widest) widest = lw;
          if (v.page !== -1) { var lx = center ? ((maxW - lw) >> 1) + x : x; v.x = lx; ui.textShadow(v, line, lx, v.y); }
          v.y += adv;
        } else if (c === '\n') v.y += adv;
        start = p + 1;
        if (last) return widest;
      }
    };

    // ---- requester (3CEA / 332E / 2DF2 / 2CB4 / 2AB4) ----
    function fillRect(v, x1, y1, x2, y2) { var s = g.pageTable[v.page]; for (var y = y1; y <= y2; y++) for (var x = x1; x <= x2; x++) s[y * 320 + x] = v.color; }   // 8A32
    function frame2(v, X, Y, W, H) {                                                                // 2CB4: 2x2 corners from the sheet corner, coloured edges
      g.blit(2, 0, 0, v.page, X, Y, 2, 2); g.blit(2, 2, 0, v.page, X + W - 2, Y, 2, 2);
      g.blit(2, 0, 2, v.page, X, Y + H - 2, 2, 2); g.blit(2, 2, 2, v.page, X + W - 2, Y + H - 2, 2, 2);
      v.color = 0xE0; fillRect(v, X + 2, Y, X + W - 3, Y + 1);
      v.color = 0xE6; fillRect(v, X + 2, Y + H - 2, X + W - 3, Y + H - 1);
      v.color = 0xE1; fillRect(v, X, Y + 2, X + 1, Y + H - 3);
      v.color = 0xE5; fillRect(v, X + W - 2, Y + 2, X + W - 1, Y + H - 3);
      v.color = 0xE2; fillRect(v, X + 2, Y + 2, X + W - 3, Y + H - 3);
    }
    function button(v, str, cx, y, colour) {                                                        // 2DF2
      v.font = 1;
      var w = ui.textWidth(v, str) + 8, x = cx - (w >> 1);
      frame2(v, x, y, w, 0x10);
      v.color = colour; ui.textShadow(v, str, x + 4, y + 4);
      return w;
    }
    // dlg = {text, b1, b2|null, w}: layout as 332E; returns {W,H,rects,btnY}
    function layout(dlg, X, Y) {
      var v = vp[2], m = { page: -1, flags: 0, color: 0, bg: 8, x: 0, y: 0, font: 4, top: 0, bottom: 199, left: 0, right: 319 };
      v.font = 4; v.color = 0xF; v.bg = 8;
      ui.wrapText(m, dlg.text, 0, 0, dlg.w - 12, 8, 0);
      var W = dlg.w, H = m.y + 0x1A, by = m.y;
      frame2(v, 0, 4, W, H);
      v.color = 0xF; v.bg = 8; v.font = 4;
      ui.wrapText(v, dlg.text, 6, 8, W - 12, 8, 1);
      var c1, c2;
      if (dlg.b2) { c1 = Math.floor((W - 4) / 3) + 2; c2 = Math.floor(((W - 4) * 2) / 3) + 2; } else c1 = ((W - 4) >> 1) + 2;
      var rects = [], w1 = button(v, dlg.b1, c1, by + 10, 0xE8), h1 = w1 >> 1;
      rects.push([X + c1 - h1, Y + by + 6, X + c1 + h1, Y + by + 22]);
      if (dlg.b2) { var w2 = button(v, dlg.b2, c2, by + 10, 0xE7), h2 = w2 >> 1; rects.push([X + c2 - h2, Y + by + 6, X + c2 + h2, Y + by + 22]); }
      g.blit(1, X, Y, 2, 0, H + 4, W, H);                                                           // save the background below the art
      g.blit(2, 0, 4, 1, X, Y, W, H); g.blit(2, 0, 4, 0, X, Y, W, H);
      return { W: W, H: H, rects: rects };
    }
    ui.requester = async function (dlg, X, Y) {                                                     // 3CEA
      var savedHover = ui.hoverPrev, sx = cur.x, sy = cur.y;
      ui.setColour(0xE7, COL.btnNormal, 1); ui.setColour(0xE8, COL.btnNormal, 1);
      await ui.frame();
      var L = layout(dlg, X, Y);
      var desc = { hotkey: 0, rects: L.rects, hover: function () {                                // 3DA2
        var hot = ui.hitTest(L.rects);
        if (hot) { var other = hot === 1 ? 2 : 1;
          ui.setColour(hot === 1 ? 0xE8 : 0xE7, COL.btnHover, 1);
          if (other <= L.rects.length) ui.setColour(other === 1 ? 0xE8 : 0xE7, COL.btnNormal, 1); }
        else { ui.setColour(0xE7, COL.btnNormal, 1); ui.setColour(0xE8, COL.btnNormal, 1); }
        ui.hoverPrev = hot;
      } };
      ui.setCursor(L.rects[0][2] - 3, L.rects[0][3] - 3);
      var r;
      do { r = await ui.menuWait(desc); } while (r === 0x63);
      await ui.delay(6);
      g.blit(2, 0, L.H + 4, 1, X, Y, L.W, L.H); g.blit(2, 0, L.H + 4, 0, X, Y, L.W, L.H);          // 2AB4
      ui.hoverPrev = savedHover; ui.setCursor(sx, sy);
      host.present();
      return r;
    };

    // ---- Alt-Q quit screen (7611) ----
    ui.quitScreen = async function () {
      host.sound(0);
      var saved = Uint8Array.from(pal);
      await ui.fade(false, 1);
      await ui.picLoad(31, 0);
      pal.set((await host.assets.json('palettes.json')).palettes['ADV.PAL']);
      await ui.fade(true, 1);
      var k;
      do { while (!host.keyReady()) await host.frame(); k = ui.getKey(); } while (!k);
      if ((k & 0x5F) === 0x59) throw new StartExit(0);
      await ui.fade(false, 1);
      fb.copyPage(1, 0); pal.set(saved);
      host.present();
      await ui.fade(true, 1);
    };

    return ui;
  }

  var api = { createUi: createUi, StartExit: StartExit, PIC_NAMES: PIC_NAMES, COL: COL, makeVp: makeVp, i16: i16 };
  if (typeof module !== 'undefined' && module.exports) module.exports = api;
  else { root.F117 = root.F117 || {}; root.F117.menu = api; }
})(typeof window !== 'undefined' ? window : globalThis);
