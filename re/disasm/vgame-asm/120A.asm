; VGAME segment 120A  lin 120A0..130DD  size 4157 (code runs past the next paragraph value; listed here)  dgroup=1E42  (vgame_asm.py; capstone recursive descent)
; entries: 26   far-call sites into this segment: 12   unresolved indirect jumps/calls: 0

; ----- data 120A:0000 .. 120A:0007 (8 bytes) -----
;   120A:0000  89 0E 98 96 E9 57 FF 00                          .....W..

; ===== func_120A_0008  bp-frame  callers: C=1 asm=0  seeds=far =====
func_120A_0008:
  120A:0008  push bp
  120A:0009  mov bp, sp
  120A:000B  mov ax, word ptr [bp + 8]
  120A:000E  shl ax, 1
  120A:0010  cdq
  120A:0011  xor ax, dx
  120A:0013  sub ax, dx
  120A:0015  cmp ax, 0x100
  120A:0018  jae loc_120A_001D
  120A:001A  mov ax, 0x100
loc_120A_001D:    ; <- jcc:120A:0018
  120A:001D  mov cx, ax
  120A:001F  mov dx, 0x7f
  120A:0022  mov ax, 0xff00
  120A:0025  div cx
  120A:0027  mov word ptr [0x7d5e], ax            ; ds:7D5E
  120A:002A  lea ax, [0x7b28]                     ; ds:7B28
  120A:002E  push ax
  120A:002F  mov ax, word ptr [bp + 6]
  120A:0032  push ax
  120A:0033  call far func_1452_0316              ; -> 1452:0316
  120A:0038  add sp, 4
  120A:003B  lea ax, [0x7b3a]                     ; ds:7B3A
  120A:003F  push ax
  120A:0040  sub ax, 0x12
  120A:0043  push ax
  120A:0044  call far func_1452_02E4              ; -> 1452:02E4
  120A:0049  lea bx, [0x7b28]                     ; ds:7B28
  120A:004D  mov ax, word ptr [0x7d5e]            ; ds:7D5E
  120A:0050  neg ax
  120A:0052  mov cx, ax
  120A:0054  imul word ptr [bx + 4]
  120A:0057  shl ax, 1
  120A:0059  rcl dx, 1
  120A:005B  mov word ptr [bx + 4], dx
  120A:005E  mov ax, cx
  120A:0060  imul word ptr [bx + 0xa]
  120A:0063  shl ax, 1
  120A:0065  rcl dx, 1
  120A:0067  mov word ptr [bx + 0xa], dx
  120A:006A  mov ax, cx
  120A:006C  imul word ptr [bx + 0x10]
  120A:006F  shl ax, 1
  120A:0071  rcl dx, 1
  120A:0073  mov word ptr [bx + 0x10], dx
  120A:0076  sar word ptr [bx], 1
  120A:0078  sar word ptr [bx + 6], 1
  120A:007B  sar word ptr [bx + 0xc], 1
  120A:007E  sar word ptr [bx + 2], 1
  120A:0081  sar word ptr [bx + 8], 1
  120A:0084  sar word ptr [bx + 0xe], 1
  120A:0087  cmp word ptr [0x7d6a], 0             ; ds:7D6A
  120A:008C  je loc_120A_009A
  120A:008E  neg word ptr [bx + 2]
  120A:0091  neg word ptr [bx + 8]
  120A:0094  neg word ptr [bx + 0xe]
  120A:0097  jmp loc_120A_00CA

; ----- data 120A:0099 .. 120A:0099 (1 bytes) -----
;   120A:0099  90                                               .
loc_120A_009A:    ; <- jcc:120A:008C
  120A:009A  mov ax, word ptr [bx + 2]
  120A:009D  neg ax
  120A:009F  mov cx, ax
  120A:00A1  sar cx, 1
  120A:00A3  sar cx, 1
  120A:00A5  sub ax, cx
  120A:00A7  mov word ptr [bx + 2], ax
  120A:00AA  mov ax, word ptr [bx + 8]
  120A:00AD  neg ax
  120A:00AF  mov cx, ax
  120A:00B1  sar cx, 1
  120A:00B3  sar cx, 1
  120A:00B5  sub ax, cx
  120A:00B7  mov word ptr [bx + 8], ax
  120A:00BA  mov ax, word ptr [bx + 0xe]
  120A:00BD  neg ax
  120A:00BF  mov cx, ax
  120A:00C1  sar cx, 1
  120A:00C3  sar cx, 1
  120A:00C5  sub ax, cx
  120A:00C7  mov word ptr [bx + 0xe], ax
loc_120A_00CA:    ; <- jmp:120A:0097
  120A:00CA  add sp, 4
  120A:00CD  pop bp
  120A:00CE  retf

; ===== func_120A_00CF  bp-frame  callers: C=7 asm=0  seeds=far =====
func_120A_00CF:
  120A:00CF  push bp
  120A:00D0  mov bp, sp
  120A:00D2  mov byte ptr [0x7d8c], 0             ; ds:7D8C
  120A:00D7  nop
  120A:00D8  mov ax, word ptr [0x8590]            ; ds:8590
  120A:00DB  mov es, ax
  120A:00DD  sub si, si
  120A:00DF  mov ax, word ptr es:[si]
  120A:00E2  cmp ax, word ptr [bp + 6]
  120A:00E5  ja loc_120A_00E9
  120A:00E7  pop bp
  120A:00E8  retf
loc_120A_00E9:    ; <- jcc:120A:00E5
  120A:00E9  mov ax, word ptr [bp + 8]
  120A:00EC  mov word ptr [0x7ccc], ax            ; ds:7CCC
  120A:00EF  mov ax, word ptr [bp + 0xa]
  120A:00F2  mov word ptr [0x7cce], ax            ; ds:7CCE
  120A:00F5  mov ax, word ptr [bp + 0xc]
  120A:00F8  mov word ptr [0x7cd0], ax            ; ds:7CD0
  120A:00FB  mov ax, word ptr [bp + 0xe]
  120A:00FE  mov word ptr [0x7d4c], ax            ; ds:7D4C
  120A:0101  mov ax, word ptr [bp + 0x10]
  120A:0104  mov word ptr [0x7d4e], ax            ; ds:7D4E
  120A:0107  lea ax, [0x7cd2]                     ; ds:7CD2
  120A:010B  push ax
  120A:010C  lea ax, [0x7b28]                     ; ds:7B28
  120A:0110  push ax
  120A:0111  lea ax, [0x7ccc]                     ; ds:7CCC
  120A:0115  push ax
  120A:0116  call far func_1452_0330              ; -> 1452:0330
  120A:011B  add sp, 6
  120A:011E  mov bx, word ptr [bp + 6]
  120A:0121  shl bx, 1
  120A:0123  mov si, word ptr es:[bx + 2]
  120A:0127  mov ax, word ptr [0x7cdc]            ; ds:7CDC
  120A:012A  cdq
  120A:012B  xor ax, dx
  120A:012D  sub ax, dx
  120A:012F  mov dx, ax
loc_120A_0131:    ; <- jcc:120A:013F
  120A:0131  mov ax, word ptr es:[si]
  120A:0134  add si, 2
  120A:0137  mov bx, word ptr es:[si]
  120A:013A  add si, 2
  120A:013D  cmp dx, ax
  120A:013F  ja loc_120A_0131
  120A:0141  mov si, bx
  120A:0143  mov ax, word ptr es:[si]
  120A:0146  add si, 2
  120A:0149  cmp ax, dx
  120A:014B  ja loc_120A_0153
  120A:014D  mov byte ptr [0x7d8c], 0x80          ; ds:7D8C
  120A:0152  nop
loc_120A_0153:    ; <- jcc:120A:014B
  120A:0153  cmp byte ptr [0x7d8e], 0             ; ds:7D8E
  120A:0158  jne loc_120A_0168
  120A:015A  call func_120A_02B2
  120A:015D  je loc_120A_0168
  120A:015F  mov byte ptr [0x7d8c], 0x80          ; ds:7D8C
  120A:0164  nop
  120A:0165  jmp loc_120A_019F

; ----- data 120A:0167 .. 120A:0167 (1 bytes) -----
;   120A:0167  90                                               .
loc_120A_0168:    ; <- jcc:120A:0158 jcc:120A:015D
  120A:0168  mov cx, word ptr es:[si]
  120A:016B  add si, 2
  120A:016E  call func_120A_0317
  120A:0171  mov ax, word ptr es:[si]
  120A:0174  add si, 2
  120A:0177  mov word ptr [0x7d5c], ax            ; ds:7D5C
  120A:017A  call func_120A_0561
  120A:017D  mov ax, word ptr [0x7d5a]            ; ds:7D5A
  120A:0180  cdq
  120A:0181  xor ax, dx
  120A:0183  sub ax, dx
  120A:0185  cmp ax, 4
  120A:0188  jae loc_120A_0190
  120A:018A  mov byte ptr [0x7d8c], 0x80          ; ds:7D8C
  120A:018F  nop
loc_120A_0190:    ; <- jcc:120A:0188
  120A:0190  call func_120A_027D
  120A:0193  call func_120A_06B5
  120A:0196  call func_120A_0A33
  120A:0199  call func_120A_0C76
  120A:019C  call func_120A_029E
loc_120A_019F:    ; <- jmp:120A:0165
  120A:019F  mov bx, word ptr [0x7d8c]            ; ds:7D8C
  120A:01A3  and bx, 0x80
  120A:01A7  xor bx, 0x80
  120A:01AB  je loc_120A_01AE
  120A:01AD  nop
loc_120A_01AE:    ; <- jcc:120A:01AB
  120A:01AE  or word ptr [0xc6b2], bx             ; ds:C6B2
  120A:01B2  pop bp
  120A:01B3  retf

; ===== func_120A_01B4  bp-frame  callers: C=1 asm=0  seeds=far =====
func_120A_01B4:
  120A:01B4  push bp
  120A:01B5  mov bp, sp
  120A:01B7  mov byte ptr [0x7d8c], 0             ; ds:7D8C
  120A:01BC  nop
  120A:01BD  mov ax, word ptr [0x8590]            ; ds:8590
  120A:01C0  mov es, ax
  120A:01C2  sub si, si
  120A:01C4  mov ax, word ptr es:[si]
  120A:01C7  cmp ax, word ptr [bp + 6]
  120A:01CA  ja loc_120A_01CE
  120A:01CC  pop bp
  120A:01CD  retf
loc_120A_01CE:    ; <- jcc:120A:01CA
  120A:01CE  mov ax, word ptr [bp + 8]
  120A:01D1  mov word ptr [0x7ccc], ax            ; ds:7CCC
  120A:01D4  mov ax, word ptr [bp + 0xa]
  120A:01D7  mov word ptr [0x7cce], ax            ; ds:7CCE
  120A:01DA  mov ax, word ptr [bp + 0xc]
  120A:01DD  mov word ptr [0x7cd0], ax            ; ds:7CD0
  120A:01E0  mov ax, word ptr [bp + 0xe]
  120A:01E3  mov word ptr [0x7d4c], ax            ; ds:7D4C
  120A:01E6  lea ax, [0x7cd2]                     ; ds:7CD2
  120A:01EA  push ax
  120A:01EB  lea ax, [0x7b28]                     ; ds:7B28
  120A:01EF  push ax
  120A:01F0  lea ax, [0x7ccc]                     ; ds:7CCC
  120A:01F4  push ax
  120A:01F5  call far func_1452_0330              ; -> 1452:0330
  120A:01FA  add sp, 6
  120A:01FD  mov bx, word ptr [bp + 6]
  120A:0200  shl bx, 1
  120A:0202  mov si, word ptr es:[bx + 2]
  120A:0206  mov ax, word ptr [0x7cdc]            ; ds:7CDC
  120A:0209  cdq
  120A:020A  xor ax, dx
  120A:020C  sub ax, dx
  120A:020E  mov dx, ax
