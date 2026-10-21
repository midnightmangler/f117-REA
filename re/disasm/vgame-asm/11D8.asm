; VGAME segment 11D8  lin 11D80..11ED6  size 342 (code runs past the next paragraph value; listed here)  dgroup=1E42  (vgame_asm.py; capstone recursive descent)
; entries: 5   far-call sites into this segment: 1   unresolved indirect jumps/calls: 0

; ===== func_11D8_0000  reg  callers: C=0 asm=0  seeds=exit =====
func_11D8_0000:
  11D8:0000  mov ah, 9
  11D8:0002  int 0x21
  11D8:0004  mov ax, 0x4c00
  11D8:0007  int 0x21

; ----- data 11D8:0009 .. 11D8:0009 (1 bytes) -----
;   11D8:0009  00                                               .

; ===== func_11D8_000A  bp-frame  callers: C=1 asm=0  seeds=far =====
func_11D8_000A:
  11D8:000A  push bp
  11D8:000B  mov bp, sp
  11D8:000D  push di
  11D8:000E  push si
  11D8:000F  push es
  11D8:0010  push bp
  11D8:0011  push ds
  11D8:0012  mov ax, 0x1e42                       ; seg 1E42
  11D8:0015  mov ds, ax
  11D8:0017  mov ax, word ptr [bp + 6]
  11D8:001A  mov word ptr [0x4662], ax            ; ds:4662
  11D8:001D  mov ax, word ptr [bp + 8]
  11D8:0020  mov word ptr [0x4666], ax            ; ds:4666
  11D8:0023  call func_11D8_0155
  11D8:0026  mov si, word ptr [0x4666]            ; ds:4666
  11D8:002A  call far func_1E42_0232              ; T:0232 slot 56
  11D8:002F  call far func_1E42_0241              ; T:0241 slot 59
  11D8:0034  mov word ptr [0x466c], 0             ; ds:466C
  11D8:003A  mov word ptr [0x4664], 0xfa00        ; ds:4664
loc_11D8_0040:    ; <- jcc:11D8:0074
  11D8:0040  mov di, word ptr [0x466c]            ; ds:466C
  11D8:0044  call far func_1E42_023C              ; T:023C slot 58
  11D8:0049  mov word ptr [0x4668], ax            ; ds:4668
  11D8:004C  call far func_11ED_0006              ; -> 11ED:0006
  11D8:0051  mov di, word ptr [0x4668]            ; ds:4668
  11D8:0055  mov bp, 0x9546
  11D8:0058  mov bx, word ptr [0x466c]            ; ds:466C
  11D8:005C  call far func_1E42_0219              ; T:0219 slot 51
  11D8:0061  mov di, word ptr [0x4668]            ; ds:4668
  11D8:0065  call far func_1E42_0223              ; T:0223 slot 53
  11D8:006A  inc word ptr [0x466c]                ; ds:466C
  11D8:006E  sub word ptr [0x4664], 0x140         ; ds:4664
  11D8:0074  jne loc_11D8_0040
  11D8:0076  pop ds
  11D8:0077  pop bp
  11D8:0078  pop es
  11D8:0079  pop si
  11D8:007A  pop di
  11D8:007B  mov sp, bp
  11D8:007D  pop bp
  11D8:007E  retf

; ===== func_11D8_007F  bp-frame  callers: C=0 asm=0  seeds=sweep =====
func_11D8_007F:
  11D8:007F  push bp
  11D8:0080  mov bp, sp
  11D8:0082  push di
  11D8:0083  push si
  11D8:0084  push es
  11D8:0085  push bp
  11D8:0086  push ds
  11D8:0087  mov ax, 0x1e42                       ; seg 1E42
  11D8:008A  mov ds, ax
  11D8:008C  mov ax, word ptr [bp + 6]
  11D8:008F  mov word ptr [0x4662], ax            ; ds:4662
  11D8:0092  mov ax, word ptr [bp + 8]
  11D8:0095  mov es, ax
  11D8:0097  call far func_1E42_0241              ; T:0241 slot 59
  11D8:009C  call func_11D8_0155
  11D8:009F  mov word ptr [0x466c], 0             ; ds:466C
  11D8:00A5  mov word ptr [0x4664], 0xfa00        ; ds:4664
