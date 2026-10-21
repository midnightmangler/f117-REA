# END.EXE structural map

Debrief, scoring, medals/ribbons, promotion, death/capture/rescue scenes, bar talk, pilot record update.
Small-model MS C 6.0, code segment 0000 (C code 0000:0010..~0000:3F44, runtime above). DGROUP = 05FA
(linear 05FA0, file offset = ds_off + 0x61F0). Shared block (SB) and pilot record (PR) layouts: see
`start-map.md` 1.3 and 3. Listing: `re/disasm/END.asm`.

Note: `END.data.txt` lists many false string xrefs (e.g. "c_europe.pic", "vietnam.pic", "brefscrn.pic") - those are small constants (0x63, 0x70, 0xB4) that happen to equal string offsets.

---------------------------------------------------------------------------------------------------

## 1. Startup and program flow

### 1.1 Init `func_0000_3BF4` [H]

| step | addr | what |
|---|---|---|
| 1 | 3CA1 | `[ds:7222]` far = SB (`seg(0:04F0):0000`), `[ds:55DE]` far = PR (`SB:1272`) |
| 2 | 3BFB..3C17 | link misc (+0x1E), sound (+0x1A), graphics (+0x1C) drivers (`45AD`, same as START 860E) |
| 3 | 3C1B | alloc 0x88B8 byte buffer -> `[ds:7220]` |
| 4 | 3C3B..3C5B | joystick calibration from SB+0x48 (448E) if +0x72 bit0; mouse init (44E7) if bit1 |
| 5 | 3C61 | `func_0000_00C9` -> `0113` = read mission world + results from SB+0x7A (see 1.3) and index the text pool |
| 6 | 3C64..3C92 | `[ds:7228]` = rank prefix (ds:1B8A[PR+0x20], "2nd Lt. " ... "Brig. Gen. ") + PR name |
| 7 | 3C98..3C9E | 3CD0, 3D4F (load requestr.pic, set up text colours/fonts via graphics driver), 4B8C |

### 1.2 main = `func_0000_0010` [H]

| step | addr | what |
|---|---|---|
| 1 | 0013 | init 3BF4 |
| 2 | 0016..0025 | if not training (SB+0x30 == 0): PR+0x36 (missions) += 1 |
| 3 | 0029 | `[ds:6440]` = 3 (rescued/landed default) |
| 4 | 002E..005A | switch SB+0x26: 1 -> `370A` cemetery scene; 2 -> `00A1` rescue test: != 0 -> `3B9A` rescue scene, == 0 -> `3BBF` TASS (captured) scene; 3 -> `3887` landing scene |
| 5 | 005C | `2BEC` mission summary text (flag.pic) |
| 6 | 005F | `03D9` debrief map / event log replay + score recording |
| 7 | 0062 | `2265` awards ceremony (ribbons, medals, promotion) |
| 8 | 0065 | `39D0` bar talk |
| 9 | 0068..0073 | PR+0x36 == 99 (0x63) -> PR+0x4E = 1 (retired) |
| 10 | 0079..008F | SB+0x26 == 1 and not training -> PR+0x4E = 2 (killed) |
| 11 | 0095 | `exit(0x23)` via `func_0000_3F44` (always) |

Quit: the shared input handlers (`1CF5`, `2092`) call `func_0000_3E61` (adv.pic quit screen); 'Y' -> `exit(0)` (3EFA..3EFD), else restore.
PR is in the shared block, so END never writes ROSTER.FIL itself; START copies PR back into the roster and saves (start-map 1.2).

### 1.3 Results read from the shared block (`func_0000_0113`, far ptr `[ds:543C]` = SB+0x7A) [H]

Same order as START `5625`, then two extra blocks written by the simulator:

| DGROUP | size | content |
|---|---|---|
| 6983, 6446 (site count), 55E4, 7210 | 2 each | header words |
| 56EA | 16 x [6446] | sites |
| 6D8A, 64CA | 2, 36 x n | flight groups |
| 6902, 6448 | 128, 128 | type tables |
| 6EFA | 750 | text pool (00C9 builds pointer table ds:6DFA) |
| 55EA | 256 | 16x16 grid (bits 0-1 territory) |
| 543A, 5438 | 2, 2 | deadline, (?) |
| 5DA4 | 16 | waypoints |
| 71E8 | 2 x 18 | objective blocks (primary, secondary) |
| 5E38 | 256 x 6 | **event log** (mission events) |

