; VGAME segment 1132  lin 11320..114A5  size 389 (code runs past the next paragraph value; listed here)  dgroup=1E42  (vgame_asm.py; capstone recursive descent)
; entries: 3   far-call sites into this segment: 2   unresolved indirect jumps/calls: 0

; ----- data 1132:0000 .. 1132:0001 (2 bytes) -----
;   1132:0000  5D CB                                            ].

; ===== func_1132_0002  reg(saves)  callers: C=1 asm=0  seeds=far =====
func_1132_0002:
  1132:0002  push ds
  1132:0003  mov ax, 0x40
  1132:0006  mov ds, ax
  1132:0008  and byte ptr [0x17], 0xdf            ; ds:0017
  1132:000D  xor ax, ax
  1132:000F  mov byte ptr ss:[0x2cd8], al
  1132:0013  mov word ptr ss:[0x2cd9], ax
  1132:0017  mov byte ptr ss:[0x2cdb], al
  1132:001B  mov byte ptr ss:[0x2cdc], al
  1132:001F  mov byte ptr ss:[0x2cdd], al
  1132:0023  mov byte ptr ss:[0x2cd6], 0x80
  1132:0029  mov byte ptr ss:[0x2cd7], 0x80
  1132:002F  xor ax, ax
  1132:0031  mov ds, ax
  1132:0033  mov bx, 0x24
  1132:0036  mov ax, word ptr [bx]
  1132:0038  mov dx, word ptr [bx + 2]
  1132:003B  mov word ptr cs:[0x181], ax          ; cs:0181
  1132:003F  mov word ptr cs:[0x183], dx          ; cs:0183
  1132:0044  mov ax, 0x6c
  1132:0047  mov dx, cs
  1132:0049  cli
  1132:004A  mov word ptr [bx], ax
  1132:004C  mov word ptr [bx + 2], dx
  1132:004F  sti
  1132:0050  pop ds
  1132:0051  retf

; ===== func_1132_0052  reg(saves)  callers: C=1 asm=0  seeds=far =====
func_1132_0052:
  1132:0052  push ds
  1132:0053  xor ax, ax
  1132:0055  mov ds, ax
  1132:0057  mov bx, 0x24
  1132:005A  mov ax, word ptr cs:[0x181]          ; cs:0181
  1132:005E  mov dx, word ptr cs:[0x183]          ; cs:0183
  1132:0063  cli
  1132:0064  mov word ptr [bx], ax
  1132:0066  mov word ptr [bx + 2], dx
  1132:0069  sti
  1132:006A  pop ds
  1132:006B  retf

; ===== func_1132_006C  reg  callers: C=0 asm=0  seeds=isr =====
func_1132_006C:
  1132:006C  sti
  1132:006D  pushf
  1132:006E  push ds
  1132:006F  push es
  1132:0070  push ax
  1132:0071  push bx
  1132:0072  mov ax, 0x1e42                       ; seg 1E42
  1132:0075  mov ds, ax
  1132:0077  mov ax, 0x40
  1132:007A  mov es, ax
  1132:007C  mov ah, byte ptr [0x2cdd]            ; ds:2CDD
  1132:0080  or ah, ah
  1132:0082  je loc_1132_008D
loc_1132_0084:    ; <- jcc:1132:009D jcc:1132:00A3
  1132:0084  dec ah
  1132:0086  mov byte ptr [0x2cdd], ah            ; ds:2CDD
  1132:008A  jmp loc_1132_0149
loc_1132_008D:    ; <- jcc:1132:0082
  1132:008D  in al, 0x60
  1132:008F  cmp byte ptr [0x2cdb], 0xe0          ; ds:2CDB
  1132:0094  mov byte ptr [0x2cdb], al            ; ds:2CDB
  1132:0097  je loc_1132_00C4
  1132:0099  cmp al, 0xe0
  1132:009B  mov ah, 1
  1132:009D  je loc_1132_0084
  1132:009F  cmp al, 0xe1
  1132:00A1  mov ah, 3
  1132:00A3  je loc_1132_0084
  1132:00A5  xor ah, ah
  1132:00A7  test byte ptr es:[0x17], 0x20
  1132:00AD  je loc_1132_00B2
  1132:00AF  xor ah, 1
loc_1132_00B2:    ; <- jcc:1132:00AD
  1132:00B2  test byte ptr es:[0x17], 3
  1132:00B8  je loc_1132_00BD
  1132:00BA  xor ah, 1
loc_1132_00BD:    ; <- jcc:1132:00B8
  1132:00BD  or ah, ah
  1132:00BF  je loc_1132_00C4
  1132:00C1  jmp loc_1132_0149