loc_120A_0210:    ; <- jcc:120A:021E
  120A:0210  mov ax, word ptr es:[si]
  120A:0213  add si, 2
  120A:0216  mov bx, word ptr es:[si]
  120A:0219  add si, 2
  120A:021C  cmp dx, ax
  120A:021E  ja loc_120A_0210
  120A:0220  mov si, bx
  120A:0222  mov ax, word ptr es:[si]
  120A:0225  add si, 2
  120A:0228  cmp ax, dx
  120A:022A  ja loc_120A_0232
  120A:022C  mov byte ptr [0x7d8c], 0x80          ; ds:7D8C
  120A:0231  nop
loc_120A_0232:    ; <- jcc:120A:022A
  120A:0232  call func_120A_02B2
  120A:0235  je loc_120A_0240
  120A:0237  mov byte ptr [0x7d8c], 0x80          ; ds:7D8C
  120A:023C  nop
  120A:023D  jmp loc_120A_0268

; ----- data 120A:023F .. 120A:023F (1 bytes) -----
;   120A:023F  90                                               .
loc_120A_0240:    ; <- jcc:120A:0235
  120A:0240  mov cx, word ptr es:[si]
  120A:0243  add si, 2
  120A:0246  call func_120A_0317
  120A:0249  mov ax, word ptr es:[si]
  120A:024C  add si, 2
  120A:024F  mov word ptr [0x7d5c], ax            ; ds:7D5C
  120A:0252  call func_120A_0561
  120A:0255  mov ax, word ptr [0x7d5a]            ; ds:7D5A
  120A:0258  cdq
  120A:0259  xor ax, dx
  120A:025B  sub ax, dx
  120A:025D  cmp ax, 4
  120A:0260  jae loc_120A_0268
  120A:0262  mov byte ptr [0x7d8c], 0x80          ; ds:7D8C
  120A:0267  nop
loc_120A_0268:    ; <- jcc:120A:0260 jmp:120A:023D
  120A:0268  mov bx, word ptr [0x7d8c]            ; ds:7D8C
  120A:026C  and bx, 0x80
  120A:0270  xor bx, 0x80
  120A:0274  je loc_120A_0277
  120A:0276  nop
loc_120A_0277:    ; <- jcc:120A:0274
  120A:0277  or word ptr [0xc6b2], bx             ; ds:C6B2
  120A:027B  pop bp
  120A:027C  retf

; ===== func_120A_027D  reg(saves)  callers: C=0 asm=0  seeds=call =====
func_120A_027D:
  120A:027D  push es
  120A:027E  sub bx, bx
  120A:0280  mov es, bx
  120A:0282  mov ax, word ptr es:[bx]
  120A:0285  mov word ptr [0x5ee6], ax            ; ds:5EE6
  120A:0288  mov ax, word ptr es:[bx + 2]
  120A:028C  mov word ptr [0x5ee8], ax            ; ds:5EE8
  120A:028F  mov ax, cs
  120A:0291  mov word ptr es:[bx + 2], ax
  120A:0295  lea ax, [0x971]                      ; ds:0971
  120A:0299  mov word ptr es:[bx], ax
  120A:029C  pop es
  120A:029D  ret

; ===== func_120A_029E  reg(saves)  callers: C=0 asm=0  seeds=call =====
func_120A_029E:
  120A:029E  push es
  120A:029F  sub bx, bx
  120A:02A1  mov es, bx
  120A:02A3  mov ax, word ptr [0x5ee6]            ; ds:5EE6
  120A:02A6  mov word ptr es:[bx], ax
  120A:02A9  mov ax, word ptr [0x5ee8]            ; ds:5EE8
  120A:02AC  mov word ptr es:[bx + 2], ax
  120A:02B0  pop es
  120A:02B1  ret

; ===== func_120A_02B2  reg  callers: C=0 asm=0  seeds=call =====
func_120A_02B2:
  120A:02B2  mov bx, ax
  120A:02B4  mov cx, word ptr [0x7d5e]            ; ds:7D5E
  120A:02B8  mov ax, word ptr [0x7cdc]            ; ds:7CDC
  120A:02BB  cdq
  120A:02BC  xor ax, dx
  120A:02BE  sub ax, dx
  120A:02C0  inc ax
  120A:02C1  shl ax, 1
  120A:02C3  cmp ax, cx
  120A:02C5  jae loc_120A_0311
  120A:02C7  mov ax, word ptr [0x7cdc]            ; ds:7CDC
  120A:02CA  add ax, bx
  120A:02CC  mov dx, ax
  120A:02CE  sub bx, bx
  120A:02D0  mov bp, dx
  120A:02D2  add bx, word ptr [0x7cda]            ; ds:7CDA
  120A:02D6  adc bp, word ptr [0x7cdc]            ; ds:7CDC
  120A:02DA  js loc_120A_0311
  120A:02DC  mov ax, word ptr [0x7cd2]            ; ds:7CD2
  120A:02DF  mov dx, word ptr [0x7cd4]            ; ds:7CD4
  120A:02E3  or dx, dx
  120A:02E5  jns loc_120A_02F1
  120A:02E7  not ax
  120A:02E9  not dx
  120A:02EB  add ax, 1
  120A:02EE  adc dx, 0
loc_120A_02F1:    ; <- jcc:120A:02E5
  120A:02F1  cmp dx, bp
  120A:02F3  ja loc_120A_0311
  120A:02F5  mov ax, word ptr [0x7cd6]            ; ds:7CD6
  120A:02F8  mov dx, word ptr [0x7cd8]            ; ds:7CD8
  120A:02FC  or dx, dx
  120A:02FE  jns loc_120A_030A
  120A:0300  not ax
  120A:0302  not dx
  120A:0304  add ax, 1
  120A:0307  adc dx, 0
loc_120A_030A:    ; <- jcc:120A:02FE
  120A:030A  cmp dx, bp
  120A:030C  ja loc_120A_0311
  120A:030E  sub ax, ax
  120A:0310  ret
loc_120A_0311:    ; <- jcc:120A:02C5 jcc:120A:02DA jcc:120A:02F3 jcc:120A:030C
  120A:0311  mov ax, 0xffff
  120A:0314  or ax, ax
  120A:0316  ret

; ===== func_120A_0317  reg  callers: C=0 asm=0  seeds=call =====
func_120A_0317:
  120A:0317  mov word ptr [0x7d58], cx            ; ds:7D58
  120A:031B  mov ax, word ptr [0x7ccc]            ; ds:7CCC
  120A:031E  neg ax
  120A:0320  mov word ptr [0x7c6c], ax            ; ds:7C6C
  120A:0323  mov ax, word ptr [0x7cce]            ; ds:7CCE
  120A:0326  neg ax
  120A:0328  mov word ptr [0x7c6e], ax            ; ds:7C6E
  120A:032B  mov ax, word ptr [0x7cd0]            ; ds:7CD0
  120A:032E  neg ax
  120A:0330  mov word ptr [0x7c70], ax            ; ds:7C70
  120A:0333  cmp cx, 0
  120A:0336  jg loc_120A_0340
  120A:0338  lea ax, [0x7b28]                     ; ds:7B28
  120A:033C  mov word ptr [0x7d50], ax            ; ds:7D50
  120A:033F  ret
loc_120A_0340:    ; <- jcc:120A:0336
  120A:0340  mov bp, cx
  120A:0342  lea bx, [0x7b4c]                     ; ds:7B4C
  120A:0346  mov word ptr [0x7d50], bx            ; ds:7D50
  120A:034A  lea di, [0x7b28]                     ; ds:7B28
  120A:034E  mov bx, word ptr [0x7d4c]            ; ds:7D4C
  120A:0352  jmp loc_120A_038C

; ----- data 120A:0354 .. 120A:0354 (1 bytes) -----
;   120A:0354  90                                               .
loc_120A_0355:    ; <- jcc:120A:03AF
  120A:0355  mov bl, byte ptr es:[si]
  120A:0358  sub bh, bh
  120A:035A  shl bx, 1
  120A:035C  add bx, word ptr [0x7d4e]            ; ds:7D4E
  120A:0360  mov bx, word ptr [bx]
  120A:0362  sub ax, ax
  120A:0364  sub dx, dx
  120A:0366  cmp byte ptr es:[si + 1], 1
  120A:036B  je loc_120A_0371
  120A:036D  xchg bx, ax
  120A:036E  jl loc_120A_0371
  120A:0370  xchg dx, ax
loc_120A_0371:    ; <- jcc:120A:036B jcc:120A:036E
  120A:0371  add si, 2
  120A:0374  mov di, word ptr [0x7d50]            ; ds:7D50
  120A:0378  add di, 0x24
  120A:037B  push di
  120A:037C  push dx
  120A:037D  push bx
  120A:037E  push ax
  120A:037F  call far func_1452_03AB              ; -> 1452:03AB
  120A:0384  add sp, 6
  120A:0387  pop bx
  120A:0388  lea di, [0x7b4c]                     ; ds:7B4C
loc_120A_038C:    ; <- jmp:120A:0352
  120A:038C  push word ptr [0x7d50]               ; ds:7D50
  120A:0390  push di
  120A:0391  push bx
  120A:0392  call far func_1452_0288              ; -> 1452:0288
  120A:0397  pop bx
  120A:0398  add sp, 2
  120A:039B  pop di
  120A:039C  add di, 0x12
  120A:039F  push di
  120A:03A0  push bx
  120A:03A1  call far func_1452_02E4              ; -> 1452:02E4
  120A:03A6  add sp, 4
  120A:03A9  add word ptr [0x7d50], 0x24          ; ds:7D50
  120A:03AE  dec bp
  120A:03AF  jne loc_120A_0355
  120A:03B1  lea bx, [0x7b4c]                     ; ds:7B4C
  120A:03B5  mov word ptr [0x7d50], bx            ; ds:7D50
  120A:03B9  mov ax, word ptr [0x7cd2]            ; ds:7CD2
  120A:03BC  mov word ptr [0x7cde], ax            ; ds:7CDE
  120A:03BF  mov ax, word ptr [0x7cd4]            ; ds:7CD4
  120A:03C2  mov word ptr [0x7ce0], ax            ; ds:7CE0
  120A:03C5  mov ax, word ptr [0x7cd6]            ; ds:7CD6
  120A:03C8  mov word ptr [0x7ce2], ax            ; ds:7CE2
  120A:03CB  mov ax, word ptr [0x7cd8]            ; ds:7CD8
  120A:03CE  mov word ptr [0x7ce4], ax            ; ds:7CE4
  120A:03D1  mov ax, word ptr [0x7cda]            ; ds:7CDA
  120A:03D4  mov word ptr [0x7ce6], ax            ; ds:7CE6
  120A:03D7  mov ax, word ptr [0x7cdc]            ; ds:7CDC
  120A:03DA  mov word ptr [0x7ce8], ax            ; ds:7CE8
  120A:03DD  lea ax, [0x7cde]                     ; ds:7CDE
  120A:03E1  mov word ptr [0x7d56], ax            ; ds:7D56
  120A:03E4  mov bp, word ptr [0x7d58]            ; ds:7D58
  120A:03E8  lea bx, [0x7c6c]                     ; ds:7C6C
  120A:03EC  lea di, [0x7b5e]                     ; ds:7B5E
  120A:03F0  push di
  120A:03F1  push bx
  120A:03F2  call far func_1452_021B              ; -> 1452:021B
  120A:03F7  pop bx
  120A:03F8  pop di
  120A:03F9  call func_120A_04C9
  120A:03FC  jmp loc_120A_042D