Event log entry (6 bytes, base ds:5E38): `+0 word time (?), +2 byte x (high nibble = grid column), +3 byte y (high nibble = grid row), +4 byte type (bits 0-5) | 0x80 primary objective | 0x40 secondary objective, +5 byte object id (low 7 bits = site/aircraft index, 0x80 = (?))`. The log ends at the first entry with byte +4 == 0.

| type | debrief text (`0A98`, jump table 0000:0D12) | scoring (`3021`, jump table 0000:34D2) |
|---|---|---|
| 1 | "%s at %s destroyed" / "%s destroyed" / "%s damaged" (id 0xD) | ground kill (316D) |
| 2 | "PRIMARY/SECONDARY OBJECTIVE destroyed" / "%s destroyed" / "%s damaged" | target destroyed (33AA) |
| 3 | "%s %s shot down" | aircraft kill (3258) |
| 4 | "%s released" (weapon) | - |
| 5 | "Hit by %s missile" | - |
| 6 | "%s %s Visual ID" | penalty DE6 |
| 7 | "%s %s Track" / "%s Radar Track" | penalty DF2 |
| 8 | "Takeoff point: %s" / "Mission end: " + Crashed / Good Bailout / Captured / Bailed & Died / Good Landing | marks end (3059) |
| 9 | (no text) | time-over-enemy tick (3100) |
| 10 | "%s at %s photographed" / "%s photographed" | photo objective (3078) |
| 11 | "Cargo delivered" (+ ", PRIMARY/SECONDARY OBJECTIVE achieved") | cargo objective (30C4) |
| 12 | as 1 | as 1 |

"Mission end" wording (0CA5..0D01): SB+0x26 1 "Crashed"; 2 -> SB+0x28 == 0 and rescued "Good Bailout", SB+0x28 == 0 and not rescued "Captured", else "Bailed & Died"; 3 "Good Landing".

---------------------------------------------------------------------------------------------------

## 2. Scoring = `func_0000_3021(maxEvents)` (called with 0x100) [H]

Walks the event log, accumulating a 32-bit score; sets `[ds:6D89]` primary done, `[ds:720E]` secondary done, counters `[ds:64C8]` air kills, `[ds:55DC]` air kills (other class), `[ds:6984]` objective ground kills, `[ds:6D88]` other ground kills, `[ds:5B9A]` civilian, `[ds:55DB]` friendly aircraft, `[ds:55E8]` friendly installations. All point tables are indexed by war state W = PR+0x3A (0 Cold, 1 Limited, 2 Conventional), 3 words each:

Per event: `id` = byte +5, `cat` = `ds:6902[site(id).type]` (bit 0x40 friendly, 0x80 civilian, low nibble value class), `F` = site flags word (+8).

