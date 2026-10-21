# START.EXE structural map

Front end: pilot roster, theatre/orders, briefing room + map, armament, hangar/launch.
Small-model MS C 6.0, one code segment 0000 (C code 0000:0010..~0000:8000, runtime above).
DGROUP = 0A95 (linear 0A950, file offset = ds_off + 0xAC60). All `ds:XXXX` below are DGROUP offsets.
Listing: `re/disasm/START.asm`. Companion docs: `end-map.md`, `setup-dswap-map.md`.

Confidence column: H = read instruction-by-instruction, M = read key paths, L = inferred from callers/strings.

---------------------------------------------------------------------------------------------------

## 1. Startup, shared block, exit

### 1.1 main = `func_0000_0010` (called from C startup 0000:8EDC at 0000:8F8C) [H]

| step | addr | what |
|---|---|---|
| 1 | 0000:0010 | `func_0000_7312` = init(): shared-block pointers, drivers, buffers, mouse/joystick |
| 2 | 0000:0013..001F | `if (word 0:04F2 != 0) { nop nop nop }` - 3 NOPs where a 3-byte near call was (?) - most likely the original `call func_0000_0703` (security-clearance quiz) was patched out in this (GOG) build. `func_0000_0703` has no remaining callers. (?) |
| 3 | 0000:0020 | `func_0000_6D07` = roster load + sync with shared pilot record |
| 4 | 0000:0023 | `func_0000_0E23` = pick weapons that are "unavailable" this session (see 5.3) |
| 5 | 0000:0026 | `func_0000_020F` = front-end state machine (returns when the player launches) |
| 6 | 0000:0029 | `func_0000_5625("temp.wld")` = serialise mission world into the shared block (+0x7A). The string argument is pushed but **not used** - nothing is written to disk here (5625 has no frame/arg access) [H] |
| 7 | 0000:0031..006E | shared+0x26 = 3, +0x28 = 0, +0x2C = 0, +0x30 = (pilot.mission_type > 1) i.e. training flag |
| 8 | 0000:0070..0088 | exit code: if takeoff base (site `[ds:E062]`) has flag 0x200 (byte +9 bit 1; carrier, see 4.1) -> `exit(0x0D)` else `exit(0x0C)` via `func_0000_76D1` |

Exit paths (`func_0000_76D1` = shutdown(code)): restores INT 1Bh/9, frees buffer; if code <= 1 sets text mode 3 (INT 10h via 9520); code 1 prints "Not enough memory!" and becomes 0.

| exit code | where | meaning |
|---|---|---|
| 0x00 | `func_0000_7611` (Alt-Q -> adv.pic "quit?" screen, key 'Y') | quit game |
| 0x01 -> 0 | 73CE (driver slot alloc failed), 7490 (buffer alloc failed) | fatal |
| 0x0C | main, land base | F117.COM plays PLAYER "title-2" then VGAME |
| 0x0D | main, carrier takeoff | straight to VGAME |

Alt-Q is caught by the shared input routine `func_0000_39F7` (key code 0x1000 = scan 0x10 'Q' with no ASCII) at 0000:3A8E -> `func_0000_7611`, i.e. it works on every menu screen.

### 1.2 Shared block access [H]

`func_0000_7387` (called first by 7312):

| DGROUP var | value | use |
|---|---|---|
| `[ds:E096]` far | `seg(0:04F0):0000` | shared block base ("SB") |
| `[ds:CACA]` far | `seg(0:04F0):1272` | current pilot record ("PR", 80 bytes, same layout as ROSTER.FIL record) |
| `[ds:CBD8]` far | `0000:04F2` | BIOS-area word: "first entry into START since launch" flag |
| `[ds:CAC0]` far | `0000:04F4` | BIOS-area word: "sound driver already initialised" flag |

`0:04F2`: if != 0, START copies roster[hdr] -> PR (6D07) and opens on the roster screen (020F); the roster screen clears it (623E:6246). If 0 (returning from END), PR is copied back into the roster and ROSTER.FIL is rewritten (6D07 -> 7272(0)).
`0:04F4`: 73CE: if 0 -> init sound driver (far 6B11; far 6AE4(SB+0x24)) and set to 1 (bytes at 0000:7409 = `mov word es:[bx],1`).

### 1.3 Shared block layout as used by the front ends (all EXEs combined)