; ----- data 120A:03FE .. 120A:03FE (1 bytes) -----
;   120A:03FE  90                                               .
loc_120A_03FF:    ; <- jcc:120A:0439
  120A:03FF  call func_120A_043C
  120A:0402  mov ax, word ptr [0x7c6c]            ; ds:7C6C
  120A:0405  sub ax, word ptr es:[si]
  120A:0408  mov word ptr [bx], ax
  120A:040A  mov ax, word ptr [0x7c6e]            ; ds:7C6E
  120A:040D  sub ax, word ptr es:[si + 2]
  120A:0411  mov word ptr [bx + 2], ax
  120A:0414  mov ax, word ptr [0x7c70]            ; ds:7C70
  120A:0417  sub ax, word ptr es:[si + 4]
  120A:041B  mov word ptr [bx + 4], ax
  120A:041E  add si, 6
  120A:0421  push di
  120A:0422  push bx
  120A:0423  call far func_1452_021B              ; -> 1452:021B
  120A:0428  pop bx
  120A:0429  pop di
  120A:042A  call func_120A_04F5
loc_120A_042D:    ; <- jmp:120A:03FC
  120A:042D  add word ptr [0x7d56], 0xc           ; ds:7D56
  120A:0432  add bx, 6
  120A:0435  add di, 0x24
  120A:0438  dec bp
  120A:0439  jne loc_120A_03FF
  120A:043B  ret

; ===== func_120A_043C  reg  callers: C=0 asm=0  seeds=call =====
func_120A_043C:
  120A:043C  mov ax, word ptr es:[si]
  120A:043F  mov word ptr [bx], ax
  120A:0441  mov ax, word ptr es:[si + 2]
  120A:0445  mov word ptr [bx + 2], ax
  120A:0448  mov ax, word ptr es:[si + 4]
  120A:044C  mov word ptr [bx + 4], ax
  120A:044F  lea ax, [0x7d3e]                     ; ds:7D3E
  120A:0453  push ax
  120A:0454  push word ptr [0x7d50]               ; ds:7D50
  120A:0458  push bx
  120A:0459  call far func_1452_0330              ; -> 1452:0330
  120A:045E  pop bx
  120A:045F  add sp, 4
  120A:0462  neg word ptr [bx]
  120A:0464  neg word ptr [bx + 2]
  120A:0467  neg word ptr [bx + 4]
  120A:046A  push word ptr [0x7d56]               ; ds:7D56
  120A:046E  mov ax, di
  120A:0470  sub ax, 0x12
  120A:0473  push ax
  120A:0474  push bx
  120A:0475  call far func_1452_0330              ; -> 1452:0330
  120A:047A  mov bx, word ptr [0x7d56]            ; ds:7D56
  120A:047E  mov ax, word ptr [0x7cd2]            ; ds:7CD2
  120A:0481  add word ptr [bx], ax
  120A:0483  mov ax, word ptr [0x7cd4]            ; ds:7CD4
  120A:0486  adc word ptr [bx + 2], ax
  120A:0489  mov ax, word ptr [0x7d3e]            ; ds:7D3E
  120A:048C  add word ptr [bx], ax
  120A:048E  mov ax, word ptr [0x7d40]            ; ds:7D40
  120A:0491  adc word ptr [bx + 2], ax
  120A:0494  mov ax, word ptr [0x7cd6]            ; ds:7CD6
  120A:0497  add word ptr [bx + 4], ax
  120A:049A  mov ax, word ptr [0x7cd8]            ; ds:7CD8
  120A:049D  adc word ptr [bx + 6], ax
  120A:04A0  mov ax, word ptr [0x7d42]            ; ds:7D42
  120A:04A3  add word ptr [bx + 4], ax
  120A:04A6  mov ax, word ptr [0x7d44]            ; ds:7D44
  120A:04A9  adc word ptr [bx + 6], ax
  120A:04AC  mov ax, word ptr [0x7cda]            ; ds:7CDA
  120A:04AF  add word ptr [bx + 8], ax
  120A:04B2  mov ax, word ptr [0x7cdc]            ; ds:7CDC
  120A:04B5  adc word ptr [bx + 0xa], ax
  120A:04B8  mov ax, word ptr [0x7d46]            ; ds:7D46
  120A:04BB  add word ptr [bx + 8], ax
  120A:04BE  mov ax, word ptr [0x7d48]            ; ds:7D48
  120A:04C1  adc word ptr [bx + 0xa], ax
  120A:04C4  pop bx
  120A:04C5  add sp, 4
  120A:04C8  ret

; ===== func_120A_04C9  reg(saves)  callers: C=0 asm=0  seeds=call =====
func_120A_04C9:
  120A:04C9  push bx
  120A:04CA  lea bx, [0x7c9c]                     ; ds:7C9C
  120A:04CE  mov word ptr [0x7d7c], bx            ; ds:7D7C
  120A:04D2  mov ax, word ptr [0x7d84]            ; ds:7D84
  120A:04D5  mov word ptr [bx], ax
  120A:04D7  mov ax, word ptr [0x7d86]            ; ds:7D86
  120A:04DA  mov word ptr [bx + 2], ax
  120A:04DD  mov ax, word ptr [0x7d88]            ; ds:7D88
  120A:04E0  mov word ptr [bx + 4], ax
  120A:04E3  push di
  120A:04E4  push bx
  120A:04E5  call far func_1452_021B              ; -> 1452:021B
  120A:04EA  add sp, 2
  120A:04ED  pop di
  120A:04EE  pop bx
  120A:04EF  add word ptr [0x7d7c], 6             ; ds:7D7C
  120A:04F4  ret

; ===== func_120A_04F5  reg(saves)  callers: C=0 asm=0  seeds=call =====
func_120A_04F5:
  120A:04F5  push bx
  120A:04F6  mov bx, word ptr [0x7d7c]            ; ds:7D7C
  120A:04FA  mov ax, word ptr [0x7c9c]            ; ds:7C9C
  120A:04FD  mov word ptr [bx], ax
  120A:04FF  mov ax, word ptr [0x7c9e]            ; ds:7C9E
  120A:0502  mov word ptr [bx + 2], ax
  120A:0505  mov ax, word ptr [0x7ca0]            ; ds:7CA0
  120A:0508  mov word ptr [bx + 4], ax
  120A:050B  push di
  120A:050C  push bx
  120A:050D  call far func_1452_021B              ; -> 1452:021B
  120A:0512  add sp, 2
  120A:0515  pop di
  120A:0516  pop bx
  120A:0517  add word ptr [0x7d7c], 6             ; ds:7D7C
  120A:051C  ret
loc_120A_051D:    ; <- jcc:120A:0597
  120A:051D  push bx
  120A:051E  mov bl, byte ptr es:[si]
  120A:0521  and bx, 0x1f
  120A:0524  shl bx, 1
  120A:0526  add bx, word ptr [0x7d4e]            ; ds:7D4E
  120A:052A  mov al, byte ptr es:[si + 1]
  120A:052E  add si, 2
  120A:0531  cwde
  120A:0532  cmp ax, word ptr [bx]
  120A:0534  pop bx
  120A:0535  je loc_120A_0589
  120A:0537  mov byte ptr [0x7d68], 0x7f          ; ds:7D68
  120A:053C  nop
  120A:053D  jmp loc_120A_0589

; ----- data 120A:053F .. 120A:053F (1 bytes) -----
;   120A:053F  90                                               .
loc_120A_0540:    ; <- jcc:120A:0592
  120A:0540  and ax, 0xff
  120A:0543  lea bx, [0x7c6c]                     ; ds:7C6C
  120A:0547  shl ax, 1
  120A:0549  mov word ptr [0x7d7c], ax            ; ds:7D7C
  120A:054C  add bx, ax
  120A:054E  shl ax, 1
  120A:0550  add bx, ax
  120A:0552  add word ptr [0x7d7c], ax            ; ds:7D7C
  120A:0556  lea ax, [0x7c9c]                     ; ds:7C9C
  120A:055A  add word ptr [0x7d7c], ax            ; ds:7D7C
  120A:055E  jmp loc_120A_0589

; ----- data 120A:0560 .. 120A:0560 (1 bytes) -----
;   120A:0560  90                                               .

; ===== func_120A_0561  reg  callers: C=0 asm=0  seeds=call =====
func_120A_0561:
  120A:0561  mov ax, word ptr es:[si]
  120A:0564  add si, 2
  120A:0567  mov word ptr [0x7d5a], ax            ; ds:7D5A
  120A:056A  or ax, ax
  120A:056C  jne loc_120A_056F
  120A:056E  ret
loc_120A_056F:    ; <- jcc:120A:056C
  120A:056F  cdq
  120A:0570  xor ax, dx
  120A:0572  sub ax, dx
  120A:0574  mov cx, ax
  120A:0576  sub di, di
  120A:0578  lea bx, [0x7c6c]                     ; ds:7C6C
  120A:057C  lea ax, [0x7c9c]                     ; ds:7C9C
  120A:0580  mov word ptr [0x7d7c], ax            ; ds:7D7C
loc_120A_0583:    ; <- jcc:120A:05FA
  120A:0583  mov byte ptr [0x7d68], 0xff          ; ds:7D68
  120A:0588  nop
loc_120A_0589:    ; <- jcc:120A:0535 jmp:120A:053D jmp:120A:055E
  120A:0589  mov ax, word ptr es:[si]
  120A:058C  add si, 2
  120A:058F  cmp ah, 0x80
  120A:0592  je loc_120A_0540
  120A:0594  cmp ax, 0x8100
  120A:0597  je loc_120A_051D
  120A:0599  push cx
  120A:059A  imul word ptr [bx]
  120A:059C  mov cx, ax
  120A:059E  mov bp, dx
  120A:05A0  mov ax, word ptr es:[si]
  120A:05A3  add si, 2
  120A:05A6  imul word ptr [bx + 2]
  120A:05A9  add cx, ax
  120A:05AB  adc bp, dx
  120A:05AD  mov ax, word ptr es:[si]
  120A:05B0  add si, 2
  120A:05B3  imul word ptr [bx + 4]
  120A:05B6  add cx, ax
  120A:05B8  adc bp, dx
  120A:05BA  add cx, word ptr es:[si]
  120A:05BD  adc bp, word ptr es:[si + 2]
  120A:05C1  add si, 4
  120A:05C4  mov ax, bp
  120A:05C6  cdq
  120A:05C7  not dx
  120A:05C9  cmp byte ptr [0x7d8e], 0             ; ds:7D8E
  120A:05CE  je loc_120A_05D2
  120A:05D0  mov dl, 0xff
loc_120A_05D2:    ; <- jcc:120A:05CE
  120A:05D2  and dl, byte ptr [0x7d68]            ; ds:7D68
  120A:05D6  mov byte ptr [di + 0x7702], dl
  120A:05DA  jns loc_120A_05F8
  120A:05DC  mov ax, word ptr es:[si - 0xa]
  120A:05E0  or ax, word ptr es:[si - 6]
  120A:05E4  or ax, word ptr es:[si - 4]
  120A:05E8  or ax, word ptr es:[si - 2]
  120A:05EC  jne loc_120A_05F1
  120A:05EE  or dl, 0x80
loc_120A_05F1:    ; <- jcc:120A:05EC
  120A:05F1  or byte ptr [0x7d8c], dl             ; ds:7D8C
  120A:05F5  call func_120A_0674
loc_120A_05F8:    ; <- jcc:120A:05DA
  120A:05F8  inc di
  120A:05F9  pop cx
  120A:05FA  loop loc_120A_0583
  120A:05FC  call func_120A_0654
  120A:05FF  sub bx, bx
  120A:0601  mov ax, word ptr [0x7d5a]            ; ds:7D5A
  120A:0604  cdq
  120A:0605  xor ax, dx
  120A:0607  sub ax, dx
  120A:0609  mov bp, ax
  120A:060B  mov ax, 1
  120A:060E  lea di, [0x7702]                     ; ds:7702