| table | Cold | Limited | Conv | used for | evidence |
|---|---|---|---|---|---|
| ds:0DEC | 140 | 120 | 100 | primary objective (any type, event byte+4 bit 0x80) | 3087, 3190, 3282, 33B9 |
| ds:0DFE | 70 | 35 | 0 | secondary objective (bit 0x40); indexed by "primary already done" (0 -> 70, 1 -> 35), so the bonus is halved once the primary is done; if the primary completes after the secondary, +(35-70) is added | 30AB, 30E5, 31EB, 32C8 |
| ds:0DE6 | -20 | -12 | 0 | visual ID (type 6); the same value is subtracted again (refund) when an aircraft with id bit 0x80 is shot down (?) | 34B2, 325E |
| ds:0DF2 | -10 | -6 | 0 | radar track (type 7); refunded when a site with F & 0x1000 is destroyed (?) | 34A2, 317B |
| ds:0DC8 | -15 | -15 | -15 | aircraft of the player's side shot down (`ds:17B6[(id&0x7F)*32] == -1`), counter 55DB | 32F4 |
| ds:0DCE | -25 | -25 | -25 | friendly/neutral installation (cat & 0x40, F hi & 5, or event in non-enemy grid cell), counter 55E8 | 340B |
| ds:0DBC | -10 | -4 | 1 | civilian target (cat & 0x80), counter 5B9A | 3451 |
| ds:0DB6 | 0 | 6 | 12 | enemy aircraft whose home site has F & 0x04 | 3366 |
| ds:0DC2 | 0 | 3 | 6 | other enemy aircraft | 3376 |
| ds:0E02 | 0 | 1 | 3 | enemy aircraft with home site 0 | 333D |
| ds:0DDA | -2 | 0 | 0 | Cold war: aircraft without id bit 0x80 (not authorised), counter 55DC | 3392 |
| ds:0DF8 | 0 | 5 | 11 | type-1 military site, Limited/Conventional (Cold only if F & 0x1000) | 322A |
| ds:0DE0 | -5 | -2 | 0 | type-1 military site in Cold war otherwise; counter 6D88 only when the value is 0 | 3237 |
| ds:0E08 | 16 words per W | | | type-2 target value by `cat & 0xF`: Cold all 0; Limited 2,6,1,1,3,8,2,2,5,3,1,9,4,0,0,0; Conv 4,12,3,3,6,16,4,5,11,7,3,18,8,0,0,0 | 346C |
| ds:0DD4 | -5 | 4 | 4 | sign: < 0 -> type-2 kill counted as unauthorised (6D88), else ground kill (6984) | 3495 |
| type 9 tick | | | | Cold: +1 per tick over enemy territory (grid bits 0-1 == 0); Limited: +1 every 4th tick, Lockheed plane +1 extra every 8th; Conventional: 0 | 3100..316B |

Multipliers applied after the loop (long math 539C mul, 5302 div; each `score = score * M / 8`):

| factor | table | values (index) |
|---|---|---|
| theatre PR+0x38 | ds:0E68 | 8,10,12,13,8 (Libya, Persian Gulf, North Cape, C. Europe, Vietnam); indices 5..8 run into the next table: 8,9,8,9 (?) |
| mission type PR+0x3C | ds:0E72 | 8,9,8,9 (Air, Strike, Air Trn, Strike Trn) |
| opponents PR+0x3E | ds:0E7A | 8,11,14,17 |
| landings PR+0x40 | ds:0E82 | 5,8,10 |
| ejected (SB+0x26 == 2) and log had an end record | ds:0E88[ds:6440] | 2,3,6,4 (territory bits at ejection point) |
| mission length SB+0x2E | immediate | 7000..8999 (0x1B58..0x2327) x9; 9000..11499 (0x2328..0x2CEB) x10; >= 11500 (0x2CEC) x11 |

Return = low word of the score = "performance rating".

---------------------------------------------------------------------------------------------------

## 3. Mission summary `func_0000_2BEC` (1077 bytes) [H]

flag.pic/flag.pal; builds text in ds:6986. Objective phrase index `ds:6D89*2 | ds:720E` -> ds:0DAE: 1 "secondary objective", 2 "primary objective", 3 "primary and secondary objectives".

| condition (in order) | first sentence |
|---|---|
| SB+0x28 != 0 and training | "If this had been an actual combat mission, %s would now be dead, with %s" + "the %s successfully accomplished." / "both objectives unaccomplished." |
| SB+0x28 != 0 | objectives ? "%s was killed in action after accomplishing his mission." : "%s died in the line of duty, mission incomplete." |
| SB+0x26 != 1 and not rescued (`[ds:6440] == 0`, i.e. captured) | "After an embarrassing international incident, %s returned to his squadron." + objectives ? "Accomplishing the %s helped calm the squadron commander." : "The squadron commander was not pleased that the assigned objectives remain unaccomplished." |
| SB+0x26 == 2 and rescued | "%s survived ejection after successfully accomplishing the %s." / "... but failed to accomplish either of the assigned objectives." |
| SB+0x26 == 3 | "%s landed safely after accomplishing the %s!" / "... but failed to accomplish either assigned objective." |

