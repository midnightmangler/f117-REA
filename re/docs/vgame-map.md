# VGAME.EXE — structural map (in-flight simulation)

Scope: map of every C function in segment 0000 (0010..E586; runtime from E6BE up is MSC 6.0 library), every
assembly segment (0FAE..14C2), the far data segments and the DGROUP tables/globals the sim uses.
Conventions per `00-conventions.md`: addresses `SEG:OFF` load-relative, `ds:XXXX` = DGROUP (1E42) offset,
`T:xxxx` = far call to the DGROUP driver thunk 1E42:xxxx. Confidence high/med/low; `(?)` = unproven.
Not decompiled yet — this is the map for the function-by-function sessions.

**Listing caveats (read before decompiling)**
- String xrefs in `VGAME.data.txt`/`funcs.txt` to ds:0042..007C (`regn.xxx`, `lb.xxx`, `me.xxx`, `nc.xxx`, `ce.xxx`, `cu.xxx`, `pg.xxx`)
  and ds:00F7 (`speech.117`) are mostly coincidental immediates (pixel coordinates 0x6E, 0x59, 0x60, ...). The only real use is the
  theatre-name table ds:0090 (see §6).
- `VGAME.asm` resolves near calls/jumps inside segments != 0000 to wrong targets; funcs.txt entries 0FB2_003F/0075/01C6,
  1058_04CA/0596, 114A_0038/008C, 120A_0910, 1377_04E5/0660/06DE and all 14D1_*/1872_* are artefacts. **For segments
  0FAE..14C2 use the per-module listings in `re/disasm/vgame-asm/` (made by `re/tools/vgame_asm.py`, conventions in
  `vgame-asm.md`); the tables in §4 below predate them and are corrected in vgame-asm.md §5.**
- Real code shown as data in the listing: 0000:1BB3 (INT 1Bh handler), 1C6D..1D87 (timer ISR + helpers), 1E79..1EAE (frame tick),
  5737..5850 (complete function, never called), CE8D (jump table, keys '1'..'8'; listing claims 52 entries/spurious `case:` labels).
  The islands 0CDD tail, 2031..2041, 6B0B..6BDD and E447/E4B6 are decoded in vgame-asm.md §4 (`vgame_asm.py --range`).
- funcs.txt size of 683E is wrong: real extent 683E..7242 (2565 bytes).

## 1. Program flow

```
E6BE  crt0 (MSC)  -> 0010 main()
0010 main():
   blockseg = word 0000:04F0          ; F117.COM publishes the shared block segment here
   ds:E574/E576 = blockseg:0000       ; far ptr "block"
   ds:9924/9926 = blockseg:1272       ; far ptr "blk2" (mission/pilot sub-block)
   0FAE:0002(block+1A)  sound driver  -> thunks 1E42:030E..0322
   0FAE:0002(block+1E)  misc driver   -> thunks 1E42:02DC..02F5
   0FAE:0002(block+1C)  gfx driver    -> thunks 1E42:011A..02B9
   1B73  hook INT 1Bh (Ctrl-Break swallowed; flag ds:2624 never read)
   if block+72 bit0: 1058:0D8C(block+48) load joystick calibration   else ds:2CD2/2CD3 = 0x80
   02C4  gfx pages: page0 = A000 (ds:8612), page1 = back buffer (ds:8614), page2 = block+20 (art buffer, ds:8616)
   T:0156 (draw page := back buffer); 1377:000C('M') rasteriser = MCGA 320x200x256
   ds:E584 = block+20 (art-buffer segment used by all blits)
   00F0  sim_load(): stflt.3dx, theatre files <th>.3dG/.3DX/.3dT + photo.3dx, speech.117, palette, 256pit.PIC, ordnance panel
   45C5  draw countermeasure counters
   0235  sim_run(): 1C0E timer install; 1132:0002 keypad INT 9 hook (only if no joystick);
         1BC2 -> 1BCE MAIN LOOP (until ds:E57E != 0)
         stop sounds T:0313(0x17,0), T:0313(0); 4D45 save world state + event log into block+7A;
         free ordnance buffer; unregister speech T:0313(0x28,0,0,0); 1132:0052; T:02A5(1); wait 2 ticks; timer restore 1C4C
   if block+72 bit0: 1058:0D7A(block+48) save joystick calibration
   1B96  unhook INT 1Bh
   if byte ds:008D == 0: int 10h AX=0003 (text mode)   (EC12 = int86)
   exit(byte ds:008D)                                   (E876)
```

**Exit code** (byte ds:008D, initialised 0x81 in the data segment): only one writer, 0000:20D3 (Alt-Q -> "Y" in 1EB0) sets 0
-> F117.COM "quit game". Every other way out of the loop (landing, crash, eject, Esc-after-eject) exits with **0x81** -> END.EXE.
The mission result is passed in the shared block, not in the exit code:

| block field | written by | meaning |
|---|---|---|
| +0x26 (w) | 3ADA:3C25 =1; C8CA:CD5A =2; 4A42:4A7D =3 | flight status: 1 flying, 2 ejected/abandoned (Shift-F10 at low speed), 3 ended normally (end code 0 and not ejected) |
| +0x28 (w) | 4A42 | end code: 0 safe landing / ejection finished, 1 crash on ground off-runway (3ADA:4274), 2 hit terrain/obstacle with realism on (3ADA:42DE), 5 hard landing (1EB0:2AEB), 6 eject at high speed (C8CA:CD04). Code 7 (Alt-Q quit) writes nothing |
| +0x2C (w) | 528D:5555, 63F2:66AA `inc` | number of missiles fired at the player |
| +0x30 bit0 | C8CA:CB36 | training/cheat mode (Alt-T) was used |
| +0x34 / +0x36 | 4A42 | ds:3664 damage bits / ds:C5F4 hits taken |
| +0x74 / +0x76 | 4A42 | final map x / y (ds:C0D0 / ds:C0DE) |
| +0x7A.. | 4D45 at exit (4BEC loads it at start) | world state serialised by 4D5D (order in §6), then the 0x600-byte event log ds:BA56 |

**Shared block reads** (F117.COM/START -> VGAME):

| offset | read at | meaning |
|---|---|---|
| +0x1A / +0x1C / +0x1E | 0010 | segments of the loaded sound / graphics / misc driver (driver header: +18 code seg, +1C slot base, +22 count, +24 entry table) |
| +0x20 | 0010:009B, 02C4:02EB | segment of the 64K art buffer (graphics page 2; cockpit PICs are decoded there; ds:E584). **Not** a sound result in VGAME |
| +0x32 (b) | 3ADA:3C15 | initial detail level -> ds:990E |
| +0x33 (b) | 00F0:013A | ds:368A (night mission flag (?); selects night palette 1C4A, clock offset, no shadows) |
| +0x38+2i / +0x40+2i, i<4 | 3ADA:3C40, 0300 | weapon station i: store type (ds:3690 index) / count -> ds:3670/3672 |
| +0x48.. (0x28 bytes) | 0010, 1058:0D8C/0D7A | joystick calibration (in/out) |
| +0x72 bit0 | 0010, 0235, 1EB0, C89C, C8CA | joystick present (use 1058 joystick + misc-driver buttons; else keypad INT 9 virtual stick) |
| +0x7A.. | 4BEC/4D5D at start | world state: sites, aircraft, strings, terrain grid, waypoints, objectives (§6) |
| blk2+0x38 | 00F0, 1EB0, 3ADA | theatre index 0..7 (lb, pg, nc, ce, vn, me, ku, cu) |
| blk2+0x3A | 3ADA:3C03 | -> ds:3688 enemy aggressiveness / scramble rate |
| blk2+0x3C bit1 | 3ADA:3C2F | -> ds:9B35 bit 0x10 (invulnerable/training) |
| blk2+0x3E | 3ADA:3C0A | -> ds:3686 enemy skill / difficulty |
| blk2+0x40 | 1EB0, 3ADA | flight realism 0..2 (turbulence, landing checks, brake decel, crash rules) (?) |
| blk2+0x42 | 0300, 4777, 5582, 93E9, C8CA, 79BE | 0 = 4 stations + gun; !=0 = 2 stations, no gun, halved radar detection (aircraft variant/easy mode (?)) |

## 2. Main loop and frame sequencing

`1BCE main_loop()` (called once from 0235 via 1BC2):

| # | call | role |
|---|---|---|
| 1 | 2F9D `view_update_and_render()` | choose camera from view code ds:C0A6, switch cockpit PIC/viewport on view change, **render 3D world** via 03CE (D826 view_begin -> sky/ground 1450 -> 04E6 terrain objects -> 983E world objects/aircraft/missiles -> D87C sorted draw -> 9EFA HUD/combat overlay incl. gunfire hits and target-camera MFD), external-view text |
| 2 | 79BE `cockpit_overlay_update()` | HUD text items (weapon line, GUN rounds, airspeed/alt/heading numerics, ACCEL/TRAINING, ILS 971A, flight-path marker), lamps, left MFD radar (8A90), waypoint-reached detection + steering bearing ds:C0A4, HUD message line |
| 3 | if ds:C0A6==0 (cockpit): 1058:000A `hud_symbology()` (asm: tapes, pitch ladder), D6DD side strip (Alt-H), 17B4 ADI ball | |
| 4 | T:01F6(ds:2E66*160) | present: copy the top ds:2E66 rows of the back buffer to A000 |
| 5 | ds:262A = 1 | frame pending; timer ISR clears it at the next frame tick; D826 (next render) waits for 0 = frame-rate cap |
| 6 | 1EB0 `flight_update()` | read one key (BIOS) into ds:DEBC + flight keys; stick (joystick/keypad); autopilot; ejection; engine/fuel; G; stall; speed; attitude matrix; altitude/position integration; touchdown check; history ring |
| 7 | 3ADA `sim_frame()` | (first frame: mission setup) map coords; map MFD; **5046 radar/SAM threat**, **5852 AI aircraft**, **683E missiles/bombs/hits**; 4738 CM timers, 4777 gun, 48B8 smoke, 4958 falling wreck, 4F2B ILS, 4FD8 lamps; airbase traffic (every 8 frames), AI takeoff (every 128); landing/crash/collision checks -> 4A42 end_mission; clock + time-of-day palette; adaptive frame-rate (ds:368E); **450A -> C8CA(key ds:DEBC)** keyboard command dispatcher + per-frame tail (fire button, gear/bay animation, jammers) + stealth signature ds:3D8A |
| 8 | loop while byte ds:E57E == 0 | set by 4A42 end_mission |

Sound is not a step of the loop: effects are fired ad hoc through D3F9 -> T:0313; the engine tone is updated from 1EB0
(T:0313(0x17, airspeed)); the sound driver is ticked from the timer ISR (T:031D on 6 of 7 frame ticks, T:0322 on the
fast PIT ticks).

**Timer** (INT 8, code islands, see §3 timer group): 1D88 calibrates the PIT against vertical retrace (16 periods);
fallback 0x4DAE counts (60 Hz). ISR 1C9B: every ds:2636 IRQs one *frame tick* 1E79 (++ds:2646, ++ds:264A, ++ds:2648,
T:0200 colour flicker/screen shake, sound tick) and clears ds:262A; 1D01 re-locks the PIT to retrace every 20 frame
ticks; BIOS INT 8 is chained through a count accumulator (ds:262C/262E). 3ADA measures ticks per frame (ds:2646 reset
to 0x0C) and adapts ds:368E (sim frames per second; all integrations divide by it, lifetimes multiply by it).

## 3. Function table — segment 0000

Grouped by subsystem; order inside a group = address. Sizes from funcs.txt (islands in parentheses). Helper semantics
used in evidence columns: `C67A(v,lo,hi)` clamp (odd wrap for v<=-0x4000), `C699` clamp, `C6B3` approx distance,
`C702` atan2 -> 16-bit angle (0 = north/+y), `C818/C831(ang,r)` r*sin / r*cos, `C88C(n)` random 0..n-1, `EE0C` abs,
`EB50/EB10/EB82/EB9E` strcpy/strcat/strlen/itoa, `EF68/EF74` long shl/shr, `EE9C/EF36` long div/mul, `D3F9(id,prio)` sound
effect, `889B(lamp,state)` cockpit lamp, `8A4F(str)` HUD/radio message, `4A42(code)` end_mission, `4ABA(type,arg)` event log.
Angles: 16-bit binary, 0x4000 = 90°, degrees = angle/0xB6.


### init/load (15)

| addr | size | alias | role | conf | evidence |
|---|---|---|---|---|---|
| 0000:0010 | 224 | `main()` | C main: reads block seg from 0000:04F0 -> ds:E574/E576 (far ptr block:0000), ds:9924/9926 = block:1272; installs drivers 0FAE_0002(block+1A sound, +1E misc, +1C gfx); 1B73 hook INT 1Bh; if block+72 bit0: 1058_0D8C(block+48) else ds:2CD2/2CD3=0x80; 02C4 gfx init; T:0156; 1377_000C(0x4D); ds:E584=block+20; 00F0 load; 45C5; 0235 run; 1058_0D7A(block+48) if +72 bit0; 1B96 unhook; if byte ds:008D==0 -> int10h AX=0003 via EC12; exit(ds:008D) via E876 | high | 0010..00EE; called from crt0 E6BE |
| 0000:00F0 | 201 | `sim_load()` (tail-jumps to 01C1) | 4BEC init; BAA2 load stflt.3dx; strcpy(ds:[8E]=ds:0042 "regn.xxx", theatre name ds:[0090+2*th]) ; 0986 load theatre 3D files; load speech.117 (E586) -> ds:008A, if ok T:0313(0x28,seg,ds:C0A0,ds:C0A2) register speech; T:0273; ds:368A=block+33 (byte); ds:0D47=byte ds:00EE[th]; ds:43DE=(ds:368A==0); ds:008C=1; 1039_0000; clear rows 0..0x5B of pages ds:4010/ds:4028 (0FB2_0246); load 256pit.PIC to page 2 (D52E); 0300 ordnance panel; 114A_02FF(0,0x5B,0x140,0x6D) | high | strings ds:00F7, ds:0102; 00FA..014F |
| 0000:0235 | 141 | `sim_run()` | ds:9916 far ptr 0000:0440 (BIOS floppy motor timeout) clamped to 1; 1C0E timer install; if !(block+72&1) 1132_0002 (input ISR install?); 1BC2 -> main loop 1BCE; on exit: T:0313(0x17,0), T:0313(0) (stop sounds); 4D45; free ds:BA3A (EE8E = DOS free); if speech loaded T:0313(0x28,0,0,0); if !(block+72&1) 1132_0052; T:02A5(1); wait 2 ticks (04C7); jmp 1C4C timer restore | high | 0235..02BF |
| 0000:02C4 | 60 | `gfx_pages_init()` | T:011A(0)->ds:8612,ds:861A; T:011A(1)->ds:8614; T:0291(1,ds:8614); ds:8616=block+20; T:0291(2,block+20) => block+0x20 is a segment handed to the gfx driver as buffer/page 2 | med | 02C4..02FF |
| 0000:0986 | 26 | `load_theatre_3d()` | 0C38 (.3dG), 09A0(.3DX), 0B05(.3dT) for name at ds:[8E]; ds:0CA8=0 | high | 0986..099F |
| 0000:09A0 | 357 | `load_3dx(name)` | name.3DX loaded to far seg (E586) -> ds:B78C; word count -> ds:0610; per-shape flag bytes -> ds:0960 and ds:07E0; ds:0510[i]=i+0x100; then photo.3dx -> ds:B78E, its flag bytes -> ds:0860; appends shapes ds:E30B / ds:E31D (mission-specific photo targets?) as type\|0x200; theatre 6 special-case patches ds:05C2/ds:051A; error msg via 0CDD | high | strings ds:0CAC..0CCF |
| 0000:0B05 | 307 | `load_3dt(name)` | name.3dT (fopen EA1C "rb"? ds:0CEC): fread word->ds:0612, 5 words->ds:0614 (tiles per level), 5x32 words->ds:061E (object count per tile); then 7-byte object records into ds:A09A.. (x,y,z words + type byte at ds:A0A0+7k); builds tile list pointers ds:E330[level*32+tile] | high | 0B09..0C35 |
| 0000:0C38 | 165 | `load_3dg()` | name.3dG: word->ds:075E, 16-byte header, 256 bytes ->ds:9F98 (L3 16x16 map), 512 ->ds:9D40, ds:9B38, ds:9934 (L2/L1/L0 4x4 sub-tile patterns, 32 tiles each); memcpy(ds:B03C, ds:0A68+th*64, 64) (L4 8x8 map per theatre) | high | 0C38..0CDC |
| 0000:1B73 | 18 | `hook_ctrlbreak()` | saves INT 1Bh vector (1BA7, IVT 0:006C) -> ds:2625/2627, installs handler 0000:1BB3 (`mov byte [ds:2624],0FFh; iret`) | high | 1B77..1B8F, bytes at 1BB3 |
| 0000:1B96 | 8 | `unhook_ctrlbreak()` | restores INT 1Bh from ds:2625/2627 | high |  |
| 0000:1BC2 | 12 | `main_loop_wrapper()` | saves bp/si/di/es around 1BCE | high |  |
| 0000:1BCE | 63 | `main_loop()` | loop { 2F9D view render; 79BE input; if !ds:C0A6 { 1058_000A; D6DD(ds:40B6); 17B4 ADI }; T:01F6(ds:2E66*160) (display start/page flip ?); ds:262A=1 (frame pending); 1EB0; 3ADA } while !ds:E57E | high | 1BCE..1C0C |
| 0000:4973 | 134 | mission_time_init() | randomize (C880), 796E, random start frame counter 3d8e, start hour 98a0=((e30c+e31e)&15)<<8, clock 9912=0, copy 256-colour palette from DGROUP 164A (day) or 1C4A (night, 368a) to 104A, set palette (14C2:0000), 1039:009D | med | 4987, 499B, 49B3/49B8 |
| 0000:4BEC | 135 | load_world_from_block() | 4E4B; deba=1 -> 4D5D copies world state block+0x7A -> DGROUP; build string ptr table df08[1..127] from pool E016 (0x2EE B); place player at departure base [e308]: ba3c=x<<5+2, c056=(0x8000-y)<<5 | high | 4BF4, 4C0D loop, 4C52/4C69 |
| 0000:4C73 | 210 | register_targets() | for the 2 mission targets (E30B!=0): look up 3D object at target site coords (0D14), copy name class c630, make new name string, 0F3D; set site B2DC = idx+0x100 | med | 4C87, 4CB9, 4D29 |

### timer (11)

| addr | size | alias | role | conf | evidence |
|---|---|---|---|---|---|
| 0000:04C7 | 30 | `wait_ticks(n)` | busy-waits until byte ds:264A (incremented by frame tick 1E79) advances by n | high | 04CB..04E1 |
| 0000:1C0E | 33 | `timer_install()` | ds:2636=1, ds:2640=1, ds:262C/262E=0; 1D88 calibrate; save INT 8 -> cs:1CFD (chain target for `jmp far` at 1CFC); install cs:1C9B; ds:262B=1 | high | 1C0E..1C4B |
| 0000:1C4C | (33) | `timer_restore()` (entry inside 1C0E block) | PIT ch0 mode 3 count 0 (18.2 Hz), restore INT 8, ds:262B=0 | high | 1C4C..1C6C; reached by `jmp` from 0235 |
| 0000:1C6D | (24) | `timer_fast()` (island) | ds:2636=ds:2639 (ticks per frame), PIT reload ds:2630=ds:263B/ds:2636 (applied at next resync), ds:2638=1 | high | vd.py 1C6D |
| 0000:1C85 | (18) | `timer_normal()` (island) | ds:2636=1, ds:2630=ds:263B | high |  |
| 0000:1C9B | (102) | `int8_handler` (island) | ds:262C/262E += reload (BIOS-tick accumulator); --ds:2640==0 -> reload from ds:2636, 1D01 resync, ds:262A=0 (frame ready), 1E79 frame tick; if ds:2636!=1 call T:0322 (sound fast tick); chains to old INT 8 when accumulator carries (ds:262E) else EOI | high | 1C9B..1CFC |
| 0000:1D01 | (135) | `timer_resync()` (island) | every 20 frames (ds:2638): if vsync mode ds:263F, waits for retrace edge on 3DA (or 3BA bit7), then reprograms PIT ch0 with ds:2630; ++ds:2634; ds:2642 = remaining poll | high | 1D01..1D87 |
| 0000:1D88 | 54 | `timer_calibrate()` | measures 16 retrace periods with PIT (1E1D) -> ds:263B counts/frame; ds:2639 = frames ratio check (4..6 ok, ds:263F=1 vsync-locked) else fallback ds:263B=0x4DAE (=60 Hz), ds:2639=5, ds:263F=0; ds:2630=ds:2632=ds:263B/ds:2636 | high | 1D88..1E1C |
| 0000:1E1D | 45 | `wait_retrace_read_pit()` | waits for vertical-retrace edge (port [0:0463]+6 = 3DA bit3, or 3BA bit7 for mono) then latches/reads PIT ch0 count | high | 1E1D..1E71 |
| 0000:1E72 | 7 | `bios_ticks()` | INT 1Ah AH=0, returns DX (low word of tick count) | high | caller C880 (random seed ?) |
| 0000:1E79 | (55) | `frame_tick()` (island) | ++ds:2646 (word), ++ds:264A (byte), ++ds:2648; T:0200 (gfx slot 46, MGRAPHIC 125C: page flip/vsync hook ?); ds:264B mod 7: on 6 of 7 ticks call T:031D (sound tick) -> ax>0: timer_fast, ax<0: timer_normal | high | vd.py 1E79 |

### input (4)