loc_120A_0612:    ; <- jcc:120A:0632
  120A:0612  mov cl, byte ptr es:[si]
  120A:0615  inc si
  120A:0616  and cx, 0xff
  120A:061A  je loc_120A_0630
  120A:061C  cmp byte ptr [di], 0x7f
  120A:061F  ja loc_120A_0626
  120A:0621  add si, cx
  120A:0623  jmp loc_120A_0630

; ----- data 120A:0625 .. 120A:0625 (1 bytes) -----
;   120A:0625  90                                               .
loc_120A_0626:    ; <- jcc:120A:061F jcc:120A:062E
  120A:0626  mov bl, byte ptr es:[si]
  120A:0629  inc si
  120A:062A  mov byte ptr [bx + 0x7a02], al
  120A:062E  loop loc_120A_0626
loc_120A_0630:    ; <- jcc:120A:061A jmp:120A:0623
  120A:0630  inc di
  120A:0631  dec bp
  120A:0632  jne loc_120A_0612
  120A:0634  cmp word ptr [0x7d5a], 0             ; ds:7D5A
  120A:0639  js loc_120A_063C
  120A:063B  ret
loc_120A_063C:    ; <- jcc:120A:0639
  120A:063C  lea di, [0x7902]                     ; ds:7902
  120A:0640  lea bx, [0x7702]                     ; ds:7702
  120A:0644  push si
  120A:0645  call func_120A_0E5B
  120A:0648  pop si
  120A:0649  mov ax, word ptr [0x7d5a]            ; ds:7D5A
  120A:064C  neg ax
  120A:064E  shl ax, 1
  120A:0650  inc ax
  120A:0651  add si, ax
  120A:0653  ret

; ===== func_120A_0654  reg  callers: C=0 asm=0  seeds=call =====
func_120A_0654:
  120A:0654  mov ax, word ptr [0x7d5c]            ; ds:7D5C
  120A:0657  cdq
  120A:0658  xor ax, dx
  120A:065A  sub ax, dx
  120A:065C  mov cx, ax
  120A:065E  sub ax, ax
  120A:0660  push es
  120A:0661  mov di, ds
  120A:0663  mov es, di
  120A:0665  lea di, [0x7a02]                     ; ds:7A02
  120A:0669  sub ax, ax
  120A:066B  add cx, 2
  120A:066E  shr cx, 1
  120A:0670  rep stosw word ptr es:[di], ax
  120A:0672  pop es
  120A:0673  ret

; ===== func_120A_0674  reg(saves)  callers: C=0 asm=0  seeds=call =====
func_120A_0674:
  120A:0674  push bx
  120A:0675  mov bx, word ptr [0x7d7c]            ; ds:7D7C
  120A:0679  sub si, 0xa
  120A:067C  mov ax, word ptr es:[si]
  120A:067F  add si, 2
  120A:0682  imul word ptr [bx]
  120A:0684  mov cx, ax
  120A:0686  mov bp, dx
  120A:0688  mov ax, word ptr es:[si]
  120A:068B  add si, 2
  120A:068E  imul word ptr [bx + 2]
  120A:0691  add cx, ax
  120A:0693  adc bp, dx
  120A:0695  mov ax, word ptr es:[si]
  120A:0698  add si, 2
  120A:069B  imul word ptr [bx + 4]
  120A:069E  add cx, ax
  120A:06A0  adc bp, dx
  120A:06A2  shl cx, 1
  120A:06A4  rcl bp, 1
  120A:06A6  shl cx, 1
  120A:06A8  rcl bp, 1
  120A:06AA  mov ax, bp
  120A:06AC  add si, 4
  120A:06AF  mov byte ptr [di + 0x7802], al
  120A:06B3  pop bx
  120A:06B4  ret

; ===== func_120A_06B5  reg  callers: C=0 asm=0  seeds=call =====
func_120A_06B5:
  120A:06B5  sub di, di
  120A:06B7  mov bx, word ptr [0x7d50]            ; ds:7D50
  120A:06BB  mov cx, word ptr [0x7d5c]            ; ds:7D5C
  120A:06BF  cmp cx, 0
  120A:06C2  je loc_120A_06E1
  120A:06C4  jns loc_120A_06C9
  120A:06C6  jmp loc_120A_075A
loc_120A_06C9:    ; <- jcc:120A:06C4
  120A:06C9  lea di, [0xc6b4]                     ; ds:C6B4
  120A:06CD  lea bp, [0xd6b4]                     ; ds:D6B4
  120A:06D1  mov word ptr [0x7d4a], di            ; ds:7D4A
  120A:06D5  cmp word ptr [0x7d5a], 0             ; ds:7D5A
  120A:06DA  jne loc_120A_072A
loc_120A_06DC:    ; <- jcc:120A:06DF
  120A:06DC  call func_120A_0815
  120A:06DF  loop loc_120A_06DC
loc_120A_06E1:    ; <- jcc:120A:06C2
  120A:06E1  ret
loc_120A_06E2:    ; <- jcc:120A:0737
  120A:06E2  and ax, 0xf
  120A:06E5  push di
  120A:06E6  lea di, [0x7cde]                     ; ds:7CDE
  120A:06EA  mov bx, word ptr [0x7d50]            ; ds:7D50
  120A:06EE  shl ax, 1
  120A:06F0  shl ax, 1
  120A:06F2  add bx, ax
  120A:06F4  add di, ax
  120A:06F6  shl ax, 1
  120A:06F8  add di, ax
  120A:06FA  shl ax, 1
  120A:06FC  shl ax, 1
  120A:06FE  add bx, ax
  120A:0700  add si, 2
  120A:0703  mov ax, word ptr [di]
  120A:0705  mov word ptr [0x7cd2], ax            ; ds:7CD2
  120A:0708  mov ax, word ptr [di + 2]
  120A:070B  mov word ptr [0x7cd4], ax            ; ds:7CD4
  120A:070E  mov ax, word ptr [di + 4]
  120A:0711  mov word ptr [0x7cd6], ax            ; ds:7CD6
  120A:0714  mov ax, word ptr [di + 6]
  120A:0717  mov word ptr [0x7cd8], ax            ; ds:7CD8
  120A:071A  mov ax, word ptr [di + 8]
  120A:071D  mov word ptr [0x7cda], ax            ; ds:7CDA
  120A:0720  mov ax, word ptr [di + 0xa]
  120A:0723  mov word ptr [0x7cdc], ax            ; ds:7CDC
  120A:0726  pop di
  120A:0727  jmp loc_120A_072C

; ----- data 120A:0729 .. 120A:0729 (1 bytes) -----
;   120A:0729  90                                               .
loc_120A_072A:    ; <- jcc:120A:06DA
  120A:072A  sub dx, dx
loc_120A_072C:    ; <- jcc:120A:074A jcc:120A:0757 jmp:120A:0727
  120A:072C  mov ax, word ptr es:[si]
  120A:072F  cmp ax, 0x8000
  120A:0732  jb loc_120A_0739
  120A:0734  cmp ax, 0x8010
  120A:0737  jb loc_120A_06E2
loc_120A_0739:    ; <- jcc:120A:0732
  120A:0739  xchg dx, bx
  120A:073B  cmp byte ptr [bx + 0x7a02], 0
  120A:0740  xchg bx, dx
  120A:0742  je loc_120A_074D
  120A:0744  push dx
  120A:0745  call func_120A_0815
  120A:0748  pop dx
  120A:0749  inc dx
  120A:074A  loop loc_120A_072C
  120A:074C  ret
loc_120A_074D:    ; <- jcc:120A:0742
  120A:074D  add bp, 8
  120A:0750  add di, 0x10
  120A:0753  add si, 6
  120A:0756  inc dx
  120A:0757  loop loc_120A_072C
  120A:0759  ret
loc_120A_075A:    ; <- jmp:120A:06C6
  120A:075A  neg cx
  120A:075C  lea di, [0xc6b4]                     ; ds:C6B4
  120A:0760  mov word ptr [0x7d4a], di            ; ds:7D4A
loc_120A_0764:    ; <- jcc:120A:07C5
  120A:0764  mov al, byte ptr es:[si]
  120A:0767  sub ah, ah
  120A:0769  shl ax, 1
  120A:076B  shl ax, 1
  120A:076D  shl ax, 1
  120A:076F  mov bp, ax
  120A:0771  shl ax, 1
  120A:0773  lea bx, [0x4ee6]                     ; ds:4EE6
  120A:0777  lea di, [0xc6b4]                     ; ds:C6B4
  120A:077B  add bx, ax
  120A:077D  add di, ax
  120A:077F  mov ax, word ptr [bx]
  120A:0781  mov dx, word ptr [bx + 2]
  120A:0784  add ax, word ptr [0x7cd2]            ; ds:7CD2
  120A:0788  adc dx, word ptr [0x7cd4]            ; ds:7CD4
  120A:078C  mov word ptr [di], ax
  120A:078E  mov word ptr [di + 2], dx
  120A:0791  mov ax, word ptr [bx + 4]
  120A:0794  mov dx, word ptr [bx + 6]
  120A:0797  add ax, word ptr [0x7cd6]            ; ds:7CD6
  120A:079B  adc dx, word ptr [0x7cd8]            ; ds:7CD8
  120A:079F  mov word ptr [di + 4], ax
  120A:07A2  mov word ptr [di + 6], dx
  120A:07A5  mov ax, word ptr [bx + 8]
  120A:07A8  mov dx, word ptr [bx + 0xa]
  120A:07AB  add ax, word ptr [0x7cda]            ; ds:7CDA
  120A:07AF  adc dx, word ptr [0x7cdc]            ; ds:7CDC
  120A:07B3  mov word ptr [di + 8], ax
  120A:07B6  mov word ptr [di + 0xa], dx
  120A:07B9  lea bx, [0xd6b4]                     ; ds:D6B4
  120A:07BD  add bx, bp
  120A:07BF  push cx
  120A:07C0  call func_120A_0902
  120A:07C3  inc si
  120A:07C4  pop cx
  120A:07C5  loop loc_120A_0764
  120A:07C7  ret
loc_120A_07C8:    ; <- jcc:120A:0824
  120A:07C8  pop bp
  120A:07C9  pop bx
  120A:07CA  pop si
  120A:07CB  sub ah, ah
  120A:07CD  push di
  120A:07CE  lea di, [0x7cde]                     ; ds:7CDE
  120A:07D2  mov bx, word ptr [0x7d50]            ; ds:7D50
  120A:07D6  shl ax, 1
  120A:07D8  shl ax, 1
  120A:07DA  add di, ax
  120A:07DC  add bx, ax
  120A:07DE  shl ax, 1
  120A:07E0  add di, ax
  120A:07E2  shl ax, 1
  120A:07E4  shl ax, 1
  120A:07E6  add bx, ax
  120A:07E8  add si, 2
  120A:07EB  mov ax, word ptr [di]
  120A:07ED  mov word ptr [0x7cd2], ax            ; ds:7CD2
  120A:07F0  mov ax, word ptr [di + 2]
  120A:07F3  mov word ptr [0x7cd4], ax            ; ds:7CD4
  120A:07F6  mov ax, word ptr [di + 4]
  120A:07F9  mov word ptr [0x7cd6], ax            ; ds:7CD6
  120A:07FC  mov ax, word ptr [di + 6]
  120A:07FF  mov word ptr [0x7cd8], ax            ; ds:7CD8
  120A:0802  mov ax, word ptr [di + 8]
  120A:0805  mov word ptr [0x7cda], ax            ; ds:7CDA
  120A:0808  mov ax, word ptr [di + 0xa]
  120A:080B  mov word ptr [0x7cdc], ax            ; ds:7CDC
  120A:080E  pop di
  120A:080F  push si
  120A:0810  push bx
  120A:0811  push bp
  120A:0812  jmp loc_120A_0819

; ----- data 120A:0814 .. 120A:0814 (1 bytes) -----
;   120A:0814  90                                               .

