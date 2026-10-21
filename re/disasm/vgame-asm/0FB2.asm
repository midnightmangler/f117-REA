; VGAME segment 0FB2  lin 0FB20..10390  size 2160  dgroup=1E42  (vgame_asm.py; capstone recursive descent)
; entries: 18   far-call sites into this segment: 31   unresolved indirect jumps/calls: 0

; ===== func_0FB2_0000  bp-frame  callers: C=1 asm=0  seeds=far =====
func_0FB2_0000:
  0FB2:0000  push bp
  0FB2:0001  mov bp, sp
  0FB2:0003  mov al, byte ptr [bp + 6]
  0FB2:0006  mov byte ptr [0xd46], al             ; ds:0D46
  0FB2:0009  push si
  0FB2:000A  push di
  0FB2:000B  call func_0FB2_0012
  0FB2:000E  pop di
  0FB2:000F  pop si
  0FB2:0010  pop bp
  0FB2:0011  retf

; ===== func_0FB2_0012  reg  callers: C=0 asm=0  seeds=call =====
func_0FB2_0012:
  0FB2:0012  mov ax, word ptr [0x49ba]            ; ds:49BA
  0FB2:0015  neg ax
  0FB2:0017  mov word ptr [0xd44], ax             ; ds:0D44
  0FB2:001A  mov ax, word ptr [0x49b6]            ; ds:49B6
  0FB2:001D  cdq
  0FB2:001E  mov dl, ah
  0FB2:0020  mov ah, al
  0FB2:0022  sub al, al
  0FB2:0024  mov cx, word ptr [0x49b8]            ; ds:49B8
  0FB2:0028  cmp cx, 0x1f0b
  0FB2:002C  jg loc_0FB2_0034
  0FB2:002E  mov ax, 0x3ff
  0FB2:0031  jmp loc_0FB2_0036

; ----- data 0FB2:0033 .. 0FB2:0033 (1 bytes) -----
;   0FB2:0033  90                                               .
loc_0FB2_0034:    ; <- jcc:0FB2:002C
  0FB2:0034  idiv cx
loc_0FB2_0036:    ; <- jmp:0FB2:0031
  0FB2:0036  cmp byte ptr [0x4368], 0             ; ds:4368
  0FB2:003B  je loc_0FB2_0043
  0FB2:003D  mov cl, byte ptr [0x4368]            ; ds:4368
  0FB2:0041  shl ax, cl
loc_0FB2_0043:    ; <- jcc:0FB2:003B
  0FB2:0043  cmp byte ptr [0x294b], 0             ; ds:294B
  0FB2:0048  je loc_0FB2_004C
  0FB2:004A  sar ax, 1
loc_0FB2_004C:    ; <- jcc:0FB2:0048
  0FB2:004C  mov bp, ax
  0FB2:004E  imul word ptr [0xd44]                ; ds:0D44
  0FB2:0052  shl ax, 1
  0FB2:0054  rcl dx, 1
  0FB2:0056  mov bx, ax
  0FB2:0058  mov cx, dx
  0FB2:005A  mov ax, word ptr [0xd1e]             ; ds:0D1E
  0FB2:005D  shl ax, 1
  0FB2:005F  imul word ptr [0x49bc]               ; ds:49BC
  0FB2:0063  shl ax, 1
  0FB2:0065  rcl dx, 1
  0FB2:0067  mov si, ax
  0FB2:0069  mov di, dx
  0FB2:006B  sub ax, bx
  0FB2:006D  sbb dx, cx
  0FB2:006F  shl ax, 1
  0FB2:0071  adc dx, word ptr [0xd1e]             ; ds:0D1E
  0FB2:0075  mov word ptr [0x2299], dx            ; ds:2299
  0FB2:0079  add bx, si
  0FB2:007B  adc cx, di
  0FB2:007D  shl bx, 1
  0FB2:007F  adc cx, 0
  0FB2:0082  mov dx, word ptr [0xd1e]             ; ds:0D1E
  0FB2:0086  sub dx, cx
  0FB2:0088  mov word ptr [0x229b], dx            ; ds:229B
  0FB2:008C  mov ax, bp
  0FB2:008E  imul word ptr [0x49bc]               ; ds:49BC
  0FB2:0092  shl ax, 1
  0FB2:0094  rcl dx, 1
  0FB2:0096  mov si, ax
  0FB2:0098  mov di, dx
  0FB2:009A  mov ax, word ptr [0xd1e]             ; ds:0D1E
  0FB2:009D  shl ax, 1
  0FB2:009F  imul word ptr [0xd44]                ; ds:0D44
  0FB2:00A3  shl ax, 1
  0FB2:00A5  rcl dx, 1
  0FB2:00A7  mov bx, ax
  0FB2:00A9  mov cx, dx
  0FB2:00AB  sub ax, si
  0FB2:00AD  sbb dx, di
  0FB2:00AF  shl ax, 1
  0FB2:00B1  adc dx, 0
  0FB2:00B4  mov ax, dx
  0FB2:00B6  sar ax, 1
  0FB2:00B8  sar ax, 1
  0FB2:00BA  sub dx, ax
  0FB2:00BC  add dx, word ptr [0xd20]             ; ds:0D20
  0FB2:00C0  mov word ptr [0x229f], dx            ; ds:229F
  0FB2:00C4  add si, bx
  0FB2:00C6  adc di, cx
  0FB2:00C8  shl si, 1
  0FB2:00CA  adc di, 0
  0FB2:00CD  mov si, di
  0FB2:00CF  sar si, 1
  0FB2:00D1  sar si, 1
  0FB2:00D3  sub di, si
  0FB2:00D5  mov dx, word ptr [0xd20]             ; ds:0D20
  0FB2:00D9  sub dx, di
  0FB2:00DB  mov word ptr [0x229d], dx            ; ds:229D
  0FB2:00DF  mov word ptr [0xd48], 0              ; ds:0D48
  0FB2:00E5  mov ah, byte ptr [0xd46]             ; ds:0D46
  0FB2:00E9  call far func_1E42_01BA              ; T:01BA slot 32
  0FB2:00EE  call func_0FB2_051F
  0FB2:00F1  call func_0FB2_0330
  0FB2:00F4  jae loc_0FB2_0130
loc_0FB2_00F6:    ; <- jcc:0FB2:013B jcc:0FB2:0141
  0FB2:00F6  cmp word ptr [0x49b6], 0             ; ds:49B6
  0FB2:00FB  js loc_0FB2_0104
  0FB2:00FD  mov ah, 0x78
  0FB2:00FF  call far func_1E42_01BA              ; T:01BA slot 32
loc_0FB2_0104:    ; <- jcc:0FB2:00FB
  0FB2:0104  sub si, si
  0FB2:0106  mov di, si
  0FB2:0108  mov dx, word ptr [0x2295]            ; ds:2295
  0FB2:010C  call func_0FB2_0555
  0FB2:010F  mov si, word ptr [0x2293]            ; ds:2293
  0FB2:0113  sub di, di
  0FB2:0115  mov dx, word ptr [0x2295]            ; ds:2295
  0FB2:0119  call func_0FB2_0555
  0FB2:011C  mov ax, word ptr [0x2615]            ; ds:2615
  0FB2:011F  mov cx, word ptr [0x2617]            ; ds:2617
  0FB2:0123  mov bx, 0x22a1
  0FB2:0126  sub dx, dx
  0FB2:0128  call far func_1E42_01D3              ; T:01D3 slot 37
  0FB2:012D  jmp loc_0FB2_01E5