| addr | size | alias | role | conf | evidence |
|---|---|---|---|---|---|
| 0000:1BB3 | (15) | `int1b_handler` (data island) | sets ds:2624=0xFF (Ctrl-Break) | high | bytes 1E 50 B8 42 1E 8E D8 C6 06 24 26 FF 58 1F CF |
| 0000:3A4E | 47 | pause_wait_key() | sound 0x19 (silence?), loop kbhit/getkey ignoring Alt-P (0x1900), D41F (restore sound), restore tick counter 2646 so paused time is not simulated | high | 3A52..3A78 |
| 0000:C89C | 45 | read_input_ch(n) | If shared block +0x72 bit0: MISC driver thunk 1E42:02EB(n) else 0; plus offset ds:43EE[n]. C89C(1) used as camera/fire button latch (ds:9534) | med | block +0x72, MISC thunk 02EB |
| 0000:C8CA | 1475 | `key_command(key)` | In-flight keyboard command dispatcher, arg = BIOS key word (scan<<8 \| ascii) from [debc]; key 0 skips to per-frame tail D17F (fire button, cooldowns, gear/bay/jammer animation + lamps) | high | sole caller 450A pushes [debc] (filled in 1EB0 via EBC4/EE6A = kbhit/int16); compare chains CE65..D027, C904..C937, D04F..D0C2; jump table CE8D (8 entries, keys '1'..'8') |

### flight (6)