| off | size | writer -> reader | meaning | evidence |
|---|---|---|---|---|
| +0x00 | char[13] | SETUP | graphics driver file name ("Mgraphic.exe") | SETUP 0000:0327..0340 (far strcpy 125F to SB:0000) |
| +0x0D | char[13] | SETUP | sound driver file name (Isound/Asound/Rsound/Nsound.117) | SETUP 0000:044B..046D |
| +0x1A | word | (F117.COM) -> START 7312, END 3BF4, DSWAP | sound driver segment (driver jump table linked by `func_0000_860E`) | 7325 |
| +0x1C | word | -> START, END | graphics driver segment | 7331 |
| +0x1E | word | -> START, END, DSWAP | misc.exe segment | 7319 |
| +0x22 | word | SETUP=1, START 0703 = 1/0 | security clearance OK. 0 -> only Libya (theatre 0) selectable and mission type forced to training (`|= 2`) | 5BF0:5C81, 623E:6324, 6D07:6D8D, 5A8A:5B37 |
| +0x24 | word | SETUP=0 -> START | argument to sound driver init (far 6AE4) (?) | 73F7 |
| +0x26 | word | START=3 before flight, SETUP=1 | mission end state: 1 crashed/killed, 2 ejected, 3 landed | main 0035, END 0010 |
| +0x28 | word | START=0 | death cause 1..6 (0 = alive), see end-map | main 003F, END 3682 |
| +0x2A | word | SETUP = [ds:0776] (=0) | unknown (?) | SETUP 04B0 |
| +0x2C | word | START=0 | count used by END bar-talk (>=3 -> "busy" quotes) (?) | main 0049, END 3AC1 |
| +0x2E | word | START 4239 | mission length/fuel figure = 12 x route length; printed "Est. Fuel required: %d lbs."; END score multiplier | 4F47, 20D6:2426, END 3617 |
| +0x30 | word | START main | training flag (pilot mission type 2/3) | 0058 |
| +0x32 | byte | SETUP | 3 if graphics driver name starts 'M'/'m', else 2 (initialised 0xFFFF) (?) | SETUP 04D2..04F1 |
| +0x33 | byte | START 4239 -> END 0EF3/372F | night(?) flag, 1 = night: always for special-equipment drop (obj 4), 90 % for Lockheed plane, 70 % otherwise | 5099..50E5 |
| +0x34 | word | (VGAME) -> END | flags; bits 0x08 and 0x04 both set + +0x36 >= 7 -> Purple Heart (wound) (?) | END 2566 |
| +0x36 | word | (VGAME) -> END | damage count (?) | END 255F |
| +0x38..+0x3E | 4 words | START | weapon index per bay 0..3 (0..18, 0x13 = empty) | 4F0F.., 0963:0A36 |
| +0x40..+0x46 | 4 words | START | quantity per bay = `byte ds:1EC6[weapon]` | 5065, 0A47 |
| +0x48 | 40 bytes | SETUP | joystick calibration (copied to DGROUP 6982 by 851A when +0x72 bit0) | SETUP 0306, START 7361 |
| +0x70 | word | SETUP = 0 | (?) | SETUP 01A6 |
| +0x72 | word | SETUP | bit0 joystick present, bit1 mouse present | SETUP 0218/0322, START 38BB/3A2C |
| +0x74/+0x76 | words | (VGAME) -> END | final x/y (world units, >>11 = 16x16 grid cell) used for rescue vs capture | END 00A1 |
| +0x7A.. | var | START 5625 -> VGAME/END 0113 | serialised mission world, see 4.3 | 562C |
| +0x1272 | 80 | START/END | current pilot record (PR) | 73C4, END 3CC6 |

---------------------------------------------------------------------------------------------------

## 2. Screen state machine

### 2.1 Generic menu machinery [H]

| function | role |
|---|---|
| `func_0000_3641(pic, drawcb)` | load PIC into page 1 (`35FC`), copy page 1 -> page 0 (far 6A8A blit 320x200), call `drawcb` once, fade in (3070) |
| `func_0000_35FC(pic, page)` = pic_load | `sprintf("%s.pic", ds:0CBA[pic])`, read file to buffer, decode into page `ds:CAB0[page]` (8782) |
| `func_0000_38AC(desc)` = menu_wait | loop: `desc->hover()` if non-null, `39F7` input; returns 1-based hotspot (Selector), 0x63 (Escape), or 0x100+key when key == desc->hotkey |
| `func_0000_39F7` | input: keyboard (far 6B7A/6B7F), joystick (+0x72 bit0, far 6B89 buttons, stick moves cursor (axis-0x80)/30), mouse (+0x72 bit1). Enter or button 0 -> 0x0D Selector; Esc or button 1 -> 0x1B; arrows 0x4800/4B00/4D00/5000 jump cursor to nearest hotspot; 0x1000 (Alt-Q) -> 7611 |
| `func_0000_393D(rects, n)` | hit-test cursor `[ds:E08A],[ds:E08C]` against n rects {x0,y0,x1,y1}; returns 1-based index or 0 |
| `func_0000_3CEA(dlg, x, y)` | modal requester (requestr.pic, page 2) with its own hotspot table at ds:B308; returns choice (1 = first button, 2 = second). Dialog structs: text at +0x16 (1 button) or +0x1E (2 buttons) |

Menu descriptor format (DGROUP): `+0 word hover_fn, +2 byte hotkey, +3 byte count, +4 count x {x0,y0,x1,y1}` (words).

| desc | screen | hover fn | hotkey | count |
|---|---|---|---|---|
| ds:6F42 | home (ready room) | - | - | 5 |
| ds:6F6E | orders (theatre/war/type) | `5E6F` | - | 0x11 (17) |
| ds:6D1E | briefing room / map | `11DB` | 0x20 space | 8 + map sites (byte ds:6D21 rewritten by 1F3F) |
| ds:6C5A | armament | `0B01` | - | 0x18 (24) |
| ds:704E | roster | `63FB` | 0x62 (-> 0x162 "Delete") | 0x0B (11) |
| ds:6FFA | pilot options panel | `71AD` | - | 0x0B (11) |
| ds:6BC6 | security quiz | `0786` | - | 0x12 (18) |
| ds:B308 | requester (copied from dialog struct +0xA) | - | - | - |

### 2.2 Top-level loop `func_0000_020F` [H]

Initial state = 4 (roster) if `0:04F2 != 0` or `PR+0x4E != 0` (dead/retired), else 0 (home menu).

| state | entered by | function | screen (pic) | returns |
|---|---|---|---|---|
| 0 | default / after any screen | `3641(5 homescrn, draw 008D)`; `38AC(ds:6F42)` (loops while 0x63) | home / ready room; 008D prints pilot, theatre, war, type and a difficulty rating from `02BA` | hotspot 1..5 |
| 1 | hotspot 1 | `func_0000_5BF0` orders | ordrscrn (6) + ordrsprt (10) on page 4 | 0 |
| 2 | hotspot 2 | `func_0000_0FA3` briefing room | brefscrn (2) + theatre map (16+theatre) | 0, or 3 (go to armament) |
| 3 | hotspot 3 / from 2 | `func_0000_0963` armament | armsscrn (1), weapons1-3 (13-15), requestr (11) | 0, or 5 (go launch) |
| 4 | hotspot 4 / initial | `func_0000_623E` roster | rostscrn (7) + rostsprt (12) | 0 |
| 5 | hotspot 5 / from 3 | `func_0000_038C` launch | hangscrn (4)+hangsprt(30) or climbin (32, carrier) | 1 -> leave loop (fly), 0 -> home |