loc_0FB2_0130:    ; <- jcc:0FB2:00F4
  0FB2:0130  mov ax, word ptr [0x229d]            ; ds:229D
  0FB2:0133  cmp ax, word ptr [0x229f]            ; ds:229F
  0FB2:0137  jne loc_0FB2_0143
  0FB2:0139  or ax, ax
  0FB2:013B  je loc_0FB2_00F6
  0FB2:013D  cmp ax, word ptr [0x2295]            ; ds:2295
  0FB2:0141  je loc_0FB2_00F6
loc_0FB2_0143:    ; <- jcc:0FB2:0137 jmp:0FB2:01E2
  0FB2:0143  push word ptr [0x2299]               ; ds:2299
  0FB2:0147  push word ptr [0x229d]               ; ds:229D
  0FB2:014B  push word ptr [0x229b]               ; ds:229B
  0FB2:014F  push word ptr [0x229f]               ; ds:229F
  0FB2:0153  call func_0FB2_06A6
  0FB2:0156  pop word ptr [0x229f]                ; ds:229F
  0FB2:015A  pop word ptr [0x229b]                ; ds:229B
  0FB2:015E  pop word ptr [0x229d]                ; ds:229D
  0FB2:0162  pop word ptr [0x2299]                ; ds:2299
  0FB2:0166  sub ax, ax
  0FB2:0168  mov si, word ptr [0xd48]             ; ds:0D48
  0FB2:016C  xor si, word ptr [0xd44]             ; ds:0D44
  0FB2:0170  jns loc_0FB2_0175
  0FB2:0172  mov ax, word ptr [0x2293]            ; ds:2293
loc_0FB2_0175:    ; <- jcc:0FB2:0170
  0FB2:0175  mov word ptr [0xd42], ax             ; ds:0D42
  0FB2:0178  sub bx, bx
  0FB2:017A  mov bp, word ptr [0x2295]            ; ds:2295
  0FB2:017E  mov si, word ptr [0xd48]             ; ds:0D48
  0FB2:0182  xor si, word ptr [0x49bc]            ; ds:49BC
  0FB2:0186  jns loc_0FB2_018A
  0FB2:0188  xchg bp, bx
loc_0FB2_018A:    ; <- jcc:0FB2:0186
  0FB2:018A  mov si, word ptr [0x2299]            ; ds:2299
  0FB2:018E  mov di, word ptr [0x229d]            ; ds:229D
  0FB2:0192  cmp di, bx
  0FB2:0194  je loc_0FB2_01A5
  0FB2:0196  cmp di, bp
  0FB2:0198  jne loc_0FB2_01A0
  0FB2:019A  mov di, bp
  0FB2:019C  mov si, word ptr [0xd42]             ; ds:0D42
loc_0FB2_01A0:    ; <- jcc:0FB2:0198
  0FB2:01A0  mov dx, bx
  0FB2:01A2  call func_0FB2_0555
loc_0FB2_01A5:    ; <- jcc:0FB2:0194
  0FB2:01A5  mov si, word ptr [0x229b]            ; ds:229B
  0FB2:01A9  mov di, word ptr [0x229f]            ; ds:229F
  0FB2:01AD  cmp di, bx
  0FB2:01AF  je loc_0FB2_01C0
  0FB2:01B1  cmp di, bp
  0FB2:01B3  jne loc_0FB2_01BB
  0FB2:01B5  mov di, bp
  0FB2:01B7  mov si, word ptr [0xd42]             ; ds:0D42
loc_0FB2_01BB:    ; <- jcc:0FB2:01B3
  0FB2:01BB  mov dx, bx
  0FB2:01BD  call func_0FB2_0555
loc_0FB2_01C0:    ; <- jcc:0FB2:01AF
  0FB2:01C0  mov ax, word ptr [0x2615]            ; ds:2615
  0FB2:01C3  mov cx, word ptr [0x2617]            ; ds:2617
  0FB2:01C7  mov bx, 0x22a1
  0FB2:01CA  sub dx, dx
  0FB2:01CC  call far func_1E42_01D3              ; T:01D3 slot 37
  0FB2:01D1  xor word ptr [0xd48], 0xffff         ; ds:0D48
  0FB2:01D6  je loc_0FB2_01E5
  0FB2:01D8  mov ah, 0x78
  0FB2:01DA  call far func_1E42_01BA              ; T:01BA slot 32
  0FB2:01DF  call func_0FB2_051F
  0FB2:01E2  jmp loc_0FB2_0143
loc_0FB2_01E5:    ; <- jcc:0FB2:01D6 jmp:0FB2:012D
  0FB2:01E5  ret

; ===== func_0FB2_01E6  bp-frame  callers: C=6 asm=0  seeds=far =====
func_0FB2_01E6:
  0FB2:01E6  push bp
  0FB2:01E7  mov bp, sp
  0FB2:01E9  push es
  0FB2:01EA  push ds
  0FB2:01EB  push si
  0FB2:01EC  push di
  0FB2:01ED  mov ah, byte ptr [bp + 0xc]
  0FB2:01F0  call far func_1E42_01BA              ; T:01BA slot 32
  0FB2:01F5  call func_0FB2_051F
  0FB2:01F8  mov si, word ptr [bp + 0xa]
  0FB2:01FB  mov cx, word ptr [bp + 8]
  0FB2:01FE  dec cx
  0FB2:01FF  lodsw ax, word ptr [si]
  0FB2:0200  mov word ptr [0x2299], ax            ; ds:2299
  0FB2:0203  push ax
  0FB2:0204  lodsw ax, word ptr [si]
  0FB2:0205  mov word ptr [0x229d], ax            ; ds:229D
  0FB2:0208  push ax
loc_0FB2_0209:    ; <- jcc:0FB2:0222
  0FB2:0209  push cx
  0FB2:020A  lodsw ax, word ptr [si]
  0FB2:020B  mov word ptr [0x229b], ax            ; ds:229B
  0FB2:020E  push ax
  0FB2:020F  lodsw ax, word ptr [si]
  0FB2:0210  mov word ptr [0x229f], ax            ; ds:229F
  0FB2:0213  push ax
  0FB2:0214  push si
  0FB2:0215  call func_0FB2_06A6
  0FB2:0218  pop si
  0FB2:0219  pop word ptr [0x229d]                ; ds:229D
  0FB2:021D  pop word ptr [0x2299]                ; ds:2299
  0FB2:0221  pop cx
  0FB2:0222  loop loc_0FB2_0209
  0FB2:0224  pop word ptr [0x229f]                ; ds:229F
  0FB2:0228  pop word ptr [0x229b]                ; ds:229B
  0FB2:022C  call func_0FB2_06A6
  0FB2:022F  mov ax, word ptr [0x2615]            ; ds:2615
  0FB2:0232  mov cx, word ptr [0x2617]            ; ds:2617
  0FB2:0236  mov bx, 0x22a1
  0FB2:0239  sub dx, dx
  0FB2:023B  call far func_1E42_01D3              ; T:01D3 slot 37
  0FB2:0240  pop di
  0FB2:0241  pop si
  0FB2:0242  pop ds
  0FB2:0243  pop es
  0FB2:0244  pop bp
  0FB2:0245  retf

