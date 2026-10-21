// Checks that tools/bundle.py produced a self-contained dist/f117-rea.html.
'use strict';
const fs = require('fs');
const path = require('path');

const dist = path.join(__dirname, '..', 'dist', 'f117-rea.html');
if (!fs.existsSync(dist)) { console.error('missing ' + dist); process.exit(1); }
const html = fs.readFileSync(dist, 'utf8');
let fail = 0;
if (/<script\s+[^>]*src=/i.test(html)) { console.error('bundle still has <script src>'); fail = 1; }
if (!/id="screen"/.test(html)) { console.error('bundle lacks the #screen canvas'); fail = 1; }
if (!fail) console.log('bundle ok (' + html.length + ' bytes)');
process.exit(fail);