Then: "The performance rating for this mission was %d%s." (suffix ", but will not be recorded as this was a training flight." when SB+0x30); air kills (`64C8+55DC`): 1 "One enemy plane was shot down.", 2..11 "%d enemy aircraft were shot down.", >= 12 (0x0C) "In an impressive display of dogfighting skills, %d ..."; ground kills (`6984+6D88`): "One enemy ground target..." / "%d enemy ground installations..."; ROE: Cold war (W=0) unauthorised military (`55DC+6D88`) and civilian (`5B9A`) -> "In violation of your Rules Of Engagement, %d civilian and %d unauthorized military targets were destroyed."; Limited war (W=1) only civilians reported; friendly kills -> "Friendly forces are outraged by the attack and destruction of their aircraft / installations / aircraft and installations."

---------------------------------------------------------------------------------------------------

## 4. Debrief map + record update `func_0000_03D9` [H]

`02A4` loads brefscrn.pic/pal, breficon.pic and the theatre map (pic table at ds:0010, PR+0x38). `0714(n)` replays the event log step by step on the map (0DA3 shows "TIME: %s" / "SCORE:  %d" / "In Flight", 0A98 the caption); menu `ds:50B5` (hover 046E, 2 hotspots): 1 = next step, 2 / Esc = done.

Record update (0421..046A): `score = 3021(0x100)`; if not training: PR+0x30 (last) = score, PR+0x2E (best) = max(best, score), PR+0x32 (dword total) += score; training: PR+0x30 = 0.

---------------------------------------------------------------------------------------------------

## 5. Awards `func_0000_2265` -> `2AFA`, `2476`, `2A01`, `2703` [H]

2265: skipped entirely for a training flight with no objective done. Clears result bytes, loads awards.pic, `2AFA` (promotion check), `2476` (awards), then if anything was awarded plays music 0x24 and shows `2A01` (promotion text) and `2703` (medal ceremony).

### 5.1 Ribbons and medals `func_0000_2476`

| award | condition | record | evidence |
|---|---|---|---|
| Combat Readiness Ribbon | training flight, PR+0x44 == 0, any objective done | +0x44 = 1, `[ds:55DD]=1` | 2477..24A5 |
| OverSeas Short Tour Ribbon | not training, +0x46 == 0, 5 <= missions < 10 | +0x46 = 1 | 24B8 |
| OverSeas Long Tour Ribbon | not training, +0x48 == 0, missions >= 10 | +0x48 = 1, +0x46 = 0 | 24DC |
| Longevity Service Ribbon | not training, +0x4A == 0, 30 (0x1E) <= missions < 60 (0x3C) | +0x4A = 1 | 2503 |
| Longevity ... with Gold Cluster | not training, +0x4C == 0, missions >= 60 | +0x4C = 1, +0x4A = 0 | 2527 |
| Purple Heart | PR+0x22 == 0, SB+0x36 >= 7, SB+0x34 has bits 0x08 and 0x04 (one per career) | +0x22 = 1, medal 1 | 254E..257E |