; ===== func_0FB2_0246  bp-frame  callers: C=9 asm=5  seeds=far =====
func_0FB2_0246:
  0FB2:0246  push bp
  0FB2:0247  mov bp, sp
  0FB2:0249  push di
  0FB2:024A  push si
  0FB2:024B  push bp
  0FB2:024C  push ds
  0FB2:024D  pop es
  0FB2:024E  call far func_1E42_016A              ; T:016A slot 16
  0FB2:0253  push ax
  0FB2:0254  mov bx, word ptr [bp + 6]
  0FB2:0257  mov ax, word ptr [bx]
  0FB2:0259  call far func_1E42_015B              ; T:015B slot 13
  0FB2:025E  mov ah, byte ptr [bx + 4]
  0FB2:0261  call far func_1E42_01BA              ; T:01BA slot 32
  0FB2:0266  call func_0FB2_051F
  0FB2:0269  mov cx, word ptr [bp + 0xe]
  0FB2:026C  mov si, word ptr [bp + 0xa]
  0FB2:026F  mov word ptr [0x2617], cx            ; ds:2617
  0FB2:0273  mov word ptr [0x2615], si            ; ds:2615
  0FB2:0277  sub cx, si
  0FB2:0279  inc cx
  0FB2:027A  lea di, [0x22a1]                     ; ds:22A1
  0FB2:027E  shl si, 1
  0FB2:0280  add di, si
  0FB2:0282  mov ax, word ptr [bp + 8]
  0FB2:0285  mov dx, cx
  0FB2:0287  rep stosw word ptr es:[di], ax
  0FB2:0289  mov cx, dx
  0FB2:028B  lea di, [0x2459]                     ; ds:2459
  0FB2:028F  add di, si
  0FB2:0291  mov ax, word ptr [bp + 0xc]
  0FB2:0294  rep stosw word ptr es:[di], ax
  0FB2:0296  mov bx, 0x22a1
  0FB2:0299  mov ax, word ptr [0x2615]            ; ds:2615
  0FB2:029C  mov cx, word ptr [0x2617]            ; ds:2617
  0FB2:02A0  sub dx, dx
  0FB2:02A2  call far func_1E42_01E2              ; T:01E2 slot 40
  0FB2:02A7  pop ax
  0FB2:02A8  call far func_1E42_0165              ; T:0165 slot 15
  0FB2:02AD  pop bp
  0FB2:02AE  pop si
  0FB2:02AF  pop di
  0FB2:02B0  mov sp, bp
  0FB2:02B2  pop bp
  0FB2:02B3  retf

; ===== func_0FB2_02B4  bp-frame  callers: C=0 asm=0  seeds=sweep =====
func_0FB2_02B4:
  0FB2:02B4  push bp
  0FB2:02B5  mov bp, sp
  0FB2:02B7  push di
  0FB2:02B8  push si
  0FB2:02B9  push bp
  0FB2:02BA  push ds
  0FB2:02BB  pop es
  0FB2:02BC  call far func_1E42_016A              ; T:016A slot 16
  0FB2:02C1  push ax
  0FB2:02C2  mov bx, word ptr [bp + 6]
  0FB2:02C5  mov ax, word ptr [bx]
  0FB2:02C7  call far func_1E42_015B              ; T:015B slot 13
  0FB2:02CC  mov ah, byte ptr [bx + 6]
  0FB2:02CF  call far func_1E42_01BA              ; T:01BA slot 32
  0FB2:02D4  call func_0FB2_051F
  0FB2:02D7  mov cx, word ptr [bp + 0xe]
  0FB2:02DA  mov si, word ptr [bp + 0xa]
  0FB2:02DD  mov word ptr [0x2617], cx            ; ds:2617
  0FB2:02E1  mov word ptr [0x2615], si            ; ds:2615
  0FB2:02E5  sub cx, si
  0FB2:02E7  inc cx
  0FB2:02E8  lea di, [0x22a1]                     ; ds:22A1
  0FB2:02EC  shl si, 1
  0FB2:02EE  add di, si
  0FB2:02F0  mov ax, word ptr [bp + 8]
  0FB2:02F3  mov dx, cx
  0FB2:02F5  rep stosw word ptr es:[di], ax
  0FB2:02F7  mov cx, dx
  0FB2:02F9  lea di, [0x2459]                     ; ds:2459
  0FB2:02FD  add di, si
  0FB2:02FF  mov ax, word ptr [bp + 0xc]
  0FB2:0302  rep stosw word ptr es:[di], ax
  0FB2:0304  mov bx, 0x22a1
  0FB2:0307  mov ax, word ptr [0x2615]            ; ds:2615
  0FB2:030A  mov cx, word ptr [0x2617]            ; ds:2617
  0FB2:030E  call far func_1E42_01E2              ; T:01E2 slot 40
  0FB2:0313  pop ax
  0FB2:0314  call far func_1E42_0165              ; T:0165 slot 15
  0FB2:0319  pop bp
  0FB2:031A  pop si
  0FB2:031B  pop di
  0FB2:031C  mov sp, bp
  0FB2:031E  pop bp
  0FB2:031F  ret

; ===== func_0FB2_0320  jump/call stub  callers: C=0 asm=1  seeds=far =====
func_0FB2_0320:
  0FB2:0320  call func_0FB2_0330
  0FB2:0323  retf

; ===== func_0FB2_0324  reg  callers: C=1 asm=3  seeds=far =====
func_0FB2_0324:
  0FB2:0324  push bp
  0FB2:0325  push si
  0FB2:0326  push di
  0FB2:0327  push es
  0FB2:0328  call func_0FB2_0330
  0FB2:032B  pop es
  0FB2:032C  pop di
  0FB2:032D  pop si
  0FB2:032E  pop bp
  0FB2:032F  retf

; ===== func_0FB2_0330  reg  callers: C=0 asm=0  seeds=call =====
func_0FB2_0330:
  0FB2:0330  sub ax, ax
  0FB2:0332  mov es, ax
  0FB2:0334  push word ptr es:[0]
  0FB2:0339  push word ptr es:[2]
  0FB2:033E  lea ax, [0x4dd]                      ; ds:04DD
  0FB2:0342  mov word ptr es:[0], ax
  0FB2:0346  mov word ptr es:[2], 0xfb2           ; seg 0FB2
  0FB2:034D  push ds
  0FB2:034E  pop es
  0FB2:034F  jmp loc_0FB2_03B8

; ----- data 0FB2:0351 .. 0FB2:0351 (1 bytes) -----
;   0FB2:0351  90                                               .
loc_0FB2_0352:    ; <- jmp:0FB2:03E2 jmp:0FB2:04A0
  0FB2:0352  sub ax, ax
  0FB2:0354  mov es, ax
  0FB2:0356  pop word ptr es:[2]
  0FB2:035B  pop word ptr es:[0]
  0FB2:0360  push ds
  0FB2:0361  pop es
  0FB2:0362  mov ax, word ptr [0x2299]            ; ds:2299
  0FB2:0365  mov bx, word ptr [0x229d]            ; ds:229D
  0FB2:0369  mov cx, word ptr [0x229b]            ; ds:229B
  0FB2:036D  mov dx, word ptr [0x229f]            ; ds:229F
  0FB2:0371  call far func_1E42_01B5              ; T:01B5 slot 31
  0FB2:0376  clc
  0FB2:0377  ret
