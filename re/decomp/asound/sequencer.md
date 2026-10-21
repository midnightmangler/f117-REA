# ASOUND.117 sequencer, decompiled (task 1.4)

Source: capstone of the code segment (image + 0x1B60), addresses `cs:XXXX`; data `ds:XXXX` = image offset.
Globals: see `re/docs/sound.md` 5.1. Extra statics found here:

| ds: / cs: | name | meaning |
|---|---|---|
| cs:000E | tickCount | +1 every snd_tick (`0430`), also when locked; read by speech id 43 (parity) |
| ds:17F0/17F1 | savedNoiseA/B | pause (id 21) copies of 19DC/19FC |
| ds:1A03 | nextNoiseB | 0 = next noise note takes slot A, 1 = slot B |
| ds:1A04/1A05 | noiseChA/B | OPL channel of noise slot A/B |
| ds:1B5E | curCh | channel for the C0 write in opLoad |
| ds:1B60 | curSlotOff | slot register offset for opLoad |
| ds:1B62 | curVoice | pointer to the voice record being interpreted |
| ds:1B64 | curOp | pointer to the 22-byte operator half |
| [bp-4] of 1360 | volFlag | fixed stack slot (stack switched to ds:17DA in 0430), so it **persists** across voices and ticks |
| ds:17E4 | rng | initial 0x04D2 |

Initial image values that matter: rng 0x04D2, 1892..1894 = 1 1 1, everything else in 17DC..1B66 = 0.

## OPL write `cs:036B(ah=chip, al=reg, bl=val)`
`shadow[ds:1A06 + reg] = val`; card 0 (AdLib, the mono reference) -> port 0x388. All register writes go through it,
except the detect sequence in init (`033A`, regs 4/2 only, no shadow).

## Small helpers
- `02E6(al=reg)`: write(reg, shadow[reg] | 0x3F)           (pause: carrier TL max)
- `02F6(al=reg, bh)`: write(reg, (shadow[reg] & 0xC0) | (bh ^ 0x3F))   (resume)
- `030B(al=ch, bx=w)`: write(A0+ch, w & 0xFF); write(B0+ch, (w >> 8) | 0x20)
- `03C4` rng (far): `rng = ror16(rng + 0x9248, 3)`; returns rng.

## Silence `cs:018F`
```
save lock; lock = -1
bytes +00..+03 of voices 0..6 = 0                               // 019B..01EC
19DC = 19FC = 0; 19FE = 1A00 = 0; 1902 = 1904 = 1906 = 1908 = 0
0210: for r = 0x5F..0x40: write(r, 0x3F); for r = 0xFF..0x60: write(r, 0); for r = 0x3F..0x01: write(r, 0)
      write(0x01, 0x20)
restore lock
```
Note: the 0x3F..0x01 loop runs with bl = 0 from the previous loop.

