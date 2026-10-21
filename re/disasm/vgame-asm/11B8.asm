; VGAME segment 11B8  lin 11B80..11D89  size 521 (code runs past the next paragraph value; listed here)  dgroup=1E42  (vgame_asm.py; capstone recursive descent)
; entries: 8   far-call sites into this segment: 5   unresolved indirect jumps/calls: 0

; ----- data 11B8:0000 .. 11B8:0007 (8 bytes) -----
;   11B8:0000  89 77 10 5E 5F C9 CB 00                          .w.^_...

; ===== func_11B8_0008  bp-frame  callers: C=1 asm=0  seeds=far =====
func_11B8_0008:
  11B8:0008  push bp
  11B8:0009  mov bp, sp
  11B8:000B  push di
  11B8:000C  push si
  11B8:000D  push es
  11B8:000E  push bp
  11B8:000F  push ds
  11B8:0010  mov ax, 0x1e42                       ; seg 1E42
  11B8:0013  mov ds, ax
  11B8:0015  mov ah, 0x3d
  11B8:0017  mov al, byte ptr [bp + 8]
  11B8:001A  mov bx, ss
  11B8:001C  mov ds, bx
  11B8:001E  mov dx, word ptr [bp + 6]
  11B8:0021  int 0x21
  11B8:0023  jae loc_11B8_0057
  11B8:0025  cmp ax, 2
  11B8:0028  jne loc_11B8_0036
loc_11B8_002A:    ; <- jcc:11B8:0039
  11B8:002A  mov bx, word ptr [bp + 6]
  11B8:002D  mov ax, 0x45f8
  11B8:0030  mov cx, 0xffff
  11B8:0033  jmp loc_11B8_01CD
loc_11B8_0036:    ; <- jcc:11B8:0028
  11B8:0036  cmp ax, 3
  11B8:0039  je loc_11B8_002A
  11B8:003B  cmp ax, 4
  11B8:003E  jne loc_11B8_004C
  11B8:0040  mov cx, 0xffff
  11B8:0043  mov bx, word ptr [bp + 6]
  11B8:0046  mov ax, 0x4608
  11B8:0049  jmp loc_11B8_01CD
loc_11B8_004C:    ; <- jcc:11B8:003E
  11B8:004C  mov cx, ax
  11B8:004E  mov ax, 0x4623
  11B8:0051  mov bx, word ptr [bp + 6]
  11B8:0054  jmp loc_11B8_01CD
loc_11B8_0057:    ; <- jcc:11B8:0023
  11B8:0057  mov word ptr [0x4660], 0x200         ; ds:4660
  11B8:005D  pop ds
  11B8:005E  pop bp
  11B8:005F  pop es
  11B8:0060  pop si
  11B8:0061  pop di
  11B8:0062  mov sp, bp
  11B8:0064  pop bp
  11B8:0065  retf

; ===== func_11B8_0066  bp-frame  callers: C=0 asm=0  seeds=sweep =====
func_11B8_0066:
  11B8:0066  push bp
  11B8:0067  mov bp, sp
  11B8:0069  push di
  11B8:006A  push si
  11B8:006B  push es
  11B8:006C  push bp
  11B8:006D  push ds
  11B8:006E  mov ax, 0x1e42                       ; seg 1E42
  11B8:0071  mov ds, ax
  11B8:0073  mov ah, 0x3c
  11B8:0075  mov cx, word ptr [bp + 8]
  11B8:0078  mov bx, ss
  11B8:007A  mov ds, bx
  11B8:007C  mov dx, word ptr [bp + 6]
  11B8:007F  int 0x21
  11B8:0081  jae loc_11B8_00B5
  11B8:0083  cmp ax, 2
  11B8:0086  jne loc_11B8_0094
loc_11B8_0088:    ; <- jcc:11B8:0097
  11B8:0088  mov bx, word ptr [bp + 6]
  11B8:008B  mov ax, 0x45f8
  11B8:008E  mov cx, 0xffff
  11B8:0091  jmp loc_11B8_01CD
loc_11B8_0094:    ; <- jcc:11B8:0086
  11B8:0094  cmp ax, 3
  11B8:0097  je loc_11B8_0088
  11B8:0099  cmp ax, 4
  11B8:009C  jne loc_11B8_00AA
  11B8:009E  mov cx, 0xffff
  11B8:00A1  mov bx, word ptr [bp + 6]
  11B8:00A4  mov ax, 0x4608
  11B8:00A7  jmp loc_11B8_01CD
loc_11B8_00AA:    ; <- jcc:11B8:009C
  11B8:00AA  mov cx, ax
  11B8:00AC  mov ax, 0x4623
  11B8:00AF  mov bx, word ptr [bp + 6]
  11B8:00B2  jmp loc_11B8_01CD