loc_0FB2_0378:    ; <- jmp:0FB2:03B6 jmp:0FB2:04A3
  0FB2:0378  sub ax, ax
  0FB2:037A  mov es, ax
  0FB2:037C  pop word ptr es:[2]
  0FB2:0381  pop word ptr es:[0]
  0FB2:0386  push ds
  0FB2:0387  pop es
  0FB2:0388  stc
  0FB2:0389  ret
loc_0FB2_038A:    ; <- jcc:0FB2:0401
  0FB2:038A  cmc
  0FB2:038B  rcr dx, 1
  0FB2:038D  mov word ptr [0x228b], dx            ; ds:228B
  0FB2:0391  sar dx, 1
  0FB2:0393  mov word ptr [0x228f], dx            ; ds:228F
  0FB2:0397  mov dx, di
  0FB2:0399  sub dx, bp
  0FB2:039B  jno loc_0FB2_03A3
  0FB2:039D  cmc
  0FB2:039E  rcr dx, 1
  0FB2:03A0  jmp loc_0FB2_0413

; ----- data 0FB2:03A2 .. 0FB2:03A2 (1 bytes) -----
;   0FB2:03A2  90                                               .
loc_0FB2_03A3:    ; <- jcc:0FB2:039B
  0FB2:03A3  sar dx, 1
  0FB2:03A5  jmp loc_0FB2_0413

; ----- data 0FB2:03A7 .. 0FB2:03A7 (1 bytes) -----
;   0FB2:03A7  90                                               .
loc_0FB2_03A8:    ; <- jcc:0FB2:0411
  0FB2:03A8  cmc
  0FB2:03A9  rcr dx, 1
  0FB2:03AB  sar word ptr [0x228b], 1             ; ds:228B
  0FB2:03AF  sar word ptr [0x228f], 1             ; ds:228F
  0FB2:03B3  jmp loc_0FB2_0413

; ----- data 0FB2:03B5 .. 0FB2:03B5 (1 bytes) -----
;   0FB2:03B5  90                                               .
loc_0FB2_03B6:    ; <- jcc:0FB2:03F9
  0FB2:03B6  jmp loc_0FB2_0378
loc_0FB2_03B8:    ; <- jmp:0FB2:034F
  0FB2:03B8  mov cx, word ptr [0x2299]            ; ds:2299
  0FB2:03BC  mov dx, word ptr [0x229d]            ; ds:229D
  0FB2:03C0  mov si, word ptr [0x229b]            ; ds:229B
  0FB2:03C4  mov di, word ptr [0x229f]            ; ds:229F
  0FB2:03C8  mov bx, cx
  0FB2:03CA  mov bp, dx
  0FB2:03CC  call func_0FB2_04BC
  0FB2:03CF  mov byte ptr [0x228a], al            ; ds:228A
  0FB2:03D2  mov bx, si
  0FB2:03D4  mov bp, di
  0FB2:03D6  call func_0FB2_04BC
  0FB2:03D9  jne loc_0FB2_03F5
  0FB2:03DB  cmp byte ptr [0x228a], 0             ; ds:228A
  0FB2:03E0  jne loc_0FB2_03E5
  0FB2:03E2  jmp loc_0FB2_0352
loc_0FB2_03E5:    ; <- jcc:0FB2:03E0
  0FB2:03E5  xchg si, cx
  0FB2:03E7  xchg di, dx
  0FB2:03E9  xchg byte ptr [0x228a], al           ; ds:228A
  0FB2:03ED  mov word ptr [0x2299], cx            ; ds:2299
  0FB2:03F1  mov word ptr [0x229d], dx            ; ds:229D
loc_0FB2_03F5:    ; <- jcc:0FB2:03D9
  0FB2:03F5  test byte ptr [0x228a], al           ; ds:228A
  0FB2:03F9  jne loc_0FB2_03B6
  0FB2:03FB  mov bp, dx
  0FB2:03FD  mov dx, si
  0FB2:03FF  sub dx, cx
  0FB2:0401  jo loc_0FB2_038A
  0FB2:0403  mov word ptr [0x228b], dx            ; ds:228B
  0FB2:0407  sar dx, 1
  0FB2:0409  mov word ptr [0x228f], dx            ; ds:228F
  0FB2:040D  mov dx, di
  0FB2:040F  sub dx, bp
  0FB2:0411  jo loc_0FB2_03A8
loc_0FB2_0413:    ; <- jmp:0FB2:03A0 jmp:0FB2:03A5 jmp:0FB2:03B3
  0FB2:0413  mov word ptr [0x228d], dx            ; ds:228D
  0FB2:0417  sar dx, 1
  0FB2:0419  mov word ptr [0x2291], dx            ; ds:2291
loc_0FB2_041D:    ; <- jmp:0FB2:04B9
  0FB2:041D  test al, 9
  0FB2:041F  je loc_0FB2_0459
  0FB2:0421  sub bx, bx
  0FB2:0423  or si, si
  0FB2:0425  js loc_0FB2_042B
  0FB2:0427  mov bx, word ptr [0x2293]            ; ds:2293
loc_0FB2_042B:    ; <- jcc:0FB2:0425
  0FB2:042B  mov ax, bx
  0FB2:042D  sub ax, cx
  0FB2:042F  imul word ptr [0x228d]               ; ds:228D
  0FB2:0433  push bx
  0FB2:0434  mov bx, dx
  0FB2:0436  idiv word ptr [0x228b]               ; ds:228B
  0FB2:043A  mov bl, bh
  0FB2:043C  xor bl, byte ptr [0x228c]            ; ds:228C
  0FB2:0440  jns loc_0FB2_0445
  0FB2:0442  neg dx
  0FB2:0444  dec ax
loc_0FB2_0445:    ; <- jcc:0FB2:0440
  0FB2:0445  sub dx, word ptr [0x228f]            ; ds:228F
  0FB2:0449  xor dh, bh
  0FB2:044B  js loc_0FB2_044E
  0FB2:044D  inc ax
loc_0FB2_044E:    ; <- jcc:0FB2:044B
  0FB2:044E  pop bx
  0FB2:044F  add ax, bp
  0FB2:0451  js loc_0FB2_0461
  0FB2:0453  cmp ax, word ptr [0x2295]            ; ds:2295
  0FB2:0457  jle loc_0FB2_0492
loc_0FB2_0459:    ; <- jcc:0FB2:041F
  0FB2:0459  mov bx, word ptr [0x2295]            ; ds:2295
  0FB2:045D  cmp di, bx
  0FB2:045F  jg loc_0FB2_0463
loc_0FB2_0461:    ; <- jcc:0FB2:0451
  0FB2:0461  sub bx, bx
loc_0FB2_0463:    ; <- jcc:0FB2:045F
  0FB2:0463  mov ax, bx
  0FB2:0465  sub ax, bp
  0FB2:0467  imul word ptr [0x228b]               ; ds:228B
  0FB2:046B  push bx
  0FB2:046C  mov bx, dx
  0FB2:046E  idiv word ptr [0x228d]               ; ds:228D
  0FB2:0472  mov bl, bh
  0FB2:0474  xor bl, byte ptr [0x228e]            ; ds:228E
  0FB2:0478  jns loc_0FB2_047D
  0FB2:047A  neg dx
  0FB2:047C  dec ax