### 2.3 Screen details

| screen | hotspot / key | action | evidence |
|---|---|---|---|
| **Orders 5BF0** | 1..9 | theatre = `ds:0DE2[hot]` (map: 1->7 Cuba, 2->2 N.Cape, 3->3 C.Europe, 4->0 Libya, 5->5 Mid East, 6->6 Desert Storm, 7->1 Persian Gulf, 8->4 Vietnam, 9->8 Korea). Every hotspot except 4 (Libya) requires SB+0x22 != 0, else requester ds:7338 "Your security clearance does not authorize ..." | 5C4B..5C9B, 5D44 |
| | 10..12 | war state PR+0x3A = hot-10 (0 Cold, 1 Limited, 2 Conventional) | 5DA7 |
| | 13..16 | mission type PR+0x3C = hot-13 (0 Air, 1 Strike, 2 Air Training, 3 Strike Training) | 5DC9 |
| | 17 | done: save roster (7272(0)), close-folder animation, return 0 | 5DF8 |
| | any change while a mission is scheduled (`[ds:D2A2]`) | requester ds:70AA "Changing pilot orders will cancel your scheduled mission." | 5C0F |
| **Briefing 0FA3** | entry | `0F4E`: load pics, `1308` | |
| | 1 / 2 / 3 | map mode `[ds:B2E8]` = 1 radar sites / 2 SAM sites / 3 hostile concentrations; redraw `141D` | 105F..10C4 |
| | 4 / 5 | set / clear "show range" bit 0x40 (site byte +9) for all listed map sites | 10C6, 111F |
| | 6 | written orders `20D6` | 116F |
| | 7 | return 3 -> armament | 1175 |
| | 8 | new mission: clear `[ds:D2A2]`, `1308` (regenerates) | 117D |
| | space (0x120) | toggle `[ds:B284]` (radar range max/avg in site info) | 118F |
| | >8 (map site) | toggle range bit of the 2 sites of that entry, `1C2F(hot-9)` site info box | 0FF7..105C |
| | Esc | return 0 | 1188 |
| **1308** mission orders | | if no mission scheduled: "Decoding mission orders." box, `40F0` (generate), then `1F3F` (build map-site list), draw map `141D`, set `[ds:D2A2]=1`, status line `1B37(0)` | 1308..1412 |
| **1B37(n)** status line | n=1..8, 0x64, 0x65, other | the "Press Selector to ..." hint for hotspot n; 0x65 "Hostile forces have concentrated...", 0x64 "No special activity...", default "Press Escape button to return to Ready Room." | 1B72..1BE8 |
| **1C2F(i)** site info | | "AIRBASE DATA" (LOC, STATUS Neutral/Friendly/Hostile from site byte+9 bits 0/2, FGTR TYPE from table ds:1708 (32-byte stride), SQDRNS = site+6) and/or "RADAR DATA" (Doppler/Pulse, RDR RNG max or avg = range x factor depending on `[ds:B284]`, MSL RNG from ds:1AB0, notes "under repair" (site+8 bit 0x40) / "off the air" (bit 0x20)) | 1CA5..1F34 |
| **Armament 0963** | 1..18 | load weapon hot-1 into selected bay, quantity `ds:1EC5[hot]`, redraw bay (`0D65`), update fuel (`0E96`), advance to next bay | 0A1C..0A6A |
| | 19..22 | select bay hot-19 (Lockheed plane: only bays 0,1 -> hotspots 19,20) | 0A6D..0AD2 |
| | 23 | done -> return 5 (launch) | 0AD5 |
| | 24 / Esc | return 0 | 0AEA |
| **Roster 623E** | 1..10 | select pilot slot: status (+0x4E) 1 -> requester ds:715F "This officer has retired..."; 2 -> ds:7244 "...deceased officers..."; else (requester ds:710D if mission scheduled) store PR back, load roster[slot] into PR, re-apply clearance rule, open options panel `6DB8` | 6284..635A |
| | Delete (0x162) | erase/create pilot in slot under cursor -> `6AB3(slot)` (name entry; redraws the line with 6861) | 637F..63CC |
| | 11 / Esc | if PR status != 0 stay; else save roster (7272(1)), return 0 | 63CF..63F3 |
| **Options 6DB8** | 1..4 | opponents PR+0x3E = hot-1 (Green/Regular/Veteran/Elite) | 6FDB |
| | 5..7 | landings PR+0x40 = hot-5 (No Crashes / Easy Landings / Realistic Landings) | 70AB |
| | 8..9 | plane PR+0x42 = hot-8 (0 "MicroProse F117A", 1 "Lockheed F117A"); Lockheed forces Air(0)/Air Training(2) to Strike(1)/Strike Training(3) | 70C6..70FD |
| **Launch 038C** | | no mission -> requester ds:7200 "You need to receive a mission briefing first."; else requester ds:73A8 "Are you ready for your mission?" / "Not yet". Yes -> land base: hangar animation `0448`; then return 1 | 03B2..042B |

