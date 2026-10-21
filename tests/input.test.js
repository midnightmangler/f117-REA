// Task 1.5: input core (src/platform/input.js). Run: node tests/input.test.js
'use strict';
const assert = require('assert');
const { createInput, wordOf, STICK_MASK } = require('../src/platform/input.js');

let passed = 0;
function t(name, fn) { fn(); passed++; }
const ev = (code, o) => Object.assign({ code: code, shiftKey: false, altKey: false, ctrlKey: false }, o || {});

// ---- key words (values from vgame-map.md sec. 7) ----
t('key words', () => {
  const w = (code, o) => wordOf(ev(code, o));
  assert.strictEqual(w('Digit1'), 0x0231);
  assert.strictEqual(w('Digit0'), 0x0B30);
  assert.strictEqual(w('Minus'), 0x0C2D);
  assert.strictEqual(w('Equal'), 0x0D3D);
  assert.strictEqual(w('Minus', { shiftKey: true }), 0x0C5F);
  assert.strictEqual(w('Equal', { shiftKey: true }), 0x0D2B);
  assert.strictEqual(w('Backspace'), 0x0E08);
  assert.strictEqual(w('Enter'), 0x1C0D);
  assert.strictEqual(w('Space'), 0x3920);
  assert.strictEqual(w('Escape'), 0x011B);
  assert.strictEqual(w('KeyC'), 0x2E63);
  assert.strictEqual(w('KeyZ', { shiftKey: true }), 0x2C5A);
  assert.strictEqual(w('KeyZ'), 0x2C7A);
  assert.strictEqual(w('BracketLeft'), 0x1A5B);
  assert.strictEqual(w('BracketLeft', { shiftKey: true }), 0x1A7B);
  assert.strictEqual(w('Slash', { shiftKey: true }), 0x353F);
  assert.strictEqual(w('Comma', { shiftKey: true }), 0x333C);
  assert.strictEqual(w('KeyQ', { altKey: true }), 0x1000);
  assert.strictEqual(w('KeyP', { altKey: true }), 0x1900);
  assert.strictEqual(w('KeyS', { altKey: true }), 0x1F00);
  assert.strictEqual(w('F1'), 0x3B00);
  assert.strictEqual(w('F10'), 0x4400);
  assert.strictEqual(w('F1', { shiftKey: true }), 0x5400);
  assert.strictEqual(w('F6', { shiftKey: true }), 0x5900);
  assert.strictEqual(w('F10', { shiftKey: true }), 0x5D00);
  assert.strictEqual(w('Insert'), 0x5200);
  assert.strictEqual(w('ArrowUp'), 0x4800);
  assert.strictEqual(w('Numpad8'), 0x4800);
  assert.strictEqual(w('Numpad8', { shiftKey: true }), 0x4838);
  assert.strictEqual(w('Numpad9', { shiftKey: true }), 0x4939);
  assert.strictEqual(w('Numpad3', { shiftKey: true }), 0x5133);
  assert.strictEqual(w('Numpad7'), 0x4700);
  assert.strictEqual(w('Numpad1'), 0x4F00);
  assert.strictEqual(w('KeyZ', { getModifierState: () => true }), 0x2C5A);   // CapsLock
});

// ---- BIOS buffer, frame drain, typematic collapse ----
t('frameKey keeps the first key, discards the rest', () => {
  const inp = createInput({ ticks: () => 0 });
  assert.strictEqual(inp.frameKey(), 0);
  inp.pushKey(0x0231); inp.pushKey(0x0332); inp.pushKey(0x0433);
  assert.strictEqual(inp.frameKey(), 0x0231);
  assert.strictEqual(inp.keyReady(), false);
  assert.strictEqual(inp.frameKey(), 0);
});
t('misc driver get/ready', () => {
  const inp = createInput({ ticks: () => 0 });
  inp.pushKey(0x1000); inp.pushKey(0x1559);
  assert.ok(inp.keyReady());
  assert.strictEqual(inp.getKey(), 0x1000);
  assert.strictEqual(inp.getKey(), 0x1559);
  assert.strictEqual(inp.getKey(), 0);
});
t('typematic repeats collapse to at most 2 words (ISR dedupe runs before the BIOS stores)', () => {
  const inp = createInput({ ticks: () => 0 });
  for (let i = 0; i < 10; i++) inp.keyDown(ev('KeyV'));
  let n = 0; while (inp.keyReady()) { inp.getKey(); n++; }
  assert.strictEqual(n, 2);
});
t('buffer holds 15 words', () => {
  const inp = createInput({ ticks: () => 0 });
  for (let i = 0; i < 20; i++) inp.pushKey(0x0100 + i);
  let n = 0; while (inp.keyReady()) { inp.getKey(); n++; }
  assert.strictEqual(n, 15);
});