loc_0FB2_047D:    ; <- jcc:0FB2:0478
  0FB2:047D  sub dx, word ptr [0x2291]            ; ds:2291
  0FB2:0481  xor dh, bh
  0FB2:0483  js loc_0FB2_0486
  0FB2:0485  inc ax
loc_0FB2_0486:    ; <- jcc:0FB2:0483
  0FB2:0486  pop bx
  0FB2:0487  add ax, cx
  0FB2:0489  js loc_0FB2_04A3
  0FB2:048B  cmp ax, word ptr [0x2293]            ; ds:2293
  0FB2:048F  jg loc_0FB2_04A3
  0FB2:0491  xchg bx, ax
loc_0FB2_0492:    ; <- jcc:0FB2:0457
  0FB2:0492  cmp byte ptr [0x228a], 0             ; ds:228A
  0FB2:0497  jne loc_0FB2_04A6
  0FB2:0499  mov word ptr [0x229f], ax            ; ds:229F
  0FB2:049C  mov word ptr [0x229b], bx            ; ds:229B
  0FB2:04A0  jmp loc_0FB2_0352
loc_0FB2_04A3:    ; <- jcc:0FB2:0489 jcc:0FB2:048F
  0FB2:04A3  jmp loc_0FB2_0378
loc_0FB2_04A6:    ; <- jcc:0FB2:0497
  0FB2:04A6  mov word ptr [0x229d], ax            ; ds:229D
  0FB2:04A9  mov word ptr [0x2299], bx            ; ds:2299
  0FB2:04AD  xchg si, cx
  0FB2:04AF  xchg di, bp
  0FB2:04B1  mov al, byte ptr [0x228a]            ; ds:228A
  0FB2:04B4  mov byte ptr [0x228a], 0             ; ds:228A
  0FB2:04B9  jmp loc_0FB2_041D

; ===== func_0FB2_04BC  reg  callers: C=0 asm=0  seeds=call =====
func_0FB2_04BC:
  0FB2:04BC  mov al, 0xf
  0FB2:04BE  or bx, bx
  0FB2:04C0  js loc_0FB2_04C4
  0FB2:04C2  and al, 0xf7
loc_0FB2_04C4:    ; <- jcc:0FB2:04C0
  0FB2:04C4  cmp bx, word ptr [0x2293]            ; ds:2293
  0FB2:04C8  jg loc_0FB2_04CC
  0FB2:04CA  and al, 0xfe
loc_0FB2_04CC:    ; <- jcc:0FB2:04C8
  0FB2:04CC  or bp, bp
  0FB2:04CE  js loc_0FB2_04D2
  0FB2:04D0  and al, 0xfb
loc_0FB2_04D2:    ; <- jcc:0FB2:04CE
  0FB2:04D2  cmp bp, word ptr [0x2295]            ; ds:2295
  0FB2:04D6  jg loc_0FB2_04DA
  0FB2:04D8  and al, 0xfd
loc_0FB2_04DA:    ; <- jcc:0FB2:04D6
  0FB2:04DA  or al, al
  0FB2:04DC  ret

; ===== func_0FB2_04DD  bp-frame  callers: C=0 asm=0  seeds=isr =====
func_0FB2_04DD:
  0FB2:04DD  push bp
  0FB2:04DE  mov bp, sp
  0FB2:04E0  cmp word ptr [bp + 2], 0x46e
  0FB2:04E5  mov ax, word ptr [0x228d]            ; ds:228D
  0FB2:04E8  je loc_0FB2_04ED
  0FB2:04EA  mov ax, word ptr [0x228b]            ; ds:228B
loc_0FB2_04ED:    ; <- jcc:0FB2:04E8
  0FB2:04ED  xor dx, ax
  0FB2:04EF  mov ax, 0x7f00
  0FB2:04F2  jns loc_0FB2_04F6
  0FB2:04F4  neg ax
loc_0FB2_04F6:    ; <- jcc:0FB2:04F2
  0FB2:04F6  add word ptr [bp + 2], 4
  0FB2:04FA  sub dx, dx
  0FB2:04FC  pop bp
  0FB2:04FD  iret

; ===== func_0FB2_04FE  bp-frame  callers: C=1 asm=0  seeds=far =====
func_0FB2_04FE:
  0FB2:04FE  push bp
  0FB2:04FF  mov bp, sp
  0FB2:0501  push di
  0FB2:0502  push si
  0FB2:0503  mov ax, word ptr [0x2615]            ; ds:2615
  0FB2:0506  mov cx, word ptr [0x2617]            ; ds:2617
  0FB2:050A  mov bx, 0x22a1
  0FB2:050D  mov dx, word ptr [bp + 6]
  0FB2:0510  call far func_1E42_01D3              ; T:01D3 slot 37
  0FB2:0515  pop si
  0FB2:0516  pop di
  0FB2:0517  pop bp
  0FB2:0518  retf

; ===== func_0FB2_0519  reg(saves)  callers: C=2 asm=0  seeds=far =====
func_0FB2_0519:
  0FB2:0519  push di
  0FB2:051A  call func_0FB2_051F
  0FB2:051D  pop di
  0FB2:051E  retf

; ===== func_0FB2_051F  reg  callers: C=0 asm=0  seeds=call =====
func_0FB2_051F:
  0FB2:051F  mov di, word ptr [0x2615]            ; ds:2615
  0FB2:0523  or di, di
  0FB2:0525  js loc_0FB2_0554
  0FB2:0527  mov ax, 0x1e42                       ; seg 1E42
  0FB2:052A  mov es, ax
  0FB2:052C  mov cx, word ptr [0x2617]            ; ds:2617
  0FB2:0530  inc cx
  0FB2:0531  sub cx, di
  0FB2:0533  shl di, 1
  0FB2:0535  mov bx, cx
  0FB2:0537  mov dx, di
  0FB2:0539  add di, 0x22a1
  0FB2:053D  mov ax, 0xffff
  0FB2:0540  rep stosw word ptr es:[di], ax
  0FB2:0542  mov word ptr [0x2615], ax            ; ds:2615
  0FB2:0545  mov cx, bx
  0FB2:0547  mov di, dx
  0FB2:0549  add di, 0x2459
  0FB2:054D  sub ax, ax
  0FB2:054F  rep stosw word ptr es:[di], ax
  0FB2:0551  mov word ptr [0x2617], ax            ; ds:2617
loc_0FB2_0554:    ; <- jcc:0FB2:0525
  0FB2:0554  ret

; ===== func_0FB2_0555  reg  callers: C=0 asm=0  seeds=call =====
func_0FB2_0555:
  0FB2:0555  mov ax, 0x1e42                       ; seg 1E42
  0FB2:0558  mov es, ax
  0FB2:055A  mov cx, di
  0FB2:055C  or si, si
  0FB2:055E  lea di, [0x22a1]                     ; ds:22A1
  0FB2:0562  je loc_0FB2_056E
  0FB2:0564  cmp si, word ptr [0x2293]            ; ds:2293
  0FB2:0568  jne loc_0FB2_05A3
  0FB2:056A  lea di, [0x2459]                     ; ds:2459