; ===== func_120A_0815  reg(saves)  callers: C=0 asm=0  seeds=call =====
func_120A_0815:
  120A:0815  push cx
  120A:0816  push si
  120A:0817  push bx
  120A:0818  push bp
loc_120A_0819:    ; <- jmp:120A:0812
  120A:0819  mov ax, word ptr es:[si]
  120A:081C  cmp ax, 0x8000
  120A:081F  jb loc_120A_0826
  120A:0821  cmp ax, 0x8010
  120A:0824  jb loc_120A_07C8
loc_120A_0826:    ; <- jcc:120A:081F
  120A:0826  mov cx, word ptr es:[si + 2]
  120A:082A  mov si, word ptr es:[si + 4]
  120A:082E  mov bp, ax
  120A:0830  imul word ptr [bx]
  120A:0832  mov word ptr [di], ax
  120A:0834  mov word ptr [di + 2], dx
  120A:0837  mov ax, bp
  120A:0839  imul word ptr [bx + 2]
  120A:083C  mov word ptr [di + 4], ax
  120A:083F  mov word ptr [di + 6], dx
  120A:0842  mov ax, bp
  120A:0844  imul word ptr [bx + 4]
  120A:0847  mov word ptr [di + 8], ax
  120A:084A  mov word ptr [di + 0xa], dx
  120A:084D  mov ax, cx
  120A:084F  imul word ptr [bx + 6]
  120A:0852  add word ptr [di], ax
  120A:0854  adc word ptr [di + 2], dx
  120A:0857  mov ax, cx
  120A:0859  imul word ptr [bx + 8]
  120A:085C  add word ptr [di + 4], ax
  120A:085F  adc word ptr [di + 6], dx
  120A:0862  mov ax, cx
  120A:0864  imul word ptr [bx + 0xa]
  120A:0867  add word ptr [di + 8], ax
  120A:086A  adc word ptr [di + 0xa], dx
  120A:086D  mov ax, si
  120A:086F  imul word ptr [bx + 0xc]
  120A:0872  add ax, word ptr [0x7cd2]            ; ds:7CD2
  120A:0876  adc dx, word ptr [0x7cd4]            ; ds:7CD4
  120A:087A  add word ptr [di], ax
  120A:087C  adc word ptr [di + 2], dx
  120A:087F  mov ax, si
  120A:0881  imul word ptr [bx + 0xe]
  120A:0884  add ax, word ptr [0x7cd6]            ; ds:7CD6
  120A:0888  adc dx, word ptr [0x7cd8]            ; ds:7CD8
  120A:088C  add word ptr [di + 4], ax
  120A:088F  adc word ptr [di + 6], dx
  120A:0892  mov ax, si
  120A:0894  imul word ptr [bx + 0x10]
  120A:0897  add ax, word ptr [0x7cda]            ; ds:7CDA
  120A:089B  adc dx, word ptr [0x7cdc]            ; ds:7CDC
  120A:089F  add word ptr [di + 8], ax
  120A:08A2  adc word ptr [di + 0xa], dx
  120A:08A5  pop bx
  120A:08A6  push bx
  120A:08A7  call func_120A_0902
  120A:08AA  pop bp
  120A:08AB  pop bx
  120A:08AC  pop si
  120A:08AD  pop cx
  120A:08AE  add bp, 8
  120A:08B1  add di, 0x10
  120A:08B4  add si, 6
  120A:08B7  ret
loc_120A_08B8:    ; <- jmp:120A:08DF
  120A:08B8  mov ch, cl
  120A:08BA  mov cl, 0x10
  120A:08BC  sub cl, ch
  120A:08BE  mov ax, word ptr [di + 2]
  120A:08C1  shl ax, cl
  120A:08C3  cdq
  120A:08C4  mov word ptr [bx], ax
  120A:08C6  mov word ptr [bx + 2], dx
  120A:08C9  mov ax, word ptr [di + 6]
  120A:08CC  shl ax, cl
  120A:08CE  cdq
  120A:08CF  mov word ptr [bx + 4], ax
  120A:08D2  mov word ptr [bx + 6], dx
  120A:08D5  ret
loc_120A_08D6:    ; <- jcc:120A:0907
  120A:08D6  mov cl, byte ptr [0x7d8e]            ; ds:7D8E
  120A:08DA  cmp cl, 0x10
  120A:08DD  jge loc_120A_08E1
  120A:08DF  jmp loc_120A_08B8
loc_120A_08E1:    ; <- jcc:120A:08DD
  120A:08E1  and cl, 0xf
  120A:08E4  mov ax, word ptr [di + 2]
  120A:08E7  sar ax, cl
  120A:08E9  jae loc_120A_08EC
  120A:08EB  inc ax
loc_120A_08EC:    ; <- jcc:120A:08E9
  120A:08EC  cdq
  120A:08ED  mov word ptr [bx], ax
  120A:08EF  mov word ptr [bx + 2], dx
  120A:08F2  mov ax, word ptr [di + 6]
  120A:08F5  sar ax, cl
  120A:08F7  jae loc_120A_08FA
  120A:08F9  inc ax
loc_120A_08FA:    ; <- jcc:120A:08F7
  120A:08FA  cdq
  120A:08FB  mov word ptr [bx + 4], ax
  120A:08FE  mov word ptr [bx + 6], dx
  120A:0901  ret

; ===== func_120A_0902  reg  callers: C=0 asm=0  seeds=call =====
func_120A_0902:
  120A:0902  cmp byte ptr [0x7d8e], 0             ; ds:7D8E
  120A:0907  jne loc_120A_08D6
  120A:0909  mov cx, word ptr [di + 0xa]
  120A:090C  cmp cx, 0x100
  120A:0910  jl loc_120A_0938
  120A:0912  mov dx, word ptr [di + 1]
  120A:0915  mov al, byte ptr [di + 3]
  120A:0918  cwde
  120A:0919  xchg dx, ax
  120A:091A  idiv cx
  120A:091C  cdq
  120A:091D  or ax, ax
  120A:091F  mov word ptr [bx], ax
  120A:0921  mov word ptr [bx + 2], dx
  120A:0924  mov dx, word ptr [di + 5]
  120A:0927  mov al, byte ptr [di + 7]
  120A:092A  cwde
  120A:092B  xchg dx, ax
  120A:092C  idiv cx
  120A:092E  cdq
  120A:092F  or ax, ax
  120A:0931  mov word ptr [bx + 4], ax
  120A:0934  mov word ptr [bx + 6], dx
  120A:0937  ret
loc_120A_0938:    ; <- jcc:120A:0910
  120A:0938  cmp cx, 1
  120A:093B  jl loc_120A_096B
  120A:093D  mov cx, word ptr [di + 9]
  120A:0940  shr cx, 1
  120A:0942  mov dx, word ptr [di + 2]
  120A:0945  mov ax, word ptr [di]
  120A:0947  sar dx, 1
  120A:0949  rcr ax, 1
  120A:094B  idiv cx
  120A:094D  cdq
  120A:094E  or ax, ax
  120A:0950  mov word ptr [bx], ax
  120A:0952  mov word ptr [bx + 2], dx
  120A:0955  mov dx, word ptr [di + 6]
  120A:0958  mov ax, word ptr [di + 4]
  120A:095B  sar dx, 1
  120A:095D  rcr ax, 1
  120A:095F  idiv cx
  120A:0961  cdq
  120A:0962  or ax, ax
  120A:0964  mov word ptr [bx + 4], ax
  120A:0967  mov word ptr [bx + 6], dx
  120A:096A  ret
loc_120A_096B:    ; <- jcc:120A:093B
  120A:096B  mov word ptr [bx + 2], 0x8000
  120A:0970  ret

; ===== func_120A_0971  bp-frame  callers: C=0 asm=0  seeds=isr =====
func_120A_0971:
  120A:0971  push bp
  120A:0972  mov bp, sp
  120A:0974  add word ptr [bp + 2], 3
  120A:0978  xchg dx, ax
  120A:0979  mov dl, dh
  120A:097B  mov dh, al
  120A:097D  mov al, ah
  120A:097F  cwde
  120A:0980  xchg dx, ax
  120A:0981  idiv cx
  120A:0983  cdq
  120A:0984  mov dl, ah
  120A:0986  mov ah, al
  120A:0988  sub al, al
  120A:098A  pop bp
  120A:098B  iret

; ===== func_120A_098C  bp-frame  callers: C=0 asm=2  seeds=far =====
func_120A_098C:
  120A:098C  push bp
  120A:098D  mov bp, sp
loc_120A_098F:    ; <- jmp:120A:0A2E
  120A:098F  mov ax, word ptr [bp + 6]
  120A:0992  mov dx, word ptr [bp + 8]
  120A:0995  add ax, word ptr [bp + 0x12]
  120A:0998  adc dx, word ptr [bp + 0x14]
  120A:099B  add ax, 1
  120A:099E  adc dx, 0
  120A:09A1  sar dx, 1
  120A:09A3  rcr ax, 1
  120A:09A5  mov word ptr [0x7d72], ax            ; ds:7D72
  120A:09A8  mov word ptr [0x7d74], dx            ; ds:7D74
  120A:09AC  mov ax, word ptr [bp + 0xa]
  120A:09AF  mov dx, word ptr [bp + 0xc]
  120A:09B2  add ax, word ptr [bp + 0x16]
  120A:09B5  adc dx, word ptr [bp + 0x18]
  120A:09B8  add ax, 1
  120A:09BB  adc dx, 0
  120A:09BE  sar dx, 1
  120A:09C0  rcr ax, 1
  120A:09C2  mov word ptr [0x7d76], ax            ; ds:7D76
  120A:09C5  mov word ptr [0x7d78], dx            ; ds:7D78
  120A:09C9  mov ax, word ptr [bp + 0xe]
  120A:09CC  mov dx, word ptr [bp + 0x10]
  120A:09CF  add ax, word ptr [bp + 0x1a]
  120A:09D2  adc dx, word ptr [bp + 0x1c]
  120A:09D5  add ax, 1
  120A:09D8  adc dx, 0
  120A:09DB  sar dx, 1
  120A:09DD  rcr ax, 1
  120A:09DF  mov cx, dx
  120A:09E1  cmp cx, 1
  120A:09E4  jbe loc_120A_0A31
  120A:09E6  dec dx
  120A:09E7  js loc_120A_0A0D
  120A:09E9  inc dx
  120A:09EA  mov word ptr [bp + 0xe], ax
  120A:09ED  mov word ptr [bp + 0x10], dx
  120A:09F0  mov ax, word ptr [0x7d72]            ; ds:7D72
  120A:09F3  mov dx, word ptr [0x7d74]            ; ds:7D74
  120A:09F7  mov word ptr [bp + 6], ax
  120A:09FA  mov word ptr [bp + 8], dx
  120A:09FD  mov ax, word ptr [0x7d76]            ; ds:7D76
  120A:0A00  mov dx, word ptr [0x7d78]            ; ds:7D78
  120A:0A04  mov word ptr [bp + 0xa], ax
  120A:0A07  mov word ptr [bp + 0xc], dx
  120A:0A0A  jmp loc_120A_0A2E

; ----- data 120A:0A0C .. 120A:0A0C (1 bytes) -----
;   120A:0A0C  90                                               .
loc_120A_0A0D:    ; <- jcc:120A:09E7
  120A:0A0D  inc dx
  120A:0A0E  mov word ptr [bp + 0x1a], ax
  120A:0A11  mov word ptr [bp + 0x1c], dx
  120A:0A14  mov ax, word ptr [0x7d72]            ; ds:7D72
  120A:0A17  mov dx, word ptr [0x7d74]            ; ds:7D74
  120A:0A1B  mov word ptr [bp + 0x12], ax
  120A:0A1E  mov word ptr [bp + 0x14], dx
  120A:0A21  mov ax, word ptr [0x7d76]            ; ds:7D76
  120A:0A24  mov dx, word ptr [0x7d78]            ; ds:7D78
  120A:0A28  mov word ptr [bp + 0x16], ax
  120A:0A2B  mov word ptr [bp + 0x18], dx
