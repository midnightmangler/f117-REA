// Asset access. The bundled build (tools/bundle.py) inlines every file of assets/ as base64 in window.F117_ASSETS
// (decision 2026-10-21: inline delivery to the iPad). Unbundled (index.src.html over http) it falls back to fetch.
// F117.assets.bytes('sound/ASOUND.117') -> Promise<Uint8Array>; .json(path) -> Promise<object>.
(function (root) {
  'use strict';
  var inline = root.F117_ASSETS || null;

  function b64(s) {
    var bin = atob(s), out = new Uint8Array(bin.length);
    for (var i = 0; i < bin.length; i++) out[i] = bin.charCodeAt(i);
    return out;
  }
  function bytes(path) {
    if (inline) {
      if (!(path in inline)) return Promise.reject(new Error('asset not bundled: ' + path));
      return Promise.resolve(b64(inline[path]));
    }
    return fetch('assets/' + path).then(function (r) {
      if (!r.ok) throw new Error(path + ': ' + r.status);
      return r.arrayBuffer();
    }).then(function (b) { return new Uint8Array(b); });
  }
  function json(path) {
    return bytes(path).then(function (b) { return JSON.parse(new TextDecoder('utf-8').decode(b)); });
  }

  root.F117 = root.F117 || {};
  root.F117.assets = { bytes: bytes, json: json, get inline() { return !!inline; } };
})(typeof window !== 'undefined' ? window : globalThis);