loc_11D8_00AB:    ; <- jcc:11D8:00DF
  11D8:00AB  mov di, word ptr [0x466c]            ; ds:466C
  11D8:00AF  call far func_1E42_023C              ; T:023C slot 58
  11D8:00B4  mov word ptr [0x4668], ax            ; ds:4668
  11D8:00B7  call far func_11ED_0006              ; -> 11ED:0006
  11D8:00BC  mov di, word ptr [0x4668]            ; ds:4668
  11D8:00C0  mov bp, 0x9546
  11D8:00C3  mov bx, word ptr [0x466c]            ; ds:466C
  11D8:00C7  call far func_1E42_0219              ; T:0219 slot 51
  11D8:00CC  mov di, word ptr [0x4668]            ; ds:4668
  11D8:00D0  call far func_1E42_022D              ; T:022D slot 55
  11D8:00D5  inc word ptr [0x466c]                ; ds:466C
  11D8:00D9  sub word ptr [0x4664], 0x140         ; ds:4664
  11D8:00DF  jne loc_11D8_00AB
  11D8:00E1  pop ds
  11D8:00E2  pop bp
  11D8:00E3  pop es
  11D8:00E4  pop si
  11D8:00E5  pop di
  11D8:00E6  mov sp, bp
  11D8:00E8  pop bp
  11D8:00E9  retf

; ===== func_11D8_00EA  bp-frame  callers: C=0 asm=0  seeds=sweep =====
func_11D8_00EA:
  11D8:00EA  push bp
  11D8:00EB  mov bp, sp
  11D8:00ED  push di
  11D8:00EE  push si
  11D8:00EF  push es
  11D8:00F0  push bp
  11D8:00F1  push ds
  11D8:00F2  mov ax, 0x1e42                       ; seg 1E42
  11D8:00F5  mov ds, ax
  11D8:00F7  mov ax, word ptr [bp + 6]
  11D8:00FA  mov word ptr [0x4662], ax            ; ds:4662
  11D8:00FD  mov ax, word ptr [bp + 8]
  11D8:0100  mov es, ax
  11D8:0102  call far func_1E42_0241              ; T:0241 slot 59
  11D8:0107  call func_11D8_0155
  11D8:010A  mov word ptr [0x466c], 0             ; ds:466C
  11D8:0110  mov word ptr [0x4664], 0xfa00        ; ds:4664
loc_11D8_0116:    ; <- jcc:11D8:014A
  11D8:0116  mov di, word ptr [0x466c]            ; ds:466C
  11D8:011A  call far func_1E42_023C              ; T:023C slot 58
  11D8:011F  mov word ptr [0x4668], ax            ; ds:4668
  11D8:0122  call far func_11ED_0006              ; -> 11ED:0006
  11D8:0127  mov di, word ptr [0x4668]            ; ds:4668
  11D8:012B  mov bp, 0x9546
  11D8:012E  mov bx, word ptr [0x466c]            ; ds:466C
  11D8:0132  call far func_1E42_021E              ; T:021E slot 52
  11D8:0137  mov di, word ptr [0x4668]            ; ds:4668
  11D8:013B  call far func_1E42_0228              ; T:0228 slot 54
  11D8:0140  inc word ptr [0x466c]                ; ds:466C
  11D8:0144  sub word ptr [0x4664], 0x140         ; ds:4664
  11D8:014A  jne loc_11D8_0116
  11D8:014C  pop ds
  11D8:014D  pop bp
  11D8:014E  pop es
  11D8:014F  pop si
  11D8:0150  pop di
  11D8:0151  mov sp, bp
  11D8:0153  pop bp
  11D8:0154  retf

; ===== func_11D8_0155  reg  callers: C=0 asm=0  seeds=call =====
func_11D8_0155:
  11D8:0155  ret