loc_0FB2_056E:    ; <- jcc:0FB2:0562
  0FB2:056E  cmp cx, dx
  0FB2:0570  jge loc_0FB2_0574
  0FB2:0572  xchg dx, cx
loc_0FB2_0574:    ; <- jcc:0FB2:0570
  0FB2:0574  or dx, dx
  0FB2:0576  jns loc_0FB2_057A
  0FB2:0578  sub dx, dx
loc_0FB2_057A:    ; <- jcc:0FB2:0576
  0FB2:057A  cmp cx, word ptr [0x2295]            ; ds:2295
  0FB2:057E  jle loc_0FB2_0584
  0FB2:0580  mov cx, word ptr [0x2295]            ; ds:2295
loc_0FB2_0584:    ; <- jcc:0FB2:057E
  0FB2:0584  cmp cx, word ptr [0x2617]            ; ds:2617
  0FB2:0588  jbe loc_0FB2_058E
  0FB2:058A  mov word ptr [0x2617], cx            ; ds:2617
loc_0FB2_058E:    ; <- jcc:0FB2:0588
  0FB2:058E  cmp dx, word ptr [0x2615]            ; ds:2615
  0FB2:0592  jae loc_0FB2_0598
  0FB2:0594  mov word ptr [0x2615], dx            ; ds:2615
loc_0FB2_0598:    ; <- jcc:0FB2:0592
  0FB2:0598  add di, dx
  0FB2:059A  add di, dx
  0FB2:059C  sub cx, dx
  0FB2:059E  inc cx
  0FB2:059F  mov ax, si
  0FB2:05A1  rep stosw word ptr es:[di], ax
loc_0FB2_05A3:    ; <- jcc:0FB2:0568
  0FB2:05A3  ret
loc_0FB2_05A4:    ; <- jmp:0FB2:0822
  0FB2:05A4  sub si, si
  0FB2:05A6  or bx, bx
  0FB2:05A8  js func_0FB2_0555
  0FB2:05AA  mov si, word ptr [0x2293]            ; ds:2293
  0FB2:05AE  cmp bx, si
  0FB2:05B0  jg func_0FB2_0555
  0FB2:05B2  ret
loc_0FB2_05B3:    ; <- jmp:0FB2:084B
  0FB2:05B3  mov ax, word ptr [0x229b]            ; ds:229B
  0FB2:05B6  cmp ax, word ptr [0x2299]            ; ds:2299
  0FB2:05BA  jae loc_0FB2_05D5
  0FB2:05BC  mov bx, word ptr [0x2299]            ; ds:2299
  0FB2:05C0  mov word ptr [0x229b], bx            ; ds:229B
  0FB2:05C4  mov word ptr [0x2299], ax            ; ds:2299
  0FB2:05C7  mov ax, word ptr [0x229f]            ; ds:229F
  0FB2:05CA  mov bx, word ptr [0x229d]            ; ds:229D
  0FB2:05CE  mov word ptr [0x229f], bx            ; ds:229F
  0FB2:05D2  mov word ptr [0x229d], ax            ; ds:229D
loc_0FB2_05D5:    ; <- jcc:0FB2:05BA
  0FB2:05D5  mov bx, word ptr [0x229b]            ; ds:229B
  0FB2:05D9  sub bx, word ptr [0x2299]            ; ds:2299
  0FB2:05DD  mov word ptr [0x2611], bx            ; ds:2611
  0FB2:05E1  mov ax, word ptr [0x229f]            ; ds:229F
  0FB2:05E4  mov dx, ax
  0FB2:05E6  mov cx, word ptr [0x229d]            ; ds:229D
  0FB2:05EA  sub ax, cx
  0FB2:05EC  mov bp, 2
  0FB2:05EF  jns loc_0FB2_05F7
  0FB2:05F1  xchg dx, cx
  0FB2:05F3  neg bp
  0FB2:05F5  neg ax
loc_0FB2_05F7:    ; <- jcc:0FB2:05EF
  0FB2:05F7  mov word ptr [0x2613], ax            ; ds:2613
  0FB2:05FA  cmp dx, word ptr [0x2617]            ; ds:2617
  0FB2:05FE  jbe loc_0FB2_0604
  0FB2:0600  mov word ptr [0x2617], dx            ; ds:2617
loc_0FB2_0604:    ; <- jcc:0FB2:05FE
  0FB2:0604  cmp cx, word ptr [0x2615]            ; ds:2615
  0FB2:0608  jae loc_0FB2_060E
  0FB2:060A  mov word ptr [0x2615], cx            ; ds:2615
loc_0FB2_060E:    ; <- jcc:0FB2:0608
  0FB2:060E  cmp ax, bx
  0FB2:0610  jae loc_0FB2_065D
  0FB2:0612  mov di, word ptr [0x229d]            ; ds:229D
  0FB2:0616  shl di, 1
  0FB2:0618  mov ax, word ptr [0x2299]            ; ds:2299
  0FB2:061B  mov dx, word ptr [0x2611]            ; ds:2611
  0FB2:061F  mov cx, dx
  0FB2:0621  mov bx, cx
  0FB2:0623  inc bx
  0FB2:0624  shr bx, 1
  0FB2:0626  neg bx
  0FB2:0628  mov si, word ptr [0x2613]            ; ds:2613
  0FB2:062C  jmp loc_0FB2_063E

; ----- data 0FB2:062E .. 0FB2:062E (1 bytes) -----
;   0FB2:062E  90                                               .
loc_0FB2_062F:    ; <- jcc:0FB2:064D
  0FB2:062F  cmp ax, word ptr [di + 0x2459]
  0FB2:0633  jbe loc_0FB2_0639
  0FB2:0635  mov word ptr [di + 0x2459], ax
loc_0FB2_0639:    ; <- jcc:0FB2:0633
  0FB2:0639  inc ax
  0FB2:063A  sub bx, dx
  0FB2:063C  add di, bp
loc_0FB2_063E:    ; <- jmp:0FB2:062C
  0FB2:063E  cmp ax, word ptr [di + 0x22a1]
  0FB2:0642  jae loc_0FB2_0648
  0FB2:0644  mov word ptr [di + 0x22a1], ax
loc_0FB2_0648:    ; <- jcc:0FB2:0642 jmp:0FB2:0650
  0FB2:0648  dec cx
  0FB2:0649  js loc_0FB2_0652
  0FB2:064B  add bx, si
  0FB2:064D  jns loc_0FB2_062F
  0FB2:064F  inc ax
  0FB2:0650  jmp loc_0FB2_0648
loc_0FB2_0652:    ; <- jcc:0FB2:0649
  0FB2:0652  cmp ax, word ptr [di + 0x2459]
  0FB2:0656  jbe loc_0FB2_065C
  0FB2:0658  mov word ptr [di + 0x2459], ax
loc_0FB2_065C:    ; <- jcc:0FB2:0656
  0FB2:065C  ret
