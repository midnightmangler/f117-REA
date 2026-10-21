// World data loader (task 1.3 decision: WLD/3DX/3DG/3DT ship pre-parsed as assets/world/<CODE>.json, see NOTES Decisions).
// loadWorld(code, readJson) -> Promise<{region, wld, x3d, grid, props}>; readJson(path) is supplied by the host
// (fetch in the browser, fs in tests), so this file holds no I/O.
(function (root) {
  'use strict';

  var REGIONS = ['CE', 'CU', 'KO', 'KU', 'LB', 'ME', 'NC', 'PG', 'VN'];   // the 9 theatre files
  var EXTRA = ['PHOTO', 'STFLT'];                                         // shipped beside them (0.2)
  var cache = {};

  function loadWorld(code, readJson) {
    code = String(code).toUpperCase();
    if (REGIONS.indexOf(code) < 0 && EXTRA.indexOf(code) < 0) return Promise.reject(new Error('world: unknown region ' + code));
    if (!cache[code]) cache[code] = Promise.resolve(readJson('assets/world/' + code + '.json'));
    return cache[code];
  }

  var api = { REGIONS: REGIONS, EXTRA: EXTRA, loadWorld: loadWorld };
  if (typeof module !== 'undefined' && module.exports) module.exports = api;
  else { root.F117 = root.F117 || {}; root.F117.world = api; }
})(typeof window !== 'undefined' ? window : globalThis);