loc_120A_0A2E:    ; <- jmp:120A:0A0A
  120A:0A2E  jmp loc_120A_098F
loc_120A_0A31:    ; <- jcc:120A:09E4
  120A:0A31  pop bp
  120A:0A32  retf

; ===== func_120A_0A33  reg  callers: C=0 asm=0  seeds=call =====
func_120A_0A33:
  120A:0A33  lea bp, [0x5eea]                     ; ds:5EEA
  120A:0A37  mov cx, word ptr es:[si]
  120A:0A3A  add si, 2
  120A:0A3D  jcxz loc_120A_0A7C
loc_120A_0A3F:    ; <- jcc:120A:0A7A
  120A:0A3F  mov di, word ptr es:[si]
  120A:0A42  add si, 2
  120A:0A45  mov bx, di
  120A:0A47  mov bl, bh
  120A:0A49  and di, 0xff
  120A:0A4D  and bx, 0xff
  120A:0A51  cmp word ptr [0x7d5a], 0             ; ds:7D5A
  120A:0A56  je loc_120A_0A62
  120A:0A58  mov al, byte ptr [di + 0x7a02]
  120A:0A5C  and al, byte ptr [bx + 0x7a02]
  120A:0A60  je loc_120A_0A77
loc_120A_0A62:    ; <- jcc:120A:0A56
  120A:0A62  shl di, 1
  120A:0A64  shl bx, 1
  120A:0A66  shl di, 1
  120A:0A68  shl bx, 1
  120A:0A6A  shl di, 1
  120A:0A6C  shl bx, 1
  120A:0A6E  push cx
  120A:0A6F  push bp
  120A:0A70  push si
  120A:0A71  call func_120A_0B3B
  120A:0A74  pop si
  120A:0A75  pop bp
  120A:0A76  pop cx
loc_120A_0A77:    ; <- jcc:120A:0A60
  120A:0A77  add bp, 0x18
  120A:0A7A  loop loc_120A_0A3F
loc_120A_0A7C:    ; <- jcc:120A:0A3D
  120A:0A7C  ret
loc_120A_0A7D:    ; <- jmp:120A:0B50
  120A:0A7D  mov ax, word ptr [di - 0x294c]
  120A:0A81  mov dx, word ptr [di - 0x294a]
  120A:0A85  add ax, word ptr [0x8602]            ; ds:8602
  120A:0A89  adc dx, 0
  120A:0A8C  mov word ptr [si], ax
  120A:0A8E  mov word ptr [si + 2], dx
  120A:0A91  mov ax, word ptr [di - 0x2948]
  120A:0A95  mov dx, word ptr [di - 0x2946]
  120A:0A99  add ax, word ptr [0x8604]            ; ds:8604
  120A:0A9D  adc dx, 0
  120A:0AA0  mov word ptr [si + 4], ax
  120A:0AA3  mov word ptr [si + 6], dx
  120A:0AA6  shl di, 1
  120A:0AA8  shl bx, 1
  120A:0AAA  push word ptr [bx - 0x3942]
  120A:0AAE  push word ptr [bx - 0x3944]
  120A:0AB2  push word ptr [bx - 0x3946]
  120A:0AB6  push word ptr [bx - 0x3948]
  120A:0ABA  push word ptr [bx - 0x394a]
  120A:0ABE  push word ptr [bx - 0x394c]
  120A:0AC2  push word ptr [di - 0x3942]
  120A:0AC6  push word ptr [di - 0x3944]
  120A:0ACA  push word ptr [di - 0x3946]
  120A:0ACE  push word ptr [di - 0x3948]
  120A:0AD2  push word ptr [di - 0x394a]
  120A:0AD6  push word ptr [di - 0x394c]
  120A:0ADA  call far func_120A_098C              ; -> 120A:098C
  120A:0ADF  add sp, 0x18
  120A:0AE2  mov ax, word ptr [0x7d74]            ; ds:7D74
  120A:0AE5  mov dx, word ptr [0x7d72]            ; ds:7D72
  120A:0AE9  mov dl, dh
  120A:0AEB  mov dh, al
  120A:0AED  mov al, ah
  120A:0AEF  cwde
  120A:0AF0  xchg dx, ax
  120A:0AF1  shl ax, 1
  120A:0AF3  rcl dx, 1
  120A:0AF5  add ax, word ptr [0x8602]            ; ds:8602
  120A:0AF9  adc dx, 0
  120A:0AFC  mov word ptr [si + 8], ax
  120A:0AFF  mov word ptr [si + 0xa], dx
  120A:0B02  mov word ptr [si + 0x10], ax
  120A:0B05  mov word ptr [si + 0x12], dx
  120A:0B08  mov ax, word ptr [0x7d78]            ; ds:7D78
  120A:0B0B  mov dx, word ptr [0x7d76]            ; ds:7D76
  120A:0B0F  mov dl, dh
  120A:0B11  mov dh, al
  120A:0B13  mov al, ah
  120A:0B15  cwde
  120A:0B16  xchg dx, ax
  120A:0B17  shl ax, 1
  120A:0B19  rcl dx, 1
  120A:0B1B  add ax, word ptr [0x8604]            ; ds:8604
  120A:0B1F  adc dx, 0
  120A:0B22  mov word ptr [si + 0xc], ax
  120A:0B25  mov word ptr [si + 0xe], dx
  120A:0B28  mov word ptr [si + 0x14], ax
  120A:0B2B  mov word ptr [si + 0x16], dx
  120A:0B2E  call far func_130D_033F              ; -> 130D:033F
  120A:0B33  mov al, 0x40
  120A:0B35  mov ah, al
  120A:0B37  or word ptr [si + 2], ax
  120A:0B3A  ret

; ===== func_120A_0B3B  reg  callers: C=0 asm=0  seeds=call =====
func_120A_0B3B:
  120A:0B3B  mov si, bp
  120A:0B3D  mov ax, word ptr [di - 0x294a]
  120A:0B41  mov dx, word ptr [bx - 0x294a]
  120A:0B45  cmp ax, 0x8000
  120A:0B48  je loc_120A_0BB2
  120A:0B4A  cmp dx, 0x8000
  120A:0B4E  jne loc_120A_0B53
  120A:0B50  jmp loc_120A_0A7D
loc_120A_0B53:    ; <- jcc:120A:0B4E
  120A:0B53  lea ax, [0xd6b4]                     ; ds:D6B4
  120A:0B57  add bx, ax
  120A:0B59  add di, ax
  120A:0B5B  mov ax, word ptr [di]
  120A:0B5D  mov dx, word ptr [di + 2]
  120A:0B60  add ax, word ptr [0x8602]            ; ds:8602
  120A:0B64  adc dx, 0
  120A:0B67  mov word ptr [si], ax
  120A:0B69  mov word ptr [si + 2], dx
  120A:0B6C  mov ax, word ptr [di + 4]
  120A:0B6F  mov dx, word ptr [di + 6]
  120A:0B72  add ax, word ptr [0x8604]            ; ds:8604
  120A:0B76  adc dx, 0
  120A:0B79  mov word ptr [si + 4], ax
  120A:0B7C  mov word ptr [si + 6], dx
  120A:0B7F  mov ax, word ptr [bx]
  120A:0B81  mov dx, word ptr [bx + 2]
  120A:0B84  add ax, word ptr [0x8602]            ; ds:8602
  120A:0B88  adc dx, 0
  120A:0B8B  mov word ptr [si + 8], ax
  120A:0B8E  mov word ptr [si + 0xa], dx
  120A:0B91  mov ax, word ptr [bx + 4]
  120A:0B94  mov dx, word ptr [bx + 6]
  120A:0B97  add ax, word ptr [0x8604]            ; ds:8604
  120A:0B9B  adc dx, 0
  120A:0B9E  mov word ptr [si + 0xc], ax
  120A:0BA1  mov word ptr [si + 0xe], dx
  120A:0BA4  call far func_130D_033F              ; -> 130D:033F
  120A:0BA9  ret
loc_120A_0BAA:    ; <- jcc:120A:0BB6
  120A:0BAA  mov al, 0x80
  120A:0BAC  mov ah, al
  120A:0BAE  mov word ptr [si + 2], ax
  120A:0BB1  ret
loc_120A_0BB2:    ; <- jcc:120A:0B48
  120A:0BB2  cmp dx, 0x8000
  120A:0BB6  je loc_120A_0BAA
  120A:0BB8  mov ax, word ptr [bx - 0x294c]
  120A:0BBC  mov dx, word ptr [bx - 0x294a]
  120A:0BC0  add ax, word ptr [0x8602]            ; ds:8602
  120A:0BC4  adc dx, 0
  120A:0BC7  mov word ptr [si + 8], ax
  120A:0BCA  mov word ptr [si + 0xa], dx
  120A:0BCD  mov ax, word ptr [bx - 0x2948]
  120A:0BD1  mov dx, word ptr [bx - 0x2946]
  120A:0BD5  add ax, word ptr [0x8604]            ; ds:8604
  120A:0BD9  adc dx, 0
  120A:0BDC  mov word ptr [si + 0xc], ax
  120A:0BDF  mov word ptr [si + 0xe], dx
  120A:0BE2  shl di, 1
  120A:0BE4  shl bx, 1
  120A:0BE6  push word ptr [di - 0x3942]
  120A:0BEA  push word ptr [di - 0x3944]
  120A:0BEE  push word ptr [di - 0x3946]
  120A:0BF2  push word ptr [di - 0x3948]
  120A:0BF6  push word ptr [di - 0x394a]
  120A:0BFA  push word ptr [di - 0x394c]
  120A:0BFE  push word ptr [bx - 0x3942]
  120A:0C02  push word ptr [bx - 0x3944]
  120A:0C06  push word ptr [bx - 0x3946]
  120A:0C0A  push word ptr [bx - 0x3948]
  120A:0C0E  push word ptr [bx - 0x394a]
  120A:0C12  push word ptr [bx - 0x394c]
  120A:0C16  call far func_120A_098C              ; -> 120A:098C
  120A:0C1B  add sp, 0x18
  120A:0C1E  mov ax, word ptr [0x7d74]            ; ds:7D74
  120A:0C21  mov dx, word ptr [0x7d72]            ; ds:7D72
  120A:0C25  mov dl, dh
  120A:0C27  mov dh, al
  120A:0C29  mov al, ah
  120A:0C2B  cwde
  120A:0C2C  xchg dx, ax
  120A:0C2D  shl ax, 1
  120A:0C2F  rcl dx, 1
  120A:0C31  add ax, word ptr [0x8602]            ; ds:8602
  120A:0C35  adc dx, 0
  120A:0C38  mov word ptr [si], ax
  120A:0C3A  mov word ptr [si + 2], dx
  120A:0C3D  mov word ptr [si + 0x10], ax
  120A:0C40  mov word ptr [si + 0x12], dx
  120A:0C43  mov ax, word ptr [0x7d78]            ; ds:7D78
  120A:0C46  mov dx, word ptr [0x7d76]            ; ds:7D76
  120A:0C4A  mov dl, dh
  120A:0C4C  mov dh, al
  120A:0C4E  mov al, ah
  120A:0C50  cwde
  120A:0C51  xchg dx, ax
  120A:0C52  shl ax, 1
  120A:0C54  rcl dx, 1
  120A:0C56  add ax, word ptr [0x8604]            ; ds:8604
  120A:0C5A  adc dx, 0
  120A:0C5D  mov word ptr [si + 4], ax
  120A:0C60  mov word ptr [si + 6], dx
  120A:0C63  mov word ptr [si + 0x14], ax
  120A:0C66  mov word ptr [si + 0x16], dx
  120A:0C69  call far func_130D_033F              ; -> 130D:033F
  120A:0C6E  mov al, 0x40
  120A:0C70  mov ah, al
  120A:0C72  or word ptr [si + 2], ax
  120A:0C75  ret