// ---- virtual stick (1132:006C) ----
function stickKeys() {
  let tick = 100;
  const inp = createInput({ ticks: () => tick });
  return { inp, setTick: (v) => { tick = v; } };
}
t('stick starts centred', () => {
  const { inp } = stickKeys();
  assert.strictEqual(inp.stickX, 0x80); assert.strictEqual(inp.stickY, 0x80);
});
t('deflection 0x5A and release recentres', () => {
  const { inp } = stickKeys();
  inp.keyDown(ev('ArrowLeft'));
  assert.strictEqual(inp.stickX, 0x80 - 0x5A); assert.strictEqual(inp.stickY, 0x80);
  inp.keyUp(ev('ArrowLeft'));
  assert.strictEqual(inp.stickX, 0x80);
  inp.keyDown(ev('ArrowRight'));
  assert.strictEqual(inp.stickX, 0x80 + 0x5A);
  inp.keyUp(ev('ArrowRight'));
  inp.keyDown(ev('ArrowUp'));    // mask 1 = Y low
  assert.strictEqual(inp.stickY, 0x80 - 0x5A);
  inp.keyUp(ev('ArrowUp'));
  inp.keyDown(ev('ArrowDown'));  // mask 2 = Y high
  assert.strictEqual(inp.stickY, 0x80 + 0x5A);
});
t('diagonals set both axes', () => {
  const { inp } = stickKeys();
  inp.keyDown(ev('Numpad7'));    // up-left
  assert.deepStrictEqual([inp.stickX, inp.stickY], [0x26, 0x26]);
  inp.keyUp(ev('Numpad7'));
  inp.keyDown(ev('Numpad3'));    // down-right
  assert.deepStrictEqual([inp.stickX, inp.stickY], [0xDA, 0xDA]);
  inp.keyUp(ev('Numpad3'));
  inp.keyDown(ev('Numpad9'));    // up-right
  assert.deepStrictEqual([inp.stickX, inp.stickY], [0xDA, 0x26]);
  inp.keyUp(ev('Numpad9'));
  inp.keyDown(ev('Numpad1'));    // down-left
  assert.deepStrictEqual([inp.stickX, inp.stickY], [0x26, 0xDA]);
});
t('re-press of the same key within 5 ticks gives 0x7F', () => {
  const { inp, setTick } = stickKeys();
  inp.keyDown(ev('ArrowLeft')); assert.strictEqual(inp.stickX, 0x26);
  inp.keyUp(ev('ArrowLeft'));
  setTick(104);                                   // 4 ticks later: < 5
  inp.keyDown(ev('ArrowLeft')); assert.strictEqual(inp.stickX, 0x80 - 0x7F);
  inp.keyUp(ev('ArrowLeft'));
  setTick(109);                                   // exactly 5 after the last accepted press: not < 5
  inp.keyDown(ev('ArrowLeft')); assert.strictEqual(inp.stickX, 0x26);
});
t('a different key resets the window; another key held is ignored', () => {
  const { inp, setTick } = stickKeys();
  inp.keyDown(ev('ArrowLeft')); inp.keyUp(ev('ArrowLeft'));
  setTick(101);
  inp.keyDown(ev('ArrowRight')); assert.strictEqual(inp.stickX, 0xDA);   // different mask: 0x5A
  inp.keyDown(ev('ArrowUp'));                                              // 2CD8 busy: ignored
  assert.strictEqual(inp.stickY, 0x80);
  inp.keyUp(ev('ArrowUp'));                                                // not the held mask: no recentre
  assert.strictEqual(inp.stickX, 0xDA);
  inp.keyUp(ev('ArrowRight')); assert.strictEqual(inp.stickX, 0x80);
});
t('typematic repeat while held does not change the stick', () => {
  const { inp, setTick } = stickKeys();
  inp.keyDown(ev('ArrowLeft'));
  setTick(101); inp.keyDown(ev('ArrowLeft')); inp.keyDown(ev('ArrowLeft'));
  assert.strictEqual(inp.stickX, 0x26);
});
t('tick counter wraps at 16 bits', () => {
  const { inp, setTick } = stickKeys();
  setTick(0xFFFE); inp.keyDown(ev('ArrowLeft')); inp.keyUp(ev('ArrowLeft'));
  setTick(2);                                     // 4 ticks later across the wrap
  inp.keyDown(ev('ArrowLeft')); assert.strictEqual(inp.stickX, 0x01);
});
t('same mask from a different key counts as a re-press (KP4 then Left)', () => {
  const { inp, setTick } = stickKeys();
  inp.keyDown(ev('Numpad4')); inp.keyUp(ev('Numpad4'));
  setTick(101);
  inp.keyDown(ev('ArrowLeft')); assert.strictEqual(inp.stickX, 0x01);
});
t('KP5 sets no axis and releases to centre', () => {
  const { inp } = stickKeys();
  inp.keyDown(ev('Numpad5')); assert.deepStrictEqual([inp.stickX, inp.stickY], [0x80, 0x80]);
  assert.strictEqual(inp.virtualStick.held, 0x80);
  inp.keyUp(ev('Numpad5')); assert.strictEqual(inp.virtualStick.held, 0);
});
t('Shift ignores keypad keys (ISR 00A7) but not the grey cursor keys (E0 path)', () => {
  const { inp } = stickKeys();
  inp.keyDown(ev('Numpad4', { shiftKey: true })); assert.strictEqual(inp.stickX, 0x80);
  inp.keyDown(ev('ArrowLeft', { shiftKey: true })); assert.strictEqual(inp.stickX, 0x26);
  inp.keyUp(ev('ArrowLeft', { shiftKey: true })); assert.strictEqual(inp.stickX, 0x80);
});
t('keys outside the table do nothing to the stick', () => {
  const { inp } = stickKeys();
  inp.keyDown(ev('KeyA')); inp.keyDown(ev('Insert'));
  assert.deepStrictEqual([inp.stickX, inp.stickY], [0x80, 0x80]);
  assert.strictEqual(inp.virtualStick.held, 0);
});
t('backquote and backslash map as in the table', () => {
  const { inp } = stickKeys();
  inp.keyDown(ev('Backquote')); assert.strictEqual(inp.stickY, 0x26); inp.keyUp(ev('Backquote'));
  inp.keyDown(ev('Backslash')); assert.strictEqual(inp.stickX, 0x26);
});
t('table has the 13 entries of DS:2CDE', () => {
  assert.strictEqual(Object.keys(STICK_MASK).length, 13);
});