Name tables used by the panels: ds:1D78 rank prefixes ("2nd Lt ", "1st Lt ", "Capt ", "Major ", "Lt Col ", "Col ", "B Gen "), ds:931E opponents ("Green/Regular/Veteran/Elite Opponents"), ds:94F0 landings ("No Crashes", "Easy Landings", "Realistic Landings"), ds:94AC plane ("MicroProse F117A", "Lockheed F117A"), ds:0D6A theatre file prefixes (lb pg nc ce vn me ku cu ko).

### 2.4 Difficulty rating `func_0000_02BA` (shown by 008D) [H]

`rating = (T60[theatre] + T54[type] + T58[opponents] + T5C[landings]) / 3 - plane + 2`, capped at 10 (0x0A).

| table | index | values |
|---|---|---|
| ds:0060 | theatre 0..8 | 0,2,5,6,3,3,4,2,5 |
| ds:0054 | mission type 0..3 | 5,7,0,0 |
| ds:0058 | opponents 0..3 | 0,3,5,8 |
| ds:005C | landings 0..2 | 0,3,6 |

---------------------------------------------------------------------------------------------------

## 3. ROSTER.FIL and the pilot record

File (802 = 2 + 10 x 80 bytes). Load `func_0000_7218` (fread 2 bytes -> ds:B39C, then 10 x 0x50 -> ds:D892), save `func_0000_7272` (same order, fwrite). The task's "4-byte header 03 00 00 00" is really a **2-byte header (selected slot = 3) followed by record 0 whose first word is its slot index 0** [verified against the file].

Save errors (7272): `func_0000_804E()==0` -> requester ds:729D "Original disk in drive. Roster file will not be saved." (804E is a disk check, probably volume label "F117A-SF" (?)); fopen fail -> ds:72EA "Disk is write protected...".

### Pilot record (80 = 0x50 bytes; also at SB+0x1272)

| off | type | field | evidence |
|---|---|---|---|
| +0x00 | word | slot index 0..9 | 623E:631D (`PR+0 = slot`), 6D6E |
| +0x02 | char[30] | name | 64E5:6504 (`rec+2`), file |
| +0x20 | word | rank 0..6 (ds:1D78) | 64E5:6512, END 2AFA |
| +0x22 | word | Purple Hearts | "PH:%d" 67DB, END 2578 |
| +0x24 | word | Airman's Medals | "AM:%d" 677B |
| +0x26 | word | Distinguished Flying Crosses | "DFC:%d" 665B |
| +0x28 | word | Silver Stars | "SS:%d" 671B |
| +0x2A | word | Air Force Crosses | "AFC:%d" 66BB |
| +0x2C | word | Congressional Medal of Honor | "CMH:%d" 65FC |
| +0x2E | word | best mission score | "Best Mission: %d" 654C, END 0443 |
| +0x30 | word | last mission score (0 after training) | "Last Mission: %d" 6576, END 043B |
| +0x32 | dword | total score | END 0456 |
| +0x36 | word | missions flown (date = theatre start date + this, 25D9); 99 -> retired | END 0021, 006C |
| +0x38 | word | theatre 0..8 (Libya, Persian Gulf, North Cape, Central Europe, Vietnam, Middle East, Desert Storm, Cuba, Korea) | 5D80 |
| +0x3A | word | war state 0 Cold / 1 Limited / 2 Conventional | 5DC2 |
| +0x3C | word | mission type 0 Air / 1 Strike / 2 Air Training / 3 Strike Training (bit0 = strike, bit1 = training) | 5DEA, 20D6:2146 |
| +0x3E | word | opponents 0..3 | 6FEB |
| +0x40 | word | landings 0..2 | 70BF |
| +0x42 | word | plane 0 MicroProse / 1 Lockheed | 70DA |
| +0x44 | word | Combat Readiness Ribbon awarded | END 249F |
| +0x46 | word | OverSeas Short Tour Ribbon | END 24D1 |
| +0x48 | word | OverSeas Long Tour Ribbon | END 24F8 |
| +0x4A | word | Longevity Service Ribbon | END 251C |
| +0x4C | word | Longevity ... with Gold Cluster | END 2543 |
| +0x4E | word | status 0 active / 1 retired / 2 killed | 623E:628C, END 0073/008F |

Roster screen detail `func_0000_64E5(slot)`: rank+name, Best/Last mission, then text `ds:931E[+0x3E]`, `ds:94F0[+0x40]`, `ds:94AC[+0x42]`; medal ribbons are blitted from page 4 (rostsprt) at source x 0x98 CMH, 0xA0 DFC, 0xA8 AFC, 0xB0 SS, 0xB8 AM, 0xC0 PH (y 0, 8x0x22 px) only when count != 0, each followed by "XX:%d".

Quirk: 6D07:6D1C does `and word [ds:D8D4],1` (roster[0].plane) inside the slot loop, and bumps type 0/2 -> 1/3 for every record with plane != 0.

---------------------------------------------------------------------------------------------------

## 4. Mission generation

### 4.1 World data (from `<theatre>.wld`, loaded by `func_0000_54BB`, via `func_0000_5466` = load .wld/.3dG/.3dT for prefix ds:0D6A[theatre])

| DGROUP | size | meaning |
|---|---|---|
| ds:D88C | word | (?) |
| ds:D33C | word | site count |
| ds:CACE | word | count of sites with fighter assignment (loop bound in 4239:4E8D) |
| ds:E084 | word | sites with index < E084 are airfields/bases (random base = random(E084-3)+3) |
| ds:CBDE | 16 x D33C | site records: +0 name index (ds:DC70 string table), +2 x, +4 y, +6 fighter type / squadrons (0 = none), +8 flags word (bit 0x01 hostile side?, 0x08 alert-able, 0x20 off-air, 0x40 show range / under repair, 0x80 actually under repair; +9 bit0 0x100 neutral?, bit1 0x200 carrier, bit2 0x400 friendly), +0xE type (low 7 bits) |
| ds:D890 | word | flight-group count |
| ds:D3BE | 36 x D890 | flight groups (patrols, transports) |
| ds:D7F6 | 128 | site type -> weapon class (low nibble), used for suggested bomb (5282) |
| ds:D33E | 128 | (?) |
| ds:DD70 | 750 | text pool (site names) |
| ds:CAD8 | 16x16 bytes | map grid: bits 0-1 territory (0 = enemy), bit 4 hostile concentration |