loc_1132_00C4:    ; <- jcc:1132:0097 jcc:1132:00BF
  1132:00C4  mov ah, al
  1132:00C6  and al, 0x7f
  1132:00C8  cmp al, 0x51
  1132:00CA  ja loc_1132_0149
  1132:00CC  sub al, 0x29
  1132:00CE  jb loc_1132_0149
  1132:00D0  mov bx, 0x2cde
  1132:00D3  xlatb
  1132:00D4  or al, al
  1132:00D6  je loc_1132_0149
  1132:00D8  test ah, 0x80
  1132:00DB  jne loc_1132_0134
  1132:00DD  cmp byte ptr [0x2cd8], 0             ; ds:2CD8
  1132:00E2  jne loc_1132_0149
  1132:00E4  mov byte ptr [0x2cd8], al            ; ds:2CD8
  1132:00E7  cmp byte ptr [0x2cdc], al            ; ds:2CDC
  1132:00EB  mov byte ptr [0x2cdc], al            ; ds:2CDC
  1132:00EE  jne loc_1132_0100
  1132:00F0  mov bx, word ptr es:[0x6c]
  1132:00F5  sub bx, word ptr [0x2cd9]            ; ds:2CD9
  1132:00F9  cmp bx, 5
  1132:00FC  mov bh, 0x7f
  1132:00FE  jb loc_1132_0102
loc_1132_0100:    ; <- jcc:1132:00EE
  1132:0100  mov bh, 0x5a
loc_1132_0102:    ; <- jcc:1132:00FE
  1132:0102  mov bl, 0x80
  1132:0104  sub bl, bh
  1132:0106  add bh, 0x80
  1132:0109  test al, 1
  1132:010B  je loc_1132_0111
  1132:010D  mov byte ptr [0x2cd7], bl            ; ds:2CD7
loc_1132_0111:    ; <- jcc:1132:010B
  1132:0111  test al, 2
  1132:0113  je loc_1132_0119
  1132:0115  mov byte ptr [0x2cd7], bh            ; ds:2CD7
loc_1132_0119:    ; <- jcc:1132:0113
  1132:0119  test al, 4
  1132:011B  je loc_1132_0121
  1132:011D  mov byte ptr [0x2cd6], bl            ; ds:2CD6
loc_1132_0121:    ; <- jcc:1132:011B
  1132:0121  test al, 8
  1132:0123  je loc_1132_0129
  1132:0125  mov byte ptr [0x2cd6], bh            ; ds:2CD6
loc_1132_0129:    ; <- jcc:1132:0123
  1132:0129  mov bx, word ptr es:[0x6c]
  1132:012E  mov word ptr [0x2cd9], bx            ; ds:2CD9
  1132:0132  jmp loc_1132_0149
loc_1132_0134:    ; <- jcc:1132:00DB
  1132:0134  cmp byte ptr [0x2cd8], al            ; ds:2CD8
  1132:0138  jne loc_1132_0149
  1132:013A  mov byte ptr [0x2cd8], 0             ; ds:2CD8
  1132:013F  mov byte ptr [0x2cd6], 0x80          ; ds:2CD6
  1132:0144  mov byte ptr [0x2cd7], 0x80          ; ds:2CD7
loc_1132_0149:    ; <- jcc:1132:00CA jcc:1132:00CE jcc:1132:00D6 jcc:1132:00E2 jcc:1132:0138
  1132:0149  mov bx, word ptr es:[0x1a]
  1132:014E  cmp bx, word ptr es:[0x1c]
  1132:0153  je loc_1132_017A
  1132:0155  mov ax, word ptr es:[bx]
loc_1132_0158:    ; <- jmp:1132:0178
  1132:0158  add bx, 2
  1132:015B  cmp bx, word ptr es:[0x82]
  1132:0160  jb loc_1132_0167
  1132:0162  mov bx, word ptr es:[0x80]
loc_1132_0167:    ; <- jcc:1132:0160
  1132:0167  cmp bx, word ptr es:[0x1c]
  1132:016C  je loc_1132_017A
  1132:016E  cmp ax, word ptr es:[bx]
  1132:0171  jne loc_1132_017A
  1132:0173  mov word ptr es:[0x1a], bx
  1132:0178  jmp loc_1132_0158
loc_1132_017A:    ; <- jcc:1132:0153 jcc:1132:016C jcc:1132:0171
  1132:017A  pop bx
  1132:017B  pop ax
  1132:017C  pop es
  1132:017D  pop ds
  1132:017E  popf
  1132:017F  cli
  1132:0180  jmp far func_0000_0000               ; -> 0000:0000