## snd_tick `cs:0C08` -> `0430`
```
17DC = 0
tickCount++                              // 0430
rng()                                    // 0435
if (lock) return 17DC                    // 0441 jmp 054D (also skips the noise update)
if (engineOn && throttle) {              // 045C
  if (voice6.active == 0) { voice6.ptr = 0E94; voice6.active = 1 }      // only +10 and +00
  else { voice6.active = 2; voice6.keyoffCnt = 2 }
}
interpretAll()                           // 1882: voices 0..6, ch = 0..6
if (engineOn && throttle && throttle != lastThrottle) {   // 048F
  lastThrottle = throttle
  030B(6, engineFnum)
  v = 0x36 + throttle/85 (AL = quotient, AH = remainder; 17EA = AX + 0x36)
  03FB: if (engineOn && throttle) { write(0x50, (0x3F - v) & 0xFF); write(0x53, v & 0xFF) }
}
// noise update 04CE
if (cntA == 0 && cntB == 0) { if (17DE != -1) { 17DE = -1; 17DC = -1 } ; return 17DC }
if (cntA) { baseA += stepA; if (--cntA == 0 && !(cntB && chA == chB)) { write(A0+chA,0); write(B0+chA,0) } }
if (cntB) { baseB += stepB; if (--cntB == 0 && !(cntA == 0 && chB == chA)) { write(A0+chB,0); write(B0+chB,0) } }
return 17DC
```
The two key-off guards are asymmetric in the original (A checks "B active and same channel"; B checks "A idle
and same channel"); kept as is.
`05A5 noiseStarted`: if (17DE != 1) { 17DE = 1; 17DC = 1 }.

## snd_noise `cs:0C1C` -> `0562`
```
r = rng()
if (cntA) 030B(chA, (~r & maskA) + baseA)
if (cntB) 030B(chB, (r & maskB) + baseB)
return 0
```

## Engine `03D5` (id 23), `041E` (24), `0424` (25)
```
23: t = min(arg2, 0x301) (signed compare); throttle = t; if (t == 0) lastThrottle = 0 else engineFnum = (t & ~1) + 0x883
24: engineOn = 0xFF          25: engineOn = 0; lastThrottle = -1
```

## Voice start `05E7(bx = voice, cx = seq, ax = chain)`
```
save lock; lock = 0
+01 = 0; +0A = 0xFF; +02 = +03 = +1C = +1D = 0; +0D = 0x40
+0E = +10 = +12 = +14 = seq; +16 = +18 = 0; +07 = 0; +1A = ax; +00 = 1
restore lock
```
Entry points 05E3 v0, 05DC v1, 05D5 v2, 05CE v3, 05C7 v4, 05C0 v5, 05B9 v6.
AX on entry is 0 from the dispatcher, **except** ids 28 and 33, which call rng first: AX = the patched note/dur
byte (0x21..0x24 / 1..4), so their +1A chain is non-zero (harmless: those streams end with dur 0, no FD).

## play dispatch `cs:0B98(id, a2, a3, a4)`
`if (id > 0x2D) return` (signed); `AX = 0; BX = 2*id; call [0911 + BX]`. Handler table: sound.md 5.7. Details:
- id 1 `0761`: +12 of voices 0..6 = 0E9A.   id 2 `0839`: return OR of +00 of voices 0..6.
- id 9 `089C`: skip if voice3.+0E == 0F3C and voice3.active.
- id 11 `08E8`: if throttle == 0 -> 03D8 with t = 1. Then v3 <- 0FA2.
- id 21 `0782`: save/zero cntA/cntB, lock = -1, 02E6 on 43 44 45 4B 4C 4D 53.
- id 22 `07C7`: 02F6(reg, voice[n].+06) for the same 7 regs/voices 0..6; restore counts; if either -> 05A5; lock = 0.
- id 37 `0720`: v0..v5 then +1A: v4 = 0B6A, v5 = 0BA6.
- id 40 `0B90`: speech paragraph = a2.

## Interpreter `cs:1360` (one voice; ch = ds:1A02, incremented at exit `1878`)
```
if (v.active == 0) goto exit
if (v.koff && --v.koff == 0) keyOff()                    // 1377, 0E5E
if (--v.active > 0) goto perTick                         // 1395 (byte)
for (;;) {                                               // 13A5
  p = v.ptr; b = mem[p]
  if (b < 0xF3) break                                    // 13B4..13C4 (signed compare against F2)
  volFlag = 0                                            // 13C8, before every command
  switch (b) {
  F3: v.+0C = mem[p+1]; v.+03 = mem[p+2]; v.+0B = 1; ptr += 3
  F4: v.+0D = mem[p+1]; ptr += 2; volFlag = 1
  F5: v.+1D = mem[p+1]; ptr += 2
  F6: n = sx(mem[p+1]); r = rng(); val = mem[p+2 + ((n-1) & r)]
      mem[p+2+n+1 + sx(mem[p+2+n])] = val; ptr += n + 3
  F7: v.+1C = mem[p+1]; ptr += 2
  F8: v.+0A = mem[p+1]; v.+02 = mem[p+2]; v.+09 = 1; ptr += 3
  F9: v.+06 = mem[p+1]; ptr += 2; volFlag = 1
  FA: v.+01 = mem[p+1]; ptr += 2
  FB: v.+07 = mem[p+1]; ptr += 2
  FC: v.+05 = mem[p+1]; ptr += 2; loadInstr(v.+05)
  FD: if (v.+1A == 0) ptr = v.+0E else v.+0E = ptr = v.+12 = v.+14 = v.+1A
  FE: if (v.+18 == 0) { n = sx(mem[p+1]); if (n == 0) { ptr += 2; v.+14 = v.+12 = ptr; v.+16 = v.+18 = 0 }
                         else { v.+18 = n; v.+12 = ptr = v.+14 } }
      else { --v.+18; v.+12 = v.+14; if (v.+18 == 0) { ptr += 2; v.+14 = ptr } ; ptr = v.+14 }
  FF: if (v.+16 == 0) { n = sx(mem[p+1]); if (n == 0) { ptr += 2; v.+12 = ptr; v.+16 = 0 }
                         else { v.+16 = n; ptr = v.+12 } }
      else { if (--v.+16 == 0) { ptr += 2; v.+12 = ptr } else ptr = v.+12 }
  }
}
if (volFlag) setVolume()                                 // 1758
v.note = mem[p]; v.active = mem[p+1]; ptr += 2
if (v.note == 0 || v.active == 0) keyOff()
else { v.koff = v.active - sx(v.gap); noteOn() }
perTick:                                                 // 17D1
if (v.slide) slide()
volFlag = 0
if (v.+09 || v.+0B) {
  if (--v.+09 == 0) { v.+09 = v.+0A; if (v.+02) { v.+1D += v.+02; volFlag = 1 } }   // byte wrap: 0 -> FF
  if (--v.+0B == 0) { v.+0B = v.+0C; if (v.+03) { v.+0D += v.+03; volFlag = 1 } }
  if (volFlag) setVolume()
}
exit: ch++
```
Counters (+16/+18) are 16-bit words set from the sign-extended count byte.

## setVolume `0C2E` (card 0 path `0D00`)
`reg = 0x40 + slotReg[chanOps[ch].carrier]; write(reg, (shadow[reg] & 0xC0) | (0x3F - ((v.+06 + sx(v.+1D)) & 0x3F)))`

## pitch `0D1C`
```
f = sx(v.detune) + fnum[note % 12]; blk = note / 12
write(A0+ch, f & 0xFF)
write(B0+ch, (shadow[B0+ch] & 0x20) | (((f & 0xFFFF) >> 8 | blk << 2) & 0xFF))
```
## slide `0DCE`
`w = ((shadow[B0+ch] & 0x1F) << 8) + shadow[A0+ch] + sx(v.slide)` (16-bit);
`write(A0+ch, w & 0xFF); write(B0+ch, (shadow[B0+ch] & 0x20) | ((w >> 8) & 0xFF))`
## keyOff `0E5E`: `write(B0+ch, shadow[B0+ch] & 0xDF)`

## noteOn `0E8A`
```
setVolume()
if (noise[ch].dur == 0) { pitch(); write(B0+ch, shadow[B0+ch] | 0x20); return }
if (ch == chA) nextNoiseB = 0
if (ch == chB) nextNoiseB = 1
if (nextNoiseB == 0) { nextNoiseB = 1; if (cntA) write(B0+chA, shadow[B0+chA] & 0xDF)
                       chA = ch; cntA = dur; maskA = mask; baseA = base; stepA = step }
else                 { nextNoiseB = 0; if (cntA) write(B0+chB, shadow[B0+chB] & 0xDF)   // tests cntA, not cntB
                       chB = ch; cntB = dur; maskB = mask; baseB = base; stepB = step }
noiseStarted()
```
noise[ch] = ds:1B06 + 8*ch: byte dur, word mask (+2), base (+4), step (+6).

## loadInstr `123E(n)` and opLoad `1048`
```
write(B0+ch, shadow[B0+ch] & 0xDF)
rec = 0x2E + 0x2C*n
opLoad(slotReg[chanOps[ch].mod], rec)
noise[ch] = { dur: mem[rec+0x0E], mask: w(rec+0x10), base: w(rec+0x12), step: w(rec+0x14) }
opLoad(slotReg[chanOps[ch].car], rec + 0x16)

opLoad(off, op):
  write(0x40+off, 0x3F)
  write(0xBD, (shadow[0xBD] & 0x3F) | (1892 ? 0x80 : 0) | (1893 ? 0x40 : 0))
  write(0x08, 1894 ? 0x40 : 0)
  write(0xC0+ch, (op[0xA] << 1 | (op[0xD] ? 0 : 1)) & 0xFF)
  write(0x60+off, (op[0] << 4 | op[1] & 0xF) & 0xFF)
  write(0x80+off, (op[2] << 4 | op[3] & 0xF) & 0xFF)
  write(0x20+off, ((op[0xB]?0x80:0) + (op[0xC]?0x40:0) + (op[4]?0x20:0) + (op[5]?0x10:0) + (op[9] & 0xF)) & 0xFF)
  write(0xE0+off, op[8] & 3)
  write(0x40+off, ((0x3F - (op[6] & 0x3F)) | op[7] << 6) & 0xFF)
```

## Init `0B76` (card 0)
Detect (regs 4/2, not shadowed), `17F2 = 0`, then silence `018F`. Returns 0.
