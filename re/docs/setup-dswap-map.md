# SETUP.EXE and DSWAP.EXE structural maps

Both small-model MS C 6.0. Shared block (SB) = `seg(0:04F0):0000`, layout in `start-map.md` 1.3.

## SETUP.EXE

Code 0000 (C), 0237 (assembly: joystick/mouse), DGROUP 024C (linear 024C0, file offset = ds_off + 0x2570).
Everything is in `func_0000_0010` (main, 1267 bytes); text-mode UI (INT 10h via 1387, print 14BE).

| step | addr | what |
|---|---|---|
| 1 | 0016..0032 | `[ds:0FD6]` far = SB:0000, `[ds:0FD0]` far = SB:120E (unused afterwards) |
| 2 | 0038..0047 | `0A9F("misc.exe")`: allocate the largest DOS block minus 0x400 paragraphs, INT 21h AX=4B03 (load overlay), shrink to header size (+0x1E/+0x20 >> 4, +8 paras); fatal errors print "$"-strings and exit 0. `0BA2(seg)` links its jump table into DGROUP 08A6 (header +0x18, +0x1C first slot, +0x22 count, +0x24 entry offsets - same format as START `860E`). Segment kept in `[ds:0FBE]` and freed on exit |
| 3 | 0048 | `0C35`: hook INT 1Bh (Ctrl-Break) -> sets `[ds:0AC8]=0xFF`; `0503` polls it and exits |
| 4 | 004B..0168 | text mode 3, title "Night Hawk F-117A Stealth Fighter 2.0 - Version 473.03", copyright, hard-disk/floppy notes |
| 5 | 0171..018D | `0C84`: FCB find-first of the volume label (extended FCB attr 0x08, name "???????????") compared with "F117B-SF"; match -> "You cannot play F117A off of 720K floppy disks!!", exit(0) |
| 6 | 0191..01B2 | SB+0x22 = 1 (security clearance), SB+0x24 = 0, SB+0x70 = 0, SB+0x32 = 0xFFFF, SB+0x2A = 0 |
| 7 | 01C4..023E | "Do you have a joystick (Y/N) ?" (key via misc driver far 024C:0A72; 0x100 = break -> exit 0): Y/y -> SB+0x72 = 1, N/n -> SB+0x72 = 0 |
| 8 | 024E..030B | if joystick: hook INT 8 (`0FC0`, 1 tick counter `[ds:0782]`), "Center joystick, then press fire button 1" (wait button 0 via far 024C:0A77(0)), `0237:002C` sample centre, `0A4B(2)` wait 2 ticks, wait release; "Move joystick to upper left corner, then press fire button 1" (sample `0237:004D` until button 0); "Now move joystick to lower right corner, then press fire button 2" (until button 1); `0237:0115` copies the 40-byte (0x14 words) calibration block ds:0DF4 -> SB+0x48; `[ds:0FD4]` = byte SB+0x24 |
| 9 | 030D..0322 | `0237:0004` mouse detect (INT 33h vector non-null and not IRET, INT 33h AX=0 returns 0xFFFF) -> SB+0x72 \|= 2 |
| 10 | 0327..0340 | copies "Mgraphic.exe" into SB+0x00 (far strcpy `125F`). **SETUP does not load MGRAPHIC.EXE itself**; it only records the file name for the loader (F117.COM) (?) |
| 11 | 0367..047B | "Select Sound Driver:" 1) IBM Sound 2) Ad Lib Sound Board 3) Roland Sound Board 4) No Sound; key '1'..'4' -> name from ds:0778 (Isound.117, Asound.117, Rsound.117, Nsound.117) copied to SB+0x0D |
| 12 | 049E..04F1 | "One Moment Please..."; SB+0x2A = `[ds:0776]` (0), SB+0x26 = 1, SB+0x30 = `[ds:0FD4]` (joystick flag / calibration byte) (?), SB+0x32 (if still 0xFFFF) = 3 when the graphics file name starts with 'M'/'m', else 2 |
| 13 | 04F7 | `053B(0x24)`: restore INT 1Bh (0C58), free misc.exe (INT 21h AH=49h, 0BFB), unhook INT 8 if hooked (0FFE, also resets PIT ch0), `exit(0x24)` |

