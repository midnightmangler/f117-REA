# F117.COM program flow, shared block, ROSTER.FIL (task 2.1)

Sources: `re/disasm/F117.asm` (0000:0100..03CA), START `6D07/7218/7272`, start-map.md 1.1-1.3, setup-dswap-map.md.
JS: `src/flow.js`, `src/block.js`, `src/roster.js`.

## F117.COM main (0000:0100..03C9)  [verified in the listing]

```
0100  shrink, alloc shared block 0x140 paragraphs (5120 B); 0:04F0 = seg; 0:04F2 = 1; 0:04F4 = 0
0150  exec SETUP.EXE                     ; 0176: exit code != 0x24 -> DOS exit 0
017F  logoArg = SB[0x0D] & 0x5F          ; upper-cased first letter of the sound driver file name ('I','A','R','N')
019B  exec MPS_LOGO.EXE logoArg          ; 01C1: exit 2 -> text mode 3, DOS exit
01CF  introFlag [0x6F9] = exit code      ; copies SB+0x00 name -> load MGRAPHIC; MISC.EXE -> SB+0x1E; sound driver -> SB+0x1A;
                                         ; sound init(2) -> SB+0x20
0265  if introFlag == 0: exec PLAYER.EXE "- title-1 title-2 title-3a credit c-pit bunker"   (exit code ignored)
0285  L: exec DSWAP.EXE 0 ; exit 0 -> Q
02B6  exec START.EXE ; [0x6F8] = exit ; 0 -> Q
02EA  exec DSWAP.EXE 1 ; exit 0 -> Q
031B  if [0x6F8] == 0x0C: exec PLAYER.EXE " title-2"          (0x0D and anything else: no animation)
0337  exec VGAME.EXE ; exit 0 -> Q
0364  exec DSWAP.EXE 2 ; exit 0 -> Q
0395  exec END.EXE ; exit == 0x23 -> goto L (intro is NOT replayed) ; else fall to Q
03C2  Q: lcall [0x4F1] (graphics/sound shutdown vector); DOS exit 0
```
JS: DSWAP (floppy swap prompt) has no meaning in a browser; `programs.dswap` is optional and defaults to exit 1 ("disk present").
Loader work on drivers (overlays, segments +0x1A/+0x1C/+0x1E/+0x20) is replaced by the platform layer; the block words stay 0.

## Shared block (SB, 0x140 paragraphs = 5120 bytes)
Layout = start-map.md 1.3 (offsets in `src/block.js` FIELDS). Pilot record PR = SB+0x1272 (80 bytes). 0:04F2 / 0:04F4 are BIOS-area words
kept in `flow.bios.firstEntry` / `flow.bios.soundInit`.

## START 6D07 roster_sync (called from START main 0000:0020)  [verified]
```
7218 roster_load()                      ; file -> ds:B39C (word, 2 bytes), ds:D892 records[10] x 0x50
for i in 0..9:                          ; 6D1C
    rec[0].plane &= 1                   ; and word [D8D4],1   (D8D4 = D892+0x42: ALWAYS record 0 - a compiler quirk, kept)
    if rec[i].plane != 0 and (rec[i].type == 0 or rec[i].type == 2): rec[i].type++      ; +0x42, +0x3C
if word 0:04F2 != 0:                    ; 6D4A  first entry since launch
    PR = rec[(byte)B39C]                ; 80 * AL (byte multiply)
else:                                   ; returning from END
    rec[PR.slot] = PR                   ; 80 * word (16-bit)
if SB+0x22 == 0: PR.theatre(+0x38) = 0; PR.type(+0x3C, low byte) |= 2         ; 6D8D
roster_save(0)                          ; 7272: silent on errors
```
## 7218 load / 7272 save
Load: fopen "Roster.Fil" (read), fread 2 bytes -> B39C, 10 x 80 bytes -> D892; if fopen fails the buffers keep their DGROUP
initial content (not recoverable here): JS seeds a missing file with the shipped ROSTER.FIL (asset `roster/ROSTER.FIL`) (?).
Save: `byte B39C = PR.slot` (low byte only; the high byte keeps its loaded value), 804E disk check (browser: always OK),
fopen write, fwrite 2 bytes + 10 x 80. File = 802 bytes.
