// ROSTER.FIL (task 2.1; decomp re/decomp/flow/flow.md): 2-byte header (selected slot) + 10 pilot records of 80 bytes = 802 bytes.
// Persisted byte-exact as base64 in a Storage (localStorage). load = START 0000:7218, save = 7272, sync = 6D07 (roster_sync).
(function (root) {
  'use strict';
  var REC = 0x50, N = 10, FILE_SIZE = 2 + N * REC;
  var KEY = 'f117-rea.ROSTER.FIL';

  // pilot record fields (start-map.md sec. 3): name: [offset, kind, count]
  var PILOT = {
    slot: [0x00, 'w'], name: [0x02, 'str', 30], rank: [0x20, 'w'], purpleHearts: [0x22, 'w'], airmansMedals: [0x24, 'w'],
    dfc: [0x26, 'w'], silverStars: [0x28, 'w'], afc: [0x2A, 'w'], cmh: [0x2C, 'w'], bestScore: [0x2E, 'w'], lastScore: [0x30, 'w'],
    totalScore: [0x32, 'd'], missions: [0x36, 'w'], theatre: [0x38, 'w'], war: [0x3A, 'w'], type: [0x3C, 'w'], opponents: [0x3E, 'w'],
    landings: [0x40, 'w'], plane: [0x42, 'w'], ribbonCombat: [0x44, 'w'], ribbonShort: [0x46, 'w'], ribbonLong: [0x48, 'w'],
    ribbonLongevity: [0x4A, 'w'], ribbonGold: [0x4C, 'w'], status: [0x4E, 'w']
  };

  function pilotGet(rec, name) {
    var d = PILOT[name], o = d[0];
    if (d[1] === 'w') return rec[o] | (rec[o + 1] << 8);
    if (d[1] === 'd') return (rec[o] | (rec[o + 1] << 8) | (rec[o + 2] << 16) | (rec[o + 3] << 24)) >>> 0;
    var s = ''; for (var k = 0; k < d[2] && rec[o + k]; k++) s += String.fromCharCode(rec[o + k]); return s;
  }
  function pilotSet(rec, name, v) {
    var d = PILOT[name], o = d[0];
    if (d[1] === 'w') { rec[o] = v & 0xFF; rec[o + 1] = (v >> 8) & 0xFF; }
    else if (d[1] === 'd') { for (var k = 0; k < 4; k++) rec[o + k] = (v >>> (8 * k)) & 0xFF; }
    else { rec.fill(0, o, o + d[2]); for (var j = 0; j < v.length && j < d[2] - 1; j++) rec[o + j] = v.charCodeAt(j) & 0xFF; }
  }

  function b64enc(u8) { var s = ''; for (var i = 0; i < u8.length; i++) s += String.fromCharCode(u8[i]); return btoa(s); }
  function b64dec(s) { var bin = atob(s), out = new Uint8Array(bin.length); for (var i = 0; i < bin.length; i++) out[i] = bin.charCodeAt(i); return out; }

  // storage: {getItem, setItem} (localStorage-like; missing/throwing storage = memory only)
  // seed: bytes of the shipped ROSTER.FIL used when nothing has been saved yet (the original reads the file from disk)
  function createRoster(opts) {
    opts = opts || {};
    var storage = opts.storage || null, seed = opts.seed || null;
    var hdr = 0;                          // ds:B39C (word)
    var recs = new Uint8Array(N * REC);   // ds:D892..
    var r = {
      get header() { return hdr; },
      record: function (i) { return recs.subarray(i * REC, (i + 1) * REC); },
      toBytes: function () { var o = new Uint8Array(FILE_SIZE); o[0] = hdr & 0xFF; o[1] = hdr >> 8; o.set(recs, 2); return o; },
      fromBytes: function (b) { hdr = b[0] | (b[1] << 8); recs.set(b.subarray(2, FILE_SIZE)); },

      // 0000:7218
      load: function () {
        var b = null;
        try { var s = storage && storage.getItem(KEY); if (s) b = b64dec(s); } catch (e) { b = null; }
        if (!b || b.length !== FILE_SIZE) b = seed && seed.length === FILE_SIZE ? seed : null;
        if (b) r.fromBytes(b);
        return r;
      },
      // 0000:7272(silent): header low byte = PR.slot, then the whole file
      save: function (pr) {
        hdr = (hdr & 0xFF00) | (pilotGet(pr, 'slot') & 0xFF);
        try { if (storage) storage.setItem(KEY, b64enc(r.toBytes())); return true; } catch (e) { return false; }
      },
      // 0000:6D07 roster_sync(block, bios): bios.firstEntry = word 0:04F2
      sync: function (block, bios) {
        var i, rec, pr = block.pilot;
        r.load();
        for (i = 0; i < N; i++) {
          recs[0x42] &= 1; recs[0x43] = 0;                     // and word [D8D4],1 : always record 0 (compiler quirk)
          rec = r.record(i);
          if (pilotGet(rec, 'plane') !== 0) {
            var t = pilotGet(rec, 'type');
            if (t === 0 || t === 2) pilotSet(rec, 'type', t + 1);
          }
        }
        if (bios.firstEntry !== 0) pr.set(r.record(hdr & 0xFF));                       // mul byte [B39C]
        else if (pilotGet(pr, 'slot') < N) r.record(pilotGet(pr, 'slot')).set(pr);     // mul word [PR]; out of range = DGROUP overwrite, ignored
        if (block.get('clearance') === 0) {
          pilotSet(pr, 'theatre', 0);
          pr[0x3C] |= 2;
        }
        r.save(pr);
        return r;
      }
    };
    return r;
  }

  var api = { createRoster: createRoster, pilotGet: pilotGet, pilotSet: pilotSet, PILOT: PILOT, REC: REC, N: N, FILE_SIZE: FILE_SIZE, KEY: KEY };
  if (typeof module !== 'undefined' && module.exports) module.exports = api;
  else { root.F117 = root.F117 || {}; root.F117.roster = api; }
})(typeof window !== 'undefined' ? window : globalThis);