loc_0FB2_065D:    ; <- jcc:0FB2:0610
  0FB2:065D  mov di, word ptr [0x229d]            ; ds:229D
  0FB2:0661  shl di, 1
  0FB2:0663  mov ax, word ptr [0x2299]            ; ds:2299
  0FB2:0666  mov dx, word ptr [0x2613]            ; ds:2613
  0FB2:066A  mov cx, dx
  0FB2:066C  mov bx, cx
  0FB2:066E  inc bx
  0FB2:066F  shr bx, 1
  0FB2:0671  neg bx
  0FB2:0673  mov si, word ptr [0x2611]            ; ds:2611
loc_0FB2_0677:    ; <- jcc:0FB2:0692 jmp:0FB2:0697
  0FB2:0677  cmp ax, word ptr [di + 0x22a1]
  0FB2:067B  jae loc_0FB2_0681
  0FB2:067D  mov word ptr [di + 0x22a1], ax
loc_0FB2_0681:    ; <- jcc:0FB2:067B
  0FB2:0681  cmp ax, word ptr [di + 0x2459]
  0FB2:0685  jbe loc_0FB2_068B
  0FB2:0687  mov word ptr [di + 0x2459], ax
loc_0FB2_068B:    ; <- jcc:0FB2:0685
  0FB2:068B  dec cx
  0FB2:068C  js loc_0FB2_0699
  0FB2:068E  add di, bp
  0FB2:0690  add bx, si
  0FB2:0692  js loc_0FB2_0677
  0FB2:0694  sub bx, dx
  0FB2:0696  inc ax
  0FB2:0697  jmp loc_0FB2_0677
loc_0FB2_0699:    ; <- jcc:0FB2:068C
  0FB2:0699  ret

; ===== func_0FB2_069A  reg(saves)  callers: C=2 asm=0  seeds=far =====
func_0FB2_069A:
  0FB2:069A  push es
  0FB2:069B  push si
  0FB2:069C  push di
  0FB2:069D  push bp
  0FB2:069E  call func_0FB2_06A6
  0FB2:06A1  pop bp
  0FB2:06A2  pop di
  0FB2:06A3  pop si
  0FB2:06A4  pop es
  0FB2:06A5  retf

; ===== func_0FB2_06A6  reg  callers: C=0 asm=0  seeds=call =====
func_0FB2_06A6:
  0FB2:06A6  sub ax, ax
  0FB2:06A8  mov es, ax
  0FB2:06AA  push word ptr es:[0]
  0FB2:06AF  push word ptr es:[2]
  0FB2:06B4  lea ax, [0x84e]                      ; ds:084E
  0FB2:06B8  mov word ptr es:[0], ax
  0FB2:06BC  mov word ptr es:[2], 0xfb2           ; seg 0FB2
  0FB2:06C3  push ds
  0FB2:06C4  pop es
  0FB2:06C5  jmp loc_0FB2_0715

; ----- data 0FB2:06C7 .. 0FB2:06C7 (1 bytes) -----
;   0FB2:06C7  90                                               .
loc_0FB2_06C8:    ; <- jcc:0FB2:06DF
  0FB2:06C8  sub ax, ax
  0FB2:06CA  mov es, ax
  0FB2:06CC  pop word ptr es:[2]
  0FB2:06D1  pop word ptr es:[0]
  0FB2:06D6  push ds
  0FB2:06D7  pop es
  0FB2:06D8  ret
loc_0FB2_06D9:    ; <- jcc:0FB2:0755
  0FB2:06D9  and al, byte ptr [0x261a]            ; ds:261A
  0FB2:06DD  test al, 6
  0FB2:06DF  jne loc_0FB2_06C8
  0FB2:06E1  mov bx, cx
  0FB2:06E3  jmp loc_0FB2_0810
loc_0FB2_06E6:    ; <- jcc:0FB2:073D
  0FB2:06E6  jmp loc_0FB2_083B
loc_0FB2_06E9:    ; <- jcc:0FB2:075B
  0FB2:06E9  cmc
  0FB2:06EA  rcr dx, 1
  0FB2:06EC  mov word ptr [0x261b], dx            ; ds:261B
  0FB2:06F0  sar dx, 1
  0FB2:06F2  mov word ptr [0x261f], dx            ; ds:261F
  0FB2:06F6  mov dx, di
  0FB2:06F8  sub dx, bp
  0FB2:06FA  jno loc_0FB2_0702
  0FB2:06FC  cmc
  0FB2:06FD  rcr dx, 1
  0FB2:06FF  jmp loc_0FB2_076D

; ----- data 0FB2:0701 .. 0FB2:0701 (1 bytes) -----
;   0FB2:0701  90                                               .
loc_0FB2_0702:    ; <- jcc:0FB2:06FA
  0FB2:0702  sar dx, 1
  0FB2:0704  jmp loc_0FB2_076D

; ----- data 0FB2:0706 .. 0FB2:0706 (1 bytes) -----
;   0FB2:0706  90                                               .
loc_0FB2_0707:    ; <- jcc:0FB2:076B
  0FB2:0707  cmc
  0FB2:0708  rcr dx, 1
  0FB2:070A  sar word ptr [0x261b], 1             ; ds:261B
  0FB2:070E  sar word ptr [0x261f], 1             ; ds:261F
  0FB2:0712  jmp loc_0FB2_076D

; ----- data 0FB2:0714 .. 0FB2:0714 (1 bytes) -----
;   0FB2:0714  90                                               .
loc_0FB2_0715:    ; <- jmp:0FB2:06C5
  0FB2:0715  mov cx, word ptr [0x2299]            ; ds:2299
  0FB2:0719  mov dx, word ptr [0x229d]            ; ds:229D
  0FB2:071D  mov si, word ptr [0x229b]            ; ds:229B
  0FB2:0721  mov di, word ptr [0x229f]            ; ds:229F
  0FB2:0725  mov bx, cx
  0FB2:0727  mov bp, dx
  0FB2:0729  call func_0FB2_04BC
  0FB2:072C  mov byte ptr [0x261a], al            ; ds:261A
  0FB2:072F  mov bx, si
  0FB2:0731  mov bp, di
  0FB2:0733  call func_0FB2_04BC
  0FB2:0736  jne loc_0FB2_074F
  0FB2:0738  cmp byte ptr [0x261a], 0             ; ds:261A
  0FB2:073D  je loc_0FB2_06E6
  0FB2:073F  xchg si, cx
  0FB2:0741  xchg di, dx
  0FB2:0743  xchg byte ptr [0x261a], al           ; ds:261A
  0FB2:0747  mov word ptr [0x2299], cx            ; ds:2299
  0FB2:074B  mov word ptr [0x229d], dx            ; ds:229D
loc_0FB2_074F:    ; <- jcc:0FB2:0736
  0FB2:074F  mov bp, dx
  0FB2:0751  test byte ptr [0x261a], al           ; ds:261A
  0FB2:0755  jne loc_0FB2_06D9
  0FB2:0757  mov dx, si
  0FB2:0759  sub dx, cx
  0FB2:075B  jo loc_0FB2_06E9
  0FB2:075D  mov word ptr [0x261b], dx            ; ds:261B
  0FB2:0761  sar dx, 1
  0FB2:0763  mov word ptr [0x261f], dx            ; ds:261F
  0FB2:0767  mov dx, di
  0FB2:0769  sub dx, bp
  0FB2:076B  jo loc_0FB2_0707