Score medals (S = PR+0x30, this mission's score; only one per mission, first match wins). If captured (`[ds:6982]`, set by the TASS scene) or training, the medal is not given; `[ds:55DA]` = its index instead -> "If this had been a real mission you'd be getting the %s." (training) / "Because your capture exposed our stealth technology, the squadron commander will not recommend you for the %s.":

| order | medal (index) | condition | counter |
|---|---|---|---|
| 1 | Congressional Medal of Honor (6) | CMH count == 0 and S > 1200 (0x4B0) | +0x2C = 1 |
| 2 | Air Force Cross (5) | (AFC + 1) x 900 (0x384) <= S | +0x2A += 1 |
| 3 | Silver Star (4) | (SS + 1) x 600 (0x258) <= S | +0x28 += 1 |
| 4 | Distinguished Flying Cross (3) | (DFC + 1) x 300 (0x12C) <= S | +0x26 += 1 |
| 5 | Airman's Medal (2) | AM < 9 and (AM + 1) x 100 (0x64) <= S | +0x24 += 1 |

Medal names: citation ds:05D2[i] ("PURPLE HEART for being wounded ..." .. "CONGRESSIONAL MEDAL OF HONOR, ..."), short ds:05DE[i], service ribbons ds:05EA[1..4].

### 5.2 Promotion `func_0000_2AFA` (check) / `2A01` (text) [H]

Only for non-training flights. Tables indexed by r = 0..5 (r -> rank r+1):

| r | to rank | total score >= (ds:05B0) | average (total / missions) >= (ds:05BC) | missions >= (ds:05C8) |
|---|---|---|---|---|
| 0 | 1st Lt | 300 (0x12C) | 100 (0x64) | 2 |
| 1 | Captain | 1125 (0x465) | 150 (0x96) | 5 |
| 2 | Major | 3000 (0xBB8) | 200 (0xC8) | 10 (0xA) |
| 3 | Lt Colonel | 7000 (0x1B58) | 250 (0xFA) | 20 (0x14) |
| 4 | Colonel | 16000 (0x3E80) | 280 (0x118) | 40 (0x28) |
| 5 | Brig. General | 27720 (0x6C48) | 280 (0x118) | 99 (0x63) |

Loop r = 5 down to the current rank: the first r whose three criteria hold promotes the pilot **one** step (PR+0x20 += 1, `[ds:55E6]=1`). From Colonel (rank 5) the promotion additionally requires missions == 99 exactly. If captured (`[ds:6982]==1`) and rank < 5 -> no promotion, `[ds:55E7]=1` -> "The capture and public trial of %s will delay his promotion to %s." (2A57).

2A01 texts: promoted -> "For demonstrated skill and daring achievment, %s was %spromoted to the rank of %s" ("posthumously " if SB+0x28 != 0; rank names ds:05F2: First Lieutenant .. Brigadier General) + `28ED` insignia; nothing at all -> "%s remained at his present rank."; missions == 99 and alive -> "Congratulations on the successful completion of your 99th mission and retirement from the Air Force." A promotion suppresses a Purple Heart display (2AE3..2AF1).

### 5.3 Ceremony `func_0000_2703`

"%s was %sawarded the %s." (ds:05D2 citation, "posthumously " if SB+0x28), medal picture from page 3 at x = ((m-1)/3) x 100, y = ((m-1)%3) x 60 (0x3C), size 0x57 x 0x3C (?); then the Combat Readiness text, then "%s is [also] awarded the %s for flying %d missions." (service ribbon), then the 55DA "would be getting" text.

---------------------------------------------------------------------------------------------------

## 6. Outcome scenes [H]

All use `func_0000_1901(name, drawcb)` (loads `%s.pic` + `%s.pal`), a music number (far 25F3) and `206A` "Press Selector to continue".

| fn | when | pic | music | text |
|---|---|---|---|---|
| 370A | SB+0x26 == 1 | cemetary | 0x25 | callback 0x3682: switch SB+0x28 (1..6) -> ds:0E90 "Your plane crashed spectacularly into the ground.", "Your plane exploded as it slammed into a hill.", "Your main tanks ran out of fuel and you went down.", "Destroyed by enemy missiles, your plane crashed before you ejected.", "Your plane crashed onto the runway, cartwheeled and exploded.", "Your prudent attempt to eject from the aircraft failed." (case order (?)) |
| 3B9A | ejected, rescued | rescue | 0x26 | callback 3B41 "Your bail-out was successful. An SAR aircraft homes on your beacon and lifts you to safety." |
| 3BBF | ejected, captured | tass | 0x26 | sets `[ds:6982]=1` (captured) |
| 3887 | SB+0x26 == 3 | landed1 + landed2/3/4 (callback 372F, picked by SB+0x33 (?)) | 0x27 | animated taxi frames from pages 2..4 |

Rescue test `func_0000_00A1`: cell = grid[(SB+0x76)>>11][(SB+0x74)>>11] (ds:55EA); `[ds:6440] = cell & 3`; non-zero (friendly/neutral territory) -> rescued, 0 (enemy territory) -> captured.

---------------------------------------------------------------------------------------------------

## 7. Bar talk `func_0000_39D0` [H]

Skipped if SB+0x28 != 0 (dead) or training. Picks scene pic ds:1036[s] (0 desk, 1 endhangr, 2 flight), a quote table `[ds:55C0]` with `[ds:55BE]` entries, and shows entry `random(n)` (3E45) via 1A75 with box positions from ds:103C..1054[s].

| priority | condition | scene | table (count) | sample first entry |
|---|---|---|---|---|
| 1 | no promotion, no medal, no objective, missions != 99 | 0 desk | ds:48E7 (8) | "What happened to the part about piece a cake?" |
| 2 | objective done and captured (6440 == 0), no promotion, no medal | 0 desk | ds:4510 (7) | "Looks like I zigged when I should've zagged." |
| 3 | missions == 99 and rank == 6 (B Gen) | 2 flight | ds:4A4A (4) | "- General, At Last! ..." |
| 4 | missions == 99, rank != 6 | 2 flight | ds:4E53 (4) | "- Wow, 99 missions! ..." |
| 5 | promoted or medal | 1 endhangr | ds:4C32 (5) | "- It's party time! ..." |
| 6 | SB+0x2C < 3 | 1 endhangr | ds:4AEB (5) | "- Gonna slouch yer way to 99, eh? ..." |
| 7 | otherwise (SB+0x2C >= 3) | 1 endhangr | ds:464E (6) | "- You made it back...! ..." |

Tables 4A4A / 4E53 point at successive lines of one multi-line string, so a random index starts mid-dialogue (?).

---------------------------------------------------------------------------------------------------

## 8. Function table (segment 0000, C code)

| addr | alias | role | conf |
|---|---|---|---|
| 0010 | main | flow 1.2, exit 0x23 | H |
| 00A1 | rescue_test | territory at ejection point | H |
| 00C9 / 0113 / 0242 | read_results / read_shared_world / shared_read | 1.3 | H |
| 02A4 | debrief_load | brefscrn/breficon/theatre map | M |
| 03D9 | debrief_map | replay + record update | H |
| 046E | debrief_hover | | L |
| 04D2, 05CA | map overlay / "%s destroyed" marker | | L |
| 0714 | replay_step | | M |
| 0880 | end_marker | uses SB+0x26 | L |
| 0A98 | event_text | event caption | H |
| 0DA3 | time_score_panel | "TIME/SCORE/In Flight" | M |
| 0E82, 0ECD, 0EE0, 0EF3 | time helpers | "00:00:00" | L |
| 0FA4 / 0FDA / 100D | load pic / pal / pic to page | | L |
| 11A2 | delay | | L |
| 1332 | objective label | "PRIMARY OBJECTIVE" | L |
| 1901 | scene_load | %s.pic + %s.pal + callback | H |
| 1A75 | text_box | | M |
| 1BAA / 1CF5 | menu_wait / read_input (Alt-Q -> 3E61) | | M |
| 206A | press_selector | | H |
| 2092 | wait_key (Alt-Q -> 3E61) | | M |
| 2265 | awards | | H |
| 2476 | award_rules | | H |
| 26A9 | award_text_box | | L |
| 2703 | medal_ceremony | | H |
| 28ED | promotion_insignia | | L |
| 2A01 | promotion_text | | H |
| 2AFA | promotion_check | | H |
| 2BA0 / 2BCB | alloc / free buffer | | H |
| 2BEC | mission_summary | | H |
| 3021 | score_mission | | H |
| 3682 (in data block) | crash_text_cb | | M |
| 370A | killed_scene | | H |
| 372F | landed_cb | landed2-4 | M |
| 3887 | landed_scene | | H |
| 39D0 | bar_talk | | H |
| 3B41 / 3B9A | rescue_text / rescue_scene | | H |
| 3BBF | captured_scene | | H |
| 3BF4 / 3CA1 | init / init_shared_ptrs | | H |
| 3CD0, 3D4F | ui init (requestr.pic, font/colour handles from graphics driver) | | L |
| 3E45 | random(n) | | H |
| 3E61 | quit_screen | | H |
| 3F44 | shutdown(code) | | H |
| 45AD | link_driver | | M |
| >= 3F44 | runtime / helpers | | - |