// ---- joystick mode, buttons ----
t('joystick mode: bytes from setStick, keyboard stick off, joystick buttons count', () => {
  const inp = createInput({ ticks: () => 0, joystick: true });
  inp.keyDown(ev('ArrowLeft'));
  assert.strictEqual(inp.stickX, 0x80);
  inp.setStick(0x10, 0xF0);
  assert.deepStrictEqual([inp.stickX, inp.stickY], [0x10, 0xF0]);
  inp.setJoyButton(1, true); assert.strictEqual(inp.button(1), 1);
  inp.setJoyButton(1, false); assert.strictEqual(inp.button(1), 0);
});
t('keyboard mode: joystick buttons ignored, pseudo-buttons work', () => {
  const inp = createInput({ ticks: () => 0 });
  inp.setJoyButton(0, true); assert.strictEqual(inp.button(0), 0);
  inp.setPseudoButton(0, 1); assert.strictEqual(inp.button(0), 1);
  inp.setPseudoButton(0, 0); assert.strictEqual(inp.button(0), 0);
});
t('switching mode recentres the virtual stick', () => {
  const inp = createInput({ ticks: () => 0 });
  inp.keyDown(ev('ArrowLeft')); inp.setJoystick(true); inp.setJoystick(false);
  assert.strictEqual(inp.stickX, 0x80); assert.strictEqual(inp.virtualStick.held, 0);
});

console.log('input.test.js: ' + passed + ' passed');