loc_11B8_00B5:    ; <- jcc:11B8:0081
  11B8:00B5  mov word ptr [0x4660], 0x200         ; ds:4660
  11B8:00BB  pop ds
  11B8:00BC  pop bp
  11B8:00BD  pop es
  11B8:00BE  pop si
  11B8:00BF  pop di
  11B8:00C0  mov sp, bp
  11B8:00C2  pop bp
  11B8:00C3  retf

; ===== func_11B8_00C4  bp-frame  callers: C=1 asm=0  seeds=far =====
func_11B8_00C4:
  11B8:00C4  push bp
  11B8:00C5  mov bp, sp
  11B8:00C7  push di
  11B8:00C8  push si
  11B8:00C9  push es
  11B8:00CA  push bp
  11B8:00CB  push ds
  11B8:00CC  mov ax, 0x1e42                       ; seg 1E42
  11B8:00CF  mov ds, ax
  11B8:00D1  mov ah, 0x3e
  11B8:00D3  mov bx, word ptr [bp + 6]
  11B8:00D6  int 0x21
  11B8:00D8  jae loc_11B8_00E3
  11B8:00DA  mov dx, 0x4630
  11B8:00DD  mov cx, 0xffff
  11B8:00E0  jmp loc_11B8_01E8
loc_11B8_00E3:    ; <- jcc:11B8:00D8
  11B8:00E3  pop ds
  11B8:00E4  pop bp
  11B8:00E5  pop es
  11B8:00E6  pop si
  11B8:00E7  pop di
  11B8:00E8  mov sp, bp
  11B8:00EA  pop bp
  11B8:00EB  retf

; ===== func_11B8_00EC  bp-frame  callers: C=0 asm=0  seeds=sweep =====
func_11B8_00EC:
  11B8:00EC  push bp
  11B8:00ED  mov bp, sp
  11B8:00EF  push di
  11B8:00F0  push si
  11B8:00F1  push es
  11B8:00F2  push bp
  11B8:00F3  push ds
  11B8:00F4  mov ax, 0x1e42                       ; seg 1E42
  11B8:00F7  mov ds, ax
  11B8:00F9  mov ah, 0x3f
  11B8:00FB  mov bx, ss
  11B8:00FD  mov ds, bx
  11B8:00FF  mov bx, word ptr [bp + 6]
  11B8:0102  mov cx, word ptr [bp + 8]
  11B8:0105  mov dx, word ptr [bp + 0xa]
  11B8:0108  int 0x21
  11B8:010A  jae loc_11B8_0115
  11B8:010C  mov dx, 0x4643
  11B8:010F  mov cx, 0xffff
  11B8:0112  jmp loc_11B8_01E8
loc_11B8_0115:    ; <- jcc:11B8:010A
  11B8:0115  pop ds
  11B8:0116  pop bp
  11B8:0117  pop es
  11B8:0118  pop si
  11B8:0119  pop di
  11B8:011A  mov sp, bp
  11B8:011C  pop bp
  11B8:011D  retf

; ===== func_11B8_011E  bp-frame  callers: C=0 asm=0  seeds=sweep =====
func_11B8_011E:
  11B8:011E  push bp
  11B8:011F  mov bp, sp
  11B8:0121  push di
  11B8:0122  push si
  11B8:0123  push es
  11B8:0124  push bp
  11B8:0125  push ds
  11B8:0126  mov ax, 0x1e42                       ; seg 1E42
  11B8:0129  mov ds, ax
  11B8:012B  push ds
  11B8:012C  mov ah, 0x3f
  11B8:012E  mov bx, word ptr [bp + 0xc]
  11B8:0131  mov ds, bx
  11B8:0133  mov bx, word ptr [bp + 6]
  11B8:0136  mov cx, word ptr [bp + 8]
  11B8:0139  mov dx, word ptr [bp + 0xa]
  11B8:013C  int 0x21
  11B8:013E  pop ds
  11B8:013F  jae loc_11B8_014A
  11B8:0141  mov dx, 0x4643
  11B8:0144  mov cx, 0xffff
  11B8:0147  jmp loc_11B8_01E8
loc_11B8_014A:    ; <- jcc:11B8:013F
  11B8:014A  pop ds
  11B8:014B  pop bp
  11B8:014C  pop es
  11B8:014D  pop si
  11B8:014E  pop di
  11B8:014F  mov sp, bp
  11B8:0151  pop bp
  11B8:0152  retf

; ===== func_11B8_0153  reg(saves)  callers: C=0 asm=3  seeds=far =====
func_11B8_0153:
  11B8:0153  push ds
  11B8:0154  mov ah, 0x3f
  11B8:0156  mov bx, 0x1e42                       ; seg 1E42
  11B8:0159  mov ds, bx
  11B8:015B  mov bx, word ptr [0x4662]            ; ds:4662
  11B8:015F  mov cx, 0x200
  11B8:0162  mov dx, 0x43f8
  11B8:0165  int 0x21
  11B8:0167  jae loc_11B8_0172
  11B8:0169  mov dx, 0x4643
  11B8:016C  mov cx, 0xffff
  11B8:016F  jmp loc_11B8_01E8