Site byte +9 bit 2 (0x400) -> "STATUS: Friendly", bit 0 (0x100) -> "Neutral" (1C2F:1CF2..1D08). (?) for the remaining bits.

### 4.2 `func_0000_40F0` (setup) and `func_0000_4239` = generate_mission (3077 bytes) [M]

40F0: `[ds:CABE]` = opponents, `[ds:B38E]` = theatre, `[ds:B38C]` = war; load theatre world; call 4239; copy suggested loadout bytes SB+0x38..0x3E to ds:CAD2..CAD5; `[ds:D33A]` = any hostile-concentration cell; then picks **3 random bases** (not takeoff/landing, with fighters, not flag 0x400/0x100) and marks them `+8 |= 0x40` ("believed under repair"); each has 1/3 chance (random(3)==0) of `+8 |= 0x80` and fighters cleared (really under repair).

Objective records: two 18-byte blocks, primary at ds:E05E, secondary at ds:E070:

| off | field |
|---|---|
| +0 | objective type (template +4): 1 photograph, 2 destroy, 3 supply drop at beacon, 4 land at secret airstrip (special equipment), 5 intercept at ONC (fighter patrol / aircraft), 6 AN-72 leaving base (destination unknown), 7 AN-72 base-to-base, 8 Tu-95 at ONC |
| +2 | target site index (`[ds:E060]` / `[ds:E072]`) |
| +4 | base (`[ds:E062]` takeoff for primary, `[ds:E074]` landing for secondary) |
| +6 | flags (template +8, high byte from template +0xA when > 0); 0x02 time limit, 0x08 exclusive, 0x10 snap target to 0x400 grid, 0x20 "while cargo is unloaded" |
| +8 | template index 0..81 |
| +0xA | ONC grid reference string (built by 58BE/58DF from theatre code table "TD00","JZ00","WX00","CC00","XV00","ES00",...) |

Mission templates: 82 (0x52) x 12 bytes at ds:11DA: `+0 theatre mask (bit per theatre), +2 war mask (bit per war state), +4 objective type, +6 site category (compared with byte ds:D2A6[site type]), +8 flags, +0xA signed: >0 = extra flag byte, <0 = -aircraft type for air objectives -> [ds:D3D4]`. Briefing paragraph per template: pointer table ds:1F24.

Algorithm (with retry loop: any failed check jumps back to 0000:4256; `[bp-2]` counts tries):

| step | addr | rule |
|---|---|---|
| 1 | 4256..42A6 | every 50 (0x32) tries re-pick a random target category from the 128-byte table ds:D2A6 (non-zero entries, never 0x15) |
| 2 | 42A8..4331 | Air mission (type bit0 = 0): primary site = random base with `flags & 0xD01 == 1` (hostile airfield). Strike: `51E8(1, category)` picks a site of that category; must be hostile (`flags & 0x801 == 1`) or its type byte must equal the category |
| 3 | 4343..4415 | secondary target = nearest (512E) site to a random point within +-0x1900 (6400) of the primary, clamped to 0x840..0x77BF, in enemy territory (grid bits 0-1 == 0); for strike, secondary must not be a hostile airfield; up to 100 (0x64) tries; must differ from primary and be within distance 0x6400 (`532A & 0xFFC0`) |
| 4 | 445E..458C | for each objective pick the nearest friendly base/carrier (sites >= E084 with flags hi&5 and &0x201) with random +-0x500 jitter (carriers 0x200 get +0xC80 bias) -> E062 (takeoff), E074 (landing) |
| 5 | 45B3..461C | Libya training: fixed sites (air: 0x16/8, strike: 3/0xF, bases 0x22 and 0x23/0x21) |
| 6 | 461F..4659 | route length = (d(primary,secondary) + d(takeoff,primary) + d(secondary,landing)) / 64 must lie in [lower, 0x384 (900) + tries]; lower starts at 0x1C2 (450) and changes by (opponents - 5) per retry |
| 7 | 465C..4776 | for each objective collect templates whose theatre and war bits match and whose category == ds:D2A6[target type]; pick one at random; copy type/flags/aircraft |
| 8 | 4778..47BC | training in Libya: template 5 (air) or 0x37 (55) (strike) forced |
| 9 | 47BF..486C | reject if: strike and either objective type >= 5; any objective type 0; same template twice; secondary type 5..8 (air); primary type 4 with Green opponents; both have flag 0x08. If secondary is farther than primary (and not training) the two blocks are swapped |
| 10 | 487D..4A81 | deadlines `[ds:D876]`: flag 0x02 -> d(takeoff, target)/16 + 450; type 5: nearest hostile airfield to takeoff becomes the patrol's home, ONC string at ds:0D8E; types 6/7: nearest base (hi&5, not 0xA) becomes departure/arrival of the transport flight group, time = distance / speed of flight group; type 8 (Tu-95): flight group at primary, aircraft type 2 changed to 0xC in Persian Gulf |
| 11 | 4AC9..4B6A | the two objective ONC strings ds:E068/ds:E07A; nearest site with a name gets its name copied to unnamed targets |
| 12 | 4B6C..4C3D | waypoints (4 x {x,y} at ds:15B2): WP0 = midpoint takeoff-primary, WP1 = primary, WP2 = secondary, WP3 = landing base; start position long x/y at ds:D29A/ds:D326 (carrier: y - 0x708) |
| 13 | 4C3D..4E0A | flight groups (ds:D3BE, D890-4 of them): flag 0x80 groups get a random hostile home base within range; patrol radius 4-opponents scaled; random squadrons 1..theatre+1 |
| 14 | 4E0D..4EC3 | **enemy fighter quality** per site with fighters: `r = random(5) + (war != 0) + opponents`; r in {0,1,3} -> downgrade via table ds:1EE6, r in {5,7,8} -> upgrade via ds:1EE4, else unchanged. Sites with flag 0x08 lose their fighters if `random(10) >= war + opponents + 2` (i.e. fewer scrambles in Cold war / Green) |
| 15 | 4EC6..4F0D | hostile-concentration cells (grid bit 4) kept with probability depending on opponents: cleared when `random(5) >= opponents` |
| 16 | 4F0F..5089 | **suggested armament** -> SB+0x38..0x3E: default {1 AIM-120, 2 HARM, 5 Maverick or 9 Mk82 (50 %), 0 AIM-9}; route x 12 > 10000 (0x2710) -> bay 2 = 0x11 fuel tank; per objective: type 1 -> bay k = 0x10 camera, types 3/4 -> 0x12 special equipment, type 2 -> best bomb for the target's weapon class (`5282(ds:D7F6[type] & 0xF)`). Libya training overrides. SB+0x2E = route x 12. Quantities from ds:1EC6 |
| 17 | 508B..5128 | times: start = ((tmplA.flags_hi + tmplB.flags_hi) & 0xF) << 8 (?) -> "00:00" at ds:0D88 (59FE formats); depart ds:0D7C = start + D876; land ds:0D82 = depart + 450; D876 reduced to a multiple of 150 (0x96). SB+0x33 night flag (see 1.3) |