; ===== func_120A_0C76  reg  callers: C=0 asm=0  seeds=call =====
func_120A_0C76:
  120A:0C76  mov cx, word ptr [0x7d5a]            ; ds:7D5A
  120A:0C7A  or cx, cx
  120A:0C7C  js loc_120A_0C94
  120A:0C7E  jne loc_120A_0C89
  120A:0C80  inc cx
loc_120A_0C81:    ; <- jcc:120A:0C86
  120A:0C81  push cx
  120A:0C82  call func_120A_0CE9
  120A:0C85  pop cx
  120A:0C86  loop loc_120A_0C81
  120A:0C88  ret
loc_120A_0C89:    ; <- jcc:120A:0C7E
  120A:0C89  sub bx, bx
loc_120A_0C8B:    ; <- jcc:120A:0C91
  120A:0C8B  push cx
  120A:0C8C  call func_120A_0CA8
  120A:0C8F  pop cx
  120A:0C90  inc bx
  120A:0C91  loop loc_120A_0C8B
  120A:0C93  ret
loc_120A_0C94:    ; <- jcc:120A:0C7C
  120A:0C94  lea di, [0x7902]                     ; ds:7902
loc_120A_0C98:    ; <- jmp:120A:0CA5
  120A:0C98  mov bl, byte ptr [di]
  120A:0C9A  inc di
  120A:0C9B  cmp bl, 0xff
  120A:0C9E  je loc_120A_0CA7
  120A:0CA0  sub bh, bh
  120A:0CA2  call func_120A_0CA8
  120A:0CA5  jmp loc_120A_0C98
loc_120A_0CA7:    ; <- jcc:120A:0C9E
  120A:0CA7  ret

; ===== func_120A_0CA8  reg  callers: C=0 asm=0  seeds=call =====
func_120A_0CA8:
  120A:0CA8  cmp byte ptr [bx + 0x7702], 0x7f
  120A:0CAD  jbe loc_120A_0CC4
  120A:0CAF  mov al, byte ptr [bx + 0x7802]
  120A:0CB3  mov byte ptr [0x7d8a], al            ; ds:7D8A
  120A:0CB6  push di
  120A:0CB7  push bx
  120A:0CB8  push si
  120A:0CB9  shl bx, 1
  120A:0CBB  mov si, word ptr es:[bx + si]
  120A:0CBE  call func_120A_0CE9
  120A:0CC1  pop si
  120A:0CC2  pop bx
  120A:0CC3  pop di
loc_120A_0CC4:    ; <- jcc:120A:0CAD
  120A:0CC4  ret
loc_120A_0CC5:    ; <- jcc:120A:0CE0 jcc:120A:0CEF
  120A:0CC5  ret
loc_120A_0CC6:    ; <- jcc:120A:0CF3
  120A:0CC6  and ax, 0x7f
  120A:0CC9  mov bx, ax
  120A:0CCB  shl bx, 1
  120A:0CCD  add bx, word ptr [0x7d4e]            ; ds:7D4E
  120A:0CD1  mov al, byte ptr es:[si]
  120A:0CD4  inc si
  120A:0CD5  cwde
  120A:0CD6  cmp ax, word ptr [bx]
  120A:0CD8  je func_120A_0CE9
  120A:0CDA  mov al, byte ptr es:[si]
  120A:0CDD  inc si
  120A:0CDE  cmp al, 0xff
  120A:0CE0  je loc_120A_0CC5
  120A:0CE2  and al, 0x1f
  120A:0CE4  sub ah, ah
  120A:0CE6  inc ax
  120A:0CE7  add si, ax

; ===== func_120A_0CE9  reg  callers: C=0 asm=0  seeds=call =====
func_120A_0CE9:
  120A:0CE9  mov al, byte ptr es:[si]
  120A:0CEC  inc si
  120A:0CED  cmp al, 0xff
  120A:0CEF  je loc_120A_0CC5
  120A:0CF1  test al, 0x80
  120A:0CF3  jne loc_120A_0CC6
  120A:0CF5  test al, 0x20
  120A:0CF7  je loc_120A_0CFC
  120A:0CF9  jmp loc_120A_0DFA
loc_120A_0CFC:    ; <- jcc:120A:0CF7
  120A:0CFC  test al, 0x40
  120A:0CFE  jne loc_120A_0D5B
  120A:0D00  mov cl, al
  120A:0D02  sub ch, ch
  120A:0D04  mov word ptr [0x7d6e], cx            ; ds:7D6E
  120A:0D08  mov word ptr [0x7d70], si            ; ds:7D70
  120A:0D0C  mov bx, cx
  120A:0D0E  cmp byte ptr es:[bx + si], 0xff
  120A:0D12  jne loc_120A_0D19
  120A:0D14  add si, bx
  120A:0D16  inc si
  120A:0D17  jmp func_120A_0CE9
loc_120A_0D19:    ; <- jcc:120A:0D12 jcc:120A:0D3A
  120A:0D19  mov bl, byte ptr es:[si]
  120A:0D1C  inc si
  120A:0D1D  sub bh, bh
  120A:0D1F  shl bx, 1
  120A:0D21  shl bx, 1
  120A:0D23  shl bx, 1
  120A:0D25  mov ax, bx
  120A:0D27  shl bx, 1
  120A:0D29  add bx, ax
  120A:0D2B  push cx
  120A:0D2C  push si
  120A:0D2D  lea si, [0x5eea]                     ; ds:5EEA
  120A:0D31  add si, bx
  120A:0D33  call far func_130D_004A              ; -> 130D:004A
  120A:0D38  pop si
  120A:0D39  pop cx
  120A:0D3A  loop loc_120A_0D19
  120A:0D3C  mov al, byte ptr es:[si]
  120A:0D3F  inc si
  120A:0D40  push es
  120A:0D41  push si
  120A:0D42  mov bx, word ptr [0x7d80]            ; ds:7D80
  120A:0D46  sub ah, ah
  120A:0D48  shl ax, 1
  120A:0D4A  add bx, ax
  120A:0D4C  mov ax, word ptr [bx]
  120A:0D4E  push ax
  120A:0D4F  call far func_130D_0116              ; -> 130D:0116
  120A:0D54  add sp, 2
  120A:0D57  pop si
  120A:0D58  pop es
  120A:0D59  jmp func_120A_0CE9
loc_120A_0D5B:    ; <- jcc:120A:0CFE
  120A:0D5B  and al, 0x1f
  120A:0D5D  mov cl, al
  120A:0D5F  sub ch, ch
  120A:0D61  mov al, byte ptr es:[si]
  120A:0D64  inc si
  120A:0D65  mov bx, word ptr [0x7d80]            ; ds:7D80
  120A:0D69  sub ah, ah
  120A:0D6B  shl ax, 1
  120A:0D6D  add bx, ax
  120A:0D6F  mov ax, word ptr [bx]
  120A:0D71  push es
  120A:0D72  call far func_1377_004C              ; -> 1377:004C
  120A:0D77  pop es
loc_120A_0D78:    ; <- jcc:120A:0DA6
  120A:0D78  mov bl, byte ptr es:[si]
  120A:0D7B  inc si
  120A:0D7C  sub bh, bh
  120A:0D7E  shl bx, 1
  120A:0D80  shl bx, 1
  120A:0D82  shl bx, 1
  120A:0D84  mov ax, bx
  120A:0D86  shl bx, 1
  120A:0D88  add bx, ax
  120A:0D8A  push si
  120A:0D8B  lea si, [0x5eea]                     ; ds:5EEA
  120A:0D8F  add si, bx
  120A:0D91  mov word ptr [0x7d7e], si            ; ds:7D7E
  120A:0D95  mov ax, word ptr [si + 2]
  120A:0D98  test al, 0x80
  120A:0D9A  jne loc_120A_0DA5
  120A:0D9C  push es
  120A:0D9D  push cx
  120A:0D9E  call far func_1377_0055              ; -> 1377:0055
  120A:0DA3  pop cx
  120A:0DA4  pop es
loc_120A_0DA5:    ; <- jcc:120A:0D9A
  120A:0DA5  pop si
  120A:0DA6  loop loc_120A_0D78
  120A:0DA8  jmp func_120A_0CE9

; ----- data 120A:0DAB .. 120A:0DF9 (79 bytes) -----
;   120A:0DAB  2A E4 50 9A 16 01 0D 13 58 5E 07 56 8B 36 70 7D  *.P.....X^.V.6p}
;   120A:0DBB  8B 0E 6E 7D 8A C4 2A E4 06 9A 4C 00 77 13 07 26  ..n}..*...L.w..&
;   120A:0DCB  8A 1C 46 2A FF D1 E3 D1 E3 D1 E3 8B C3 D1 E3 03  ..F*............
;   120A:0DDB  D8 56 8D 36 EA 5E 03 F3 8B 44 02 A8 80 75 09 06  .V.6.^...D...u..
;   120A:0DEB  51 9A 55 00 77 13 59 07 5E E2 D4 5E E9 EF FE     Q.U.w.Y.^..^...
;   far pointers (offset,seg) at: 120A:0DAF 120A:0DC5 120A:0DED
loc_120A_0DFA:    ; <- jmp:120A:0CF9
  120A:0DFA  and al, 0x1f
  120A:0DFC  mov cl, al
  120A:0DFE  sub ch, ch
  120A:0E00  mov al, byte ptr es:[si]
  120A:0E03  inc si
  120A:0E04  push ax
  120A:0E05  mov bp, cx
loc_120A_0E07:    ; <- jcc:120A:0E53
  120A:0E07  mov bl, byte ptr es:[si]
  120A:0E0A  inc si
  120A:0E0B  sub bh, bh
  120A:0E0D  shl bx, 1
  120A:0E0F  shl bx, 1
  120A:0E11  shl bx, 1
  120A:0E13  lea ax, [0xd6b4]                     ; ds:D6B4
  120A:0E17  add bx, ax
  120A:0E19  mov dx, word ptr [bx + 2]
  120A:0E1C  cmp dx, 0x8000
  120A:0E20  je loc_120A_0E52
  120A:0E22  mov ax, word ptr [bx]
  120A:0E24  add ax, word ptr [0x8602]            ; ds:8602
  120A:0E28  adc dx, 0
  120A:0E2B  inc dx
  120A:0E2C  cmp dx, 1
  120A:0E2F  ja loc_120A_0E52
  120A:0E31  mov cx, ax
  120A:0E33  mov ax, word ptr [bx + 4]
  120A:0E36  mov dx, word ptr [bx + 6]
  120A:0E39  add ax, word ptr [0x8604]            ; ds:8604
  120A:0E3D  adc dx, 0
  120A:0E40  inc dx
  120A:0E41  cmp dx, 1
  120A:0E44  ja loc_120A_0E52
  120A:0E46  pop bx
  120A:0E47  push bx
  120A:0E48  push es
  120A:0E49  push si
  120A:0E4A  push bx
  120A:0E4B  push ax
  120A:0E4C  push cx
  120A:0E4D  add sp, 6
  120A:0E50  pop si
  120A:0E51  pop es
loc_120A_0E52:    ; <- jcc:120A:0E20 jcc:120A:0E2F jcc:120A:0E44
  120A:0E52  dec bp
  120A:0E53  jne loc_120A_0E07
  120A:0E55  add sp, 2
  120A:0E58  jmp func_120A_0CE9

; ===== func_120A_0E5B  reg  callers: C=0 asm=0  seeds=call =====
func_120A_0E5B:
  120A:0E5B  mov word ptr [0x7d7a], bx            ; ds:7D7A
  120A:0E5F  sub bp, bp
  120A:0E61  mov al, byte ptr es:[si]
  120A:0E64  add si, 1
  120A:0E67  sub ah, ah
  120A:0E69  mov cx, ax
