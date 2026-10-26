# START: menu machinery, requester, roster and pilot screens (task 2.4)

JS: `src/frontend/menu.js` (machinery), `roster-screen.js` (screens), `start.js` (shell). Addresses = START 0A95:xxxx (`re/disasm/START.asm`).
Far thunks in START: 0A95:(69B8 + 5*i) = MGRAPHIC entry i (6A8A = #42 blit, 6A26 = #22 sprite_draw, 6AA3 = #47 char_width, 69D1 = #5 text_draw,
6B39 = #77 sprite_grab, 6B2F = #75 set_page_seg), 6B7A/6B7F = MISC key_ready/get_key, 6B89 = joystick button, 6BB1 = sound play(id).

## Pages and VPs (73CE..747D)
Pages 0..4 = ds:CAB0[]; page 0 = screen. VP array at ds:DC02, 0x16 bytes each: VP n = {page n, clip 0..319 x 0..199} (DC18 = page 1, DC2E = page 2).
Page 1 = clean picture (and back buffer), page 3 = backup of the screen art, page 4 = sprite sheet of the current screen, page 2 = requestr.pic.
Draw order everywhere: draw into page 1, then blit the changed rectangle 1 -> 0. The cursor lives only on page 0 (restore = blit 1 -> 0).

## Colours
DAC patches are queued by 3517(index, rgb ptr, count) and written by 8427 (INT 10h AX=1012) on the next 70 Hz tick.
ds:11B8 table (6-bit RGB): 11BE 3F322B button hover, 11C1 3F0000 row hover (red), 11C4 393C3B button normal, 11C7 3E291B selected, 11CD 0A120F row normal, 11D0 1F2924 option normal.
Palette = PALETTES.PAL:min(pic,8) copied to ds:64E3 by 826C (rostscrn = pic 7). Roster row i is drawn in colour 0xFF-i; hover / selection only
patch that DAC entry. NOTE: entry 0xFF (row 1) is red (63,0,0) in PALETTES.PAL:7, so row 1 shows red until it was hovered once (?: no DOSBox to compare).
Fade 3070/3088 -> 30A0: linear scale of the 256 colours, duration = 4 BIOS ticks (~0.22 s) per speed unit (self-calibrated iteration count).

## Input 39F7 / menu_wait 38AC
misc get_key = ASCII byte if non-zero, else scan<<8 (Alt-Q 0x1000, arrows 0x4800/4B00/4D00/5000, Delete 0x5300). Pointer (INT 33h) sets the cursor each
call; button 0 -> 0x0D, button 1 -> 0x1B (only if no key). Returns 1 on Enter only if the previous call's key was not Enter (same for Esc 2), 0x62 for Delete (0x5300) and
Backspace (8), else the key. Arrow keys jump the cursor to the nearest rect centre (8BEA distance: max + min/4, best < 1000) in a 45 degree cone.
menu_wait: loop { 8427 tick; hover(); r = 39F7; 1 -> hit test, sound 0x1A (hit) / 0x22 (miss, loop); 2 -> 0x63, sound 0x23; key == desc.hotkey -> key+0x100 }.
Alt-Q -> 7611: stops sound, fade out, adv.pic page 0 + adv.pal, key: 'Y' (& 0x5F) -> shutdown(0) = exit code 0, else restore the screen.

## Requester 3CEA(dlg, x, y)  [dlg: +0 text, +2 button1, +4 button2|0, +6 width]
Measures the text with 3776 (page -1, maxW = width-12, line advance 8), height = 8*lines + 0x1A. Panel is built on page 2 at (0,4): 2CB4 frame
(2x2 corners copied from the sheet corner, edges 0xE0 top, 0xE6 bottom, 0xE1 left, 0xE5 right, fill 0xE2), body text font 4 colour 0xF shadow 0x8 (36C4: copies at +1/+1, +0/+1, +1/+0 in the
shadow colour), buttons 2DF2 (frame 0x10 high, font 1, colour 0xE8 / 0xE7, text width + 8). Button centres: 2 buttons (W-4)/3+2 and (W-4)*2/3+2, one button (W-4)/2+2.
Background saved to page 2 at y = H+4, panel blitted to pages 1 and 0, hotspot rects computed relative to the screen position. Cursor goes to the first button's
(x1-3, y1-3); Esc is ignored; after the click 2B06(6) frames and the saved background is restored. Hover swaps DAC 0xE8 / 0xE7 between 11C4 and 11BE.

## Roster 623E
`0:04F2 = 0`; screen_enter(7, 615C). Loop on menu_wait(ds:704E, hotkey 0x62):
- 1..10: status (+0x4E) 1 -> requester 7244 (retired), 2 -> 715F (deceased), else: if ds:D2A2 (mission scheduled) requester 710D ("OK"/"No Way!", 2 = cancel);
  D2A2 = 0; row colour of the old pilot back to 11CD; roster[PR.slot] = PR; PR = roster[hot-1]; PR.slot = hot-1; clearance rule (SB+0x22 == 0 -> theatre 0, type |= 2);
  row colour 11C7; pilot_options 6DB8.
- 11 / Esc: cursor bg restore; PR.status != 0 -> same requesters, stay; else D878 = D879 = PR.plane, save roster (7272(1): error requesters), return 0.
- 0x162 (Delete): hit test the cursor on rows 1..10; D2A2 -> requester 710D; new_pilot(row); D2A2 = 0 (also after Esc).
615C: rostsprt -> page 4, page 1 -> page 3, rows in font 1 colour 0xFF-i via 6861, "Press 'Delete' key to erase a pilot" centred at x 0xA0 y 0x90 font 3 colour 0x1A,
selected row colour, blit (0x1E,0x2C,0x10E,0x6E) 1 -> 0, cursor (0xA0, 10*slot+0x2F).
6861(slot, y): blit page 3 -> 1 (0x1E,y,0x102,8); "%s%s" rank prefix + name at x 0x1E; total score right-aligned to x 0xE0; missions to 0xF6; status string centred at 0xFD + trunc((0x23-w)/2).
63FB hover: previous row (unless it is the selected pilot's row) -> 11CD, details area restored from page 3; new row -> 11C1 and 64E5 details.
64E5: font 4: rank + last word of the name (6A7C) at (0x32,0x9F) colour 1; "Best/Last Mission: %d" (0x32,0xA8/0xB0) colour 0x1C; opponents / landings / plane strings at (0xA2, 0xA0/0xA8/0xB0);
medals in order CMH DFC AFC SS AM PH: sprite (0,0x98+8k) 0x22x8 from page 4 to (x,0xBF), "XX:%d" centred at (x+0x11, 0xB8), x += 0x26 from 0x24; blit (0x24,0x9F,0xE0,0x29) 1 -> 0.
6AB3 new_pilot(row): buffer "2nd Lt " + typed text, Enter (or 29 chars / width > 0x96) creates: record zeroed, name, slot, war 2, type 3, status 0 -> copied to PR; Esc leaves it. Backspace never erases the prefix.

## Pilot options 6DB8 (ds:6FFA hover 71AD)
Cursor (0x103,0xB4); DAC 0xEB..0xF4 = black; panel (0xC0,0x28,0x6F,0x98): saved from page 1 to page 4 at (0x6F,0), art from page 4 (0,0); checkmark sprite (12x8 cut from page 2 at (0x134,0xB0)) at (0xC0+X, 0x28+Y)
with X = ds:0EA9[h-1], Y = ds:0EB3[h-1] for hotspots h = opponents+1, landings+5, plane+8; "rank + last word" types itself at (0xD9,0x37) font 3 colour 0x1C, one char per random(6)+6 frames
(sound 0x21, stops at width > 0x52). Hotspots 1-4 opponents, 5-7 landings, 8-9 plane (Lockheed turns type 0/2 into 1/3), 10 or Esc leaves; marker moved with sound 0x1B.
Exit: Esc -> PR = roster[slot] (changes discarded), cursor back; else roster[slot] = PR, cursor (0x129,0xB6). Hover colours: DAC (0xF5-h) = 11C1 hover / 11D0 normal.
