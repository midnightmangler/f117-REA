# PLAYER.EXE timing and fade (task 2.2) - JS: src/frontend/intro.js

Frame callback 0000:0738 (60 Hz; capstone of the unpacked image, the .asm listing elides it):
```
if (guard) return; guard = 1; time++                    ; 0738..0748
if (countdown != 0 && fade != 0) { fade_step(); goto out }   ; 74C..75D   (the animation is FROZEN while a fade runs)
if (countdown != 0 && --countdown != 0) goto out        ; 760..76B
if (tail == head) { skip++; goto out }                  ; 76D..784  (underrun: no data decoded yet; JS has everything)
tail = draw_cel(tail); wrap ring; frames++; countdown = ticksPerFrame (60/rate)   ; 788..7E0
out: guard = 0
```
So cel 0 is drawn on the first tick, then 300 fade ticks pass with no new cel, then one cel every 3 ticks (20 fps) / 6 (10 fps).
`finish()` returns as soon as the last cel is drawn (no hold of the final frame).

## Fade: init calls 0E0C(5), set_dac (0D0C) while ds:13D4 != 0
- 0E0C: `13D4 = 5*60 = 300`; `step = 13D2/20` if divisible else 0x100, where 13D2 = DAC entries writable during one retrace
  (0DE4, hardware dependent). JS uses step = 0x100 (whole palette per tick; the usual case since the measured count is rarely a multiple of 20) (?).
  `inc = 0x10000 / (step*300/256 - 1) = 219`; scale (13D6) = inc; block 0 is computed at once from the (still empty) shadow palette.
- set_dac while fading: copies the 768 palette bytes to the shadow (ds:13DA) and writes BLACK to the DAC.
- fade_step 0EE3: write the previously computed block to the DAC (index = low byte of pos), `compute()` the next (0E65), `13D4--`.
- compute 0E65: out = round(comp * scale / 65536) = (p >> 16) + ((p >> 15) & 1); after each full pass of 256 entries
  scale += inc, clamped to 0xFFFF.
- Net: step 1 writes black, step k (k >= 2) writes scale 219k, step 300 writes the clamped full palette. Duration 300 ticks = 5 s.
- Every PLAYER launch (also the " title-2" one) fades its first palette; later files in the same launch set the DAC directly.

## poll 0696 / quit
Key -> quit(key code), joystick/mouse button -> quit(0x1B). The exit code is ignored by F117.COM. VRAM is not cleared at exit.

## Open: intro music
The only sound calls in PLAYER are snd_play(3) in poll (only when guard != 0), snd_play(2) in finish() (argc > 2: wait while a song is
active) and snd_play(0) in quit. Nothing in PLAYER (or F117.COM, whose snd_init only silences) starts song id 3 => who starts the
intro music is unresolved (the timer module 026B may do it) (?). `intro.js` plays no music.