What SETUP leaves in SB: +0x00 graphics driver file name, +0x0D sound driver file name, +0x22 = 1, +0x24, +0x26 = 1, +0x2A = 0, +0x30, +0x32, +0x48..+0x6F joystick calibration, +0x70 = 0, +0x72 input flags (bit0 joystick, bit1 mouse). Driver segments SB+0x1A/+0x1C/+0x1E are not written by SETUP (filled later by the loader (?)).

| function | role | conf |
|---|---|---|
| 0010 | main | H |
| 0503 | break check | H |
| 0512 | set cursor (INT 10h AH=2) | M |
| 053B | shutdown(code) | H |
| 0A4B | wait n timer ticks | H |
| 0A9F | load overlay driver (INT 21h 4B03) | H |
| 0BA2 | link driver jump table | H |
| 0BFB | free segment | H |
| 0C35 / 0C58 / 0C69 | hook / restore / read INT 1Bh vector | H |
| 0C84 | volume-label check "F117B-SF" | H |
| 0FC0 / 0FFE | hook / unhook INT 8 timer | H |
| 1244 / 125F | strcpy / far strcpy | H |
| 1387 | int86 wrapper | M |
| 14BE | print string at row/col | M |
| 1509 | delay / tick (?) | L |
| 0237:0004 | mouse present | H |
| 0237:002C / 004D | joystick centre / extreme sampling | M |
| 0237:0115 / 0127 | calibration block to / from far ptr | H |
| 1994 | (references "Isound.117") runtime-side default (?) | L |
| >= 1516 | C runtime | - |

## DSWAP.EXE

Code 0000, DGROUP 0225 (linear 02250, file offset = ds_off + 0x2300). Invoked with one argument N
(0 = start.exe, 1 = vgame.exe, 2 = end.exe; `atoi` = 0FF8). Everything in `func_0000_0010` (main).

| step | addr | what |
|---|---|---|
| 1 | 0016..0042 | name = ds:006A[N] (start.exe / vgame.exe / end.exe); if `fopen(name,"r")` succeeds in the current directory -> `exit(1)` immediately (no swap needed) |
| 2 | 0043..0077 | far ptrs: 0:0410 (BIOS equipment word), 0:04F4, SB:0000, SB:1272 |
| 3 | 007D..00C0 | link sound (SB+0x1A) and misc (SB+0x1E) drivers (`085A`), graphics calls go through far stubs 0225:08DC.. (init pages, palette) |
| 4 | 00D3..0111 | 8 KB buffer (0494); first drive to try = 2 - current drive (10D0, 1-based) (?); floppy count from equipment word bits 6-7 (`& 0xC0`): 0 -> 1 drive, else 2 |
| 5 | 0116 | hook INT 1Bh (0523) |
| 6 | 011D..01D8 | for each floppy drive: reset + read sector with 3 retries (`10F4` = INT 13h AH=0/2); if the disk reads, try `fopen(sprintf("%s:\%s", drive letter, name))`; found -> select that drive (`1120(drive+1)`, set drive) and finish; otherwise toggle drive (`xor 1`) |
| 7 | 0198..01FF | not found: `023E(frame)` shows swap.pic/swap.pal with the "insert disk" frame ds:0070[N] (0 for start/end, 1 for vgame; source row = frame x 12), waits for a key: 'B'/'b' -> try drive B next, any other key -> drive A; repeat |
| 8 | 020D | `0219(1)`: restore graphics, free buffer, restore INT 1Bh, `exit(1)` |

Exit code is always 1 (both the "already present" path and the "found after swap" path) (?) - except runtime/alloc failures.

| function | role | conf |
|---|---|---|
| 0010 | main | H |
| 0219 | shutdown(code) | H |
| 023E | show swap prompt frame | H |
| 03A7 / 03D3 / 0423 / 045B | load pic / pal / file into buffer | M |
| 0494 / 04BF | alloc / free buffer | H |
| 0523 / 0546 / 0557 | hook / restore / read INT 1Bh | H |
| 085A | link driver jump table | M |
| 0F2E / 107A / 0FF8 | fopen / sprintf / atoi (runtime) | M |
| 10D0 / 1120 | get / set current drive | M |
| 10F4 | BIOS INT 13h wrapper | H |