| addr | size | alias | role | conf | evidence |
|---|---|---|---|---|---|
| 0000:1EB0 | 3543 | flight_update() | Per-frame player flight step: first-frame init, flight-key dispatch (reads the frame's BIOS key into ds:DEBC), stick input (joystick or keypad), autopilot, ejection sequence, engine/fuel, load factor, stall speed, thrust/speed integration, attitude matrix update, altitude/position integration, ground contact & landing/crash check, history ring, chase-camera rates | high | called once per loop from 1BCE:1BFF; only caller of EE6A/EBC4 besides 3A4E; writes 2DEE/2DF0/2DF2/2DF4/2DF6, B07E, BA3C, C056; key switch 1F2D..1F82 |
| 0000:2C87 | 50 | mat_mul_into_attitude(A,B) | tmp(ds:2DDC)=114A_04B4(A,B) (3x3 matrix mul), memcpy(2D94,2DDC,0x12); every 8th call sets rebuild flag 2DFB | high | 2C8B..2CB4; called 3x from 1EB0 (28C4,28FF,2937) |
| 0000:2CB9 | 421 | attitude_matrix_to_euler() | pitch 2DF0=asin(-m[5] @2D9E); heading 2DEE and roll 2DF2 from m[1],m[2],m[3],m[4],m[8] via 2E7F/2ED9/2F4A with quadrant fixes; sets 2DFB near ±80° pitch | high | writes 2DEE/2DF0/2DF2 from 2D96..2DA4 |
| 0000:2E5E | 33 | rebuild_attitude_matrix() | DFA9(&2D94, heading, pitch, roll) (Euler→matrix, re-orthonormalise), clears 2DFB/2DF8 | high | 2E5E..2E7E |
| 0000:D441 | 100 | `recalc_timestep()` | clamp [368e] (sim frames per second) to [4-[3da8]..15]; derive [43e8] (=clamp((-120/v+9)/2,1,4) when v>15), [b198]=clamp(2*dt,3,16), [b2b2]=dt*250, [9f94]=dt*200 | high | code D441..D4A4; FrameRate display CA8E prints [368e] and [43e8] |
| 0000:D4F5 | 21 | `time_accel_off()` | if [3da8]==2: [3da8]=1, [368e]*=2, D441 | high | D4FC..D506; key Shift-X |

### autopilot/INS (2)

| addr | size | alias | role | conf | evidence |
|---|---|---|---|---|---|
| 0000:4F2B | 173 | ils_glideslope() | if !(9b34&1): compute glide angle to nearest base e00c (carrier: -0x18/-0x80 offsets) vs pitch; [46f2]=0 off/1 low/2 on slope/3 high (threshold 0x5B0) | med | 4FA4..4FC8 |
| 0000:D50A | 35 | `set_waypoint_from_obj(slot, obj)` | waypoint table ds:2e9e[slot]{x,y} (4-byte) = object table 0xB2D0[obj*16] +0/+2 | high | D514 [bx-0x4d30] (=0xB2D0), D51E [si+0x2e9e] |

### weapons (9)

| addr | size | alias | role | conf | evidence |
|---|---|---|---|---|---|
| 0000:0300 | 206 | `build_ordnance_panel()` | load ordnance.pic to page 1; for 4 bays (2 if blk1272+42!=0): weapon type = block+38+2*i, icon idx = word ds:36A8+type*0x1A, icon src rect ds:00A2/00A4[idx*4]; blit 0x4D x 0x0F to (0xA9, 0x6E+15*i) with T:01EC; T:01BF(0x2F); T:0160 page sel; clip ds:2299..229F; 0FB2_0324; T:0296?; T:029B(2,0xA9,0x6E,0x4D,0x3C) save rect -> handle ds:BA3A; T:02A0 | high | 0305..03CB, ds:010D "ordnance.pic" |
| 0000:4777 | 321 | gun_tick() | move gun bullets table E47A (b198+4 slots); on odd frames if trigger C89C(0) and rounds 3682>0 and !c09a: rounds -= 40/fps, sound 6, spawn bullet at player with velocity from heading 2dee/pitch 2df0, z=alt-2; 991a=firing flag | high | 4791..47AC integrate, 4801..489C spawn; skipped when blk1272+0x42!=0 |
| 0000:49F9 | 73 | rearm() | clear 3664/c5f4, bay counts 3672[i]=9 if weapon type 3670[i]<0x10 else 1, gun 3682=1000, fuel 3666=5000 | med | caller C8CA @D0C4 (key) |
| 0000:683E | 2565 | missiles_update() | Updates 12 missile slots (0..7 enemy-fired vs player, 8..11 player-fired): seeker lock, ECM/decoy/flare/chaff effects, steering, motion, terrain impact, hit resolution & damage, bomb/equipment drop resolution, map plotting | high | loop `[bp-0x1e]<0xC`, stride 0x1C at 0x3C3A; strings " misses ", " destroyed by ", "Blast damage", "Equipment Delivered", "Bad Drop", " ground impact", "Hit by ", "Ineffective", " hit by " |
| 0000:7243 | 149 | missile_seek(mslot,tx,ty,talt,class) | Bearing [9526] and distance [9524] from missile to target; returns 1 if within seeker cone (\|err\|<=0x1000, class 3 exempt; class 0 = IR needs tail aspect \|mslheading-playerheading\|<=0x2000); \|err\|>0x6000 for AI missile out of energy => kill (life=0) | high | C6B3=dist, C702=atan2; writes 9524/9526 |
| 0000:7663 | 666 | weapon_release() | Fire/drop selected store [3680] (bay table 3670): checks \|roll\|<=0x3000, count>0, bay doors open (9b34&4 — "Bay closed"), altitude (2df6 — "Insufficient Altitude"); fuel tank store (missile idx -2) => fuel [3666]+=0x76C "Fuel transfer"; else take free slot 8..11, init from player state, lifetime from range, target from designated ground target [3d94] if lock [e588]; bombs half speed; RTBOMB pitch 0xC000; [b07c]=slot; "<store> fired"; sound 0xD/0x10 | high | strings 3EFA/3F05/3F1B/3F29; caller C8CA (key dispatch) |
| 0000:8A67 | 40 | wpn_vs_target(w,obj) | Return byte ds:3898[w*16 + (ds:C630[type(obj)&0x7F] & 0xF)] — weapon-vs-target-class table (?effect/kill prob) | med | callers 683E, 9EFA (hit resolution) |
| 0000:93E9 | 196 | mfd_stores_page() | Right page 0x15: clear, for each bay (2 or 4, by mission+0x42) print count [3672+4i] and weapon name (table 3690 stride 0x1A, +0xA long name) | high | caller 825D, C8CA |
| 0000:B96C | 37 | ccip_angle() | Returns angle from\|pitch 2DF0\|and altitude 2DF4 (((0x4000−\|pitch\|)<<12)/(alt+0x1000) − 0x4000); used for bomb pipper placement (?) | low | used at AD89 only for weapon idx 0x1E/0x1D |

### countermeasures (4)

| addr | size | alias | role | conf | evidence |
|---|---|---|---|---|---|
| 0000:450A | 187 | keys_and_signature() | Calls C8CA(last key [debc]) = keyboard command dispatcher, then computes stealth signature [3d8a] = f(alt 2df4 or skill 3686) + speed b07e>>10 + bank/2 + extras (9b34 bits 4:+0x18, 0x10:+0x10) | high | 450E push [debc]; 4597 writes 3d8a; 3d8a compared to 100 in 528D/5582 |
| 0000:45C5 | 27 | draw_cm_counts() | loop i=1..3 -> 45E0(i) | high | 45CE loop <4 |
| 0000:462E | 266 | release_cm(type) | type 1 Flare/2 Chaff/3 Decoy: dec count 3668[type] ("Stores exhausted"), alloc slot in CM table 39D8 (decoy slot 0 only, needs !(3664&0x40)), lifetime (9-2*skill)*fps (decoy x8); flare->3dbe=3*fps, chaff->3dbc=3*fps; message "<X> released"; sound 0xF | high | strings; 46A1..46C2 table writes |
| 0000:4738 | 63 | cm_tick() | decrement CM lifetimes 39E0[i]; decoy slot drives indicator 7 (889B(7,0x29/0)) | high | 4757, 476E |

### AI (3)

| addr | size | alias | role | conf | evidence |
|---|---|---|---|---|---|
| 0000:5852 | 2976 | ai_aircraft_update() | Per-frame update of all enemy/neutral aircraft slots 0..[defc]-1: target selection (patrol / formation / RTB / attack), AI gunfire, maneuver-table steering, flight integration, crash, landing, takeoff scramble, detection | high | only caller 3ADA; loop `imul bx,slot,0x24` on 0xC16A array; strings " landing"/" on final"; calls 63F2, 66F8, 78FD, 4B03, 8625 |
| 0000:63F2 | 774 | ai_detect_and_fire(slot) | One AI aircraft's sensor pass: radar/visual detection of player via 5582 (radar idx = type+0x18), sets RWR vars (c09c, c166/c168, 98a2, c0aa, e578), alert accumulator slot+0x22; >0xC0 => detected (df02++, flag 0x4000, 56BB); close => "Visual ID - <type>" (flag 0x800, defa++, log 6); launch AAM into missile slot (slot&7) "X fired by <type>", block+0x2C++ | high | strings 3E45/3E52; writes 3C3A.. missile slot; `inc es:[bx+0x2c]` at 66AA |
| 0000:66F8 | 325 | ai_takeoff(slot, airfieldObj) | Spawn aircraft on airfield/carrier: pos from ground obj (carrier if objflags byte&2: alt 0x8C, speed 100; land: alt 12, speed 10), heading 0/0x8000 by [b19a], flags \|=0x403, base=obj, loiter timer = type.+0x12 * (type.+0x14*[368e])>>11; msg "<loc> : <type> taking off" | high | string 3E61; called from 5852 scramble branch and 3ADA |

### SAM/radar/ground (9)

| addr | size | alias | role | conf | evidence |
|---|---|---|---|---|---|
| 0000:0D14 | 553 | `find_nearest_ground_obj(long x, long y)` | scans levels 1..2, 9 neighbour tiles, tile object lists; skips types with ds:C630[type]==0; candidates need ds:07E0[type]!=0 or ds:3DA4 or destroyed-state match; keeps min Manhattan distance; result record ds:BA40 {+0 type/state, +2 dist, +4 long x, +8 long y, +C objptr, +E level,+F tile,+10 idx,+11 ?}; returns 0xBA40 or 0 | high | 0D1A..0F3C; callers 3ADA,4C73,73C8,B850 |
| 0000:5046 | 583 | radar_threat_tick() | redraw signature (EMV) bar meters (114A:033C) when 3d8a changes; for each radar site (<992c, type B2D4!=0, alive): scan timer B2DA, rate from alert B2D8 & aggressiveness 3688; at tick 4 and no current lock -> 528D(site); after loop draw active radar beam on map (8625/8719) from site/aircraft [c0aa]; 3d98-- | high | 5106..5144, 5211, 5280 |
| 0000:528D | 757 | radar_sweep(site) | 5582 detection; strength bar, c09c, 3d98=fps, c0aa=site, beam width c166/c168; first detection "<site> detected"; if sig+det>100: warning 56A9, alert += (3688+3686+1)*16, >0x7F -> 56BB (global alert); if alert>0xC0 & dist-to-base>0x500: first time >=0xFA "- Radar ID" (event 7, defe++), else launch SAM in slot site&7 of 3C3A table if in range: "<site> firing <SAM>", block+0x2C++ | high | strings; 54DB..5555 |
| 0000:5582 | 295 | radar_detect(x,y,alt,type,&brg,&rng) | detection value: (radar.range-dist)*(terrain clutter b1a0[cell]&0xC)*(2*skill+radar.sens+1); doppler radars (flags bit0) scaled by speed b07e and aspect vs heading; 0 if alt diff>>10 > dist; >100 incl. signature -> D4F5 (cancel time accel); halved if blk1272+0x42 | high | 55BC [type*0xE+2EBA], 55EB, 5632 |
| 0000:56BB | 86 | global_alert() | alert timer 3d90=[b2b2]; last known player pos b2cc/b786/b79a (= decoy pos if decoy active 39E0), heading 9920; c0e2=0xFF; raise all sites (<e56c) alert to >= (3688+3686-1)*16 | high | 56CB..5725 |
| 0000:5737 | 282 | manpads_tick() | UNREFERENCED (in "data" gap 5737..57E7, code continues to 5850): every 16 clock ticks, if player cell b1a0 bit 0x10 and !98a4, fire SA-14 (missile type 0x21) from random point in cell; "SA-14 fired"; 56BB | med | no E8 call/word ref found to 5737 |
| 0000:B850 | 181 | ground_obj_lookup(x,y) | Finds map object at world (x,y): 0D14(x<<5,(0x8000−y)<<5) → tile-object ptr ds:9F40; converts back and searches go[1..C0E0) for same x,y → returns index; if none, writes it into go[0] (x,y, shape = rec[0]+0x100) and returns 0; returns -1 if no object | high | calls 0D14, loop vs C0E0, writes B2D0/B2D2/B2DC |
| 0000:B9F6 | 21 | is_ship_class(i) | 1 if class nibble of ds:C630[go[i].shape&0x7F] ∈ {9,0xB,0xC,0xD} (naval?) | med | table C630, consts 9/B/C/D |
| 0000:BA2B | 43 | is_class_CD(i) | 1 if class nibble ∈ {0xC,0xD} (?) | med | same table |

### damage/scoring (12)

| addr | size | alias | role | conf | evidence |
|---|---|---|---|---|---|
| 0000:0F3D | 128 | `set_obj_state(rec, state)` | writes state into ds:B79E table (5-byte entries: 4 key bytes level/tile/idx/? + state; count ds:9932) or appends; sets objptr+6 bit 0x80 (object altered); special when key == ds:DED0 / ds:C0D8 | high | 0F41..0FBB |
| 0000:0FBD | 74 | `get_obj_state(k0,k1,k2,k3)` | linear search ds:B79E 5-byte table backwards; returns state byte or 0; ds:950C = index | high | 0FC0..1006 |
| 0000:3ADA | 2608 | sim_frame() | Per-frame world/mission step: first-frame mission setup (c0da==1), map clamp, map plot, calls threat (5046), AI (5852), weapons/hits (683E), CM/gun/smoke/ILS, nearest-airbase & landing/crash/eject checks, clock, adaptive frame rate, ends with 450A (key dispatch). See Sub-structure | high | called from main loop 1BCE after 1EB0; strings "Cargo delivered"/"Safe Landing"; calls 4A42(0/1/2) |
| 0000:4958 | 27 | fall_tick() | integrates c62e += b782, b782 -= 12 (min -16): falling body (cargo/debris?) | low | 4966 |
| 0000:4A42 | 120 | end_mission(code) | code 7: set quit flag e57e only (used by quit key in 1EB0 with exit=0). else (if c09a==0 or code==0): e57e=1, block+0x28=code, block+0x26=3 if code==0 && !c09a, block+0x74/+0x76=map x/y, +0x34=[3664], +0x36=[c5f4]; log event 8 | high | 4A4B..4AB3 |
| 0000:4ABA | 73 | log_event(type,arg) | append 6-byte record to log at ds:BA56 (max 255, count 951a); zero type byte of next | high | 4ACD..4AFC |
| 0000:72D8 | 240 | aircraft_destroyed(slot) | Kill AI aircraft: type kill counter (type+0x1E)++, flag 0x20 (falling), wreck pos c0d2/c0e4/c62e, b782=0x80, mission-target check (slot 0 when goal type>=5 => 7594(0)), log event 3 (or 0x83), msg "<type>", sound 5, 9d3e=1 if it was the locked air target | high | `inc [bx+0x3012]`, `or [..c182],0x20` |
| 0000:73C8 | 460 | ground_obj_destroyed(obj) | Destroy ground object: B2D6\|=0x80, defe-- if radar (B2D6&0x1000), spawn wreck 3D object via 0D14 (world long coords x<<5,(0x8000-y)<<5) -> [9f40], mission goal check (E304 records, goal type 2) -> 7594, log event; obj 0 = terrain feature hit (792E, counter c0e6[type]++, log 2); set wreck shape 0F3D; [3d96]=obj; sound 5 | high | callers 683E, 9EFA; `or byte [bx+B2D6],0x80` |
| 0000:7594 | 134 | mission_target_achieved(n) | n=0 primary / 1 secondary: once-only via 9b34 bit (0x4000>>n); log 0x8B/0x4B for goal types 3/4; msg "Primary target"/"Second. target"; [2eae]=2/1 (3 if both); 9b35 \|= 0x40/0x20 | high | strings 3EEB/3EDC |
| 0000:761A | 73 | player_hit() | Unless invulnerable (9b35&0x10): ([3686]+1) random damage bits ORed into [3664] (damage bitmask), [c5f4]++ (hit count), 83E9(0x16) (damage MFD page?), [991e]=1, sound 4 | high | `C88C(8)` random 0..7, `or [3664],1<<r` |
| 0000:792E | 63 | obj_can_be_wrecked(obj) | Returns 0 if 3D object [9f40] already has the destroyed shape (c0d8 or ded0 chosen by B9F6(obj)) or its linked object is the same, else 1 | med | reads [9f40]+0, +0xC, byte +6 &0x7f |
| 0000:9515 | 200 | mfd_mission_page() | Right page 0x18: for primary/secondary (bits 0x4000>>i of [9B34] = completed → "PRIMARY/SECONDARY Mission Completed") else objective text by type (jump table 95AE: 1 Photograph enemy, 2 Destroy enemy, 3 Drop supplies over, 4 Land supplies at, 5 Hit AN72 flying to, 6 Plane returning to, 7 Hit AN72 leaving, 8 Destroy plane over) + target name + " at <place>" (4B8F) + "Before hh:mm:ss"/"Time expired" if deadline flag; then "Return to <home>" ([E31A]) | high | strings 4146..4212; jump table @95AE |

### 3D/terrain (37)

| addr | size | alias | role | conf | evidence |
|---|---|---|---|---|---|
| 0000:03CE | 249 | `render_world_view(...)` | per-view 3D render: sets window rect in struct ds:[0344] (+0E..+14) from args, T:01FB; 04C7(ds:43E8) frame wait; ds:7D80 = 0x7F90 (detail 3) / 0x8390; clears ds:C05C/C06E/C070/98A4 (set 1 if byte ds:11E2<0x14); D826 begin frame (camera); 04E6 terrain/objects; 983E; D87C; ds:7D80=0x7D90; 9EFA overlay (saves ds:C6B2); toggles ds:0346 | high | caller 2F9D (cockpit view loop); 03D2..04C5 |
| 0000:04E6 | 810 | `draw_terrain_objects(cam...)` | LOD loop ds:E328 = 4..1 (skips levels with ds:04FA[l]==0); converts camera pos per level (0810, F018 >>12), then for 9 (or 15) neighbouring tiles (offset tables ds:04CC/ds:04DE) gets tile id (0871), walks the tile's 7-byte object list (ptr table ds:E330[level*32+tile], count ds:061E[level*32+tile]) and submits each object (E2B6 / C436 transform) with destroyed-state substitution (0FBD); ds:9506/9508/950A = tile-relative eye pos | high | 0502..080E |
| 0000:0810 | 97 | `coord_to_level(level, long c)` | rescales a 32-bit world coord to LOD level: L0 c<<1, L1 c, L2 (c+2)>>2, L3 (c+8)>>4, L4 (c+0x20)>>6 (F018 = long sar) | high | 0816..086F |
| 0000:0871 | 276 | `map_tile(level,x,y)` | hierarchical terrain map lookup; bounds ds:0506[level] (1024,256,64,16,8); L4 byte ds:B03C[y*8+x]; L3 byte ds:9F98[y*16+x]; L2/L1/L0 recurse on (x>>2,y>>2) one level up, then byte from pattern tables ds:9D40/9B38/9934[tile*16 + (y&3)*4 + (x&3)]; returns 0 if out of range; L4 offsets x,y by +2 | high | 0875..0982 |
| 0000:1007 | 417 | `nearest_tall_obj_test(x,y,z)` | via 78FD (coords >>5, y=0x8000-y): on L4 tile, objects whose shape flag ds:0960[type]&0x10 and !(byte+6 & 0x50): picks nearest, computes rel pos ds:4994/96/98, shape seg ds:8590 = ds:B78A[ds:0511[type*2]], identity matrix 1452_03AB(0,0,0,ds:49D0), 120A_01B4(type,dx,dz,-dy,ds:49D0); ds:C6B2 cleared first => collision vs tall structures (?) | med | 100D..11A4; callers 78FD<-5852,683E |
| 0000:1450 | 868 | `draw_sky_ground(win)` | horizon gradient: detail ds:990E<3 -> flat fill 0FB2_0000(win+4); else 16 sky bands (band offsets ds:0D22) as quads via 0FB2_01E6, colours 0x80+i (0x88 if ds:438E&&ds:43E0 = night/IR?), then 16 ground bands colours 0x70+i (0x7C if same flag); uses pitch/roll ds:49B6/49B8/49BA/49BC (copied to ds:9928/9F42/98F8/9914), sin/cos via 104E_0000, zoom ds:4368, halved if ds:294B; band table ds:C0AC[16] | high | 1456..17B0; caller D826 |
| 0000:1A98 | 81 | `draw_sprite_scaled(x,y,size,idx)` | centred scaled bitmap (h=size*3/4) via T:0188 (MGRAPHIC 0B70) on page ds:4070 (if ds:0348) or ds:0344; sprite table far ptrs ds:91B8[idx*4] | med | caller 9EFA (explosions/billboards ?) |
| 0000:1AE9 | 69 | `draw_sprite2_scaled(...)` | same, sprite table ds:9208[idx*4], page ds:0344 | med | caller DC46 |
| 0000:1B2E | 69 | `draw_sprite2_scaled_p(...)` | same as 1AE9 but page ds:4070 | med | caller DC46 |
| 0000:2F9D | 1969 | view_update_and_render() | Per-frame: select camera from view code C0A6 (cockpit/look/external/tracking views), build camera pos/orient, switch cockpit pic & viewport on view change, call 03CE to render 3D world, draw per-view overlay (cockpit frames, external-view flight data text), store viewport height in 2E66 | high | first call of loop (1BCE:1BCE); loads 256pit/256left/256right/256rear.pic at 369F/371A/3740/3747; call 03CE at 37A5; "HEADING AIRSPEED ALTITUDE" 3928 |
| 0000:48B8 | 160 | smoke_tick() | 16 smoke puffs table 3A08 (8 B): rise/drift; every 8 frames emit puff at burning site [3d96]; 3a88=newest | med | 48D2.., 490F |
| 0000:4E5F | 204 | time_of_day_palette() | at clock&0x3F in {0,0x10,0x20,0x30} (and clock&0x40) blend/copy palette ranges from day 164A / night 1C4A tables (x3 RGB) and upload (14C2:0000): dusk/dawn sky colours | med | 4E63..4F24 |
| 0000:78FD | 49 | terrain_collide(x,y,alt) | Convert to world long coords (x<<5, (0x8000-y)<<5, alt) and call 1007; result in byte [c6b2] (nonzero = hit terrain/obstacle) | med | callers 5852 (sets slot flag 0x2000 = pull up), 683E (impact) |
| 0000:983E | 1724 | world_objects_draw() | 3D object pass (called by 03CE with 9EFA): own aircraft model in external views, ground-target auto-select, explosion/smoke sprites, aircraft models + shadows, missiles, cargo/parachute (?), own shadow | high | BB0D (3D shape draw) with shapes 0x18/0x11/0x0B; see sub-structure |
| 0000:B5DC | 438 | project_to_hud(x,y,z) | World point → screen: d=(player−p) (z>>5), external-camera offset when C0A6&0x80, rotate by view matrix ds:B082 (B792 rows 0..2); if in front: X=160+x*256/z → 4A10, Y=(y*256/z)*3/4 + (0x3C or 0x34 cockpit / 0x64 no-HUD) → 4A18; depth z>>3 → DEBE; off-screen → 4A10=-1 (raw x kept in 952C) | high | 0xA0 add, EF68 shl 8 + EE9C div, writes 4A10/4A18/DEBE/952C |
| 0000:B792 | 84 | view_dot(row,dx,dy,dz) | 32-bit dot product of (dx,dy,dz) with view-matrix row `row` (words at ds:B082+2r, B088+2r, B08E+2r) using fixmul 104E:0000 | high | three 104E_0000 calls on B082/B088/B08E |
| 0000:B7E6 | 106 | depth_along_view(a1..a6) | Depth of point relative to eye along forward vector ds:49C2/49C8/49CE (Δz>>5) → result>>3 stored in DEBE | med | 104E_0000 with 49C2/49C8/49CE, writes DEBE |
| 0000:B991 | 101 | ground_obj_shape(i) | Shape id for go[i]: C436(go[i]+0xC); if destroyed (flag 0x80 at +6): either tile byte (ptr table ds:0A60)&0x20 → shape\|0x100, else wreck shape [C0D8] (ship class, B9F6) or [DED0]\|0x100 | med | B2D6&0x80, tables 0A60, C0D8/DED0 |
| 0000:BA56 | 76 | set_bg_for_aircraft(i) | Sets render flag ds:49F6 from coarse map ds:B1A0[(y>>11)*16+(x>>11)]&3 under ac[i] (0/1 rule differs for last 4 aircraft slots) — backdrop sky/ground choice for target cam (?) | low | B1A0 grid, writes 49F6 |
| 0000:BB0D | 338 | draw_world_obj(shape,x32,y32,z,h,p,r,scale) | Draws 3D object at 32-bit world position relative to main eye (BA3C:BA3E, C056:C058(+0x1000000), alt 2DF4) or external camera (B2B4/B77E/B788 when C0A6&0x80); scale shifts; D9E7 (set offset) + E2B6 (draw) ; page [4010]/[4028] by 40B6 | med | caller 983E, E2B6/D9E7 |
| 0000:BC5F | 144 | draw_obj_mfdcam(shape,x32,y32,z,h,p,r) | Same as BB0D but relative to MFD-camera eye B792:B794/B796:B798/B834 | med | B792/B796/B834 |
| 0000:C436 | 38 | shape_resolve(s) | If bit8 of s set: ds:0510[s&0x7F]\|(s&0x8000) else s (shape alias table, runtime-filled) | med | table 0510 |
| 0000:C4BA | 248 | draw_fire_particles(x,y,z,h,p,r) | 6 flame particles (ds:3A8A, 8 bytes: dx,dy,frame,active), random offsets from table ds:4398, shapes 0x24 / 0x25+frame via E2B6 | med | loop 6, C88C(7)/C88C(2), 0x24/0x25 |
| 0000:C5B2 | 200 | draw_smoke_list(a,b,c) | 16 entries ds:3A08 (8 bytes: x,y,z,type) projected (B7E6) and drawn as shape 0x25 via BC5F, size from depth DEBE and 114A_0461; skipped if 3D96==-1 | med | loop 0x10, BC5F(0x25,...) |
| 0000:D4A5 | 80 | `recalc_detail()` | from detail level [990e]: LOD distance table ds:48d6[6] = 0x20<<(i+lvl); [48e2]=[48de]+[48e0]; [48e4]=clamp(2*[48e0],0x1000,9999); far clip [48e6]=(lvl+1)*0xD05 | high | D4B5..D4F0; [48e6] used as far-z cull in E3BF (E435) |
| 0000:D826 | 86 | `view_begin(vp, ang a,b,c, cam x,y,z, terrain_flag, ?)` | start a 3D view: D8AF viewport, D9A2 camera rotation, D9E7 camera position; if flag: [c6b2]=0, [8590]=[b78c], 120A:0F97, wait until timer clears [262a], then 1450 (sky/terrain); reset object list [49f4]=0 | high | code D826..D87B |
| 0000:D87C | 51 | `view_end()` | DC46 (draw sorted objects), thunk 0192, advance [c07a]/[c078] by [4ed0]<<7 (*9/*8), save camera matrix 49be->49e2 (18 bytes) | high | D880..D8AA |
| 0000:D8AF | 243 | `viewport_setup(vp)` | from viewport struct {+0 idx,+0E x0,+10 x1,+12 y0,+14 y1}: screen centre [d1e]/[d20] (horizon y forced to 0x3c/0x34/0x64 when x0==0 depending on cockpit [368c]/[294b]), clip rect ds:85fa..8604, [2293]/[2295] w/h, gfx thunks 025F/0250/019C, perspective tables [e56a]/[e570] (0x4906/0x4916 +0x20 in cockpit) | high | code D8B4..D99E |
| 0000:D9A2 | 69 | `camera_set_angles(a,b,c,d)` | camera matrix ds:49be = DFA9(-a,-b,-c); 1452:03AB -> matrix ds:49d0; 120A:0008(49d0,d) (horizon setup ?) | med | D9B9 push 0x49be |
| 0000:D9E7 | 23 | `camera_set_pos(x,y,z)` | [49ac],[49ae],[49b0] = camera translation | high |  |
| 0000:D9FE | 318 | `queue_world_object(shape, x32, y32, alt, ya, pi, ro)` | world object -> relative to player ([ba3c:ba3e] X, [c056:c058] Y (+0x1000000 bias), [2df4] alt) or to external camera ([b2b4:b2b6],[b77e:b780],[b788]) when [c0a6]&0x80; scale by [294b]; reject if >0x7fff; E3AC cull; then DB3C insert | high | DA0A..DA78; [e328]=1 |
| 0000:DB3C | 266 | `objlist_insert()` | insert transformed object (globals 4986..499e) into depth-sorted draw list: 22-byte records at ds:4a20, pointer array ds:4e6c (max 50=0x32), key = 32-bit depth [4990:4992]<<shift; full list -> drops first entry | high | DB40 cmp 0x32; DB6E imul 0x16 +0x4a20 |
| 0000:DC46 | 867 | `objlist_draw()` | draw object list back-to-front: per 22-byte rec {+0 depth32,+4 colour,+6 flags,+8 shape(id, 0x400=sprite via 1AE9, 0x8000 no-sort),+A/+C/+E cam xyz,+10/12/14 angles}; shape 0x18 = player F-117 (gear [c09e], hook bit [9b34]&8, bay [9908] animation, parts 0x21/0x22/0x23 ordered by facing); 1452:03AB object matrix, 120A:00CF draw shape; ids>=0x25 also get label sprite via 1B2E (table ds:4ed2) | high | DC54..DFA4 |
| 0000:E2B6 | 127 | `draw_object_now(shape, ya,pi,ro, x,y,z)` | immediate (unsorted) shape draw: shape flags from ds:0a60[hi][lo] (&7 -> size class [49aa]); E3BF cull; if flag 0x80 -> DB3C queue else 1039:011A colour, 1452:03AB, transpose, 120A:00CF | high | E2E9 [bx+0xa60] |
| 0000:E3AC | 19 | `cull_point(x,y,z)` | wrapper: E3BF with bp,bx,cx = x,y,z | high |  |
| 0000:E3BF | 236 | `transform_and_cull()` | rotate point by camera matrix 49be (3x3) -> 32-bit cam coords [4988],[498c],[4990]; cull vs far [48e6], near [48f6+2*[49aa]], x/y frustum via tables ds:4966/4976 when [438e] else [e56a]/[e570] (formulas in vgame-asm.md §4); [49a8] = approx distance; returns AX=1 (ZF=0) if culled | high | code E3BF..E52F (capstone, vgame-asm.md §4) |
| 0000:E530 | 86 | `palette_step(far cur, far target, n)` | move n RGB triples of cur one step toward target, return number changed (palette fade, e.g. day/night/flash) | high | loop E541; callers 4973, 4E5F then 14C2:0000 |

### cockpit/HUD/MFD (61)

| addr | size | alias | role | conf | evidence |
|---|---|---|---|---|---|
| 0000:01B9 | 8 | `redraw_lamps2()` | 1039_0000 then falls into 01C1 | med | caller C8CA |
| 0000:01C1 | 116 | `draw_cockpit_lamps()` (?) | 1058_000E; two T:01E7 calls on page ds:[4040] at (0,0x8C,0x1D)/(0x1E,0x40,0x25) with colours 0x0F/0x0A swapped by ds:43DE | low | 01C1..0234; T:01E7 is also used by D578 (lamp draw) |
| 0000:11A8 | 86 | `draw_map_view(win,cx,cy,zoom)` | D826 begin (view from above: args 0xC000 pitch?, 0x2000), T:0250/T:019C clip/page, 11FE plot objects, D87C end; ds:48C4=0, ds:7D8E=0 | high | caller 8462 (tactical map MFD, zoom ds:40AE) |
| 0000:11FE | 354 | `map_plot_objects(cx,cy,zoom)` | for passes ds:9518=4..0 (level = ds:0CFC[pass], mask ds:9516=0x80 for passes 0/1) computes visible tile range (1360) and draws every tile object with z==0 via 13F1; ds:950E tile size in pixels, ds:DEF8 shift, ds:7D8E | high | 1202..135F |
| 0000:1360 | 89 | `map_tile_range(...)` | screen rect (0,0)-(ds:2293,ds:2295) -> tile index range via 13B9, clamped to [0, ds:9510) | high | 1363..13B7 |
| 0000:13B9 | 56 | `map_screen_to_tile(sx,sy,&tx,&ty)` | (sx-ds:0D1E+ds:9512)/ds:950E, ((sy-ds:0D20)*4/3+ds:9514)/ds:950E (4:3 aspect) | high | 13BC..13EF |
| 0000:13F1 | 94 | `map_draw_obj(type,x,y)` | for level>=3 filter by ds:[A62][type]&0x80 == ds:9516; shape seg ds:8590=ds:B78C; identity matrix (1452_03AB); 120A_00CF(type,x,0,-y,ds:49D0,ds:C05A) draws shape top-down | high | 13F6..144C |
| 0000:17B4 | 448 | `draw_adi_ball()` | attitude indicator in 32x28 window at (0x109,0x8C): clears window ds:[0D1C] (ds:2293/2295=0x20/0x1C), draws 2-band horizon polygon from ds:9928/9F42/98F8/9914 (104E_0000 sin/cos), restores clip (0x13F,0xC7), 114A_03FD frame (0x109,0x8A,0x11C,...col 0x21), blits to cockpit via T:01EC using page ds:40B6 | high | main loop 1BE9 (when ds:C0A6==0) |
| 0000:1974 | 137 | `draw_sky_bands_win(y)` | 16 horizontal sky bands (offsets ds:0D24/0D22) in x 0xA9..0xF5, clipped at y>=0x6E, colours 0x80+i; window ds:[0D1C] | med | caller BCEF |
| 0000:19FD | 155 | `draw_ground_bands_win(y,mode)` | 16 bands below y in x 0xA9..0xF5, clipped at y<=0xA9, colours 0x70+i (0xF0+i if mode==1) | med | caller BCEF |
| 0000:39C0 | 77 | draw_cockpit_number(slot,val) | itoa(val)→ds:B2A0, pad to 2 chars in 2E7C ("0x" for <10), 3 chars if >99; D667(0,slot,str) | high | 39C4..3A08 |
| 0000:3A0D | 46 | draw_fuel_readout() | if in-cockpit (368C): 39C0(3, min(fuel 3666,9999)/10) | high | 3A18..3A34 |
| 0000:3A3B | 19 | draw_throttle_readout() | if 368C: 39C0(4, throttle 2E0A) | high | 3A42..3A48 |
| 0000:3A7D | 92 | redraw_cockpit_panel() | redraw all 0x25 lamps whose state ds:4712[i*12]!=0 on page [4010] (lamps <4 also on [4040]); MFDs 81E8(DF06), 825D(E008); fuel, throttle readouts; 45C5 | high | 3A86..3AD4 |
| 0000:45E0 | 78 | draw_cm_count(i) | itoa(3668[i]) and print at cockpit pos 3dca[i] via D667, only if cockpit drawn (368c) | high | 45F5 [bx+3668], 4623 [bx+3dca] |
| 0000:4FD8 | 73 | cm_lights() | countdown chaff 3dbc, flare 3dbe, alert 3dc0; indicators 0x0E,0x0F,0x18 via 5021 | high |  |
| 0000:5021 | 36 | set_light(idx,on) | if cockpit drawn and state 4712[idx*0xC] changed -> D578(page 4010, idx, on) | high | 5032 |
| 0000:56A9 | 18 | warn_light() | 3dc0=2*fps, sound 8 | high |  |
| 0000:796E | 80 | cockpit_reset_indicators() | 114A_0280(2,0); D578 lamps (4010:0x16,0x1D,0; 4040:0) set 1; [40ca]=0; [e008]=0x18 (default MFD page?) | low | called only from 4973 |
| 0000:79BE | 2090 | cockpit_overlay_update() | Per-frame HUD/instrument overlay: reads current back page (gfx thunk 1E42:01FB → [40B6]); target-type lamp swap ([E32A] vs [40CA]); stall/warning lamp blink; weapon line "<count> <weapon name>" + "GUN <rounds>"; flight-path marker; vertical-speed bar; ILS (971A) when [9B35]&4; air-target seeker circle; heading tape, airspeed & altitude numerics; "ACCEL" when time-accel [3DA8]>1; "TRAINING" when [9B35]&0x10; waypoint-reached detection (dist<0x200 → [2EAE]++ and message "Waypoint N reached"); waypoint bearing caret; transient message line [C5A4] while [40CC]>0 | high | strings GUN/ACCEL/TRAINING/Waypoint reached @7B81,7F48,7F62,7FA9; called only from main loop 1BCE @1BD1; no key reads |
| 0000:81E8 | 117 | mfd_left_set(mode) | Select left-MFD mode [DF06]: lamp off for old (table 40B8), mode 0 → moving map 8462(player x,y), mode 1 → clear MFD (114A:0280(1,0)); lamp on | high | writes DF06 @8238; lamp table ds:40B8 = {0x16,0x17} |
| 0000:825D | 229 | mfd_right_set(mode) | Select right-MFD page [E008]; mode 0x13 → view-direction page (8342 + clear), 0x14 → TIME/waypoints (8F71), 0x15 → stores (93E9), 0x18 → mission objectives (9515); lamp table 4096+mode*2; mode 0x13 also lamps 0x1B/0x19 ([483E], [43E0]) | high | switch @82D9; writes E008 @82EC |
| 0000:8342 | 167 | mfd_view_dir_text() | Print " Ahead "/" Right "/" Rear  "/" Left  " from view angle [E582] (0/4000/8000/C000) at (0xC5,0xC1) on page 4010, font chosen by [4856] | high | strings 40F8..4110; switch @838E |
| 0000:83E9 | 76 | mfd_refresh(mode) | If mode==0x16: draw 7 system-status lamps (889B(0xA+i, bit i of [3664] ? 0x0A : 0x29)); then if mode is the current right page, redraw it (825D) | high | loop @83F8, callers 761A/7663/C8CA with 0x14/0x15/0x16 |
| 0000:8435 | 45 | map_window_init() | Set map window rect DEC0=0x4A, E32E=0x96, DEC2=0x6E, E470=0xA9, 98FA=0x4D, 98FC=0x3C, [DF06]=0, then falls into 8575 | high | constants @8435; jmp 8575 |
| 0000:8462 | 275 | mfd_map_draw(x,y) | Draw left-MFD moving map centred on (x,y), heading-relative offset, zoom [40AE]: compute origin [40B2]/[40B4], terrain map 11A8(port 4058,...), plot ground objects with flags&0x84==4 (8625), then 94AD | high | uses 40AE shift 9-zoom; loop over obj table B2CE.. count C0E0 |
| 0000:8575 | 62 | mfd_zoom_in() | External view (C0A6&0x80): [3D9E]-- (camera distance?); else map mode 0: [40AE]++ (≤9) + redraw; radar mode 1: [40B0]++ (≤7) | high | called from C8CA @C93A |
| 0000:85B3 | 62 | mfd_zoom_out() | Inverse of 8575 ([3D9E]++, [40AE]-- ≥2, [40B0]-- ≥0) | high | called from C8CA @C93F |
| 0000:85F1 | 23 | map_x(wx) | ((wx-[40B2]) >> (10-[40AE])) + 0x70 | high | code |
| 0000:8608 | 29 | map_y(wy) | (((wy-[40B4]) >> (10-[40AE]))*3>>2) + 0x8B (4:3 aspect) | high | code |
| 0000:8625 | 165 | map_plot(wx,wy,colour,big) | Plot an object on map if map mode 0 and cockpit view, clip to window DEC0/E32E/DEC2/E470; 1 or 2x2 pixels; returns 1 if clipped | high | uses 8880 |
| 0000:86CA | 79 | map_project(wx,wy,&sx,&sy) | World→map coords with inside-window test (returns 1 if inside) | high | caller 3ADA |
| 0000:8719 | 168 | map_arc(cx,cy,r,colour,lines,a0,a1) | Draw circle/arc on map in 16-unit angle steps (high byte), as points or connected segments (87C1); used for SAM/radar range rings | med | caller 5046 (radar/SAM); C818/C831 = r·sin/cos |
| 0000:87C1 | 60 | map_line(x0,y0,x1,y1) | Map-window-clipped line (world coords → 85F1/8608 → 114A:0070) | high | clip rect DEC0..E470 pushed |
| 0000:87FD | 34 | line_screen(x0,y0,x1,y1) | Line clipped to full 320x200 (0..0x13F, 0..0xC7) via 114A:0070 | high | constants |
| 0000:881F | 75 | line_hud(x0,y0,x1,y1) | Line clipped to HUD window: [294B]? (0x63..0xDC,0x1E..0x5A) : (0x30..0x10F,0x0F..0x5A) | high | constants @882A/883B |
| 0000:886A | 22 | set_colour(c) | Store colour in port+4 of both draw pages (4010, 4028) | high | 16 callers |
| 0000:8880 | 27 | map_pixel(x,y,c) | set_colour + 1-pixel line | high | code |
| 0000:889B | 115 | lamp_set(idx,state) | Cockpit indicator lamp: table ds:3F30 stride 6 {sprite, ?, cur state}; if changed draw sprite (D578) on page 4010 (idx 2 also on 4040); only in cockpit view | high | table read @88AD..8908 |
| 0000:890E | 80 | mfd_text(side,col,row,str,colour) | Text in MFD cell grid: side 1 left x=0x4A+4*col, side 2 right x=0xA9+4*col, y=0x6E+6*row | high | constants; strings at 0x6E are coincidental |
| 0000:8A90 | 541 | mfd_radar_draw(page) | Left-MFD mode 1 heading-up tactical display, range [40B0]: clear, 1024-unit grid lines, aircraft (table C16C stride 0x24, count DEFC) with alt-relative symbol (>1000 above/below), selected air target box ([3D92], when E32A==1), radar-lock box ([C0AA]), missiles (table 3C3A stride 0x1C, 12 entries), ground objects (B2CE.., count C0E0; symbol by flags), player marker, decoys (table 39D8 stride 0xC, 4 entries, kind 1/2/3) | high | called from 79BE @7C66 when [DF06]==1 |
| 0000:8ED6 | 155 | radar_project(wx,wy) | World → heading-up radar coords [4A10]/[4A18] (rotate by [2DEE], scale >>(7-[40B0]), centre 0x70/0x98); [DEBE]=-1 if outside 0x4E..0x93 × 0x71..0xA6 | high | code |
| 0000:8F71 | 677 | mfd_time_page() | Right page 0x14: "TIME hh:mm:ss", per waypoint " Waypoint n - d Km", "<t> MIN. ETA", cumulative clock; fuel-needed per leg (throttle²/1000 + [C5F4] if [3664]&0x20) × time ×5; fuel bars 927F against fuel [3666] | high | strings 4118/411D/412F; waypoint table 2E9E |
| 0000:9216 | 105 | map_route() | Map mode 0: draw route lines from player through remaining waypoints [2EAE..3] | high | 87C1 loop |
| 0000:927F | 78 | fuel_bar(v,colour) | Clamp v to 0..10000; if >0x86 fill rect x 0xAA..0xAA+v/0x87, y 0xA4..0xA7 on back page | med | 0FB2:0246 fill |
| 0000:94AD | 52 | mfd_left_restore() | Blit left-MFD rect (0x4A,0x6E, 0x4D×0x3C) between back page and page 4040 (direction ?) via 1E42:01EC | med | args |
| 0000:94E1 | 52 | mfd_left_save() | Same blit, pages swapped | med | args |
| 0000:971A | 291 | hud_ils() | ILS needles to runway object [E00C] (localiser x → [4A10], glideslope from alt [2DF4] → [4A18]; carrier when flags&2), label "ILS" | high | string 421C "ILS"; called from 79BE when [9B35]&4 |
| 0000:9EFA | 4552 | hud_overlay_update() | Per-frame HUD/combat overlay pass (called only from 03CE after the 3D view): missile-track boxes, gun-round flight + hit tests, explosion flash, target boxes/diamonds for current target mode, emitter labels, target-camera MFD page (photo recon "Frame n", Maverick "Missile" cam, "Camera"), radio-beacon cues. See sub-structure. | high | strings " destroyed by gunfire" A02C/A1BB, "Hit by gunfire" A0AC, "Frame " A705, "Camera" A7A4, "Missile" A88A, "Target photographed." A7C6, "Primary/Secondary/No Target" AA1C/AA40/AAA1, "Radio Beacon" B01E, "Radio beacon bearing " B038, "Drop supplies now" B08A |
| 0000:B0C2 | 122 | hud_diamond() | Draws 4-line diamond (±4 px) at projected point ds:4A10/4A18 in colour ds:2CA0 via 881F (line) | high | 4 calls 881F with ±4 offsets |
| 0000:B13C | 53 | cam_dir_label_update() | Quadrant of (heading 2DEE − camera bearing DF00 + 0x2000)&0xC000 (left/right swapped); if changed vs ds:E582 store and call 8342 (" Ahead "/" Rear "/" Right "/" Left " label) | high | and 0xC000, writes E582, calls 8342 |
| 0000:B171 | 269 | hud_target_box(x,y,size,style,colour) | Draws square box (style 0) or corner brackets (style≠0) of half-size `size` around (x,y); size halved when byte 294B set; nothing if ds:368C==0 | high | 881F line calls, sar [bp+8] if 294B |
| 0000:B27E | 188 | mfd_lock_box_jitter(flag) | Draws 4 short tick lines around MFD centre (0xCF,0x8C); if flag, offset taken from cycling table ds:4310 (index ds:430E 0..5) | med | consts 0xCF/0x8C, table 4310, 87FD |
| 0000:B33A | 251 | mfd_lock_brackets(flag) | Draws shrinking/jittering bracket box in camera window clamped to x 0xA9..0xF5, y 0x6E..0xA9 using table ds:4320 (index 430E 0..6) | med | C67A clamps to 0xA9/0xF5/0x6E, table 4320 |
| 0000:B435 | 192 | mfd_lock_indicator(a,b) | If Maverick (trk type 0x1B) being tracked & cam mode E580==4 → B27E(1); if in-range flag E588: B33A(a&&b), then cockpit lamp 3 on panels [4010]/[4040] via D578 (blinking with frame parity 3D8E bit0); else lamp off when 4736 | med | D578(...,3,on/off), E588, 3C4A==0x1B |
| 0000:B4F5 | 130 | hud_label(str,colour,size) | If projected point on screen: box via B171, and if inside HUD area (x 0x15..0x117, y 1..0x4B) prints `str` centred below box via 898F | high | bounds 0x14/0x118/0x4C, EB82 strlen, 898F |
| 0000:BCEF | 1863 | mfd_target_camera(shape,x,y,z,h,p,r,mode,zoom) | Renders the target-camera MFD window (page [4070], rect x 0xA9..0xF5, y 0x6E..0xA9): sets camera by mode, draws sky/ground, either single object or full world (04E6), effects, static, "BRG nnn" + zoom label. See sub-structure. | high | "BRG " C3AD, 0FB2_0246 with 0xA9/0x6E/0xF5, writes B792/B796/B834/DF00/953C |
| 0000:C45C | 94 | mfd_static(a,b) | Static/noise in camera window: gfx 0250/019C, 0FB2_0519, two 0FB2_069A passes with rect ds:2299..229F | med | called when 43E0 set |
| 0000:D578 | 239 | `lamp_draw(page, lamp, on)` | draw cockpit button/indicator lamp `lamp` on page: rect from 12-byte table ds:4708[lamp] {x,y,w,h,style,state}; colours from ds:46a2[style*8 + on]; style 4 draws 2 extra edges; stores state at 4712[lamp] | high | D57E imul 0xc, [4708..4712]; two/four calls to 01E7 |
| 0000:D667 | 118 | `led_digits(page, field, str)` | draw digit string as 4x7 LED glyphs: field table ds:4684[field*6]{x,y,maxlen}; glyph src x from ds:4670[digit]; copy from page 2 via 01EC; non-digits -> glyph 0 | high | D66B imul 6; D690 cmp '0'..'9'; push 7,4 (h,w) |
| 0000:D6DD | 328 | `draw_side_strip(page)` | if [466e] (Alt-H): draw an overlay strip (two layouts by [294b]) with copy-rects and highlight box for item [46f2] (prev [46f4]) using 6-byte table ds:46f6 | med | called each frame from main loop 1BE6 with [40b6]; [46f2] written by 2F9D/4F2B |

### text/msg (13)

| addr | size | alias | role | conf | evidence |
|---|---|---|---|---|---|
| 0000:0CDD | 22 | `load_error(msg)` | shows msg via 895E(msg,0,0x60,0x0F) then `mov sp,bp; call 0000:EBEA` = runtime exit (never returns; the `leave; ret` is dead) | high | callers 09A0, BAA2; vgame-asm.md §4 |
| 0000:4B03 | 140 | site_name(site) | build "<B2DC name> at <B2CE name>" in msg buffer 98a6 from string ptr table df08; truncate to 25 chars | high | 4B1D, " at " |
| 0000:4B8F | 93 | site_name_short(site) | name of site (B2CE or B2DC) into 98a6, max 18 chars | high | callers 9515 @963F/@96FC (missed by xref) |
| 0000:895E | 49 | text_draw(str,x,y,colour) | Draw string on current back page (4010 if [40B6]==0 else 4028) via 89C0 | high | code |
| 0000:898F | 49 | text_draw2(str,x,y,colour) | Byte-identical twin of 895E | high | code |
| 0000:89C0 | 55 | port_text(port,str,x,y,colour) | Set port +8 x, +A y, +4 colour, +C=0; call gfx thunk 1E42:0133 (MGRAPHIC slot 5) with str,len | high | code |
| 0000:89F7 | 33 | num_draw(n,x,y,colour) | itoa(n,C604,10) then text_draw | high | EB9E=itoa |
| 0000:8A18 | 55 | num_draw_r(n,x,y,colour) | Right-aligned number (x - 4*strlen) | high | EBBA/EB82 |
| 0000:8A4F | 24 | msg_show(str) | strcpy(C5A4,str); [40CC] = [368E]*3 (display frames) — HUD message line drawn by 79BE @8140 | high | 10 callers (all event messages) |
| 0000:92CD | 104 | fmt_hhmm(t) | 98A6 = "hh:mm" of t+[98A0] (t/1800 h, t/30 m) with night shift ([368A]) | med | strings 4139/413A |
| 0000:9335 | 125 | fmt_hhmmss(t) | 98A6 = "hh:mm:ss" (ss = 2t mod 60) — clock unit = 2 s | high | divisors 0x708,0x1E,×2 |
| 0000:93B2 | 55 | fmt_2dig(n) | Append n mod 60 as 2 digits ("0" pad) | high | code |
| 0000:B577 | 101 | fmt_range(r) | sprintf into ds:98A6 "Range " + (r>>6) + "." + ((r&0x3F)*2/13) + suffix ds:4341 (64 units per range unit, 1 decimal) | high | "Range " B57B, sar 6, and 0x3F, /0xD |

### sound (2)

| addr | size | alias | role | conf | evidence |
|---|---|---|---|---|---|
| 0000:D3F9 | 38 | `sfx(id, prio)` | play sound `id` via thunk 0313 if prio >= sound level [43f2] (and prio>1 when [c09a] ejected/crashed); then D41F | high | D3FC cmp [bp+6],[43f2]; D414 call 0313 |
| 0000:D41F | 34 | `engine_sound_update()` | selects continuous sound 0x18 (engine) or 0x19 (silence?) depending on [43f2]==0, [2e0a] (throttle?) !=0, [c09a]==0 | med | D426 [2e0a], push 0x18/0x19 -> 0313 |

### fileio (10)

| addr | size | alias | role | conf | evidence |
|---|---|---|---|---|---|
| 0000:0CF3 | 32 | `set_ext(name, ext)` | finds '.' in name and strcpy(ext) over it (EB50 = strcpy) | high | 0CF8..0D0C |
| 0000:4D45 | 24 | save_world_to_block() | deba=0 -> 4D5D (DGROUP -> block+0x7A) then append event log BA56 (0x600 B) | high | called from 0235 at exit; 4D51 |
| 0000:4D5D | 174 | xfer_world_state() | serialize list (see Shared block) in either direction via 4E0B | high | 4D5F..4E05 |
| 0000:4E0B | 64 | xfer(ptr,len) | far memcpy between ds:ptr and cursor [951c:951e]; direction by deba; advance cursor | high | 4E18 |
| 0000:4E4B | 20 | xfer_reset() | cursor 951c:951e = block seg : 0x7A | high | 4E52 add ax,0x7a |
| 0000:BAA2 | 107 | load_stflt_3dx() | Loads STFLT.3DX (E586 → seg ds:B78A); header word N, skips (N+1) words, copies N bytes to ds:0760[i] and sets ds:09E0[i]=6 (per-shape attribute tables) | med | "stflt.3dx", "Load Error on STFLT.3DX" |
| 0000:D52E | 17 | `pic_load(name, page, ?)` | open pic file (11B8_0008), decode (11D8_000A), close (11B8_00C4) | high | callers load "256pit.PIC","adv.pic","ordnance.pic"; D557/D569 wrap 11B8 |
| 0000:D557 | 9 | `pic_open(name, mode)` | wrapper -> 11B8:0008 | high | 11B8:0008 holds "File not found" msgs |
| 0000:D569 | 7 | `pic_close(h)` | wrapper -> 11B8:00C4 | med |  |
| 0000:E586 | 311 | `file_load_seg(name)` | fopen(name, mode ds:4ee2), length (EC90) -> [c0a0:c0a2]; check free mem (thunk 0214); DOS alloc (EE52); read whole file in 64K chunks with int21 AH=3F (regs ds:c5f6, ED10); returns segment or 0 | high | E634 [c5f6]=0x3f00; callers load speech.117, *.3DX, stflt.3dx |

### util/math (23)

| addr | size | alias | role | conf | evidence |
|---|---|---|---|---|---|
| 0000:02C2 | 1 | `_nullsub1` | `ret`; called from crt0 (MSC _setargv/_setenvp stub ?) | med | caller E6BE |
| 0000:02C3 | 1 | `_nullsub2` | `ret`; called from crt0 | med | caller E6BE |
| 0000:1BA7 | 12 | `get_ivt(si)` | returns IVT entry 0:[si] in BX:AX | high |  |
| 0000:2E7F | 90 | ratio16(a,b) | signed (\|a\|<<16)/\|b\|/2 (fixed-point a/b, 0x8000=1) via long div EFB8 | med | 2EB7 call EFB8, shr/rcr |
| 0000:2ED9 | 113 | asin16(x) | arcsine by search+interp in quarter-sine table ds:2084 (65 words); asin(-0x8000)=0xC000 | high | table 2084=0000,0324,..,7FFF = 32767*sin(i*90/64) |
| 0000:2F4A | 17 | acos16(x) | 0x4000-asin16(x) | high | 2F50..2F57 |
| 0000:2F5B | 66 | isqrt(x) | Newton integer sqrt of\|x\|(returns 1 if <4) | high | loop 2F79..2F96 |
| 0000:B905 | 24 | range_to_ground(i) | B933(go[i].x, go[i].y, 1) → range (also bearing in 952E) | high | B2D0/B2D2 |
| 0000:B91D | 22 | range_to_aircraft(i) | B933(ac[i].x, ac[i].y, 0) | high | C16C/C16E |
| 0000:B933 | 57 | range_bearing(x,y,wantBrg) | Range from player (C0D0,C0DE) → ds:952A and return; if wantBrg bearing atan2 → ds:952E | high | C702 → 952E, C6B3 → 952A |
| 0000:C67A | 31 | clampw(v,lo,hi) | v>hi→hi; v<lo→ (v≤-0x4000 ? hi : lo); else v (signed) | high | code |
| 0000:C699 | 26 | clamp(v,lo,hi) | plain signed clamp | high | code |
| 0000:C6B3 | 79 | approx_dist(a,b) | max(\|a\|,\|b\|)+min(\|a\|,\|b\|)/2, saturate 0x7FFF | high | code |
| 0000:C702 | 278 | atan2(x,y) | 16-bit angle (0=+y/north, 0x4000=+x/east, 0x8000=south); rational approximation (consts 0x1333, 0xB00, 0x2800), no table | high | special cases 0/0x4000/0x8000/0xC000 |
| 0000:C818 | 25 | sin_mul(ang,r) | r*sin(ang) via 104E:0076 (sin, table ds:2084) and 104E:0000 (fixmul >>15) | high | far calls |
| 0000:C831 | 20 | cos_mul(ang,r) | C818(ang+0x4000, r) | high | add ah,0x40 |
| 0000:C845 | 30 | sext8(b) | sign-extend byte | high | code |
| 0000:C863 | 29 | sign(v) | -1/0/1 | high | code |
| 0000:C880 | 12 | randomize() | seed = BIOS tick (1E72 int 1Ah) → ds:9540, EE1A (srand) | high | int 1A via 1E72 |
| 0000:C88C | 16 | random(n) | (rand() * n) >> 15 (EE2C = rand) → 0..n-1 | high | imul, shr 15 |
| 0000:DFA9 | 378 | `matrix_from_angles(mtx*, a,b,c)` | build 3x3 rotation matrix (9 words) from three angles via 104E sin/cos/mul; writes temps 49b2..49bc | med | callers D9A2, 2E5E, 2F9D; callees 104E_0000/0066/0076 only |
| 0000:E123 | 358 | `object_matrix()` | compose object rotation from [499a..499e] with camera matrix into ds:49d0..49e0 | med | writes 49d0..49e0, reads 499a..499e |
| 0000:E289 | 45 | `matrix_transpose_49d0()` | swap off-diagonal elements of matrix ds:49d0 (d2<->d6, d4<->dc, da<->de) | high | code |

### 3a. Sub-structure of the large functions

#### 1EB0 flight_update (C local frame 0x30)
| range | phase |
|---|---|
| 1EB5..1F02 | First call only (C0DA==0): zero speed B07E, alt 2DF4/2DF6, pitch/roll, throttle 2E0A, engine B19C; heading 2DEE = 0 if theatre table ds:3DAA[blk2+0x38]>0 else 0x8000; +0x400 if start base (e308) flags byte B2D7[e308*16] bit1 (carrier?); 2E5E; 3A3B; C0DA=1 |
| 1F08..1F2D | Key fetch: DEBC = first BIOS key this frame (EE6A(0)), remaining buffered keys discarded |
| 1F2D..1F82 | Key switch (see Keys). Unhandled codes stay in DEBC for 450A→C8CA (other key handler, outside range) |
| 1F9B..1FBB | dec 2E0E (joystick-recentre debounce); if throttle!=0 && engine B19C==0 → sound 0x0B |
| 1FBD..21B4 | Stick source: blk+0x72 bit0 set → 1058_0CB2 reads joystick (port 0x201) into 2CD2/2CD3; else 2CD2/3 = 0x80+(keypad stick 2CD6/7-0x80)*(sens 43EA+1)/3 |
| 21B5..223D | Stick→commands: DEB6 (roll cmd) = -2*s*(|s|+2), s=(2CD2>>4)-8; E472 (pitch cmd)=6*((2CD3>>4)-8), halved if negative; no nose-down on ground |
| 2238..22BB | Any stick input → autopilot off (3684=0); lamp 4 = autopilot; if 3684!=0: roll cmd from heading error (C0A4-2DEE), pitch cmd from altitude error (3684-2DF4) |
| 22BB..2355 | Buffet/turbulence magnitude: (500-alt)*airspeed>>13 if realism blk2+0x40; + gear-down overspeed buffet; halved with flaps; + control damage (3664&4) * C5F4; random jitter added to both cmds when airborne |
| 2355..23B4 | Low-altitude auto pull-up when gear up, not stalled, realism<2, |roll|<0x3000, 991A==0 (?) |
| 23B4..24BD | Ejection/crash sequence when C09A!=0: forced roll, C09A++, camera alt DEF6 decays → end_mission(0) at DEF6<0; at alt 0 spawns wreck/chute object (3A08 table, 3D96, 9D3C=-16), sounds 5/4 |
| 24BD..2564 | Engine: engine damage (3664&2) caps throttle to (25-C5F4)*4; engine spool B19C → throttle (lag /4/368E); fuel 3666 -= thr²/1000+2(+leak C5F4 if 3664&0x20) every 2*368E frames; fuel<=0 → engine off |
| 2564..2620 | Load factor 990C = table ds:2D14[|roll|>>8] (+pitch cmd, cap 0x80) = G×16; G-meter string ds:9900 = "N.nG" |
| 2620..26F1 | Thrust [bp-2C] from engine B19C minus gravity (sin pitch), scaled by alt, fuel weight, G; stall speed E474 = f(alt 2DF6)*sqrt(G); flaps (9B34&2) −1/4 stall, −1/16 thrust; gear down (!(9B34&1)) −1/8 thrust; B03A = E474*27 |
| 26F1..27E5 | Speed B07E integrated toward thrust*27; AoA B784 (cap 0x2000), 98F6 = (B784-0x200)*cos(roll); brakes (9B34&8): on ground decel (4-realism)*0xD8, stop below 0x1B0; airborne B07E-=B07E/16; cap 0xAFC8 |
| 27E5..2868 | Horizontal speed [bp-22]=B07E*cos(pitch); airspeed B194=B07E/27; engine/wind sound 1E42_0313(0x17,B194); yaw rate [bp-14] from bank & G; on ground: rudder = -roll cmd<<6, no rotation below stall speed |
| 2868..293C | 9910 → crash attitude (pitch→0xFC00, speed 0, throttle 0); incremental rotation matrices (roll 2DCA.., pitch 2DB8.., yaw 2DA6..) built with cos/sin and multiplied into attitude 2D94 (2C87); 2CB9 extracts Euler |
| 293C..29D6 | Stall: if B03A>B07E airborne → pitch -= deficit>>1/2, stall-warning sound 0x0E; on ground: roll=0, pitch>=0 |
| 29D6..2A17 | E56E = 1 unless air-target mode and |pitch|>|roll|/2+0x1000 (?); rebuild matrix if flagged |
| 2A17..2AEB | Climb rate E586=sin(pitch-AoA)*B07E/16; altitude 2DF6 += E586/368E (floor ground C0CE, ceiling 0xEA60=60000); X BA3C:BA3E += sin(hdg)*hspeed/16/368E; Y C056:C058 += cos(hdg)*...; display alt 2DF4 = compressed 2DF6 (≤0x2000 linear, then /2, then /4) |
| 2AEB..2B88 | Touchdown check (on ground, previous alt higher, 3DA2 armed): sink E586 vs limit 0x180 (0x100 at base flag 0x200); realism>0 also requires gear down and small roll → else sound 4, delay(0x3C), end_mission(5) (crash) |
| 2B88..2BCF | History ring ds:B094[(3D8E&15)*16] = {X dword, Y dword, alt2DF4, hdg, pitch, roll} (used by view 0x84) |
| 2BCF..2C84 | If E32A==1 (air target mode): body-axis heading/pitch rate over N frames (N from target 3D92 range) → E572, E57C (gunsight lead?) |

#### 2F9D view_update_and_render
| range | phase |
|---|---|
| 2FA2..2FFB | default camera = player: DEC4/6 = BA3C X, B2B4/6 = X, B77E/80 = C056 Y, DECA/C = 0x100000-Y, B788 = 2DF4+0x18, DED2 = alt; zoom 3D9E clamped 2..8 |
| 2FFE..3049 | switch on view code C0A6 |
| 3049 | 0x00 front cockpit, 0x44 forward no-cockpit: camera = player attitude |
| 30A4 | 0x41 rear look: hdg+0x8000, pitch negated (256rear.pic) |
| 30D0 | 0x42 left look: hdg-0x4000 (256left.pic) |
| 30BA | 0x43 right look: hdg+0x4000 (256right.pic) |
| 30E7 | 0x84 delayed chase: camera = history ring entry 368E frames back |
| 3135 | 0x85 side view: camera abeam (0x18<<zoom) looking hdg-0x4000 |
| 318E | 0x87 chase: camera behind (0x18<<zoom) and above (4<<zoom) |
| 31EE..349D | 0x88 / 0x89 / 0x8B tracking: DED4 = object id (0x89: weapon B07C; else E32A==1 → air target 3D92+0x80, else ground target 3D94+0x100). Id <0x80 → missile table ds:3C3A stride 0x1C; bit 0x80 → aircraft table ds:C16C stride 0x24; bit 0x100 → ground/base table ds:B2D0 stride 0x10. 0x88 camera behind player looking at object; 0x8B camera at object looking at player; missile ids: camera behind missile (34A0) |
| 3522 | 0x8C fixed camera at DECE/DEF2/DEF6 (set when ejecting, C09A) pitch 0xF400 |
| 3561..3576 | camera matrix B082 = copy of 2D94 (front) or DFA9(hdg E478, pitch C0A8, roll B79C); camera alt B788≥16 |
| 3584..3663 | 368C = in-cockpit flag (C0A6&0xC0==0). On change: viewport height in page structs [4010]+0x10/[4028]+0x10 = 0x5A or 0xC7; cockpit on: 114A_02FF, throttle, MFD 8462; off: blit cockpit area pages |
| 3668..36FB | on view change (C0A6!=2E7A): load pic 0→256pit.pic (+3A7D,01C1,1039_009D), 0x41→256rear, 0x42→256left, 0x43→256right, else 1039_00B7 (external); 2E7A=C0A6 |
| 36FB..3765 | 3D window height [bp-2]: front 0x5B (0x6B if 2E08), rear 0x9D, left/right 0xA1, external 0xC8 |
| 3765..37CD | 294B forced 0 outside front view; render: 03CE(-hdg,pitch,roll, camX dword, camY dword, camAlt dword, 0,0,320,height); 9F96 = C6B2 unless 2E0C countdown |
| 37D0..39B4 | overlays: cockpit frame blits; 0x41/0x42/0x43 border blits (114A_03FD); 0x44 → 0FB2_01E6 text 2E6A; external views if option 43E4: "HEADING AIRSPEED ALTITUDE" + hdg/0xB6 (deg), B194, alt 2DF6 (rounded 5) at y=0xBE; message C5A4 centred if timer 40CC |
| 39B7 | 2E66 = viewport height (main loop 1BF0 passes 2E66*160 to 1E42_01F6) |

#### 3ADA sim_frame()
| range | phase |
|---|---|
| 3ADA-3B0F | map coords: c0d0=(X32 ba3c+0x10)>>5, c0de=0x8000-((Z32 c056+0x10)>>5) |
| 3B19-3C7B | once (c0da==1): 4C73 register targets; reset state (fuel 3666=10000, c5f4=2, 2646=0xC, fps 368e=4, D441, 3d98=1...); runway offset b19a=3DAA[theatre]; carrier start (site flag 0x200): X-=b19a<<7, 9b34|=8 + light 0x23, else Z-=b19a*0x708; 4973; log_event(8); 8435; 889B(3,10); 9515 (briefing text); 3688/3686 <- blk1272+0x3A/+0x3E; 990e <- block+0x32; D4A5; block+0x26=1; copy stores block+0x38[i]/+0x40[i] -> 3670/3672 (4 stations); c0da=2; 3A0D; gfx 0278 |
| 3C80-3CD9 | clamp c0d0 to [0x100,0x7E00], c0de to [0x200,0x7D00] and rewrite 32-bit X/Z |
| 3CD9-3D7B | if cockpit drawn (368c) & df06==0: map: 86CA project player, 94E1 or 8462(x,y) redraw; target markers for undone targets (9b34 & 0x4000>>i) via 114A:03FD; e008==0x14 -> 9216 |
| 3D7E | **5046 radar/SAM threat**, **5852 AI aircraft**, **683E weapons in flight/hits/scoring** |
| 3D87-3DBA | player marker on map (heading sprite) |
| 3DBD-3DCF | 4738 CM timers, 4777 gun, 48B8 smoke, 4958 falling body, 4F2B ILS, 3A0D, 4FD8 lights |
| 3DD2-3E07 | timers 3d90--, df04-- (sound 0x29 at 0), 9d3a-- (sound 0x2A at 0) |
| 3E07-4090 | every 8 frames: nearest friendly airbase (flags 0x201, hi&5) -> e00c, dist 9922; on change set ambient objects in last 4 object slots (defc-1..-4: types 0x1C/0x15/0x18-1B/0x0A/0x0B); every 128 frames spawn AI takeoff 66F8 from that base; shift c0e2->c62c->deb8 |
| 4096-40C1 | landing-base hint: base==landing base e31a & fuel<5000 & on glideslope -> sound 0x2D once |
| 40C1-426E | runway test (dist<0x200 or on ground): runway elev c0ce (0, carrier 0x80), box 9930 x 9b36 (+0x80 if blk1272+0x40==1); carrier hook catch -> 9910=1, sound 0xF; inside box 3da2=1: "Cargo delivered" for target type 4 at this base (7594); stopped on friendly base -> after 16/fps frames "Safe Landing", sound 0x2B, **end_mission(0)** |
| 4274-42D8 | crash: not on runway & alt 2df4==0 (unless blk1272+0x40==0 & c5f4<=4 & fuel) & !c09a & speed b194>0x32 -> sound 4, wait 120, **end_mission(1)**; airborne -> 3dc8=1 |
| 42DE-4326 | 9f96 set & !(c0a6&0x80): if blk1272+0x40 && 2df6 -> sound 4, **end_mission(2)** (collision: 9F96 is copied from the render collision flag C6B2 in 2F9D) else bounce 2df6+=500 |
| 4326-4359 | carrier deck motion phase e00a |
| 4359-441D | frame counter 3d8e++; each 368e frames: clock 9912++ (first: sound 0x2C), 4E5F palette; targets with E30A&0x20 past deadline deb4 removed (site|=0x80, 0D14/0F3D); every 32 ticks log_event(9) (track point) |
| 441D-4503 | every 4*fps frames: e57a=timer ticks per frame; adapt fps divisor 368e from ticks 2646 & accel 3da8, D441; df02 = count of alerted (>0xC0) sites + aircraft |
| 4503 | **450A: key dispatch C8CA + signature** |

#### 5852 ai_aircraft_update()
- 5858: every other frame, if no ground hit pending ([3d96]==-1): expire smoke-trail entry 3A08[(3d8e&0x1e)>>1]. Clear one AI-bullet entry E47A[((3d8e&0xC)>>2)+[b198]].
- 588C: [b080]=[9522] (attackers last frame), [9522]=0. Loop slot=0..[defc]-1 (6359), skip if !(flags&1).
- 6372: [9520]=slot.type (C180). Branch: not airborne (flags&2==0) or speed 0 -> **62B6 scramble check**; airborne: mode var [bp-0x1c]: RTB flag 4 -> **5A34 mode 2**; no alert ([3d90]==0) -> **589D mode 3**; flags 0x140 & alert<=threshold -> mode 3; else **63B4 mode 1 attack**.
- 589D mode 3 (patrol): if formation flag (byte C183 bit0 = 0x100) and leader [3d9c]!=-1: station at leader pos + rotated (slot&7)<<11 offset, alt leader+(slot&7)*64. Else every 64 frames pick waypoint: 8 random ground objects (not B2D7&4), choose one whose bearing best matches bearing to player; target alt = [2df4]+1000 clamp 5000..20000. If bearing to player off > 0x5780 and slot!=0 -> retire (flags&=0x1C1, timer 0).
- 5A34 mode 2 (RTB/approach): target = base ground obj; carrier/land approach heights 0x8C/0x0C+... using [b19a] runway sign.
- 63B4 mode 1 (attack): target = last-known player pos (b2cc,b786,b79a) or decoy (39d8,39da) if [39e0].
- 5AB4: mode 3 with slot flag 8 (visual) -> target = actual player pos (c0d0,c0de) at own alt.
- 5AD8: bearing/dist/elevation to target. 5B2D mode 1 and dist<0x400: attackers++; dist<0x200 and every 4th frame and alert>threshold ([3d90]>[9f94]) and heading err & pitch err <0x400 -> spawn bullet into E47A table (x,y,alt,vx,vy,vz).
- 5C06: maneuver lookup: skill = clamp([3686]+(slot&3),0,2) (slot0=1); roll cmd = word table 0x3ABA[skill][alt-sector][bearing-sector] <<12; special 0x100/0x200 entries = vertical maneuvers (pitch 0x6000/0xA000).
- 5D89: clamp roll to ±type.+0x16<<12 and roll-rate ±type.+0x16<<8. Takeoff (byte bit 0x400): accel to type.+0x12, clear above alt 300. Flags 0x30 -> roll 0x400. Every 4th frame terrain check 78FD -> byte flag 0x2000 -> pitch cmd 0x3000.
- 5E82: integrate roll->heading, pitch; falling flag 0x20: pitch -0x200 and write smoke point into 3A08 ring ([3a88]=index). Pitch clamp ±0x400 per step, loop-over handling (>0x4000 flips heading/roll by 0x80).
- 5FA0: velocity: speed*cos(pitch) -> 32-bit pos accumulators (+8,+0xC), alt += speed*sin(pitch); x,y = acc>>5. Alt>30000 -> pitch 0. Alt<0 -> crash: flags cleared, explosion pos c0cc/c0d6/c0dc, [9d3c]=-16, drop air lock [3d92].
- 60BB: mode 2 reached base (dist<0x10): msg "<loc> : <type> on final" (sets 0x200) / " landing" (sets 0x1000).
- 6129: landed (0x1000): stop, set runway heading, decelerate by 60/[368e]; stopped -> deactivate (slot0 with goal>=5: flags=0). Last 4 slots ([defc]-4..): speed<100 -> relaunch flags 0x406.
- 61C2: fuel/loiter timer (+0x1C) -> 0: set RTB flag 4 and pick nearest airbase among ground objs 3..[e56c]-1 with (B2D6&0x101)==1.
- 6225: airborne: map plot 8625(x,y,0x29/0,1) if [990e] or slot0; staggered sensor pass every 16*[368e] frames -> 63F2(slot) unless falling.
- 62B6 scramble: every 2^([3688]+4) ticks per slot (not last 4 slots, not slot 0): random airbase obj (B2D6&0x181==1) whose based type (B2D8)==slot type, alert>threshold or flag 0x80; dist(base, last-known player)>>6 < type.+0x14 -> 66F8 takeoff.

#### 683E missiles_update()
- 6844: save ground obj 0 (B2CE..B2DD, 8 words) to B2BC; warning lamps 889B(0,0),(1,0),(8, 0x11 if detected [df02] blinking else 3). Target point = decoy (39d8/39da if [39e0]) else player (c0d0/c0de).
- 7084: loop mslot 0..11, skip if life (+0xE)==0; class = weapon.+0xC.
- 70BA (mslot<8, enemy missile): 7243 vs player (alt [2df4]); ECM: radar jammer (9b34&0x10, class>0) or IR jammer (9b34&0x20, class<=0): beyond burn-through ((3686<<8)+0x180) lose lock; classes 1 and -1 always lose; **if alert [3d90] < threshold [9f94] and weapon != SA-14 (0x21) the missile does not guide (stealth)**. Decoys 39D8[1..3] (stride 0xC): type 1 (flare) seduces class<=0; type 2 (chaff) seduces class 1,2, and class 3 only if aspect test (\|bearing-playerheading\| vs 0x40-12*diff) passes. Launcher lost: SAM site radar off (B2D6&0x10==0) or launching aircraft lost visual (flag 8) at dist>0x200 -> no guidance. Speed ramps to weapon.+0xA>>6.
- 68AF (mslot>=8, player missile): class 7 (AIM-9/AIM-120): choose nearest airborne aircraft with lock (7243), set +0x14; dist<0x180 marks aircraft flag 0x10 (?). Classes 4/5/6 with target obj (+0x14): HARM/ASM homing on ground obj; obj 0 aimpoint moved -> B850 + clear. Weapon 0x1C (LGBOMB): homes on designated [3d94].
- 6A32: warnings for enemy missiles: lamp 1/0x29 for IR (class<=0), lamp 0/0x11 radar; missile-close tone D3F9(9,1).
- 6AB6..6BDD: heading/pitch steering clamped by difficulty (enemy) and weapon.+0xE turn rate (heading <<7, pitch <<8), roll = 2*turn; 6B0B..6BDD decoded as pseudo-C in vgame-asm.md §4.
- 6BDE: gravity/pitch decay (C863), FFBOMB/altitude-1 bombs pitch down to floor (+0x16); motion: x+=v*sin(h), y-=v*cos(h), alt+=v*sin(p); life--; every 4th frame terrain test 78FD.
- 6CE1 impact (alt<0 or terrain): explosion at missile pos, [9d3c]=-6, life 0, 8342 (direction text); bombs 1C/1D/1E: Equip (0x26) -> delivery check vs goals type 3 in E304 (dist<0x100, time [9912]<[deb4]) "Equipment Delivered" (7594) / "Bad Drop"; else nearest ground obj B850, blast radius 8A67(store,obj)<<6/(diff+2) -> 73C8 " destroyed by <store>"; player blast check -> 761A "Blast damage". Player non-bomb: " ground impact".
- 6ED3 hit test: dist + \|dalt\|>>5 < speed*8/[368e] and locked: enemy missile -> explosion, life=2*[368e], "Hit by <weapon>" + 761A + log 5 (unless decoy active); player class 7 -> snap to aircraft, 72D8(kill); player vs ground -> 8A67 damage vs random(4): 73C8 or "Ineffective"; then raise alert [3d90]=[b2b2] and set last-known player pos b2cc/b786=impact, b79a=3000; msg "<obj> hit by <weapon>".
- 7059: enemy missiles plotted on map every other frame 8625(x,y,0x11). 7232: restore ground obj 0.

#### 79BE cockpit_overlay_update (C part of the HUD; tapes/ladder are 1058:000A)
1. 79C4 back page id ← 1E42:01FB, store [40B6]. Altitude for display = [2DF6] rounded to 5 when ≥100 ([bp-20]).
2. If not cockpit view ([368C]==0) → skip to 8140.
3. 79F2 if [991E]: one-shot clear of HUD band (886A(0xD), 114A:02CE(0,0,0x13F,0x59)), 1E42:02A5(0x3C) (?).
4. 7A25 target-type change ([E32A]≠[40CA]): swap lamp sprites on page 4040 and blit (1E42:01EC) region (0x77,0x5E, 0x3B×9) to pages.
5. 7A8B [2956]=1; if [C0A6]≠0 (not cockpit camera) → 8140.
6. 7A9A stall: airspeed [B194] < [E474] and airborne ([2DF4]≠[C0CE]) → lamp 4 blinks with [3D8E]&1 on 4010/4028/4040; else if [4742] force off.
7. 7B0C weapon line: count [3672+4*[3680]] + name (weapon table 3690+0x1A*type+0xA) at y 0x55; if mission+0x42==0, "GUN " + [3682] rounds.
8. 7BC2 if [E32A] is 0 or 2: vertical-speed marker at x=[C6B0] = 0x3C+([98F6]>>6) (sprite 114A:03FD).
9. 7C21 lamp 9 (colour 0x11 if blinking & distance to [E31A] home > fuel range [3666], else 3) — "bingo fuel" (?).
10. 7C5A if left MFD mode 1 → 8A90 radar redraw.
11. if [294B]==0 (normal HUD): 7C74 [9B35]&2 cross-hair; 7CC3 when [294A]==0: stall-margin bar ((E474-B194)*2/5), vertical-speed bar ([E586]>>4), glide marker when gear-down-like flags ([9B34]&1==0, mission+0x40, [E586]<0); 7DB7 ILS (971A); 7DC1 [E32A]==1: flight-path/target designator from [E57C]/[E572]; seeker circle when weapon class (33A0 table +0)==7.
12. 7E90 numerics: airspeed [B194] (89F7) and altitude (8A18); if [294A]≠0 heading [2DEE]/0xB6 (degrees) and frame boxes.
13. 7F38 "ACCEL" if [3DA8]>1; 7F51 "TRAINING" if [9B35]&0x10.
14. 7F6B unless [3664]&8 (nav damaged): waypoint distance test & "Waypoint n reached" (8A4F); bearing [C0A4] = atan2 (C702) to waypoint [2EAE]; heading-tape caret at x=0x9F+((brg-hdg)>>6)/3.
15. 8079 alternative compact layout when [294B]≠0.
16. 8140 message line: while [40CC]>0 and cockpit camera, draw string C5A4 centred at y 0x14, [40CC]--.
17. 817A if [C0A6]==0x42: framed number box (altitude) at 0xC4,0xB9 on both pages (?).

#### 983E world_objects_draw
1. 9843 [C0A6]==0x8B: draw own model 0x18 at 32-bit pos ([BA3C:BA3E], 0x1000000-[C056:C058], alt [2DF4]+0x10, hdg/pitch/roll [2DEE]/[2DF0]/[2DF2]); [49F6] = terrain-type bits at map cell (C0D0>>11, C0DE>>11) from table B1A0 (16 cols).
2. 989A [B2BA]-- (target-cycle cooldown).
3. 98A5 if [3D94]&0x80 (ground target re-select request) and right page 0x13/0x19, no cooldown, [E32A]≠1, cockpit camera: scan ground objects (count C0E0) inside ±0x2000 of view dir ([2DEE]-[952E]+[E582]) and range < 100<<(6-[368A]) ([952A] from B905/B933) → nearest becomes [3D94]; none → [B2BA]=4 or [3D94]=-1.
4. 99E1 16 effect slots (table 3A08 stride 8: x,y,z,type): project (B5DC), draw scaled sprite (D9FE) — explosions/smoke/fire (?).
5. 9A7C high-altitude LOD flag ([2DF4]+[9922] > 1500).
6. 9AA9..9D13 aircraft (table C16C stride 0x24, DEFC entries, flag +0x16&2 = active): visible range < 0x12C0; nearest in front → [3D92] (air target); far = dot, near = 3D model shape word ds:300E[(type*16+lod)*2] via BB0D; shadow (shape 4) when low over carrier/landing area or not night; BA56 sets colour flags.
7. 9D32 missiles in flight (table 3C3A stride 0x1C, 12 entries; +0xE active): dot (colour 0x29 own <8 / 0x0D enemy) or model shape ds:33A4[type*0x12].
8. 9DE7 if [C62E]>0: object at ([C0D2],[C0E4]) model 0x0B (LOD 5/6 by [B782]) — dropped cargo/ejected item (?).
9. 9E49 external views (C0A6&0x80, ≠0x8B): own model 0x18, and shadow model 0x11 at ground height [C0CE] when alt<1000 and day ([368A]==0).

#### 9EFA hud_overlay_update (order of execution)
1. 9F00: 9530=9D38 (previous "camera drawn" flag), 9D38=0.
2. 9F29: loop 12 trk[] (active = +0x0E): project +0/+2/+4 (B5DC), box B171 size 6, colour 0x11 for slots 0..7, 0x0A for 8..11 (player vs enemy missiles?).
3. 9F5E..A256: gun rounds shell[0 .. B198+4): draw tracer segment (114A_0006, colour 0x0D player / 0x29 enemy) between midpoint and current projection. Slots < [B198]: hit-test vs ac[0..DEFC) alive (flags+0x16 bit1) with radius 0x17A/(4*([368E]+2))/([3686]+1); hit → flag 0x10, 72D8(kill aircraft), " destroyed by gunfire", explosion at ac pos (C0CC/C0D6/C0DC, 9D3C=0x10). Slots ≥ [B198] (enemy rounds): vs player (C0D0,C0DE,2DF4) < 0x20 → "Hit by gunfire" and if < 0x20/(4−[3686]) → 761A (player damage). Round below ground (z<0): explosion at impact; B850 ground lookup; if not already destroyed and 792E: 8A67 kill probability vs distance → 73C8 (destroy ground object) + " destroyed by gunfire".
4. A257: explosion flash while 9D3C≠0: re-aim to burning aircraft 992E, project, draw sprite 1A98(x,y,size=256/depth,frame 16−|9D3C|); 9D3C stepped toward 0.
5. A2F7: return unless ds:368C (HUD present). E588=0.
6. A306 target mode E32A==2 (air-to-ground) and not external view: project go[3D94]; weapon on current station = 36A6[3670[3680]] → missile record ds:3394+idx*18; in-range tests vs record +8 (range) and depth DEBE → E588 lock flag, box style; idx 0x1C (LGBOMB) laser-spot logic with B905; box B171; for idx 0x1C diamond at point 0x80 ahead of target (B0C2).
7. A4CB: radar-emitter label: 3D98>0 and C0AA≥0 → ground emitter go[C0AA], label = name ds:DF08[go.+0xE] via B4F5.
8. A52A: if display page E008==0x13 and E32A∈{0,2}: 
   - auto-designate (9B35 bit0): point ahead/below (pitch/alt geometry) → B850 → 3D94.
   - photo recon (station type 36A6==-1 and 9B34 bit2 = camera pod): 2 objectives ds:E304 (type 1 = photograph) within range → bitmask B2B8; shutter on input button C89C(1)/9534 when 4222==0 and 40B6: "Frame n" (counter 4220), cockpit text at (0xD1,0x8E), sound 0x12; at 4222==3 "Target photographed." → 7594(0/1) objective flags 9B35 0x40/0x20, log 4ABA(0x8A/0x4A, target).
   - else Maverick (trk[B07C] type 0x1B, 43E2==0): BCEF(mode 4) "Missile".
   - else BCEF(mode 1, ground target) + B435 + B13C + B577 Range + "<type name> at <place name>" (names ds:DF08[...]) + "Primary Target"/"Secondary Target" (go index == E306 / E318) or "No Target".
9. AAAA: 9534 = C89C(1) latch. E32A==1 (air-to-air): project ac[3D92], box (bigger "lock" style when weapon class 7 in range). If E008==0x13: BA56 + BCEF(aircraft shape from type table ds:300E+32*type, ac angles +0xE/+0x10/+0x12) + Range + "MIG-23 Flogger"-style name (ds:2FF4+32*type, +7) + "Primary Target" for ac[0] when objective type E304≥5; 9532 = closure/aspect value (?).
10. ACEA: air emitter label (C0AA<0 → ac[−1−C0AA], name ds:2FF4+32*type).
11. AD4A: E32A==2 and weapon idx 0x1E (FFBOMB) / 0x1D (RTBOMB): bomb pipper (B96C, sin/cos) projected, fallback position at HUD bottom; 881F line from (0xA0,C6B0); for 0x1E/0x1D with ground target: steering/release bars (3×114A_0006) with DEBE from range; diamond B0C2.
12. AF7A: 2 objectives with flag 0x10 (radio beacon) while clock 9912<DEB4 and range<0xC80: diamond on target (if it is 3D94), "Radio Beacon" label, every 8*[368E] frames message "Radio beacon bearing NNN" (deg = brg/0xB6); range<0x100 and stores on station 0 (3672) → "Drop supplies now".
13. B09D: if E008==0x13 and camera was drawn last frame but not this frame: clear camera window (114A_0280(2,0x9F)).

#### BCEF mfd_target_camera(shape,x,y,z,h,p,r,mode,zoom)
1. 9D38=1. Shape class = (shape bit8 ? ds:0960 : ds:09E0)[shape&0x7F]&7 → nominal range ds:436E[cls] (0,10,30,..250), zoom label ds:436A = '8'−cls ('8X'..). Range doubled if x,y low bytes both 0; halved for mode1+zoom1. 4070->[0]=40B6 (page select).
2. Camera eye (E580=mode): mode 4 → from Maverick track trk[B07C] (heading 3C42 → DF00, pitch 3C44 → 953C, pos → B792/B796/B834); mode<2 → look from player: DF00=atan2 bearing, 953C=elevation, C5A2=range, 953A=zoom (range>>4+0x190 scaled), 4368 = extra shift from zoom<0; mode≥2 → chase/ground view: DF00=heading 2DEE, 953C=98FE (pitch−0x6EF), 953E=roll 2DF2, 953A=0x20. If range small or mode 3 → eye = external camera (B2B4/B77E/B788) else eye placed at distance on the bearing.
3. Horizon row (0x8B + elevation*zoom, clamped 0x6E..0xA9), colour by target class (sky 0x78 / 8 / 0xFC); 294B saved and cleared; 7D80 palette remap (0x8190 if 43E0, 0x7F90 else; 0x8390 + fill if time-of-day 990E<3).
4. If ds:034A==0 and mode≠4: fill sky/ground (0FB2_0246 or 1974/19FD horizon helpers), D826 (camera set), E2B6 draw single object (destroyed objects get 0x80 flag).
   Else: D826 camera, 04E6 full world/terrain render from eye (348 forced 1), then mode1+zoom: D87C, D826, E2B6 object, and C4BA fire if ac[3D92] flag 0x20 (DC46 first); otherwise C5B2 smoke list. Restore 348/9928/9F42/98F8/9914.
5. D87C; explosion bitmap (gfx thunk 0188 with frame from far-ptr table ds:91F8 indexed by |9D3C|) when 9D3C and 9D3E.
6. 43E0 → C45C static + lamp 0x19 on [4010]; 0FB2_0519 (present/flip?).
7. mode 1: "BRG nnn" (DF00/0xB6) at (0xB9,0xA1); if 034A also zoom label ds:436A at (0xEC,0xA3). Restore 294B.

#### C8CA key_command(key)
- C8CA: clear pseudo buttons [43ee],[43f0]; key==0 -> D17F tail; else jmp CE65.
- CE65: '9' special; codes 0x231..0x938 step 0x101 -> jump table CE8D (8 words: C968 C96F C961 C944 C973 C977 CB77 C9AE); others: linear subtract chain CE9D..D027.
- All handlers return to C8FA: if [9b35]&0x10 -> training chain C904 (Alt-R/I/J/K/L/N); then D038: if [e008]==0x14 nav-edit chain D04F (+ clamp D13A).
- D172: if [c09a] force view 0x8C.
- D17F per-frame tail (runs even with no key): cooldown [43ec]; fire weapon on button(1) (7663; refresh stores page); damage [3664]&0x40 kills both jammers; jammer A duty timer [43f4] vs [368e]*20 + lamp 6; bay-forced-open on [3664]&0x10; nav page refresh every 32 frames ([3d8e]&0x1f) via 83E9(0x14); bay door animation [9908] + lamp 2 (blink [3d8e]&1); gear animation [c09e] + lamp 3.

## 4. Assembly segments, far data, driver thunks

Driver thunk slot = (thunk-0x11A)/5; graphics MGRAPHIC slots 0..83 (011A..02B9), misc MISCOVR 90..95 (02DC..02F5), sound xSOUND.117 100..104 (030E..0322).

#### 0FAE — driver-thunk installer
| entry | size | alias | role | conf | evidence |
|---|---|---|---|---|---|
| 0FAE:0002 | 61 | drv_install(drvseg) | Patches the 5-byte `JMP FAR` thunks in DGROUP 011A.. : slot base = word drv:[1C], count = drv:[22], entry offsets at drv:[24+2i], code seg = drv:[18]; thunk = 0x11A + 5*slot | high | called 3x from main 0000:0041/004F/005D with block+1A (sound), +1E (misc), +1C (graphics) |

#### 0FB2 — 2D clipping, span-edge polygon fill front end, horizon
DGROUP: 2299/229D/229B/229F = line x0,y0,x1,y1; 2293/2295 = clip xmax/ymax; 22A1[] left-edge x per row, 2459[] right-edge x per row (0x1B8 bytes apart); 2615/2617 = ymin/ymax touched; 0D42..0D48 horizon temps.
| entry | size | alias | role | conf | evidence |
|---|---|---|---|---|---|
| 0FB2:0000 | 18+ | draw_horizon(groundColour) | [0D46]=colour, calls 0012: builds horizon line from pitch [49B6]/[49B8] and roll sin/cos [49BA]/[49BC] about screen centre [0D1E],[0D20] (zoom shift [4368], [294B] halves), fills ground with colour, sky with colour 0x78 via span tables + gfx 01D3 | high | callers 1450 (3D view) |
| 0FB2:01E6 | 96 | fill_polygon(?, n, pts*, colour) | colour=[bp+C] → gfx 01BA; for n vertex pairs at [bp+A] calls edge-clipper 06A6; fills via gfx 01D3 | high | callers 1450,17B4,1974,19FD,2F9D |
| 0FB2:0246 | 110 | fill_rect(page*, x0, y0, x1, y1) | selects page word [page+0] (gfx 015B), colour byte [page+4], writes span tables rows y0..y1 = x0..x1, gfx 01E2; restores draw page | high | 12 calls; e.g. 00F0 clears (0,0)-(13F,5B) |
| 0FB2:02B4 | 108 | fill_rect_near (colour at page+6) | same as 0246, near `ret` (internal variant) | med | no far callers |
| 0FB2:0320 | 4 | line_clip_draw (asm callers) | `call 0330; retf` | high | called by 1058 HUD (0FB2:0320) |
| 0FB2:0324 | 12 | line_clip_draw() | saves regs, calls 0330: Cohen-Sutherland clip of (2299,229D)-(229B,229F) against 0..[2293]/0..[2295] (outcodes via 04BC), draws with gfx 01B5; installs INT 0 handler 0FB2:04DD while dividing | high | callers 0300, 114A:0006/0070 |
| 0FB2:04DD | 33 | int0_clip_handler | divide-overflow ISR used during clipping: returns ±0x7F00, skips the IDIV (`add [bp+2],4; iret`) | high | installed at 0FB2:033E |
| 0FB2:04FE | 27 | fill_spans(mode) | gfx 01D3 with dx=[bp+6] over accumulated span table | med | caller C45C |
| 0FB2:0519 | 6 | spans_reset() | calls 051F: span tables 22A1←FFFF, 2459←0 for rows [2615]..[2617] | high | callers BCEF, C45C |
| 0FB2:069A | 12 | add_edge() | calls 06A6: clip edge (2299,229D)-(229B,229F) (INT0 hook 084E) and rasterise into span tables (0555 vertical/05B3 Bresenham) | high | caller C45C |

#### 1039 — palette manager (VGA DAC, via 14C2)
| entry | size | alias | role | conf | evidence |
|---|---|---|---|---|---|
| 1039:0000 | 156 | palette_build_apply() | if [0D47]≠2 patches 0x30-byte ramps (colours 0x70-0x7F and 0xA0-0xAF) of the 3 base palettes 164A/194A/1C4A from 1F4A..203A; copies 0x300 bytes of one base palette (choice by [43DC] and [368A]) to working palette DS:104A and loads all 256 DAC entries (14C2:0000); if [368C] also 009D | high | callers 00F0, 01B9; [0D47]=byte table DS:00EE[theatre] |
| 1039:009D | 26 | pal_set_98_A() | DAC 0x98..0x9F ← DS:206A | high | 14C2:0000(0x98,8,ds:206A) |
| 1039:00B7 | 26 | pal_set_98_B() | DAC 0x98..0x9F ← DS:1212 | high | |
| 1039:00D1 | 23 | pal_save() | read 768 DAC bytes → DS:0D4A (14C2:00B7) | high | caller 1EB0 (before adv.pic) |
| 1039:00E8 | 25 | pal_restore() | DAC 0..255 ← DS:0D4A | high | caller 1EB0 |
| 1039:0101 | 25 | pal_set_134A() | DAC 0..255 ← DS:134A (palette for adv.pic screen?) | med | caller 1EB0 2071 path |
| 1039:011A | 54 | shade_level() → al | 0..0x1F value from [4993] (z/height byte), [49AA], [43E6]; 0 if [7D8E]≠0 | low | callers DB3C, E2B6 (3D) |

#### 104E — fixed-point helpers and fast sin/cos (Q15 sine table DGROUP 2084)
| entry | size | alias | role | conf | evidence |
|---|---|---|---|---|---|
| 104E:0000 | 22 | fmul15r(a,b) | (a*b)>>15 rounded (shl/rcl then adc) [verified] | high | 87 far calls |
| 104E:0016 | 15 | fmul15(a,b) | (a*b)>>15 truncated [verified] | high | code |
| 104E:0025 | 50 | fdiv8(a,b) | (a<<8)/b, saturates ±7FFF | high | code |
| 104E:0057 | 15 | muldiv(a,b,c) | a*b/c | high | code |
| 104E:0066 | 16 | fcos(angle) | sin(angle+0x4000) | high | 11 calls |
| 104E:0076 | 12 | fsin(angle) | table DS:2084 (257 words, ±32767, 256 steps per 360°), linear interpolation on low byte (008A) | high | 12 calls |
| 104E:0082/0086 | — | sin_bx / cos_bx (register) | angle in BX → BX; used by HUD 1058:0789 | high | |

#### 1058 — HUD renderer + joystick (port 0x201)
HUD layout block DGROUP 291C..2948, 284C..2904 (param blocks for gfx string/number calls), 2B12/2B82 ladder vertex tables.
| entry | size | alias | role | conf | evidence |
|---|---|---|---|---|---|
| 1058:000A | 4 | hud_symbology() | → 0016: draws HUD: airspeed digits from [B194]/50, altitude tape from [2DF6]/1000, heading tape from [2DEE], pitch ladder from [2DF0] rotated by roll [2DF2] (5 rungs, sin/cos 104E:0082), flight-path/marker boxes; styles by [294A] (0/1/other) and [294B] (large HUD); colours [2CA0]/[2CA1]; gfx 011F/0124/0129/012E/0138/0151/0174/01A1/01B5/01BA/0197 | high | caller main loop 1BDB (only when [C0A6]==0) |
| 1058:000E | 4 | hud_init_colours() | → 09D8: day/night colour set by [43DE] (0x0A/0x2F vs 0x0F/0x07), source seg [E584] into blit blocks, then falls into 0A2C | high | caller 01C1 |
| 1058:0012 | 4 | hud_layout() | → 0A2C: two complete HUD geometry sets for [294B]=1 (big) / 0 (normal) | high | caller 1EB0 key handler 2051 (toggle [294B]) |
| 1058:0C60 | — | hex4(ax) | 4 hex chars via table DS:295C "0123456789ABCDEF" → 2957..295A | high | |
| 1058:0C91 | 14 | joy_center() | reads stick (0CC1) and sets min/centre/max calibration = current | high | caller 1EB0 (key at 2063, 40-frame debounce [2E0E]) |
| 1058:0CB2 | 15 | joy_read() | 0CC1 raw timing loop on port 0x201 (axes A-X, A-Y → [2CCA],[2CCC], 0xFFFF on timeout) then 0D09 auto-calibrating scale to bytes [2CD2] (X) [2CD3] (Y), 0x80 = centre | high | caller 1EB0 1FCB (if block+72 bit0) |
| 1058:0D7A | 18 | joy_cal_save(far*) | copy 0x14 words DS:2CA2.. → far ptr | high | main 00BB with block+0x48 |
| 1058:0D8C | 22 | joy_cal_load(far*) | far ptr → DS:2CA2 (0x14 words) | high | main 0076 with block+0x48 |

#### 1132 — keyboard INT 9 hook (keypad = virtual stick)
| entry | size | alias | role | conf | evidence |
|---|---|---|---|---|---|
| 1132:0002 | 80 | kbd_install() | clears NumLock (40:17 &= ~0x20), resets [2CD6]=[2CD7]=0x80, saves INT 9 vector to cs:0181 and hooks 1132:006C | high | caller 0235 (if block+72 bit0 clear = no joystick) |
| 1132:0052 | 26 | kbd_remove() | restores INT 9 | high | caller 0235 exit |
| 1132:006C | ~276 | int9_isr | reads port 0x60; scancodes 0x29..0x51 → direction mask via DS:2CDE (sc 0x29 backquote=1, sc 0x2B backslash=4; keypad 7=5 8=1 9=9 -=2 4=4 5=0x80 6=8 +=8 1=6 2=2 3=0xA); press sets: mask 1 → [2CD7]=lo, 2 → [2CD7]=hi, 4 → [2CD6]=lo, 8 → [2CD6]=hi, lo/hi = 0x80∓0x5A, or ∓0x7F if same key re-pressed within 5 BIOS ticks; release recentres to 0x80; ignores when shift XOR numlock; de-duplicates typematic repeats in BIOS buffer; chains via `JMP FAR cs:[0181]` (114A:0000) | high | code 1132:008D..0180 |

#### 114A — screen-space drawing helpers (C-callable)
Page descriptors: words at DS:4010, 4028, 4040, 0344, 4070 are pointers to structs {+0 page id, +4 colour, +6 alt colour, +0E x0, +10 x1, +12 y0, +14 y1 (viewport)}.
| entry | size | alias | role | conf | evidence |
|---|---|---|---|---|---|
| 114A:0006 | 50 | view_line(x0,y0,x1,y1) | line clipped to viewport of page [4010] (origin gfx 0250→019C, clip 2293/2295), colour [page+4] | high | 19 calls (79BE, 983E, 9EFA) |
| 114A:0070 | 222 | win_line(x0,y0,x1,y1,wx0,wy0,wx1,wy1,both) | line clipped to arbitrary window; if `both` also drawn on the other page ([40B6] flip) | high | callers 87C1, 87FD, 881F, 8A90 |
| 114A:014F | 140 | rect_outline(x0,y0,x1,y1,colour) | 4 win_line calls on full screen, colour to both page structs | high | caller 79BE |
| 114A:01DB | 165 | marker_box(x,y,colour) | 9x7 box (x±4, y±3) | high | caller 8A90 |
| 114A:0280 | 78 | mfd_clear(side, colour) | fill_rect left MFD (4A,6E)-(96,A9) if side==1 else right MFD (A9,6E)-(F5,A9) on visible-dependent page | high | 8 callers (MFD pages) |
| 114A:02CE | 49 | fill_rect_both(x0,y0,x1,y1) | 0FB2:0246 on pages [4010] and [4028] | high | 1EB0, 3ADA, 79BE |
| 114A:02FF | 61 | restore_rect(x,y,w,h) | gfx 01EC copy from page 2 (cockpit art) to pages 0 and 1 | high | 00F0 (0,5B,140,6D = whole panel), 1EB0, 2F9D |
| 114A:033C | 45 | side_bar(len, colour, y0, y1) | if [368C]: horizontal bar from x=0x56 right (len>0) or from 0x88 left (len<0), rows y+0xBB | med | callers 5046, 528D, 63F2 (threat/detection gauge?) |
| 114A:03AD | 80 | blit_icon(col,row,x,y) | 7x7 cell from art page ([E584]) at (col*8+1,row*8+0x29) to (x-3,y-3), masked (gfx 027D) | high | caller 8A90 (map symbols) |
| 114A:03FD | 84 | blit_art(sx,sy,dx,dy,w,h,masked) | rect from art segment [E584] to current page [40B6]; masked→027D, else opaque 0287 | high | 11 calls (2F9D cockpit views, 17B4, 3ADA, 79BE, D6DD) |
| 114A:0461 | 84 | detail_scale(level,v) | v*{1/2,5/8,3/4,7/8,1} for level 0..3,else | high | callers 983E, C5B2 |
| 114A:04B4 | 563 | mat3_mul(a*,b*,out*) | 3x3 Q15 matrix product via 104E:0000 | high | caller 2C87 |

#### 11B8 — DOS file I/O with fatal errors
| entry | size | alias | role | conf | evidence |
|---|---|---|---|---|---|
| 11B8:0008 | 94 | fopen(name, mode) | INT21/3D; errors → 01CD with "File not found"/"No file buffers"/"Open error"; [4660]=0x200 | high | via D557 |
| 11B8:0066 | 94 | fcreate(name, attr) | INT21/3C | high | |
| 11B8:00C4 | 40 | fclose(h) | INT21/3E | high | via D569 |
| 11B8:00EC/011E | — | fread(h,n,buf) / fread_far(h,n,off,seg) | INT21/3F | high | |
| 11B8:0153/0174 | — | refill buffer DS:43F8 (512) from [4662] | | high | used by 11ED |
| 11B8:0195 | — | fwrite_far | INT21/40 | high | |
| 11B8:01CD | — | fatal(name,msg) | INT10 mode 3, print name+msg ($-strings DS:45F8..), exit via 11D8:0000 (INT21/4C00) | high | |

#### 11D8 + 11ED — .PIC loader (LZW)
| entry | size | alias | role | conf | evidence |
|---|---|---|---|---|---|
| 11D8:000A | 117 | pic_decode(handle, page) | for 200 rows: 11ED:0006 decodes one 320-byte row into DS:9546, gfx 0219 writes row (023C row offset, 0232 page seg, 0241 clear) | high | caller D52E (pic_load) |
| 11D8:007F / 00EA | 107 | pic_decode_to_seg variants | same, output to ES segment (gfx 022D / 021E+0228 hooks) | med | no direct far callers found (via pointers?) |
| 11ED:0006 | 42 | lzw_row() | LZW decoder: 9-bit start codes (0x1FF/0x100), dictionary 0x800 entries × 3 bytes at DS:C6B4, input via 512-byte buffer DS:43F8 | high | code 11ED:0030..00AE |

#### 120A + 130D + 1377 — 3D object renderer and own rasteriser
| entry | size | alias | role | conf | evidence |
|---|---|---|---|---|---|
| 120A:0008 | 145 | camera_setup(angles*, fov) | [7D5E]=0x7FFF00/max(2|fov|,0x100) projection scale; view matrix DS:7B28 (copy 1452:0316, transpose 1452:02E4), scaled, axis flip if [7D6A] | high | caller D9A2 |
| 120A:00CF | 229 | draw_object(id, x, y, z, a, b) | object db in segment [8590]: es:[0]=count, es:[2+2*id]=LOD list (dist,ptr pairs); transform by view (1452:0330), LOD by distance [7CDC], cull 02B2, transform verts 0317, draw faces 06B5/0A33/0C76 (with INT0 hook 027D/029E); sets [C6B2]|=0x80 if drawn | high | 7 calls (13F1, DC46, E2B6) |
| 120A:01B4 | 200 | test_object(id,x,y,z,a) | same transform/LOD/cull without drawing (visibility/hit test) | high | caller 1007 |
| 120A:0F97 | 166 | prerotate_grid() | rotates vertex list of object #count (last object) by view matrix into 32-bit cache DS:4EE6 (12 bytes/vertex) | med | caller D826 (per-frame 3D setup) |
| 130D:01BD | 72 | line3d(x0,y0,x1,y1,colour) | 16-bit points → 32-bit segment DS:5EEA, clip 033F, draw 0205 | high | no callers (130D:000E in the old listing was the tail of 120A:0F97) |
| 130D:004A/0116/033F/0205 | — | add_edge(SI) / polygon_emit(colour) / clip_segment(SI) / draw_if_visible(SI) | see vgame-asm.md §2 (130D) for registers and globals 85DC..8600 | high | only from 120A |
| 1377:000C | 26 | raster_init(modeChar) | 'E' EGA, 'M' MCGA (stride 320), 'C' CGA, 'T' Tandy: builds row-offset table DS:861C, vtable ptr [85F2] = cs:0070/007C/0088/0094 | high | main 008F `push 0x4D` ('M') |
| 1377:0043/004C/0055/005E/0067 | 9 each | raster slot +2/+4/+6/+8/+A wrappers (0043, 0067 dead) | via vtable [85F2] (M = cs:007C): 0287 put_pixel(x,y,c), 01E0 set_colour(AX) (colours ≥0xA0 with hi=FF fogged by [48C4]), 046F Bresenham line(SI), 0B09 fill_spans (colour hi FB discard, FC stipple, FD OR, FE AND, else dither pattern) | high | 1377:0070 vtable words; vgame-asm.md §2 |
| 1377:00A0 | 34 | dos_alloc_max(min) | INT21/48 | high | |
| 1377:072B | 136 | edge_to_spans() | polygon edge into span tables, clip [85FC]/[8600] | high | 130D:0067 |
| 1377:07E8 | 94 | hspan(x0,x1,y?) | clipped span update ([9160]) | med | far call from 130D:019E region |

#### 1452 — 3D math (tables in 14D1)
| entry | size | alias | role | conf | evidence |
|---|---|---|---|---|---|
| 1452:0006 | 45 | sin(a) | 14D1:0000 quarter-wave, 2048 words | high | |
| 1452:0033 | 48 | cos(a) | same table | high | |
| 1452:0063 | 99 | atan2(y,x) | octant select via DS:91A8, table 14D1:1000 | high | |
| 1452:00DB/011C | — | v*sin(a) / v*cos(a) | | high | |
| 1452:0160 | 48 | asin(v) | table 14D1:3202 (1024 words) | high | |
| 1452:0190 | 74 | hypot2(a,b) | max + max*T[min/max], table 14D1:3000 (257 words, √(1+t²)−1) | high | |
| 1452:01E2 | — | hypot3(a,b,c) | two hypot2 | high | |
| 1452:021B | — | vec_rot(v*, m*) | v ← M·v (Q15) in place | high | |
| 1452:0288 | — | mat_mul(a*,b*,out*) | 3x3 Q15 | high | |
| 1452:02E4 | 50 | mat_transpose(src*,dst*) | | high | 120A:0008 |
| 1452:0316 | 26 | mat_copy(src*,dst*) | 9 words | high | |
| 1452:0330 | 123 | vec_mul32(v*, m*, out*) | 3 dword results | high | |
| 1452:03AB | 138 | mat_from_euler(a1,a2,a3,out*) | rotation matrix from three angles (sin/cos via 0006/0033) | high | 5 C callers (1007, 13F1, D9A2, DC46, E2B6) |
| 1452:04D9 | 164 | euler_from_mat(m*,o1*,o2*,o3*) | asin+atan2, gimbal case if |m[5]|>0x3E80 | high | |
| 1452:0544/0556/0591/05C8 | — | mulQ15 / safe muldiv / sat. div / imul32 | | high | |
| 1452:05D3 | — | mat_from_euler (other order) | | med | |

#### 14C2 — VGA DAC I/O
| entry | size | alias | role | conf | evidence |
|---|---|---|---|---|---|
| 14C2:0000 | 40+ | dac_set(first, count, far rgb*) | waits vertical retrace (3DA bit3), writes 3C8/3C9; if BIOS 0:489 bit1 (grey-scale summing) converts to grey 0.30R+0.59G+0.11B | high | 6 callers (1039, 4973, 4E5F) |
| 14C2:00B7 | 26 | dac_read_all(far*) | 768 bytes from 3C7/3C9 | high | 1039:00D1 |

### Far data segments

| seg | size | content | evidence |
|---|---|---|---|
| 14D1 | 0x3A10 | 0000–0FFF: sin quarter-wave, 2048 words Q15 (0..32767). 1000–2FFF: atan table, 4096 words (0..0x2000 = 0..45°, angle unit 0x10000 = 360°). 3000–3201: hypot correction 257 words (0..27145 = (√2−1)·65536). 3202–3A01: asin, 1024 words (0..16383 = 90°). | 1452 code; values dumped. funcs `14D1_1561/157C/1637/203A/2526` are data mis-decoded as code |
| 1872 | 0x4FD0 | 20 sprites 55×47, format {w,h; per row: count, xstart, count colour bytes}: explosion/fireball animation (small flash → big fireball → debris), colours 0x00–0x5F. Far ptr table DS:91B8 (20 dwords: 0000,00D5,0229,054B,0810,09F9,0CDA,10F4,1712,1DBA,260E,2EA9,37A2,3F50,4454,484D,4B01,4CA4,4DEB,4F00). The "letters A–Z" are colour bytes 0x41–0x5A. | relocs at DS:91BA..9206; 0000:1A98 draws [91B8+4*i] via gfx 0188 |
| 1D6F | 0xD30 | 8 sprites 24×20 same format: smoke/cloud puffs (colours 4B–4E grey, 45–47). Far ptr table DS:9208 (8 dwords: 0000,01B6,0361,04F2,06A7,0848,09EF,0B82). | 1AE9/1B2E draw [9208+4*i] (callers DC46 = 3D view) |

### Driver thunks (DGROUP 1E42:011A..0322)

Graphics = MGRAPHIC.EXE (code seg 019C, slots 0..83 → 011A..02B9), misc = MISC.EXE ("MISCOVR", seg 0007, slots 90..95 → 02DC..02F5), sound = xSOUND.117 (seg 01B6 for AdLib, slots 100..104 → 030E..0322). Only thunks VGAME calls are listed.
| thunk | slot | drv entry | role | conf | evidence |
|---|---|---|---|---|---|
| 011A | 0 | 04FE | get_page_seg(n): 0 → A000 screen, else DOS-allocated 64K buffer | high | 02C4: page0→[8612],[861A]; page1→[8614] |
| 011F/0124/0129/012E/0138 | 1/2/3/4/6 | 0224/020E/0219/022F/0203 | HUD glyph/number/tape primitives (register args BX=param block, BP; CX,DX from stack) | med | only from 1058 HUD |
| 0133 | 5 | 019A | draw_string(str, xy?) | med | 89C0 |
| 0151 | 11 | 071A | HUD scale/tape strip blit (direction by SI) | low | 1058:00D4 |
| 0156 | 12 | 07A3 | draw page := page 1 (back buffer) | high | main |
| 015B/0160/0165 | 13/14/15 | 07B2/07AC/07C3 | set draw page (AX=n / stack n / AX=seg) | high | 0FB2, 0300, 114A |
| 016A | 16 | 07C8 | get draw page seg | high | 0FB2:024E |
| 0174 | 18 | 0EE6 | opaque blit from param block (BP) | med | 1058 |
| 0188 | 22 | 0B70 | draw scaled sprite (page, x, y, w, h, far sprite*) | high | 1A98/1AE9/1B2E |
| 0192/0197 | 24/25 | 07CD | reset viewport origin [196]=0 | high | D87C |
| 019C | 26 | 07D5 | set viewport origin offset (from 0250) | high | 11A8, 17B4, 114A |
| 01A1 | 27 | 07DB | set origin (AX) | high | 1058 |
| 01AB | 29 | 07E4 | returns 0x1450 (default HUD/view origin offset = row 16, x 80) | med | 1058:0BC4 |
| 01B5 | 31 | 0599 | draw line AX,BX–CX,DX in current colour | high | 0FB2:0371, 1058 |
| 01BA/01BF | 32/33 | 0561/055B | set colour (AH register / stack byte) | high | |
| 01D3/01E2 | 37/40 | 0F3D/0F3B | fill rows AX..CX from span tables BX (left) BX+1B8 (right), DX=pattern (01E2: DX=0) | high | 0FB2 |
| 01E7 | 41 | 1188 | recolour(page*, x0,y0,x1,y1, from, to) — replace colour in rect (cockpit lamps) | high | 01C1, D578 |
| 01EC | 42 | 1131 | copy_rect(srcPage, sx, sy, dstPage, dx, dy, w, h) | high | 26 calls (114A:02FF) |
| 01F6 | 44 | 11F1 | present: copy AX words back buffer (page1) → A000; AX = [2E66]*160 | high | main loop 1BF5 |
| 01FB | 45 | 080F | get visible-page flag cs:[198] → [40B6] | high | 79BE, 03CE |
| 0200 | 46 | 125C | per-timer-tick: random flicker of DAC colour 0x0D (LCG, 4 RGB triplets) + screen-shake countdown (CRTC start-low jitter) | high | timer ISR 0000:1E85 |
| 0214 | 50 | 04A4 | DOS largest free block | high | E586 |
| 0219/021E | 51/52 | 12E0 | write 320-byte row SS:BP → ES:DI | high | 11D8 |
| 0223/0228/022D | 53/54/55 | 12DD–12DF | no-op row hooks | high | 11D8 |
| 0232 | 56 | 12D5 | ES := page seg[SI] | high | 11D8 |
| 023C | 58 | 12BA | row offset of row DI | high | 11D8 |
| 0241 | 59 | 1118 | clear 64000 bytes at ES | high | 11D8 |
| 0250 | 62 | 0814 | offset of (x,y) = x + rowtab[y] | high | 11A8, 17B4, 114A |
| 0255 | 63 | 0826 | returns 3 (adapter id = VGA/MCGA) | high | C8CA |
| 025F | 65 | 07FE | set driver var [00CE] (?) | low | D8AF |
| 0273/0278 | 69/70 | 04CA/04E4 | display off / on (wait retrace, 3D8 & sequencer reg 1) | high | 00F0, 1EB0 around picture loads |
| 027D/0287 | 71/73 | 0E30/0ED5 | masked / opaque blit, param block {srcSeg, dx, dy, page, sx, sy, w, h, ...} | high | 114A:03AD/03FD |
| 0291 | 75 | 0791 | set page seg table[n] = seg | high | 02C4 (page 2 = block+0x20) |
| 0296/029B/02A0 | 76/77/78 | 09A8/0B0C/09D4 | memory pool init / save rect to allocated buffer (handle → [BA3A]) / free | med | 0300 (ordnance.pic MFD area) |
| 02A5 | 79 | 1251 | screen_shake(ticks) ([1250]) | high | 0235, 79BE (0x3C) |
| 02DC | 90 | MISC 000A | key-not-ready? (INT16/01: returns 0 when a key is waiting, FFFF otherwise) | high | 1EB0 20B7 loop |
| 02E1 | 91 | MISC 0005 | getkey (INT16/00) | high | 1EB0 ('Y' test) |
| 02EB | 93 | MISC 0029 | joystick button n (port 201 bit n+4) → 1 if pressed | high | C89C |
| 030E | 100 | 0B76 | sound init(arg) | med | (not called by VGAME directly?) |
| 0313 | 101 | 0B98 | sound command(n, …), n ≤ 0x2D dispatch table; e.g. 0x28 = register speech.117 data (seg,off), 0x17/0 at start, 0x0B/0x0C/0x11/0x19 effects | high | 17 calls (D3F9 wrapper) |
| 0318 | 102 | 0BB5 | sound stop/silence | med | |
| 031D | 103 | 0C08 | sound tick → returns timer-rate request (>0 / <0) | high | timer 1E9D (6 of 7 ticks) |
| 0322 | 104 | 0C1C | fast sound tick (when PIT runs faster than frame rate) | high | ISR 1CD4 |

## 5. Key globals (DGROUP)

Consolidated; where the parts disagreed the resolution is noted. w = word, b = byte, dw = dword.

### Player state
| ds: | size | name | evidence |
|---|---|---|---|
| BA3C:BA3E | dw | player X (east), 32-bit world units | 1EB0:2A67 `+= sin(hdg)*v/368E`; 4BEC:4C52 start pos = base.x<<5 |
| C056:C058 | dw | player Y (north, stored inverted: map y = 0x8000-(Y>>5)); renderers add 0x1000000 bias | 1EB0:2A90; 3ADA:3AF5 |
| C0D0 / C0DE | w | player map X = (X+16)>>5, map Y = 0x8000-((Y+16)>>5) (0..0x7FFF); used by AI, radar, MFDs, event log (>>7) | 3ADA:3AF2/3B0C; clamped 0x100..0x7E00 / 0x200..0x7D00 at 3C80 |
| 2DEE / 2DF0 / 2DF2 | w | heading / pitch / roll (binary angles) | written only by 2CB9 (Euler from matrix); heading/0xB6 shown as degrees (2F9D:3938) |
| 2D94..2DA5 | 9w | attitude matrix (Q15) | 2C87 / 2CB9 / 2E5E |
| 2DF6 | w | true altitude (ft), 0..60000, floor = ds:C0CE | 1EB0:2A42..2AB7; HUD 1058 and ext.-view text display it |
| 2DF4 | w | compressed altitude used by 3D/AI/ground tests: <0x2000 linear, then /2+0x2000, then /4+0x3000 | 1EB0:2ABD..2AEB (only writer besides init) |
| C0CE | w | ground/deck elevation under the player (0 land, 0x80 carrier deck) | 1EB0:2AA0; 3ADA:40D5 |
| B07E | w | speed (internal units, max 0xAFC8) | 1EB0:26F1..27E5; catapult sets 0x546 (2033) |
| B194 | w | airspeed shown = B07E/27 | 1EB0:27FF |
| E586 | w | climb rate | 1EB0:2A3A |
| E474 / B03A | w | stall speed / stall speed*27 | 1EB0:265B..26F1; stall lamp in 79BE:7A9A |
| B784 / 98F6 | w | angle of attack / bank-projected AoA (flight-path marker) | 1EB0:2766/2784 |
| 990C | w | load factor *16 (G), string ds:9900 "N.nG" | 1EB0:2564..261B |
| 2E0A | w | throttle % 0..100 | keys - = _ + in 1EB0; readout 3A3B |
| B19C | w | engine spool (lags throttle; 0 = engine off) | 1EB0:24E4..2561 |
| 3666 | w | fuel (10000 at start 3B3B; 5000 after rearm 49F9; +0x76C "Fuel transfer") | 1EB0:2551; 3A0D |
| 3684 | w | altitude-hold target, 0 = autopilot off ('7'; any stick input clears) | C8CA:CB77; 1EB0:2238 |
| C0A4 | w | desired heading (bearing to current waypoint, autopilot steering) | 79BE:7F6B..; 1EB0:2261 |
| DEB6 / E472 | w | roll / pitch command this frame | 1EB0:21B5..22BB |
| 9B34 | w | systems/mission bits: 0x01 gear retracted; 0x02 flaps ('9'); 0x04 bay doors open; 0x08 wheel brakes / catapult hold ('0'); 0x10 radar jammer ('4'); 0x20 IR jammer ('3'); 0x2000 secondary / 0x4000 primary target achieved | gear: C8CA tail D39C..D3C5 (bit set when ds:C09E reaches 0 with ds:A098=0) and 1EB0:22E0 (gear-down overspeed buffet when bit clear) — part G's "1 = gear down" is wrong; brakes: 1EB0:2787, catapult 2025..2041, carrier start 3ADA:3BC2; jammers vs missile classes 683E:70E1 |
| 9B35 | b | 0x01 auto-designate ('n'), 0x02 camera locked, 0x04 ILS display (F9), 0x10 training/invulnerable (Alt-T, blk2+3C), 0x20/0x40 secondary/primary achieved | C8CA, 761A, 7594 |
| A098 / C09E | w | gear-down command (1 at start, '6') / gear position 0 (up) .. 3 (down) | 3ADA:3B88; C977; D39C |
| E58A / 9908 | w | bay-door command ('8') / bay door position 0..2 | C9AE; D348..D374 |
| 3664 | w | damage bits: 0x02 engine, 0x04 controls, 0x08 nav, 0x10 bay jammed, 0x20 fuel leak, 0x40 ECM/decoy dead (7 status lamps, page 0x16) | 761A random bit; 1EB0:24BD/2308/2530; 83E9 |
| C5F4 | w | hits taken / damage severity (leak rate, engine cap) | 761A; 1EB0:24C4 |
| 3682 | w | gun rounds (1000) | 4777; 79BE "GUN" |
| 3668[1..3] | w | flares / chaff / decoys left | 462E |
| 3670+4i / 3672+4i | w | station i store type (ds:3690 index) / count | 3ADA:3C40 from block+38/+40 |
| 3680 | w | selected station 0..3 (Space) | C8CA:CB42; 7663 |
| B07C | w | missile slot of player's last guided weapon | 7663:78AF |
| C09A | w | ejection sequence counter (0 = in aircraft) | C8CA:CD60; 1EB0:23B4 |
| DECE/DEF2/DEF6 | w | eject camera x/y/alt (DEF6 decays; <0 ends mission) | C8CA:CD04; 1EB0:2400 |
| 3D8A | w | stealth/radar signature (alt or skill term + B07E>>10 + bank/2 + 0x18 bay open + 0x10 radar jammer) | 450A:4597; compared with 100 in 5582 |

### View / cockpit / display
| ds: | size | name | evidence |
|---|---|---|---|
| C0A6 | w | view code: 0 cockpit front; 0x41 rear, 0x42 left, 0x43 right look (cockpit PICs); 0x44 front without panel; 0x84 delayed chase, 0x85 side, 0x87 chase, 0x88 player->target, 0x89 weapon cam, 0x8B target->player, 0x8C eject cam. bit 0x80 = external camera | 2F9D switch 2FFE; set by F1, Shift-F1..F6, M < > ? |
| 2E7A | w | view whose PIC is loaded | 2F9D:3668 |
| 368C | w | in-cockpit flag (C0A6&0xC0)==0; all MFD/lamp drawing returns if 0 | 2F9D:3597 |
| 2E66 | w | rows of 3D viewport presented (0x5B front .. 0xC8 external) | 2F9D:39B7; main loop 1BF0 |
| 2E08 | w | Alt-C: taller front 3D window (0x6B rows instead of 0x5B) | 2F9D:370C; C9DE |
| E582 | w | camera look direction 0/0x4000/0x8000/0xC000 (/ , . m) | C8CA:CC25; 8342 |
| DF06 | w | left MFD mode: 0 moving map, 1 tactical radar | 81E8; F3 |
| E008 | w | right MFD page: 0x13 target camera, 0x14 nav/time/ETA, 0x15 stores, 0x16 damage lamps, 0x18 mission objectives, 0x19 (?) | 825D; F5/F7/F8/F10 |
| 40AE / 40B0 | w | map zoom 2..9 / radar range 0..7 (z / x) | 8575/85B3 |
| 3D9E | w | external camera distance shift 2..8 (z / x in external view) | 2F9D:2FEE |
| 40B6 | b | back-buffer page select (from T:01FB) | 79BE:79C9 |
| 4010 / 4028 / 4040 / 4058 / 4070 / 0344 / 0D1C | w | pointers to page/window descriptors {+0 page, +4 colour, +6 alt colour, +8 x, +A y, +0E..+14 viewport rect}: 4010/4028 draw pages 0/1, 4040 static cockpit copy, 4058 map, 4070 target-camera MFD, 0344 main 3D view, 0D1C ADI window | 886A, 89C0, 114A |
| 294A | b | HUD declutter 0..2 ('v') | C8CA:CBA8; 79BE, 1058 |
| 294B | b | big HUD / alternate layout ('c'; forced 0 outside front view) | 1EB0:2045; 1058:0A2C |
| 2CA0 / 2CA1 | b | HUD colours | 1058:09D8, 79BE |
| 990E | w | detail level 0..3 (Alt-D; init block+32) | C8CA:CA0A; D4A5; 1450 |
| 43F2 | w | sound level 0..3 (Alt-V) | D3F9 |
| 43EA | w | keyboard stick sensitivity 0..2 (Ins) | 1EB0:2189 |
| 43DE / 368A / 43DC | w | lamp colour scheme / night flag / palette dirty | 00F0, Alt-N (training), 1039:0000 |
| 466E, 43E0, 43E4, 43E6, 034A | w | Alt-H side strip, F6 MFD static, Alt-M ext.-view flight data, Alt-A shading, Alt-W camera full-world render | C8CA |
| C5A4 / 40CC | str / w | HUD message text / frames left (3*368E) | 8A4F; 79BE:8140 |
| 98A6, C604, DED6 | str | text scratch buffers | |

### Time, mission, targets, world
| ds: | size | name | evidence |
|---|---|---|---|
| 368E | w | sim frames per second (init 4; every 4*368E frames 3ADA:4430 sets it to ~(368E*0x3C0/(ticks*3DA8)+2)>>2 = measured fps / time-accel, clamped 4-accel..15 by D441); every integration divides by it, lifetimes multiply by it [verified 441D..44A6] | 3ADA:441D..4503; D441; Alt-F shows it |
| 3DA8 | w | time acceleration 1/2 (Shift-Z/X; cancelled on detection D4F5) | C8CA:CAC7 |
| 3D8E | w | frame counter | 3ADA:4359 |
| 9912 | w | mission clock, 1 unit = 2 game s, advanced every 368E frames; start hour ds:98A0 | 3ADA:436C; 9335 |
| 2646 / 264A / 2648 | w/b/w | frame-tick counters (timer ISR) | 1E79 |
| 262A | b | frame pending (loop sets, ISR clears) | 1BFA, 1CC5, D826 |
| C0DA | w | mission phase 0 pre-init / 1 first frame / 2 running | 1EB0:1EB5, 3ADA:3B0F |
| E57E | b | leave main loop | 4A42 |
| 008D | b | exit code (0x81; 0 = quit) | 20D3 |
| E32A | w | target mode 0 nav / 1 air / 2 ground (F2) | C8CA:CD7E; 9EFA |
| 3D92 / 3D94 | w | selected air target (aircraft slot) / ground target (site idx); bit 0x80 or -1 = none ('b' drops) | 983E auto-select; 9EFA |
| E588 | w | weapon in range / lock cue | 9EFA:A3F4; 7663 |
| C0AA, C09C, 3D98, C166/C168, 98A2, E578 | w | RWR: emitter (site idx >=0, aircraft -1-slot), strength, display timer, beam arc, colour, doppler flag | 528D, 63F2 |
| 3D90 / 9F94 / B2B2 | w | enemy alert timer / threshold / value after an attack (stealth gate for AI guns and missile guidance) | 56BB; 683E:70BA; D441 |
| B2CC/B786/B79A, 9920 | w | enemy's last-known player x/y/alt, heading | 56BB; 683E:7028 |
| DF02, DEFE, DEFA | w | alerted threats / radar IDs / visual IDs counts | 528D, 63F2 |
| E304 / E316 | 2x0x12 | primary / secondary objective (§6) — E306/E318 target site, E308 departure base, E31A landing/home base | 9515, 7594 |
| DEB4 | w | objective deadline (clock) | 9515, 3ADA:4392 |
| 2E9E+4i / 2EA0+4i | w | waypoint i x / y (4) | 8F71, 9216, C8CA nav keys |
| 2EAE / 2EB0 / B838 | w | current waypoint / waypoint being edited / edit mode | 79BE:7FA5; C8CA |
| E00C / 9922 | w | nearest friendly airbase (site idx) / distance (every 8 frames) | 3ADA:3E07 |
| 3DA2, 3DC8, 9910, E00A | w | on runway / stopped-frames / hook caught / carrier deck phase | 3ADA:40C1..4359 |
| 46F2 | w | ILS state 0 off, 1 low, 2 on slope, 3 high | 4F2B |
| DEFC / C0E0 / 992C / E56C | w | aircraft slot count / ground-site count / radar-site count / airbase limit | 4D5D order |
| 951A | w | event-log record count (max 255) | 4ABA |
| 3D96 | w | burning/last destroyed site (-1 none) | 73C8, 48B8 |
| 9D3C / C0CC,C0D6,C0DC / 992E | w | explosion flash timer / explosion point / exploding aircraft | 9EFA:A257 |
| E574:E576 / 9924:9926 | dw | far ptr shared block / blk2 = block+0x1272 | 0010 |

## 6. Lookup tables and object arrays

Static type tables (DGROUP, initialised data):

| ds: | stride x count | content |
|---|---|---|
| 0090 | word x 8 | theatre name ptrs: 0 lb (Libya), 1 pg (Persian Gulf), 2 nc (North Cape), 3 ce (Central Europe), 4 vn (Vietnam), 5 me (Middle East), 6 ku (Kuriles), 7 cu (Cuba) — strcpy'd over ds:0042 "regn.xxx", extension replaced by 0CF3 (.3dG/.3DX/.3dT) |
| 00EE | byte x 8 | per-theatre value 6,6,2,2,2,6,6,2 -> ds:0D47 (1039:0000 skips palette ramp patch when 2) (?) |
| 0A68 | 64 x 8 | per-theatre L4 8x8 terrain map (copied to ds:B03C) |
| 3DAA | word x 8 | per-theatre ±1: runway direction sign / start heading (N or S) |
| 2EB2 | 0x0E x 23 | radar/emitter types: +0 name[8] (0 none, 1 SA-2, 2 SA-5, 3 SA-8B, 4..7 SA-10..13, 8..11 SA-N-4..7, 12 Hawk, 13 Rapier, 14 Tiger, 15 Seacat, 16 IL76 AWACS, 17..20 fighter radars, 21 OTH, 22 ?); +8 range; +0A sensitivity/power (added to 2*skill in 5582); +0C flags (bit0 doppler -> look-down/speed dependent, bit1 no search-cone limit) |
| 2FF4 | 0x20 x 29 | aircraft types (MIG-23 ... ends at 0x3394): +0 name[7], +7 nickname (" Flogger"), +12 max speed (MIG-23 740), +14 detect/scramble radius & loiter factor, +16 agility 1..5 (roll limit <<12, rate <<8), +18 radar type (2EB2 index, 0 none, -1 western), +1A 3D shape id, +1C =2 (?), +1E kill counter (runtime) |
| 300E | word | aircraft LOD shape ids [type*16+lod] (overlaps 2FF4 rows: = row+0x1A) | 
| 3394 | 0x12 x 40 | projectiles (missiles/bombs): +0 name[8] (0 None, 1..0x0F SAMs SA-2..Seacat, 0x10..0x15 AA-x, 0x16 AIM120, 0x17 AIM-9, 0x18 HARM, 0x19 Penguin, 0x1A Harpoon, 0x1B AGM-65, 0x1C LGBOMB, 0x1D RTBOMB, 0x1E FFBOMB, 0x1F AIM-7W, 0x20 AIM-9W, 0x21 SA-14, 0x22..0x25 AAMs, 0x26 Equip., 0x27 SA-9); +8 range/lifetime; +0A max speed (slot speed = >>6); +0C seeker class (<=0 IR, 1..3 radar (3 = aspect test), 4 anti-radiation, 5 anti-ship, 6 TV, 7 player AAM; bombs); +0E turn rate (<<7 heading, <<8 pitch); +10 3D shape id |
| 3690 | 0x1A x 20 | player stores: +0 short name[10] ("AIM-9M"), +0A long name[12] ("Sidewinder"), +16 projectile index (3394) (-1 camera pod, -2 extra fuel), +18 icon index in ordnance.pic. Rows: AIM-9M, AIM-120, AGM-88A, P3 ASM/Penguin, AGM-86A/Harpoon, AGM-65D, GBU-12, Mk 20, Durandal, Mk 82-0, Mk 82-1, Mk 20 Rockeye II, Mk 122, CBU-72, Mk 35, ISC B-1, 135 mm camera, 1900lbs extra fuel, Special/Equip, 20 mm (row 19 = 0x387E) |
| 3898 | 16 x 20 | weapon-vs-target-class effect table: byte [store*16 + (ds:C630[shape]&0xF)] (8A67) |
| 3ABA | word [3][8][8] | AI manoeuvre table: [skill][altitude sector][bearing sector] -> roll command <<12; 0x100/0x200 = vertical manoeuvres (5852:5C06) |
| 2084 | word x 257 | sine Q15, 256 steps per turn (104E sin/cos; asin by search 2ED9) |
| 2D14 | byte x 128 | load factor*16 by |roll|>>8 |
| 2CDE | byte x 0x29 | scan code 0x29..0x51 -> virtual-stick direction bits (1132 ISR) |
| 3F30 | 6 x n | cockpit lamp map {sprite, ?, state} (889B) |
| 4708 | 12 x 0x25 | lamp rectangles {x,y,w,h,style,state(4712)} (D578); colours ds:46A2[style*8+on] |
| 4684 / 4670 | 6 x n / byte x 10 | LED digit fields {x,y,len} / glyph x per digit (D667) |
| 4096 / 40B8 | word | right / left MFD page -> lamp ids |
| 436A..437E | | target-camera zoom label "nX", nominal range per size class (0,10,30,50,80,100,150,200,250), scales |
| 164A / 194A / 1C4A, 104A, 0D4A, 134A | 0x300 | base palettes day / ? / night, working palette, saved DAC, quit-screen palette |
| 91B8 / 9208 | far ptr x 20 / x 8 | explosion sprites (seg 1872) / smoke puffs (seg 1D6F) |

Runtime arrays (DGROUP):

| ds: | stride x count | fields |
|---|---|---|
| B2CE sites | 0x10 x [C0E0] (entry 0 = scratch aim point, saved/restored by 683E) | +0 name string idx (ds:DF08), +2 x, +4 y, +6 radar type (2EB2, 0 none), +8 flags (lo: 0x01 airbase, 0x02 being scanned, 0x04 announced, 0x10 radar on/tracking, 0x80 destroyed; hi: 0x01 friendly/no-launch, 0x02 carrier, 0x04 not a waypoint, 0x08 no AI traffic, 0x10 radar ID'd), +0A alert 0..255 (0x7F alert, 0xC0 shoot, 0xFA ID), +0C scan timer / based aircraft type (?), +0E shape/name2 idx (|0x100 = mission target). Parts D/F index the same array from ds:B2D0 (= +2) |
| C16A aircraft | 0x24 x [DEFC] | +0 home/waypoint site, +2 x, +4 y, +6 alt, +8 dw x acc, +0C dw y acc (x = acc>>5), +10 heading, +12 pitch, +14 roll, +16 type (2FF4), +18 flags (0x1 active, 0x2 airborne, 0x4 RTB, 0x8 sensor contact, 0x10 missile-threatened (?), 0x20 shot down/falling, 0x100 formation, 0x200 on final, 0x400 taking off, 0x800 visual ID made, 0x1000 landed, 0x2000 terrain pull-up, 0x4000 has detected player), +1A speed, +1C loiter/fuel timer, +1E AAM projectile idx, +20 ?, +22 alert accumulator. Parts E/F use base ds:C16C (= +2). Last 4 slots: ambient/transport traffic |
| 3C3A missiles | 0x1C x 12 (0..7 enemy, 8..11 player) | +0 x, +2 y, +4 alt, +6 speed, +8 heading, +0A pitch, +0C roll, +0E life (0 = free), +10 projectile idx, +12 player store idx, +14 target, +16 launcher (site >2 / -aircraft slot) or bomb pitch floor, +18/+1A aim point |
| 39D8 countermeasures | 0x0C x 4 | slot 0 towed decoy, 1..3 flare/chaff: +0 x, +2 y, +6 type (1 flare, 2 chaff), +8 life |
| E47A gun rounds | 0x0C x ([B198]+4) | +0 x, +2 y, +4 z, +6/+8/+0A velocity; player rounds first, 4 enemy rounds after |
| 3A08 smoke/effects | 8 x 16 | x, y, z/vz, type/age; ds:3A88 = newest |
| 3A8A fire particles | 8 x 6 | dx, dy, frame, active |
| E304 objectives | 0x12 x 2 | +0 type (1 photograph, 2 destroy, 3 drop supplies, 4 land supplies, 5 hit AN72 flying to, 6 plane returning to, 7 hit AN72 leaving, 8 destroy plane over; >=5 = aircraft target in slot 0), +2 target site, +4 base site, +6 flags (0x10 radio beacon, 0x20 timed, 2 deadline), +7 valid, +8 hour |
| BA56 event log | 6 x 255 | +0 clock, +2 x>>7, +3 y>>7, +4 type, +5 arg. Types: 2 terrain object destroyed, 3 aircraft killed (0x83 mission aircraft), 4 weapon released, 5 player hit, 6 visual ID, 7 radar ID, 8 start/end, 9 track point (every 32 clock units), 0x8A/0x4A photographed, 0x8B/0x4B primary/secondary achieved. Copied to block after the world state at exit |
| B1A0 | 16 x 16 bytes | coarse terrain cells (coord>>11): &0x0C radar clutter, 0x10 populated (MANPADS), &3 terrain type |
| C630 / C0E6 | byte x 0x80 | per-shape class nibble (9,B,C,D naval) + flags / per-shape destroyed counter |
| DF08 / E016 | word x 128 / 0x2EE | string pointers into string pool (names of sites/places) |
| B79E | 5 x [9932] | altered/destroyed 3D map objects {level, tile, idx, ?, state} |
| B094 | 16 x 16 | player flight history ring (view 0x84) |
| 4A20 / 4E6C | 22 x 50 / ptr x 50 | depth-sorted 3D draw list |
| Terrain map | | L4 8x8 ds:B03C, L3 16x16 ds:9F98 (.3dG), L2/L1/L0 4x4 patterns ds:9D40/9B38/9934; tile object lists ptr ds:E330[level*32+tile], counts ds:061E; 7-byte records {x,y,z,type} at ds:A09A (.3dT) |

World-state serialisation order (4D5D, block+0x7A..): ds:DED0(1) C0D8(1) C0E0(2) 992C(2) E56C(2) sites B2CE(C0E0*16)
DEFC(2) aircraft C16A(DEFC*0x24) C630(0x80) C0E6(0x80) strings E016(0x2EE) terrain B1A0(0x100) DEB4(2) 3D9C(2)
waypoints 2E9E(0x10) objectives E304(0x24); at exit + event log BA56(0x600).

**Sound effect ids** (argument of D3F9 / T:0313; meaning from call site, (?) where only inferred): 0x04 crash/hit,
0x05 explosion, 0x06 gun, 0x08 radar warning, 0x09 missile close, 0x0B engine start, 0x0C throttle cut, 0x0D/0x10 weapon
release, 0x0E stall warning, 0x0F countermeasure / hook, 0x11 catapult launch, 0x12 camera shutter, 0x13 gear, 0x14
eject, 0x17 airflow (param = airspeed), 0x18 engine on / 0x19 engine off (D41F), 0x1F bay doors, 0x28 register speech.117
(seg, size), 0x29/0x2A timer beeps, 0x2B safe landing, 0x2C clock start, 0x2D landing hint. No separate speech table found
in VGAME: speech.117 is handed whole to the sound driver (00F0:0127).

## 7. Input mapping

**Path**: once per frame 1EB0 drains the BIOS keyboard buffer (EBC4 kbhit, EE6A = INT 16h AH=0) keeping only the
*first* key in ds:DEBC (1F08..1F2D); flight keys are handled in 1EB0's switch (1F2D..1F82); the same ds:DEBC is passed at
the end of the frame by 450A to C8CA (all other commands). C8CA's tail D17F runs every frame (fire button, cooldowns,
animations). Alt-Q / pause use the misc driver (T:02DC key ready, T:02E1 get key).
**Stick**: if block+0x72 bit0 (joystick): 1058:0CB2 reads port 0x201 (auto-calibrating) -> ds:2CD2 (X) / ds:2CD3 (Y),
0x80 = centre; Alt-S recentres (1058:0C91). Else the INT 9 hook 1132:006C maps keypad keys (and arrow keys, which share
the scan codes) to a virtual stick ds:2CD6/2CD7 (deflection 0x5A, 0x7F if the key is re-pressed within 5 ticks, release
recentres); 1EB0:2189 scales it by Ins sensitivity ds:43EA. Stick -> roll cmd ds:DEB6 = -2*s*(|s|+2), s=(X>>4)-8; pitch
cmd ds:E472 = 6*((Y>>4)-8) (halved when negative).
**Buttons**: C89C(n) = joystick button n via misc driver T:02EB (only with joystick) OR keyboard pseudo-button
ds:43EE+2n. Button 0 = gun trigger (4777) — keyboard Backspace; button 1 = fire selected weapon (C8CA tail -> 7663,
cooldown 4 frames) and camera shutter — keyboard Enter.

Keypad virtual stick (1132): Home=up+left, Up/KP8=up(nose down?) (bit1 -> Y low), PgUp=up+right, KP- = down, Left=left,
KP5=centre, Right=right, KP+ = right, End=down+left, Down=down, PgDn=down+right, ` = up, \ = left. (Y low/high vs pitch
sign not yet checked.)

Key words are BIOS INT 16h AX = scan<<8 | ascii.

### Keys handled in 1EB0 (flight)

| code | key | handler | action |
|---|---|---|---|
| 0x011B | Esc | 210F | only while ejecting (C09A): DEF6=0 -> ends the eject sequence (end_mission(0)) |
| 0x0B30 | 0 | 2003 | toggle wheel brakes ds:9B34 bit 0x08, lamp 0x23; releasing on a deck/raised ground (C0CE!=0) at throttle 100 = catapult: speed 0x546, sound 0x11 |
| 0x0C2D | - | 1F84 | throttle -10 |
| 0x0D3D | = | 1FD3 | throttle +10 (+5 below 10) |
| 0x0C5F | _ | 1FF4 | throttle 0, sound 0x0C |
| 0x0D2B | + | 1FEC | throttle 100 |
| 0x1000 | Alt-Q | 2071 | quit prompt (adv.pic); 'Y' -> end_mission(7), exit code 0 |
| 0x1900 | Alt-P | 2183 | pause (3A4E; paused time not simulated) |
| 0x1F00 | Alt-S | 2059 | joystick recentre (1058:0C91), 40-frame debounce ds:2E0E |
| 0x2E63 | c | 2045 | toggle big HUD ds:294B (1058:0012 relayout) |
| 0x3000 | Alt-B | 2122 | blank screen + pause ("boss key" (?)), restore cockpit |

### Keys handled in C8CA (commands)

"train" = only when ds:9B35&0x10 (Alt-T); "nav" = only when right MFD page ds:E008 == 0x14. Countermeasure types are
fixed by 462E strings: 1 Flare, 2 Chaff, 3 Decoy. Jammers by 683E: 0x10 radar jammer (affects radar classes),
0x20 IR jammer (IR classes).

| code | key | handler | action |
|---|---|---|---|
| 0x0231 | 1 | C968 | release flare (462E(1)) |
| 0x0332 | 2 | C96F | release chaff (462E(2)) |
| 0x0433 | 3 | C961 | toggle IR jammer (9B34^0x20; auto-off after 368E*20 frames, lamp 6) |
| 0x0534 | 4 | C944 | toggle radar jammer (9B34^0x10; lamp 5; +0x10 signature) |
| 0x0635 | 5 | C973 | release decoy (462E(3)) |
| 0x0736 | 6 | C977 | landing gear: if airborne toggle gear-down command ds:A098, sound 0x13 (animation in tail) |
| 0x0837 | 7 | CB77 | altitude hold on (max(alt,500)) / off |
| 0x0938 | 8 | C9AE | bay doors command ds:E58A (not if 3664&0x10), sound 0x1F |
| 0x0A39 | 9 | C993 | toggle flaps (9B34^2), lamp 0x21 |
| 0x0E08 | Backspace | CBBE | pseudo button 0 (gun) if blk2+42==0 |
| 0x1C0D | Enter | CBD5 | pseudo button 1 (fire selected weapon / shutter) |
| 0x3920 | Space | CB42 | next weapon station ds:3680 |
| 0x1A5B/0x1A7B | [ { | CC93 | target camera zoom in (page 0x13) (?) |
| 0x1B5D/0x1B7D | ] } | CC4C | target camera zoom out (?) |
| 0x2C5A / 0x2D58 | Z / X | CAC7 / CAE4 | time acceleration on / off |
| 0x2C7A / 0x2D78 | z / x | C93A / C93F | zoom in / out (map, radar, or external camera distance) |
| 0x2F76 | v | CBA8 | HUD declutter 0..2 |
| 0x3062 | b | CB95 | drop target designation |
| 0x316E | n | C8E6 | toggle auto-designate (9B35 bit0) |
| 0x324D, 0x333C, 0x343E, 0x353F | M < > ? | CC02, CBF9, CBF0, CBE7 | views 0x42 left, 0x43 right, 0x41 rear, 0x44 no panel |
| 0x326D, 0x332C, 0x342E, 0x352F | m , . / | CC0B.. | target camera direction left / right / rear / ahead (then page 0x13, clears targets) |
| 0x3B00 | F1 | CBDE | cockpit view |
| 0x3C00 | F2 | CD7E | target mode nav -> air -> ground |
| 0x3D00 | F3 | CDB8 | left MFD map / radar |
| 0x3E00 | F4 | CDCB | lamp colour scheme (43DE) |
| 0x3F00 | F5 | CDD6 | right MFD stores page |
| 0x4000 | F6 | CDDB | MFD static/jam display (43E0), lamp 0x19 (?) |
| 0x4100 / 0x4200 | F7 / F8 | CDE9 / CDF3 | nav page (edit mode 1 / 0) |
| 0x4300 | F9 | CE55 | toggle ILS display (9B35^4) |
| 0x4400 | F10 | CE5D | mission objectives page |
| 0x5400..0x5900 | Shift-F1..F6 | CCE0, CCCE, CCD7, CCE9, CCF2, CCFB | views 0x87 chase, 0x84 delayed chase, 0x85 side, 0x89 weapon, 0x88 player->target, 0x8B target->player |
| 0x5B00 | Shift-F8 | CE01 | reset waypoints from objectives |
| 0x5D00 | Shift-F10 | CD04 | eject: fast -> end_mission(6), slow -> block+26=2; C09A=1, view 0x8C |
| 0x5200 | Ins | CA50 | keyboard sensitivity 0..2 |
| 0x1100 | Alt-W | C9CE | target camera renders full world (034A) |
| 0x1400 | Alt-T | CB27 | training mode toggle (sets block+30 bit0) |
| 0x1E00 | Alt-A | C9BE | shading flag 43E6 (?) |
| 0x2000 | Alt-D | CA0A | detail level |
| 0x2100 | Alt-F | CA8E | show frame rate |
| 0x2300 | Alt-H | C9C6 | side strip overlay |
| 0x2E00 | Alt-C | C9DE | taller 3D window (2E08) |
| 0x2F00 | Alt-V | CAEA | sound level |
| 0x3200 | Alt-M | C9D6 | external-view flight data text (43E4) |
| 0x1300 / 0x1700 / 0x2500 / 0x2400 / 0x2600 / 0x3100 | Alt-R / I / K / J / L / N (train) | D0C4.. D02A | rearm+repair / move north / south / west / east / day-night |
| 0x4800/4838, 0x5000/5032, 0x4B00/4B34, 0x4D00/4D36 | Up/KP8, Down/KP2, Left/KP4, Right/KP6 (nav) | D12C.. | move edited waypoint (arrow codes only with joystick; without joystick arrows fly) |
| 0x4900/4939, 0x5100/5133 | PgUp/KP9, PgDn/KP3 (nav) | D27E, D2A5 | previous / next waypoint |
| 0x4700 / 0x4F00 | Home / End (nav) | D2D4 / D2CC | clock -60 / +60 (ETA planning (?)) |

Touch-port notes: everything the player can do funnels through three places — ds:DEBC (one key word per frame),
ds:2CD2/2CD3 (stick bytes) and C89C buttons (ds:43EE/43F0). A port can inject synthetic key words into ds:DEBC and
write the stick bytes directly without touching the dispatchers.

## 8. Open questions (priority order)

1. ds:368E is measured frames/s (resolved, §5); still open: the real-time length of one frame tick (PIT locked to retrace/ds:2639) and therefore the exact clock unit of ds:9912 (one unit per ~second, displayed as 2 game s).
2. Shared block offsets: confirm +0x20 (art-buffer segment), +0x32/+0x33, +0x48 (joystick cal), blk2+0x3A/+0x3C/+0x3E/+0x40/+0x42 against START/F117.COM writers; +0x26/+0x28/+0x2C/+0x30/+0x34/+0x36/+0x74/+0x76 against END.EXE readers.
3. 5737..5850 (SA-14 MANPADS function) has no caller: dead code or called through an undiscovered pointer.
4. ds:9B34 bit 0x08: wheel brake vs hook (DC46 draws a part of the F-117 model when rolling with it set); airborne effect B07E-=B07E/16 suggests speed brake too.
5. blk2+0x40 / +0x42 exact meaning (realism level / aircraft variant or easy radar).
6. Keypad virtual-stick sign (which direction is nose up) and T:01F6 present size.
7. Field meanings in 2EB2/2FF4/3394 beyond name/index/shape are from use only.
8. 79BE vs 1058:000A split of HUD drawing (C text items vs asm symbology) — verify no duplicate drawing.
9. (resolved 2026-10-21, task 0.3) 0CDD tail, 2031 region, 6B0B..6BDD, E447/E4B6 islands: see vgame-asm.md §4.

## 9. Tools used (scratch, not in repo)

`vd.py SEG OFF LEN [x|w|s]` — capstone 16-bit disassembly / hex / word dump of the unpacked VGAME image (python 3.13 has
capstone; header 2352). Superseded in the repo by `re/tools/vgame_asm.py` (`--segs` per-module listings, `--range SEG:OFF LEN`). `drv.py` — prints driver headers (slot base, count, entry table) of MGRAPHIC/MISC/xSOUND.
`an.py` — per-function callees, string refs, DGROUP reads/writes, shared-block field use from VGAME.asm.