Weapon index table (armament + SB bays): 0 AIM-9M, 1 AIM-120A, 2 AGM-88A HARM, 3 Penguin-3, 4 AGM-84A Harpoon, 5 AGM-65 Maverick, 6 GBU-12, 7 Mk 20 Rockeye, 8 Durandal, 9 Mk 82 Slick, 10 Mk 82 Snakeye, 11 Rockeye II, 12 Mk 122 Fireye, 13 CBU-72 FAE, 14 Mk 35 IN cluster, 15 ISCB-1, 16 135mm camera, 17 1900 lbs fuel, 18 special equipment, 0x13 empty. Quantities ds:1EC6: 4,3,1,2,1,2,2,2,2,3,3,2,2,2,2,1,1,1,1.

### 4.3 Hand-off to VGAME: `func_0000_5625` [H]

Appends to far ptr SB+0x7A (`[ds:B390]`) with `func_0000_588D(src, size, count)` (= far memcpy 95F4): D88C(2), D33C(2), CACE(2), E084(2), sites CBDE (D33C x16), D890(2), flight groups D3BE (D890 x 36), D7F6(128), D33E(128), DD70(0x2EE=750), grid CAD8(256), D876(2), CABC(2), waypoints 15B2(16), objectives E05E(2 x 18). Same order as the .wld reader 54BB and END's reader (END 0113). `func_0000_585C` is the reverse (no callers).

---------------------------------------------------------------------------------------------------

## 5. Briefing text, armament, map, quiz

### 5.1 Written orders `func_0000_20D6` [M]

| part | source |
|---|---|
| header | "416th Tactical Fighter Squadron"; title by PR+0x3C: 0 "Air Combat Mission Orders", 1 "Ground Strike Mission Orders", 2 "Air Training Orders", 3 "Ground Strike Training Orders" (2142..2167, 2300..2315) |
| pilot/date | "Pilot: %s%s." (rank ds:1D78 + name); date `25D9`: per-theatre start month ds:0882, day ds:088C, year ds:0896 plus PR+0x36 missions -> "%s %d, %d" (month name table ds:08A8, month lengths ds:08C2) |
| page 1 | `24F7(blk,0)` "PRIMARY TARGET INTELLIGENCE SUMMARY:" + template paragraph ds:1F24[tmpl] + "OBJECTIVE:" + `2651`; same for secondary |
| page 2 | "FLIGHT PLAN:" "Depart from %s at %s hours." (takeoff name, ds:0D88), INS note (string ds:A361 via 3776), "Land at %s." |
| ROE | "RULES OF ENGAGEMENT:" text ds:9781[war] (clandestine / limited / full war paragraphs) |
| armament | "SUGGESTED ARMAMENT:" lines ds:A409[weapon] for bytes ds:CAD2..CAD5 (only 2 bays for Lockheed, 23E1), "Est. Fuel required: %d lbs." = SB+0x2E |

`func_0000_2651(blk, out)` objective sentence, switch on template objective type (jump table 0000:284E): 1 "Photograph the %s at %s" / 2 "Destroy ..." (+ " before %s hours" if flag 0x02, " ... while the cargo is still being unloaded." if 0x20); 3 beacon drop; 4 secret airstrip; 5 "Intercept and destroy the %s%s at ONC %s." (aircraft name ds:1708 + 32 x [ds:D3D4], suffix " fighter patrol" when template +0xA == -2); 6/7 AN-72 texts; 8 Tu-95 text.

`func_0000_149C(anim)` animates the flight plan on the map: lines takeoff->primary->secondary->landing with captions "Depart from %s at %s hours.", objective sentences (2651), "Land at %s." (2B1B boxes, 31FA lines). Called from `141D` (map redraw) at 0000:144B.

### 5.2 Map `func_0000_141D` / `1F3F` / `1C2F` / `1B37` [M]