loc_0FB2_076D:    ; <- jmp:0FB2:06FF jmp:0FB2:0704 jmp:0FB2:0712
  0FB2:076D  mov word ptr [0x261d], dx            ; ds:261D
  0FB2:0771  sar dx, 1
  0FB2:0773  mov word ptr [0x2621], dx            ; ds:2621
loc_0FB2_0777:    ; <- jmp:0FB2:0838
  0FB2:0777  test al, 9
  0FB2:0779  je loc_0FB2_07B3
  0FB2:077B  sub bx, bx
  0FB2:077D  or si, si
  0FB2:077F  js loc_0FB2_0785
  0FB2:0781  mov bx, word ptr [0x2293]            ; ds:2293
loc_0FB2_0785:    ; <- jcc:0FB2:077F
  0FB2:0785  mov ax, bx
  0FB2:0787  sub ax, cx
  0FB2:0789  imul word ptr [0x261d]               ; ds:261D
  0FB2:078D  push bx
  0FB2:078E  mov bx, dx
  0FB2:0790  idiv word ptr [0x261b]               ; ds:261B
  0FB2:0794  mov bl, bh
  0FB2:0796  xor bl, byte ptr [0x261c]            ; ds:261C
  0FB2:079A  jns loc_0FB2_079F
  0FB2:079C  neg dx
  0FB2:079E  dec ax
loc_0FB2_079F:    ; <- jcc:0FB2:079A
  0FB2:079F  sub dx, word ptr [0x261f]            ; ds:261F
  0FB2:07A3  xor dh, bh
  0FB2:07A5  js loc_0FB2_07A8
  0FB2:07A7  inc ax
loc_0FB2_07A8:    ; <- jcc:0FB2:07A5
  0FB2:07A8  pop bx
  0FB2:07A9  add ax, bp
  0FB2:07AB  js loc_0FB2_07BB
  0FB2:07AD  cmp ax, word ptr [0x2295]            ; ds:2295
  0FB2:07B1  jle loc_0FB2_07EC
loc_0FB2_07B3:    ; <- jcc:0FB2:0779
  0FB2:07B3  mov bx, word ptr [0x2295]            ; ds:2295
  0FB2:07B7  cmp di, bx
  0FB2:07B9  jg loc_0FB2_07BD
loc_0FB2_07BB:    ; <- jcc:0FB2:07AB
  0FB2:07BB  sub bx, bx
loc_0FB2_07BD:    ; <- jcc:0FB2:07B9
  0FB2:07BD  mov ax, bx
  0FB2:07BF  sub ax, bp
  0FB2:07C1  imul word ptr [0x261b]               ; ds:261B
  0FB2:07C5  push bx
  0FB2:07C6  mov bx, dx
  0FB2:07C8  idiv word ptr [0x261d]               ; ds:261D
  0FB2:07CC  mov bl, bh
  0FB2:07CE  xor bl, byte ptr [0x261e]            ; ds:261E
  0FB2:07D2  jns loc_0FB2_07D7
  0FB2:07D4  neg dx
  0FB2:07D6  dec ax
loc_0FB2_07D7:    ; <- jcc:0FB2:07D2
  0FB2:07D7  sub dx, word ptr [0x2621]            ; ds:2621
  0FB2:07DB  xor dh, bh
  0FB2:07DD  js loc_0FB2_07E0
  0FB2:07DF  inc ax
loc_0FB2_07E0:    ; <- jcc:0FB2:07DD
  0FB2:07E0  pop bx
  0FB2:07E1  add ax, cx
  0FB2:07E3  xchg bx, ax
  0FB2:07E4  js loc_0FB2_0810
  0FB2:07E6  cmp bx, word ptr [0x2293]            ; ds:2293
  0FB2:07EA  jg loc_0FB2_0810
loc_0FB2_07EC:    ; <- jcc:0FB2:07B1
  0FB2:07EC  push ax
  0FB2:07ED  push bx
  0FB2:07EE  push cx
  0FB2:07EF  push si
  0FB2:07F0  push di
  0FB2:07F1  mov dx, di
  0FB2:07F3  mov di, ax
  0FB2:07F5  mov si, bx
  0FB2:07F7  call func_0FB2_0555
  0FB2:07FA  pop di
  0FB2:07FB  pop si
  0FB2:07FC  pop cx
  0FB2:07FD  pop bx
  0FB2:07FE  pop ax
  0FB2:07FF  cmp byte ptr [0x261a], 0             ; ds:261A
  0FB2:0804  jne loc_0FB2_0825
  0FB2:0806  mov word ptr [0x229f], ax            ; ds:229F
  0FB2:0809  mov word ptr [0x229b], bx            ; ds:229B
  0FB2:080D  jmp loc_0FB2_083B

; ----- data 0FB2:080F .. 0FB2:080F (1 bytes) -----
;   0FB2:080F  90                                               .
loc_0FB2_0810:    ; <- jcc:0FB2:07E4 jcc:0FB2:07EA jmp:0FB2:06E3
  0FB2:0810  mov dx, bp
  0FB2:0812  sub ax, ax
  0FB2:0814  mov es, ax
  0FB2:0816  pop word ptr es:[2]
  0FB2:081B  pop word ptr es:[0]
  0FB2:0820  push ds
  0FB2:0821  pop es
  0FB2:0822  jmp loc_0FB2_05A4
loc_0FB2_0825:    ; <- jcc:0FB2:0804
  0FB2:0825  mov word ptr [0x229d], ax            ; ds:229D
  0FB2:0828  mov word ptr [0x2299], bx            ; ds:2299
  0FB2:082C  xchg si, cx
  0FB2:082E  xchg di, bp
  0FB2:0830  mov al, byte ptr [0x261a]            ; ds:261A
  0FB2:0833  mov byte ptr [0x261a], 0             ; ds:261A
  0FB2:0838  jmp loc_0FB2_0777
loc_0FB2_083B:    ; <- jmp:0FB2:06E6 jmp:0FB2:080D
  0FB2:083B  sub ax, ax
  0FB2:083D  mov es, ax
  0FB2:083F  pop word ptr es:[2]
  0FB2:0844  pop word ptr es:[0]
  0FB2:0849  push ds
  0FB2:084A  pop es
  0FB2:084B  jmp loc_0FB2_05B3

; ===== func_0FB2_084E  bp-frame  callers: C=0 asm=0  seeds=isr =====
func_0FB2_084E:
  0FB2:084E  push bp
  0FB2:084F  mov bp, sp
  0FB2:0851  cmp word ptr [bp + 2], 0x7c8
  0FB2:0856  mov ax, word ptr [0x261d]            ; ds:261D
  0FB2:0859  je loc_0FB2_085E
  0FB2:085B  mov ax, word ptr [0x261b]            ; ds:261B
loc_0FB2_085E:    ; <- jcc:0FB2:0859
  0FB2:085E  xor dx, ax
  0FB2:0860  mov ax, 0x7f00
  0FB2:0863  jns loc_0FB2_0867
  0FB2:0865  neg ax
loc_0FB2_0867:    ; <- jcc:0FB2:0863
  0FB2:0867  add word ptr [bp + 2], 4
  0FB2:086B  sub dx, dx
  0FB2:086D  pop bp
  0FB2:086E  iret

; ----- data 0FB2:086F .. 0FB2:086F (1 bytes) -----
;   0FB2:086F  00                                               .