loc_120A_0E6B:    ; <- jmp:120A:0EEB
  120A:0E6B  mov bx, word ptr [0x7d7a]            ; ds:7D7A
  120A:0E6F  add bx, cx
  120A:0E71  mov al, byte ptr [bx]
  120A:0E73  mov bx, cx
  120A:0E75  shl bx, 1
  120A:0E77  sub dx, dx
  120A:0E79  cmp al, 0
  120A:0E7B  jne loc_120A_0E80
  120A:0E7D  mov dx, 2
loc_120A_0E80:    ; <- jcc:120A:0E7B jmp:120A:0EC4 jmp:120A:0ED8
  120A:0E80  cmp dx, 0
  120A:0E83  je loc_120A_0E97
  120A:0E85  cmp dx, 1
  120A:0E88  je loc_120A_0E9D
  120A:0E8A  cmp dx, 2
  120A:0E8D  je loc_120A_0EA6
  120A:0E8F  cmp dx, 3
  120A:0E92  je loc_120A_0EAC
  120A:0E94  jmp loc_120A_0EB2

; ----- data 120A:0E96 .. 120A:0E96 (1 bytes) -----
;   120A:0E96  90                                               .
loc_120A_0E97:    ; <- jcc:120A:0E83
  120A:0E97  mov dx, 1
  120A:0E9A  jmp loc_120A_0EDA

; ----- data 120A:0E9C .. 120A:0E9C (1 bytes) -----
;   120A:0E9C  90                                               .
loc_120A_0E9D:    ; <- jcc:120A:0E88
  120A:0E9D  mov byte ptr [di], cl
  120A:0E9F  inc di
  120A:0EA0  mov dx, 4
  120A:0EA3  jmp loc_120A_0ECA

; ----- data 120A:0EA5 .. 120A:0EA5 (1 bytes) -----
;   120A:0EA5  90                                               .
loc_120A_0EA6:    ; <- jcc:120A:0E8D
  120A:0EA6  mov dx, 3
  120A:0EA9  jmp loc_120A_0ECA

; ----- data 120A:0EAB .. 120A:0EAB (1 bytes) -----
;   120A:0EAB  90                                               .
loc_120A_0EAC:    ; <- jcc:120A:0E92
  120A:0EAC  mov dx, 4
  120A:0EAF  jmp loc_120A_0EDA

; ----- data 120A:0EB1 .. 120A:0EB1 (1 bytes) -----
;   120A:0EB1  90                                               .
loc_120A_0EB2:    ; <- jmp:120A:0E94
  120A:0EB2  sub bp, 1
  120A:0EB5  js loc_120A_0EC6
  120A:0EB7  pop ax
  120A:0EB8  mov dl, al
  120A:0EBA  sub dh, dh
  120A:0EBC  mov cl, ah
  120A:0EBE  sub ch, ch
  120A:0EC0  mov bx, cx
  120A:0EC2  shl bx, 1
  120A:0EC4  jmp loc_120A_0E80
loc_120A_0EC6:    ; <- jcc:120A:0EB5
  120A:0EC6  mov byte ptr [di], 0xff
  120A:0EC9  ret
loc_120A_0ECA:    ; <- jmp:120A:0EA3 jmp:120A:0EA9
  120A:0ECA  mov al, byte ptr es:[bx + si]
  120A:0ECD  cmp al, 0xff
  120A:0ECF  je loc_120A_0ED8
  120A:0ED1  or al, al
  120A:0ED3  jns loc_120A_0EE2
  120A:0ED5  mov byte ptr [di], al
  120A:0ED7  inc di
loc_120A_0ED8:    ; <- jcc:120A:0ECF jcc:120A:0EE0
  120A:0ED8  jmp loc_120A_0E80
loc_120A_0EDA:    ; <- jmp:120A:0E9A jmp:120A:0EAF
  120A:0EDA  mov al, byte ptr es:[bx + si + 1]
  120A:0EDE  cmp al, 0xff
  120A:0EE0  je loc_120A_0ED8
loc_120A_0EE2:    ; <- jcc:120A:0ED3
  120A:0EE2  sub ah, ah
  120A:0EE4  xchg cx, ax
  120A:0EE5  mov ah, al
  120A:0EE7  mov al, dl
  120A:0EE9  push ax
  120A:0EEA  inc bp
  120A:0EEB  jmp loc_120A_0E6B

; ===== func_120A_0EEE  bp-frame  callers: C=0 asm=0  seeds=sweep =====
func_120A_0EEE:
  120A:0EEE  push bp
  120A:0EEF  mov bp, sp
  120A:0EF1  push es
  120A:0EF2  push si
  120A:0EF3  push di
  120A:0EF4  mov di, word ptr [bp + 8]
  120A:0EF7  mov word ptr [di], 0
  120A:0EFB  mov word ptr [di + 2], 0
  120A:0F00  mov word ptr [di + 4], 0
  120A:0F05  mov ax, word ptr [0x8590]            ; ds:8590
  120A:0F08  mov es, ax
  120A:0F0A  sub si, si
  120A:0F0C  mov ax, word ptr es:[si]
  120A:0F0F  cmp ax, word ptr [bp + 6]
  120A:0F12  ja loc_120A_0F19
  120A:0F14  pop di
  120A:0F15  pop si
  120A:0F16  pop es
  120A:0F17  pop bp
  120A:0F18  retf
loc_120A_0F19:    ; <- jcc:120A:0F12
  120A:0F19  mov bx, word ptr [bp + 6]
  120A:0F1C  shl bx, 1
  120A:0F1E  mov si, word ptr es:[bx + 2]
  120A:0F22  mov ax, word ptr es:[si]
  120A:0F25  mov si, word ptr es:[si + 2]
  120A:0F29  mov ax, word ptr es:[si]
  120A:0F2C  add si, 2
  120A:0F2F  mov cx, word ptr es:[si]
  120A:0F32  add si, 2
  120A:0F35  call func_120A_0317
  120A:0F38  mov ax, word ptr es:[si]
  120A:0F3B  add si, 2
  120A:0F3E  mov word ptr [0x7d5c], ax            ; ds:7D5C
  120A:0F41  push di
  120A:0F42  call func_120A_0561
  120A:0F45  pop di
  120A:0F46  mov cx, word ptr [0x7d5c]            ; ds:7D5C
  120A:0F4A  cmp cx, 0
  120A:0F4D  jle loc_120A_0F92
loc_120A_0F4F:    ; <- jcc:120A:0F5D jcc:120A:0F90
  120A:0F4F  mov ax, word ptr es:[si]
  120A:0F52  add si, 2
  120A:0F55  cmp ax, 0x8000
  120A:0F58  jb loc_120A_0F5F
  120A:0F5A  cmp ax, 0x8010
  120A:0F5D  jb loc_120A_0F4F
loc_120A_0F5F:    ; <- jcc:120A:0F58
  120A:0F5F  cdq
  120A:0F60  xor ax, dx
  120A:0F62  sub ax, dx
  120A:0F64  cmp ax, word ptr [di]
  120A:0F66  jbe loc_120A_0F6A
  120A:0F68  mov word ptr [di], ax
loc_120A_0F6A:    ; <- jcc:120A:0F66
  120A:0F6A  mov ax, word ptr es:[si]
  120A:0F6D  add si, 2
  120A:0F70  cdq
  120A:0F71  xor ax, dx
  120A:0F73  sub ax, dx
  120A:0F75  cmp ax, word ptr [di + 2]
  120A:0F78  jbe loc_120A_0F7D
  120A:0F7A  mov word ptr [di + 2], ax
loc_120A_0F7D:    ; <- jcc:120A:0F78
  120A:0F7D  mov ax, word ptr es:[si]
  120A:0F80  add si, 2
  120A:0F83  cdq
  120A:0F84  xor ax, dx
  120A:0F86  sub ax, dx
  120A:0F88  cmp ax, word ptr [di + 4]
  120A:0F8B  jbe loc_120A_0F90
  120A:0F8D  mov word ptr [di + 4], ax
loc_120A_0F90:    ; <- jcc:120A:0F8B
  120A:0F90  loop loc_120A_0F4F
loc_120A_0F92:    ; <- jcc:120A:0F4D
  120A:0F92  pop di
  120A:0F93  pop si
  120A:0F94  pop es
  120A:0F95  pop bp
  120A:0F96  retf

; ===== func_120A_0F97  reg(saves)  callers: C=1 asm=0  seeds=far =====
func_120A_0F97:
  120A:0F97  push di
  120A:0F98  push si
  120A:0F99  push es
  120A:0F9A  push bp
  120A:0F9B  mov ax, word ptr [0x8590]            ; ds:8590
  120A:0F9E  mov es, ax
  120A:0FA0  sub si, si
  120A:0FA2  mov si, word ptr es:[si]
  120A:0FA5  shl si, 1
  120A:0FA7  add si, 2
  120A:0FAA  mov si, word ptr es:[si]
  120A:0FAD  mov cx, word ptr es:[si]
  120A:0FB0  add si, 2
  120A:0FB3  sub di, di
  120A:0FB5  lea bx, [0x7b28]                     ; ds:7B28
  120A:0FB9  cmp cx, 0
  120A:0FBC  je loc_120A_1038
  120A:0FBE  lea di, [0x4ee6]                     ; ds:4EE6
loc_120A_0FC2:    ; <- jcc:120A:1036
  120A:0FC2  push cx
  120A:0FC3  push si
  120A:0FC4  mov ax, word ptr es:[si]
  120A:0FC7  mov cx, word ptr es:[si + 2]
  120A:0FCB  mov si, word ptr es:[si + 4]
  120A:0FCF  mov bp, ax
  120A:0FD1  imul word ptr [bx]
  120A:0FD3  mov word ptr [di], ax
  120A:0FD5  mov word ptr [di + 2], dx
  120A:0FD8  mov ax, bp
  120A:0FDA  imul word ptr [bx + 2]
  120A:0FDD  mov word ptr [di + 4], ax
  120A:0FE0  mov word ptr [di + 6], dx
  120A:0FE3  mov ax, bp
  120A:0FE5  imul word ptr [bx + 4]
  120A:0FE8  mov word ptr [di + 8], ax
  120A:0FEB  mov word ptr [di + 0xa], dx
  120A:0FEE  mov ax, cx
  120A:0FF0  imul word ptr [bx + 6]
  120A:0FF3  add word ptr [di], ax
  120A:0FF5  adc word ptr [di + 2], dx
  120A:0FF8  mov ax, cx
  120A:0FFA  imul word ptr [bx + 8]
  120A:0FFD  add word ptr [di + 4], ax
  120A:1000  adc word ptr [di + 6], dx
  120A:1003  mov ax, cx
  120A:1005  imul word ptr [bx + 0xa]
  120A:1008  add word ptr [di + 8], ax
  120A:100B  adc word ptr [di + 0xa], dx
  120A:100E  mov ax, si
  120A:1010  imul word ptr [bx + 0xc]
  120A:1013  add word ptr [di], ax
  120A:1015  adc word ptr [di + 2], dx
  120A:1018  mov ax, si
  120A:101A  imul word ptr [bx + 0xe]
  120A:101D  add word ptr [di + 4], ax
  120A:1020  adc word ptr [di + 6], dx
  120A:1023  mov ax, si
  120A:1025  imul word ptr [bx + 0x10]
  120A:1028  add word ptr [di + 8], ax
  120A:102B  adc word ptr [di + 0xa], dx
  120A:102E  pop si
  120A:102F  pop cx
  120A:1030  add di, 0x10
  120A:1033  add si, 6
  120A:1036  loop loc_120A_0FC2
loc_120A_1038:    ; <- jcc:120A:0FBC
  120A:1038  pop bp
  120A:1039  pop es
  120A:103A  pop si
  120A:103B  pop di
  120A:103C  retf
