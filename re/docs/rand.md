# rand() / srand() — MS C 6.0 runtime as linked into START, VGAME and END

All three executables carry the same runtime `rand`/`srand` pair (byte-identical code, different DGROUP
addresses). The generator is the classic Microsoft LCG. [verified] in all three listings.

| exe | srand | rand | `__aulmul` (long mul helper) | seed dword (DGROUP) | initial value |
|---|---|---|---|---|---|
| START | 0000:96BC | 0000:96CE | 0000:978E | ds:AE8C (lo) / ds:AE8E (hi) | 1 |
| VGAME | 0000:EE1A | 0000:EE2C | 0000:EF36 | ds:929E / ds:92A0 | 1 |
| END   | 0000:52CA | 0000:52DC | 0000:539C | ds:5158 / ds:515A | 1 |

Initial value read from the unpacked EXE data segment (DGROUP + offset); it is the runtime's `_holdrand = 1L`.

## Algorithm

`srand(n)` (e.g. START 0000:96BC): `seed_lo = n; seed_hi = 0` — the seed is the unsigned 16-bit argument, high word
cleared.

`rand()` (e.g. START 0000:96CE..96F3):

```
seed = seed * 0x000343FD + 0x00269EC3     ; 32-bit wrap. 0x343FD = 214013, 0x269EC3 = 2531011
return (seed >> 16) & 0x7FFF              ; mov ax,dx ; and ah,7Fh
```

Instruction evidence (START): `mov ax,43FDh / mov dx,3` = multiplier 0003:43FD; `add ax,9EC3h / adc dx,26h` = increment
0026:9EC3; `mov ax,dx / and ah,7Fh` = high word masked to 15 bits. No other operation touches the seed.

Period 2^32; the returned 15-bit value is the high half, so consecutive results are well mixed for `% n` use.

## Seed source

All three programmes seed exactly once, from the BIOS tick counter: `INT 1Ah, AH=0` returns CX:DX = ticks since
midnight at 18.2 Hz; only **DX (the low 16 bits)** is used.

| exe | helper | seeding call site | when |
|---|---|---|---|
| START | 0000:8607 `bios_ticks()` → DX | 0000:737D inside `init()` 0000:7312 | once at programme start, before the menu |
| VGAME | 0000:1E72 `bios_ticks()` | 0000:C880 `randomize()` (also stores the seed at ds:9540; no reader of ds:9540 found) called from `mission_time_init()` 0000:4973 | once, first sim frame (c0da==1 branch of 3ADA) |
| END   | 0000:45A6 `bios_ticks()` | 0000:3C37 inside `init()` 0000:3BF4 | once at programme start |

So START's mission generator, VGAME's in-flight randomness and END's quote pick are each seeded independently by the
wall clock. There is no seed hand-over between executables through the shared block. For a deterministic replay in the
port, seed each stage with a chosen 16-bit value instead of the clock.

## Wrappers the game code actually calls

| exe | wrapper | formula | notes |
|---|---|---|---|
| START | 0000:76C0 `random(n)` | `rand() % n` (unsigned 16-bit `div`) | 30 call sites; n = 0x14, 5, 0x10, 3, 0x3200, 0x96, 0x64, 0x500, 0xA, 2, 6 ... and table sizes from ds:E084-3 / ds:D33C. `n` must be non-zero (no guard). |
| VGAME | 0000:C88C `random(n)` | `(rand() * n) >> 15` (signed `imul`, arithmetic shift via 0000:EF74) | 13 call sites: n = 8 (damage bits 761A), 7/2 (fire particles C4BA), 4 (ground damage 6ED3), 0x12C, 0x1000 (4973), 0x4000 (3F91), ds:C0E0, ds:E56C, 0x24 locals. Result 0..n-1 for 0 < n ≤ 0x7FFF. |
| END | 0000:3E45 `random(n)` | `((long)n * rand()) >> 15` (`__aulmul` 539C then shift 53CE by 15) | one caller 0000:3B16 (quote index, n = ds:55BE) |

Note the two distributions differ: START takes `rand() mod n` (low bits of the 15-bit value), VGAME/END scale the 15-bit
value (high bits). Port each wrapper as written.

## JS reference

```js
// MS C 6.0 runtime rand/srand — START 0000:96CE / VGAME 0000:EE2C / END 0000:52DC
let holdrand = 1;                                   // uint32, runtime default
function srand(n) { holdrand = n & 0xFFFF; }        // high word cleared
function rand() {
  holdrand = (Math.imul(holdrand, 214013) + 2531011) >>> 0;
  return (holdrand >>> 16) & 0x7FFF;
}
function randomStart(n) { return rand() % n; }                 // START 0000:76C0
function randomVgame(n) { return (rand() * n) >> 15; }        // VGAME 0000:C88C (n < 0x8000 so no overflow)
function randomEnd(n)   { return Math.floor(n * rand() / 32768); } // END 0000:3E45 (same value as randomVgame)
```

Check values (seed 1): rand() = 41, 18467, 6334, 26500, 19169, 15724, 11478, 29358 — the familiar MSVC sequence.