`1F3F` builds the map-site list at ds:B286 (pairs of site indices, count `[ds:B2E6]`, copied into the briefing hotspot count byte ds:6D21) from sites with fighters/radars matching the current mode. `141D` -> `183A` (brefscrn + overlay, 2E50), `196A`, `1AB6` draw radars/SAM rings, hostile concentrations (grid bit 4), waypoints. Hover (`11DB`) shows `1B37(hot)` hints and the site info box `1C2F` for map sites.

### 5.3 Armament rules [H]

| rule | evidence |
|---|---|
| Bays: MicroProse plane 4 bays, Lockheed 2 bays ((2 - plane) x 2); Lockheed bays 2,3 forced empty (0x13) and not selectable | 07EE:0809..0838, 0963:0A77 |
| Without a scheduled mission all bays are cleared to 0x13 and fuel shows 0 | 07EE:0822, 08EF |
| A bay holding Special Equipment (0x12) cannot be changed: requester box "The Special Equipment container is needed for this sortie!" | 0963:09C4..0A16 |
| Weapon hotspots 1..18 only (special equipment is never selectable) | 0999 |
| Unavailable weapons: `[ds:D878 + w] != 0` -> hotspot drawn disabled (39B3) | 07EE:0858..0882 |
| 0E23: clears 20 flags at ds:D878, then marks random(5) (0..4) random weapon types (random(16)) unavailable, skipping ones whose partner `ds:01C4[w]` (0xFF = none) is already unavailable (?); finally D878/D879 (AIM-9, AIM-120) = plane, i.e. Lockheed has no air-to-air missiles | 0E23 |
| Fuel display (`0E96`): 10000 (0x2710) lbs internal if a mission is scheduled + 1900 (0x76C) per fuel tank (weapon 0x11); needed fuel = SB+0x2E shown by 07EE "%d lbs." | 0EBD..0EEC, 0900 |
| No weight limit code found | - |

### 5.4 Security clearance quiz `func_0000_0703` / draw `057E` [H]

| step | addr |
|---|---|
| SB+0x22 = 0; `3641(0 air_id, draw 057E)` | 0709..071A |
| 057E: `[ds:B282]` = random(20) = correct aircraft; planes PIC `0x19 + (B282>>2)` (planes1..5, 4 silhouettes per sheet, position from B282 & 3) into page 4 and blitted; two other random distinct decoys removed; 18 names listed from table ds:936A (20 entries: F-14D Tomcat ... Il-76 Mainstay); `ds:B270[i]` = aircraft id of answer i | 0632..06E3 |
| `38AC(ds:6BC6)` (18 hotspots, Esc ignored); answer `ds:B26F[hot] == [ds:B282]` -> SB+0x22 = 1, "Correct. Security clearance confirmed."; else SB+0x22 = 0, "Incorrect. Your security clearance level is now reduced." | 071F..0755 |
| Effect of 0: orders screen only allows Libya; pilot forced to theatre 0 + training | see 1.3 |

In this build 0703 is unreachable (see main step 2) and the byte at 0000:057C is `ret` with the real draw routine at 057E (?). SETUP initialises SB+0x22 = 1, so clearance is always granted.

---------------------------------------------------------------------------------------------------

## 6. PIC files / sprite sheets

PIC name table ds:0CBA (index -> name): 0 air_id, 1 armsscrn, 2 brefscrn, 3 folder1, 4 hangscrn, 5 homescrn, 6 ordrscrn, 7 rostscrn, 8 breficon, 9 folder2, 10 ordrsprt, 11 requestr, 12 rostsprt, 13 weapons1, 14 weapons2, 15 weapons3, 16..24 theatre maps (libya persian n_cape c_europe vietnam mid_east kuwait cuba korea), 25..29 planes1..5, 30 hangsprt, 31 adv, 32 climbin. Pages: `ds:CAB0[page]` segments of 5 320x200 pages (73CE:7417..747D); page 0 = screen, 1 = back buffer.

| sheet | loaded into | used by | frame coordinates |
|---|---|---|---|
| rostsprt (12) | page 4 | roster (615C) | medal ribbons x = 0x98..0xC0 step 8, y 0, 8x34 (64E5); options-panel sprite x/y tables ds:0EA8 (opp), ds:0EAD (land), ds:0EB0 (plane) / ds:0EB2.. (6E47..6EA1) |
| ordrsprt (10) | page 4 | orders (5A8A) | marker positions: war state x ds:0DEC / y ds:0DFA, mission type x ds:0DF2 / y ds:0E00 (words, e.g. x 217,310,310 / y 144,135,144); theatre highlight colours ds:0DD8 |
| requestr (11) | page 2 | requester 3CEA, special-equipment box | dialog struct +0xA holds the button hotspot table |
| weapons1/2/3 (13-15) | pages 3, 4, 2 | armament (07EE) | weapon icons blitted per bay in 0D65 (coordinates computed, not a table) (?) |
| breficon (8) | page 3 | briefing map icons (0F4E) | - (?) |
| hangsprt (30) | page 3 | hangar animation (0448, loaded by 0311 callback) | per-frame table ds:0136 (18 entries, 0xFF = skip) (?) |
| planes1..5 (25-29) | page 4 | quiz (057E) | 4 aircraft per sheet, 2x2 grid of 0x92x0x4F (?) |

No generic frame-rectangle table was found; blits use immediate coordinates or the small x/y tables above (?).

---------------------------------------------------------------------------------------------------

## 7. Function table (segment 0000, C code)