; ----- data 11B8:0171 .. 11B8:0171 (1 bytes) -----
;   11B8:0171  90                                               .
loc_11B8_0172:    ; <- jcc:11B8:0167
  11B8:0172  pop ds
  11B8:0173  retf

; ===== func_11B8_0174  bp-frame  callers: C=0 asm=0  seeds=sweep =====
func_11B8_0174:
  11B8:0174  push bp
  11B8:0175  mov bp, sp
  11B8:0177  push di
  11B8:0178  push si
  11B8:0179  push es
  11B8:017A  push bp
  11B8:017B  push ds
  11B8:017C  mov ax, 0x1e42                       ; seg 1E42
  11B8:017F  mov ds, ax
  11B8:0181  mov ax, word ptr [bp + 6]
  11B8:0184  mov word ptr [0x4662], ax            ; ds:4662
  11B8:0187  call far func_11B8_0153              ; -> 11B8:0153
  11B8:018C  pop ds
  11B8:018D  pop bp
  11B8:018E  pop es
  11B8:018F  pop si
  11B8:0190  pop di
  11B8:0191  mov sp, bp
  11B8:0193  pop bp
  11B8:0194  retf

; ===== func_11B8_0195  bp-frame  callers: C=0 asm=0  seeds=sweep =====
func_11B8_0195:
  11B8:0195  push bp
  11B8:0196  mov bp, sp
  11B8:0198  push di
  11B8:0199  push si
  11B8:019A  push es
  11B8:019B  push bp
  11B8:019C  push ds
  11B8:019D  mov ax, 0x1e42                       ; seg 1E42
  11B8:01A0  mov ds, ax
  11B8:01A2  push ds
  11B8:01A3  mov ah, 0x40
  11B8:01A5  mov bx, word ptr [bp + 0xc]
  11B8:01A8  mov ds, bx
  11B8:01AA  mov bx, word ptr [bp + 6]
  11B8:01AD  mov cx, word ptr [bp + 8]
  11B8:01B0  mov dx, word ptr [bp + 0xa]
  11B8:01B3  add dx, word ptr [bp + 0xe]
  11B8:01B6  int 0x21
  11B8:01B8  pop ds
  11B8:01B9  jae loc_11B8_01C4
  11B8:01BB  mov dx, 0x464e
  11B8:01BE  mov cx, 0xffff
  11B8:01C1  jmp loc_11B8_01E8

; ----- data 11B8:01C3 .. 11B8:01C3 (1 bytes) -----
;   11B8:01C3  90                                               .
loc_11B8_01C4:    ; <- jcc:11B8:01B9
  11B8:01C4  pop ds
  11B8:01C5  pop bp
  11B8:01C6  pop es
  11B8:01C7  pop si
  11B8:01C8  pop di
  11B8:01C9  mov sp, bp
  11B8:01CB  pop bp
  11B8:01CC  retf
loc_11B8_01CD:    ; <- jmp:11B8:0033 jmp:11B8:0049 jmp:11B8:0054 jmp:11B8:0091 jmp:11B8:00A7
  11B8:01CD  push ax
  11B8:01CE  mov ax, 3
  11B8:01D1  int 0x10
  11B8:01D3  mov di, 0
loc_11B8_01D6:    ; <- jmp:11B8:01DC
  11B8:01D6  cmp byte ptr [bx + di], 0
  11B8:01D9  je loc_11B8_01DE
  11B8:01DB  inc di
  11B8:01DC  jmp loc_11B8_01D6
loc_11B8_01DE:    ; <- jcc:11B8:01D9
  11B8:01DE  mov byte ptr [bx + di], 0x24
  11B8:01E1  mov dx, bx
  11B8:01E3  mov ah, 9
  11B8:01E5  int 0x21
  11B8:01E7  pop dx
loc_11B8_01E8:    ; <- jmp:11B8:00E0 jmp:11B8:0112 jmp:11B8:0147 jmp:11B8:016F jmp:11B8:01C1
  11B8:01E8  mov ah, 9
  11B8:01EA  int 0x21
  11B8:01EC  cmp cx, -1
  11B8:01EF  je loc_11B8_0204
  11B8:01F1  add cx, 0x30
  11B8:01F4  mov byte ptr [0x43f6], cl            ; ds:43F6
  11B8:01F8  mov byte ptr [0x43f7], 0x24          ; ds:43F7
  11B8:01FD  mov dx, 0x43f6
  11B8:0200  mov ah, 9
  11B8:0202  int 0x21
loc_11B8_0204:    ; <- jcc:11B8:01EF
  11B8:0204  mov ax, 0x4c00
  11B8:0207  int 0x21
