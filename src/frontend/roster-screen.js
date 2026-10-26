// START roster and pilot screens (task 2.4; decomp re/decomp/start/roster.md): 623E roster_screen, 615C roster_draw, 63FB hover,
// 64E5 pilot_details, 6861 roster_line, 6AB3 new_pilot (name entry), 6DB8 pilot_options + 71AD hover, 6A7C last_word.
// Rows are drawn once with palette index 0xFF-i and highlighted by patching that DAC entry (3517); the selected pilot uses 0x11C7.
(function (root) {
  'use strict';
  function mods() {
    if (typeof module !== 'undefined' && module.exports) return { R: require('../roster.js'), M: require('./menu.js') };
    return { R: root.F117.roster, M: root.F117.menu };
  }
  var RANKS = ['2nd Lt ', '1st Lt ', 'Capt ', 'Major ', 'Lt Col ', 'Col ', 'B Gen '];                 // ds:1D78
  var STATUS = ['Active', 'Retired', 'KIA'];                                                          // ds:0E40
  var OPPONENTS = ['Green Opponents', 'Regular Opponents', 'Veteran Opponents', 'Elite Opponents'];  // ds:931E
  var LANDINGS = ['No Crashes', 'Easy Landings', 'Realistic Landings'];                               // ds:94F0
  var PLANES = ['MicroProse F117A', 'Lockheed F117A'];                                                // ds:94AC
  var ROSTER_RECTS = [[28, 43, 292, 52], [28, 53, 292, 62], [28, 63, 292, 72], [28, 73, 292, 82], [28, 83, 292, 92], [28, 93, 292, 102],
    [28, 103, 292, 112], [28, 113, 292, 122], [28, 123, 292, 132], [28, 133, 292, 142], [269, 157, 302, 187]];       // ds:704E
  var OPTION_RECTS = [[195, 73, 247, 82], [195, 83, 247, 93], [248, 73, 300, 82], [248, 83, 300, 93], [195, 106, 300, 115],
    [195, 116, 300, 125], [195, 126, 300, 136], [195, 149, 300, 159], [195, 160, 300, 172], [195, 175, 300, 187]];   // ds:6FFA (11th is garbage)
  var MARK_X = [40, 40, 91, 91, 82, 82, 82, 82, 82], MARK_Y = [33, 43, 33, 43, 67, 76, 85, 110, 120];             // ds:0EA9 / 0EB3 (hotspot 1..9)
  var DLG = {
    changePilot: { text: 'Changing pilots will cancel your scheduled mission.', b1: 'OK', b2: 'No Way!', w: 0x94 },                // 710D
    deceased: { text: 'U.S. Air Force regulations prohibit deceased officers from flying multi-million dollar aircraft.  Please choose again or erase this entry.', b1: 'OK', b2: null, w: 0xA0 },   // 715F
    retired: { text: 'This officer has retired. Please choose again or erase this entry.', b1: 'OK', b2: null, w: 0x78 },     // 7244
    diskOriginal: { text: 'Original disk in drive. Roster file will not be saved.', b1: 'OK', b2: null, w: 0x78 },            // 729D
    diskProtected: { text: 'Disk is write protected. Roster file will not be saved.', b1: 'OK', b2: null, w: 0x78 }           // 72EA
  };

  // 6A7C: the last word of the name (scan back to the last space; index 0 stops the scan)
  function lastWord(name) {
    var i = name.length - 1;
    while (i > 0 && name[i] !== ' ') i--;
    if (i > 0) i++;
    return name.substr(Math.max(i, 0));
  }
  function ltoa(v) { return String(v >>> 0); }
  function dec(v) { return String((v << 16) >> 16); }

  // ctx: {ui, host, block, bios, roster, state}; state = {planeSel} (ds:D878/D879)
  function createRosterScreens(ctx) {
    var ui = ctx.ui, g = ctx.host.gfx, fb = ctx.host.fb, block = ctx.block, roster = ctx.roster;
    var X = mods(), R = X.R, COL = X.M.COL;
    var pr = block.pilot, vp0 = ui.vp[0], vp1 = ui.vp[1];
    var marker = null;                                                                                // ds:CABA, cut from requestr (74B1)
    function slot() { return R.pilotGet(pr, 'slot'); }
    function rec(i) { return roster.record(i); }
    function ask(dlg, x, y) { return ui.requester(dlg, x, y); }
    function clearanceRule() {                                                                        // 6324..6340
      if (block.get('clearance') === 0) { R.pilotSet(pr, 'theatre', 0); pr[0x3C] |= 2; }
    }

    // 6861 roster_line(slot, y); font/colour are those of VP 1 at the call
    function rosterLine(i, y) {
      var r = rec(i);
      g.blit(3, 0x1E, y, 1, 0x1E, y, 0x102, 8);
      var rank = RANKS[Math.min(R.pilotGet(r, 'rank'), 6)];
      ui.text(vp1, rank + R.pilotGet(r, 'name'), 0x1E, y);
      var s = ltoa(R.pilotGet(r, 'totalScore')); ui.text(vp1, s, 0xE0 - ui.textWidth(vp1, s), y);
      s = dec(R.pilotGet(r, 'missions')); ui.text(vp1, s, 0xF6 - ui.textWidth(vp1, s), y);
      s = STATUS[Math.min(R.pilotGet(r, 'status'), 2)];
      ui.text(vp1, s, 0xFD + Math.trunc((0x23 - ui.textWidth(vp1, s)) / 2), y);
    }

    // 615C roster_draw
    async function rosterDraw() {
      await ui.picLoad(12, 4);
      g.blit(1, 0, 0, 3, 0, 0, 320, 200);
      vp1.font = 1;
      for (var i = 0; i < 10; i++) { vp1.color = 0xFF - i; rosterLine(i, 0x2C + 10 * i); }
      vp1.font = 3; vp1.color = 0x1A;
      ui.textCentered(vp1, "Press 'Delete' key to erase a pilot", 0xA0, 0x90);
      ui.setColour(0xFF - slot(), COL.selected, 1);
      g.blit(1, 0x1E, 0x2C, 0, 0x1E, 0x2C, 0x10E, 0x6E);
      ui.setCursor(0xA0, 10 * slot() + 0x2F);
    }

    // 64E5 pilot_details(i): the panel (0x24,0x9F,0xE0x0x29) on page 1, then copied to the screen
    function pilotDetails(i) {
      var r = rec(i);
      vp1.font = 4; vp1.color = 1;
      ui.text(vp1, RANKS[Math.min(R.pilotGet(r, 'rank'), 6)] + lastWord(R.pilotGet(r, 'name')), 0x32, 0x9F);
      vp1.color = 0x1C;
      ui.text(vp1, 'Best Mission: ' + dec(R.pilotGet(r, 'bestScore')), 0x32, 0xA8);
      ui.text(vp1, 'Last Mission: ' + dec(R.pilotGet(r, 'lastScore')), 0x32, 0xB0);
      ui.text(vp1, OPPONENTS[R.pilotGet(r, 'opponents') & 3], 0xA2, 0xA0);
      ui.text(vp1, LANDINGS[Math.min(R.pilotGet(r, 'landings'), 2)], 0xA2, 0xA8);
      ui.text(vp1, PLANES[R.pilotGet(r, 'plane') & 1], 0xA2, 0xB0);
      var x = 0x24, medals = [['cmh', 'CMH', 0x98], ['dfc', 'DFC', 0xA0], ['afc', 'AFC', 0xA8], ['silverStars', 'SS', 0xB0],
        ['airmansMedals', 'AM', 0xB8], ['purpleHearts', 'PH', 0xC0]];
      for (var m = 0; m < medals.length; m++) {
        var n = R.pilotGet(r, medals[m][0]);
        if (!n) continue;
        g.blit(4, 0, medals[m][2], 1, x, 0xBF, 0x22, 8);
        ui.textCentered(vp1, medals[m][1] + ':' + dec(n), x + 0x11, 0xB8);
        x += 0x26;
      }
      g.blit(1, 0x24, 0x9F, 0, 0x24, 0x9F, 0xE0, 0x29);
    }

    // 63FB roster_hover
    function rosterHover() {
      var hot = ui.hitTest(ROSTER_RECTS), prev = ui.hoverPrev;
      if (prev !== 0 && hot !== prev) {
        if (prev - slot() !== 1) ui.setColour(0x100 - prev, COL.normal, 1);
        if (prev <= 10) { g.blit(3, 0x24, 0x9F, 1, 0x24, 0x9F, 0xE0, 0x29); g.blit(1, 0x24, 0x9F, 0, 0x24, 0x9F, 0xE0, 0x29); }
      }
      if (hot !== 0 && hot !== prev) {
        if (hot - slot() !== 1) ui.setColour(0x100 - hot, COL.hover, 1);
        if (hot <= 10) pilotDetails(hot - 1);
      }
      ui.hoverPrev = hot;
    }

    // 6AB3 new_pilot(i): name entry on row i; Enter creates the pilot (and makes it the current one), Esc leaves the row alone
    async function newPilot(i) {
      ui.restoreCursorBg();
      var y = 10 * i + 0x2C, buf = RANKS[0], start = buf.length, rowDraw = function () { g.blit(1, 0x1E, y, 0, 0x1E, y, 0x9E, 8); };
      vp1.color = 0xFF - i; vp1.font = 1;
      g.blit(3, 0x1E, y, 1, 0x1E, y, 0x9E, 8);
      ui.text(vp1, buf, 0x1E, y); g.textDraw(vp1, '_');
      rowDraw();
      for (;;) {
        var key;
        if (buf.length - start === 29 || ui.textWidth(vp1, buf) > 0x96) key = 0x0D;
        else {
          while (!ctx.host.keyReady()) await ctx.host.frame();
          key = ui.getKey() & 255;
        }
        if (key === 0x1B) break;
        if (key === 0x0D) { commit(i, buf.substr(start)); break; }
        if (key === 8) { if (buf.length > start) buf = buf.slice(0, -1); }
        else if (key >= 0x20 && key <= 0x7E) buf += String.fromCharCode(key);
        g.blit(3, 0x1E, y, 1, 0x1E, y, 0x9E, 8);
        ui.text(vp1, buf, 0x1E, y); g.textDraw(vp1, '_');
        rowDraw(); ctx.host.present();
      }
      rosterLine(i, y);
      g.blit(1, 0x1E, y, 0, 0x1E, y, 0x10E, 8);
      ctx.host.present();
    }
    function commit(i, name) {                                                                        // 6BD0
      ui.setColour(0xFF - slot(), COL.normal, 1);
      ui.setColour(0xFF - i, COL.selected, 1);
      var r = rec(i); r.fill(0);
      R.pilotSet(r, 'name', name); R.pilotSet(r, 'slot', i); R.pilotSet(r, 'war', 2); R.pilotSet(r, 'type', 3); R.pilotSet(r, 'status', 0);
      pr.set(r);
    }

    // 71AD options hover
    function optionsHover() {
      var hot = ui.hitTest(OPTION_RECTS), prev = ui.hoverPrev;
      if (prev !== 0 && hot !== prev) ui.setColour(0xF5 - prev, COL.option, 1);
      if (hot !== 0 && hot !== prev) ui.setColour(0xF5 - hot, COL.hover, 1);
      ui.hoverPrev = hot;
    }
    function markerAt(idx) { return [0xC0 + MARK_X[idx - 1], 0x28 + MARK_Y[idx - 1]]; }                 // hotspot index 1..9

    // 6DB8 pilot_options
    async function pilotOptions() {
      ui.restoreCursorBg();
      var savedHover = ui.hoverPrev, sx = ui.cur.x, sy = ui.cur.y;
      ui.hoverPrev = 0; ui.setCursor(0x103, 0xB4);
      ui.setColours(0xEB, new Array(30).fill(0));                                                      // 3517(0xEB, ds:67A4 = zeros, 10)
      if (!marker) marker = g.spriteGrab(2, 0x134, 0xB0, 12, 8);
      g.blit(1, 0xC0, 0x28, 4, 0x6F, 0, 0x6F, 0x98);
      g.blit(4, 0, 0, 1, 0xC0, 0x28, 0x6F, 0x98);
      function mark(idx) {
        var p = markerAt(idx);
        g.spriteDraw(vp1, p[0], p[1], 12, 8, marker, 0);
      }
      mark(R.pilotGet(pr, 'opponents') + 1); mark(R.pilotGet(pr, 'landings') + 5); mark(R.pilotGet(pr, 'plane') + 8);
      g.blit(1, 0xC0, 0x28, 0, 0xC0, 0x28, 0x6F, 0x98);
      // the pilot's name types itself onto the panel (6EE0..6F92)
      var s = RANKS[Math.min(R.pilotGet(pr, 'rank'), 6)] + lastWord(R.pilotGet(pr, 'name'));
      vp1.font = 3; vp0.font = 3; vp1.color = 0x1C; vp0.color = 0x1C;
      for (var i = 0; i < 50; i++) {
        await ui.delay(ctx.host.random(6) + 6);
        if (i >= s.length) break;
        var tmp = s.substr(0, i + 1);
        if (ui.textWidth(vp0, tmp) > 0x52) break;
        ctx.host.sound(0x21);
        ui.text(vp0, tmp, 0xD9, 0x37); ui.text(vp1, tmp, 0xD9, 0x37);
        ctx.host.present();
      }
      var desc = { hover: optionsHover, hotkey: 0, rects: OPTION_RECTS }, r, prevIdx = 0;
      for (;;) {
        r = await ui.menuWait(desc);
        if (r === 0x63 || r === 10) break;
        if (r >= 1 && r <= 4) { prevIdx = R.pilotGet(pr, 'opponents') + 1; R.pilotSet(pr, 'opponents', r - 1); }
        else if (r >= 5 && r <= 7) { prevIdx = R.pilotGet(pr, 'landings') + 5; R.pilotSet(pr, 'landings', r - 5); }
        else if (r === 8 || r === 9) {
          prevIdx = R.pilotGet(pr, 'plane') + 8; R.pilotSet(pr, 'plane', r - 8);
          var t = R.pilotGet(pr, 'type');
          if (r - 8 !== 0 && (t === 0 || t === 2)) R.pilotSet(pr, 'type', t + 1);                      // Lockheed: strike missions only
        }
        if (r < 10) {
          var o = markerAt(prevIdx);
          g.blit(4, o[0] - 0xC0, o[1] - 0x28, 1, o[0], o[1], 12, 8); g.blit(4, o[0] - 0xC0, o[1] - 0x28, 0, o[0], o[1], 12, 8);
          ctx.host.sound(0x1B);
          var n = markerAt(r);
          g.spriteDraw(vp1, n[0], n[1], 12, 8, marker, 0); g.spriteDraw(vp0, n[0], n[1], 12, 8, marker, 0);
        }
      }
      g.blit(4, 0x6F, 0, 1, 0xC0, 0x28, 0x6F, 0x98); g.blit(4, 0x6F, 0, 0, 0xC0, 0x28, 0x6F, 0x98);
      ui.hoverPrev = savedHover;
      if (r === 0x63) { pr.set(rec(slot())); ui.setCursor(sx, sy); }
      else { rec(slot()).set(pr); ui.setCursor(0x129, 0xB6); }
      ctx.host.present();
    }

    // 623E roster_screen: returns 0
    async function rosterScreen() {
      ctx.bios.firstEntry = 0;
      var desc = { hover: rosterHover, hotkey: 0x62, rects: ROSTER_RECTS };
      await ui.screenEnter(7, rosterDraw);
      for (;;) {
        var r = await ui.menuWait(desc);
        if (r >= 1 && r <= 10) {
          var status = R.pilotGet(rec(r - 1), 'status');
          if (status === 1) { await ask(DLG.retired, 0x56, 0x46); continue; }
          if (status === 2) { await ask(DLG.deceased, 0x56, 0x46); continue; }
          if (ui.missionScheduled && await ask(DLG.changePilot, 0x56, 0x46) === 2) continue;
          ui.missionScheduled = 0;
          ui.setColour(0xFF - slot(), COL.normal, 1);
          if (slot() < 10) rec(slot()).set(pr);
          pr.set(rec(r - 1)); R.pilotSet(pr, 'slot', r - 1);
          clearanceRule();
          ui.setColour(0x100 - r, COL.selected, 1);
          await pilotOptions();
        } else if (r === 11 || r === 0x63) {
          ui.restoreCursorBg();
          var st = R.pilotGet(pr, 'status');
          if (st !== 0) { await ask(st === 1 ? DLG.retired : DLG.deceased, 0x56, 0x46); continue; }
          ctx.state.planeSel = pr[0x42];
          if (!roster.save(pr)) await ask(DLG.diskProtected, 0x56, 0x46);
          return 0;
        } else if (r === 0x162) {
          var h = ui.hitTest(ROSTER_RECTS);
          if (h < 1 || h > 10) continue;
          if (ui.missionScheduled && await ask(DLG.changePilot, 0x56, 0x46) === 2) continue;
          await newPilot(h - 1);
          ui.missionScheduled = 0;
        }
      }
    }

    return { rosterScreen: rosterScreen, rosterLine: rosterLine, pilotDetails: pilotDetails, newPilot: newPilot, pilotOptions: pilotOptions,
      rosterHover: rosterHover, optionsHover: optionsHover, DLG: DLG };
  }

  var api = { createRosterScreens: createRosterScreens, lastWord: lastWord, RANKS: RANKS, ROSTER_RECTS: ROSTER_RECTS, OPTION_RECTS: OPTION_RECTS,
    DLG: DLG, MARK_X: MARK_X, MARK_Y: MARK_Y };
  if (typeof module !== 'undefined' && module.exports) module.exports = api;
  else { root.F117 = root.F117 || {}; root.F117.rosterScreen = api; }
})(typeof window !== 'undefined' ? window : globalThis);