| addr | alias | role | conf |
|---|---|---|---|
| 0010 | main | startup, state machine, world hand-off, exit 0x0C/0x0D | H |
| 008D | home_draw | home screen info panel (pilot, theatre, war, type, rating) | M |
| 020F | frontend_loop | state machine (2.2) | H |
| 02BA | difficulty_rating | 0..10 rating | H |
| 0311 | hangar_cb | (mis-split code) load hangsprt into page 3 | M |
| 038C | launch_screen | "ready?" + hangar/climb-in | H |
| 0448 | hangar_anim | hangar door/plane animation | L |
| 057E | quiz_draw | aircraft silhouettes + 18 names | H |
| 0703 | security_quiz | sets SB+0x22 (unreferenced in this build) | H |
| 0786 | quiz_hover | highlight answer under cursor | M |
| 07EE | arms_init | bays init, load weapon sheets, fuel text | H |
| 0963 | armament_screen | armament state | H |
| 0B01 / 0BD4 | arms_hover / weapon_info | weapon description box (string table ds:A587 via 3776) | M |
| 0D65 | draw_bay | draw weapon in bay | L |
| 0E23 | roll_shortages | unavailable weapons | M |
| 0E96 | fuel_text | fuel carried | H |
| 0F4E | brief_enter | load brefscrn, theatre map, 1308 | H |
| 0FA3 | briefing_room | map/briefing state | H |
| 11DB | brief_hover | hints + site info | M |
| 1308 | mission_orders | generate if needed, draw map, schedule | H |
| 141D, 183A, 196A, 1AB6, 2E50 | map_draw* | map layers | L |
| 149C | flightplan_anim | animated route with captions | M |
| 1B37 | status_hint | "Press Selector ..." line | H |
| 1C2F | site_info | AIRBASE/RADAR DATA box | M |
| 1F3F | build_map_sites | map hotspot list | M |
| 20D6 | written_orders | 2-page orders | M |
| 24F7 | target_summary | intel summary + objective | M |
| 25D9 | mission_date | date string | H |
| 2651 | objective_text | objective sentence | H |
| 2864 / 289A | load_file / load_palette | read file into buffer / palette | L |
| 2901 | anim_step | folder/marker animation step | L |
| 2A84 | text_centered | | L |
| 2B06 | delay | | L |
| 2B1B | message_box | text box with border | M |
| 3070 / 3088 / 30A0 | fade_in / fade_out / fade | | L |
| 31FA | draw_route_line | | L |
| 332E / 2AB4 | requester_draw / restore | | M |
| 3517 | set_colour_triplet | patch 3-byte palette entry (highlight) | L |
| 3567 | draw_text | | M |
| 3588 | wait_selector | | M |
| 35FC | pic_load | | H |
| 3641 | screen_enter | | H |
| 3693 | blit_sprite | | L |
| 373C | text_width | | L |
| 3776 | draw_wrapped_text | | M |
| 38AC | menu_wait | | H |
| 393D | hit_test | | H |
| 3989 | restore_cursor_bg | | L |
| 39B3 / 39D5 | hotspot_disable / enable | | L |
| 39F7 | read_input | | H |
| 3CEA | requester | | H |
| 3E84 | set_cursor | | L |
| 3EA5 / 3F33 | page_turn / wait | | L |
| 405F | wait_ticks | | L |
| 40A4 / 40CF | alloc_buffer / free_buffer | "Insufficient system memory" / "Buffer dealloc error" | H |
| 40F0 | mission_setup | | H |
| 4239 | generate_mission | | M |
| 512E | nearest_site(x,y,kind) | | L |
| 51E8 | random_site_of_category | | L |
| 5282 | best_weapon_for_class | | L |
| 532A | site_distance | | H |
| 5356 | assign_flight_group | | L |
| 5413 | distance(dx,dy) | | L |
| 5466 | load_theatre_files | .wld/.3dG/.3dT | H |
| 54BB | read_wld | | H |
| 5625 | write_world_to_shared | | H |
| 5743 | atan2 | 16-bit angle | M |
| 585C / 588D | shared_read / shared_write | | H |
| 58BE / 58DF | onc_string | ONC grid reference | M |
| 59D8 | clamp | | L |
| 59FE | format_time | "00:00" | L |
| 5A8A | orders_draw | | M |
| 5BF0 | orders_screen | | H |
| 5E6F / 5FFA / 6045 | orders_hover / ... / theatre_text | | L |
| 60DC | theatre_description | | M |
| 615C | roster_draw | | M |
| 623E | roster_screen | | H |
| 63FB | roster_hover | shows 64E5 | M |
| 64E5 | pilot_details | | H |
| 6861 | roster_line | | L |
| 6A7C | name_ptr | | L |
| 6AB3 | new_pilot | name entry | L |
| 6D07 | roster_sync | | H |
| 6DB8 | pilot_options | | H |
| 7218 / 7272 | roster_load / roster_save | | H |
| 7312 | init | | H |
| 7387 | init_shared_ptrs | | H |
| 73CE | init_video_sound_pages | | H |
| 74B1 | init_requester | load requestr into page 2 | M |
| 7611 | quit_screen | adv.pic, 'Y' -> exit(0) | H |
| 76C0 | random(n) | `rand() % n` | H |
| 76D1 | shutdown(code) | | H |
| 7744, 7904, 7C05, 7C56, 7D71, 7E88 | world/3d file readers | .3dG/.3dT/.wld parsing (?) | L |
| 804E | disk_check | "Original disk in drive" (?) | L |
| 851A / 8545 / 8573 | joystick_cal_load / mouse_poll / mouse_init | | M |
| 860E | link_driver | patch far-jump stubs at DGROUP 69B8 from driver header (+0x18, +0x1C first slot, +0x22 count, +0x24 offsets) | H |
| 8782 | pic_decode | | L |
| 8A32 | fill_rect | | L |
| >= 8EDC | C runtime | | - |
