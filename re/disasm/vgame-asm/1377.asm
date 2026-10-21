; VGAME segment 1377  lin 13770..14526  size 3510 (code runs past the next paragraph value; listed here)  dgroup=1E42  (vgame_asm.py; capstone recursive descent)
; entries: 28   far-call sites into this segment: 12   unresolved indirect jumps/calls: 3

; ----- data 1377:0000 .. 1377:000B (12 bytes) -----
;   1377:0000  CD 08 EB E1 83 CD 01 C3 83 CD 02 C3              ............

; ===== func_1377_000C  bp-frame  callers: C=1 asm=0  seeds=far =====
func_1377_000C:
  1377:000C  push bp
  1377:000D  mov bp, sp
  1377:000F  mov ax, word ptr [bp + 6]
  1377:0012  sub ah, ah
  1377:0014  cmp al, 0x61
  1377:0016  jb loc_1377_001A
  1377:0018  sub al, 0x20
loc_1377_001A:    ; <- jcc:1377:0016
  1377:001A  mov word ptr [0x85f4], ax            ; ds:85F4
  1377:001D  cmp al, 0x45
  1377:001F  jne loc_1377_0026
  1377:0021  call func_1377_00F3
  1377:0024  pop bp
  1377:0025  retf
loc_1377_0026:    ; <- jcc:1377:001F
  1377:0026  cmp al, 0x4d
  1377:0028  jne loc_1377_002F
  1377:002A  call func_1377_0116
  1377:002D  pop bp
  1377:002E  retf
loc_1377_002F:    ; <- jcc:1377:0028
  1377:002F  cmp al, 0x43
  1377:0031  jne loc_1377_0038
  1377:0033  call func_1377_0132
  1377:0036  pop bp
  1377:0037  retf
loc_1377_0038:    ; <- jcc:1377:0031
  1377:0038  cmp al, 0x54
  1377:003A  jne loc_1377_0041
  1377:003C  call func_1377_0155
  1377:003F  pop bp
  1377:0040  retf
loc_1377_0041:    ; <- jcc:1377:003A
  1377:0041  pop bp
  1377:0042  retf

; ----- data 1377:0043 .. 1377:004B (9 bytes) -----
;   1377:0043  8B 1E F2 85 2E FF 57 02 CB                       ......W..

; ===== func_1377_004C  reg  callers: C=0 asm=4  seeds=far =====
func_1377_004C:
  1377:004C  mov bx, word ptr [0x85f2]            ; ds:85F2
  1377:0050  call word ptr cs:[bx + 4]
  1377:0054  retf

; ===== func_1377_0055  reg  callers: C=0 asm=3  seeds=far =====
func_1377_0055:
  1377:0055  mov bx, word ptr [0x85f2]            ; ds:85F2
  1377:0059  call word ptr cs:[bx + 6]
  1377:005D  retf

; ===== func_1377_005E  reg  callers: C=0 asm=1  seeds=far =====
func_1377_005E:
  1377:005E  mov bx, word ptr [0x85f2]            ; ds:85F2
  1377:0062  call word ptr cs:[bx + 8]
  1377:0066  retf

; ----- data 1377:0067 .. 1377:00C1 (91 bytes) -----
;   1377:0067  8B 1E F2 85 2E FF 57 0A CB F3 00 46 02 BD 01 7B  ......W....F...{
;   1377:0077  03 86 08 46 08 16 01 87 02 E0 01 6F 04 09 0B 09  ...F.......o....
;   1377:0087  0B 32 01 C4 02 04 02 17 05 C5 0B C5 0B 55 01 11  .2...........U..
;   1377:0097  03 29 02 19 06 B3 0C B3 0C 55 8B EC B4 48 BB FF  .).......U...H..
;   1377:00A7  FF CD 21 73 12 81 EB 00 04 3B 5E 06 77 09 8B 5E  ..!s.....;^.w..^
;   1377:00B7  06 B4 48 CD 21 5D CB 2B C0 5D CB                 ..H.!].+.].
loc_1377_00C2:    ; <- jcc:1377:00F8
  1377:00C2  mov cx, 0x1e0
  1377:00C5  mov ax, ds
  1377:00C7  mov es, ax
  1377:00C9  lea di, [0x861c]                     ; ds:861C
  1377:00CD  sub ax, ax
loc_1377_00CF:    ; <- jcc:1377:00D3
  1377:00CF  stosw word ptr es:[di], ax
  1377:00D0  add ax, 0x50
  1377:00D3  loop loc_1377_00CF
  1377:00D5  lea bx, [0x70]                       ; ds:0070
  1377:00D9  mov word ptr [0x85f2], bx            ; ds:85F2
  1377:00DD  mov ax, 0x28
  1377:00E0  shl ax, 1
  1377:00E2  mov bx, ax
  1377:00E4  sub ax, 1
  1377:00E7  mov word ptr [0x9172], ax            ; ds:9172
  1377:00EA  mov ax, bx
  1377:00EC  inc ax
  1377:00ED  neg ax
  1377:00EF  mov word ptr [0x9174], ax            ; ds:9174
  1377:00F2  ret

; ===== func_1377_00F3  reg  callers: C=0 asm=0  seeds=call,vtab =====
func_1377_00F3:
  1377:00F3  cmp word ptr [0x916e], 0             ; ds:916E
  1377:00F8  jne loc_1377_00C2
  1377:00FA  mov cx, 0xc8
  1377:00FD  mov ax, ds
  1377:00FF  mov es, ax
  1377:0101  lea di, [0x861c]                     ; ds:861C
  1377:0105  sub ax, ax
loc_1377_0107:    ; <- jcc:1377:010B
  1377:0107  stosw word ptr es:[di], ax
  1377:0108  add ax, 0x28
  1377:010B  loop loc_1377_0107
  1377:010D  lea bx, [0x70]                       ; ds:0070
  1377:0111  mov word ptr [0x85f2], bx            ; ds:85F2
  1377:0115  ret

; ===== func_1377_0116  reg  callers: C=0 asm=0  seeds=call,vtab =====
func_1377_0116:
  1377:0116  mov cx, 0xc8
  1377:0119  mov ax, ds
  1377:011B  mov es, ax
  1377:011D  lea di, [0x861c]                     ; ds:861C
  1377:0121  sub ax, ax
loc_1377_0123:    ; <- jcc:1377:0127
  1377:0123  stosw word ptr es:[di], ax
  1377:0124  add ax, 0x140
  1377:0127  loop loc_1377_0123
  1377:0129  lea bx, [0x7c]                       ; ds:007C
  1377:012D  mov word ptr [0x85f2], bx            ; ds:85F2
  1377:0131  ret

; ===== func_1377_0132  reg  callers: C=0 asm=0  seeds=call,vtab =====
func_1377_0132:
  1377:0132  mov cx, 0x64
  1377:0135  mov ax, ds
  1377:0137  mov es, ax
  1377:0139  lea di, [0x861c]                     ; ds:861C
  1377:013D  sub ax, ax
loc_1377_013F:    ; <- jcc:1377:014A
  1377:013F  stosw word ptr es:[di], ax
  1377:0140  add ax, 0x2000
  1377:0143  stosw word ptr es:[di], ax
  1377:0144  sub ax, 0x2000
  1377:0147  add ax, 0x50
  1377:014A  loop loc_1377_013F
  1377:014C  lea bx, [0x88]                       ; ds:0088
  1377:0150  mov word ptr [0x85f2], bx            ; ds:85F2
  1377:0154  ret

; ===== func_1377_0155  reg  callers: C=0 asm=0  seeds=call,vtab =====
func_1377_0155:
  1377:0155  mov cx, 0x32
  1377:0158  mov ax, ds
  1377:015A  mov es, ax
  1377:015C  lea di, [0x861c]                     ; ds:861C
  1377:0160  sub ax, ax
loc_1377_0162:    ; <- jcc:1377:0175
  1377:0162  stosw word ptr es:[di], ax
  1377:0163  add ax, 0x2000
  1377:0166  stosw word ptr es:[di], ax
  1377:0167  add ax, 0x2000
  1377:016A  stosw word ptr es:[di], ax
  1377:016B  add ax, 0x2000
  1377:016E  stosw word ptr es:[di], ax
  1377:016F  sub ax, 0x6000
  1377:0172  add ax, 0xa0
  1377:0175  loop loc_1377_0162
  1377:0177  lea bx, [0x94]                       ; ds:0094
  1377:017B  mov word ptr [0x85f2], bx            ; ds:85F2
  1377:017F  ret

; ----- data 1377:0180 .. 1377:01BC (61 bytes) -----
;   1377:0180  83 3E F4 85 45 74 01 CB BA C4 03 B8 02 0F EF BA  .>..Et..........
;   1377:0190  CE 03 B8 01 00 EF B8 08 FF EF B8 05 00 EF B8 03  ................
;   1377:01A0  00 EF B8 04 00 EF CB 55 8B EC 8B 46 06 A3 F6 85  .......U...F....
;   1377:01B0  8B D8 D1 E3 8B 87 12 86 A3 1A 86 5D CB           ...........].

; ===== func_1377_01BD  reg  callers: C=0 asm=0  seeds=call,vtab =====
func_1377_01BD:
  1377:01BD  mov bx, ax
  1377:01BF  sub bh, bh
  1377:01C1  mov word ptr [0x8606], bx            ; ds:8606
  1377:01C5  shl bx, 1
  1377:01C7  mov ax, word ptr [bx - 0x6e68]
  1377:01CB  xchg ah, al
  1377:01CD  mov bx, ax
  1377:01CF  mov dx, 0x3ce
  1377:01D2  mov al, 0
  1377:01D4  out dx, ax
  1377:01D5  inc al
  1377:01D7  mov ah, bl
  1377:01D9  out dx, ax
  1377:01DA  mov ax, word ptr [0x861a]            ; ds:861A
  1377:01DD  mov es, ax
  1377:01DF  ret

; ===== func_1377_01E0  reg  callers: C=0 asm=0  seeds=vtab =====
func_1377_01E0:
  1377:01E0  mov word ptr [0x8606], ax            ; ds:8606
  1377:01E3  cmp ah, 0xff
  1377:01E6  jne loc_1377_01FE
  1377:01E8  cmp al, 0xa0
  1377:01EA  jb loc_1377_01FE
  1377:01EC  mov ah, al
  1377:01EE  and ah, 0xf0
  1377:01F1  sub al, byte ptr [0x48c4]            ; ds:48C4
  1377:01F5  cmp al, ah
  1377:01F7  ja loc_1377_01FB
  1377:01F9  mov al, ah
loc_1377_01FB:    ; <- jcc:1377:01F7
  1377:01FB  mov byte ptr [0x8606], al            ; ds:8606
loc_1377_01FE:    ; <- jcc:1377:01E6 jcc:1377:01EA
  1377:01FE  mov ax, word ptr [0x861a]            ; ds:861A
  1377:0201  mov es, ax
  1377:0203  ret

; ===== func_1377_0204  reg  callers: C=0 asm=0  seeds=call,vtab =====
func_1377_0204:
  1377:0204  mov word ptr [0x8606], ax            ; ds:8606
  1377:0207  mov bx, ax
  1377:0209  and bx, 0xf
  1377:020C  mov ax, word ptr [0x861a]            ; ds:861A
  1377:020F  mov es, ax
  1377:0211  mov al, byte ptr [bx - 0x6e68]
  1377:0215  mov ah, al
  1377:0217  mov word ptr [0x917a], ax            ; ds:917A
  1377:021A  and ax, 0x3333
  1377:021D  shl al, 1
  1377:021F  shl al, 1
  1377:0221  or al, ah
  1377:0223  mov ah, al
  1377:0225  mov word ptr [0x917c], ax            ; ds:917C
  1377:0228  ret

; ===== func_1377_0229  reg  callers: C=0 asm=0  seeds=call,vtab =====
func_1377_0229:
  1377:0229  mov ah, al
  1377:022B  mov word ptr [0x8606], ax            ; ds:8606
  1377:022E  shl al, 1
  1377:0230  shl al, 1
  1377:0232  shl al, 1
  1377:0234  shl al, 1
  1377:0236  and ah, 0xf
  1377:0239  or al, ah
  1377:023B  mov ah, al
  1377:023D  mov word ptr [0x917e], ax            ; ds:917E
  1377:0240  mov ax, word ptr [0x861a]            ; ds:861A
  1377:0243  mov es, ax
  1377:0245  ret

; ===== func_1377_0246  bp-frame  callers: C=0 asm=0  seeds=vtab =====
func_1377_0246:
  1377:0246  push bp
  1377:0247  mov bp, sp
  1377:0249  mov ax, word ptr [bp + 6]
  1377:024C  cmp ax, word ptr [0x85fa]            ; ds:85FA
  1377:0250  jl loc_1377_0285
  1377:0252  cmp ax, word ptr [0x85fe]            ; ds:85FE
  1377:0256  jg loc_1377_0285
  1377:0258  mov word ptr [0x9162], ax            ; ds:9162
  1377:025B  mov ax, word ptr [bp + 8]
  1377:025E  cmp ax, word ptr [0x85fc]            ; ds:85FC
  1377:0262  jl loc_1377_0285
  1377:0264  cmp ax, word ptr [0x8600]            ; ds:8600
  1377:0268  jg loc_1377_0285
  1377:026A  mov word ptr [0x9164], ax            ; ds:9164
  1377:026D  mov ax, word ptr [bp + 0xa]
  1377:0270  call func_1377_01BD
  1377:0273  call func_1377_0356
  1377:0276  out dx, al
  1377:0277  mov ah, byte ptr es:[di]
  1377:027A  mov al, 0x55
  1377:027C  test si, 2
  1377:0280  je loc_1377_0284
  1377:0282  rol al, 1
loc_1377_0284:    ; <- jcc:1377:0280
  1377:0284  stosb byte ptr es:[di], al
loc_1377_0285:    ; <- jcc:1377:0250 jcc:1377:0256 jcc:1377:0262 jcc:1377:0268
  1377:0285  pop bp
  1377:0286  retf

; ===== func_1377_0287  bp-frame  callers: C=0 asm=0  seeds=vtab =====
func_1377_0287:
  1377:0287  push bp
  1377:0288  mov bp, sp
  1377:028A  mov ax, word ptr [bp + 6]
  1377:028D  cmp ax, word ptr [0x85fa]            ; ds:85FA
  1377:0291  jl loc_1377_02C2
  1377:0293  cmp ax, word ptr [0x85fe]            ; ds:85FE
  1377:0297  jg loc_1377_02C2
  1377:0299  mov word ptr [0x9162], ax            ; ds:9162
  1377:029C  mov ax, word ptr [bp + 8]
  1377:029F  cmp ax, word ptr [0x85fc]            ; ds:85FC
  1377:02A3  jl loc_1377_02C2
  1377:02A5  cmp ax, word ptr [0x8600]            ; ds:8600
  1377:02A9  jg loc_1377_02C2
  1377:02AB  shl ax, 1
  1377:02AD  mov bx, ax
  1377:02AF  mov ax, word ptr [0x861a]            ; ds:861A
  1377:02B2  mov es, ax
  1377:02B4  mov di, word ptr [bx - 0x79e4]
  1377:02B8  add di, word ptr [bp + 6]
  1377:02BB  mov ax, word ptr [bp + 0xa]
  1377:02BE  mov word ptr [0x8606], ax            ; ds:8606
  1377:02C1  stosb byte ptr es:[di], al
loc_1377_02C2:    ; <- jcc:1377:0291 jcc:1377:0297 jcc:1377:02A3 jcc:1377:02A9
  1377:02C2  pop bp
  1377:02C3  retf

; ===== func_1377_02C4  bp-frame  callers: C=0 asm=0  seeds=vtab =====
func_1377_02C4:
  1377:02C4  push bp
  1377:02C5  mov bp, sp
  1377:02C7  mov ax, word ptr [bp + 6]
  1377:02CA  cmp ax, word ptr [0x85fa]            ; ds:85FA
  1377:02CE  jl loc_1377_030F
  1377:02D0  cmp ax, word ptr [0x85fe]            ; ds:85FE
  1377:02D4  jg loc_1377_030F
  1377:02D6  mov bx, word ptr [bp + 8]
  1377:02D9  cmp bx, word ptr [0x85fc]            ; ds:85FC
  1377:02DD  jl loc_1377_030F
  1377:02DF  cmp bx, word ptr [0x8600]            ; ds:8600
  1377:02E3  jg loc_1377_030F
  1377:02E5  shl bx, 1
  1377:02E7  mov di, word ptr [0x861a]            ; ds:861A
  1377:02EB  mov es, di
  1377:02ED  mov di, word ptr [bx - 0x79e4]
  1377:02F1  mov cx, ax
  1377:02F3  sar ax, 1
  1377:02F5  sar ax, 1
  1377:02F7  add di, ax
  1377:02F9  call func_1377_0204
  1377:02FC  and cx, 3
  1377:02FF  mov bx, cx
  1377:0301  mov ah, byte ptr [bx - 0x6e68]
  1377:0305  and al, ah
  1377:0307  not ah
  1377:0309  and ah, byte ptr es:[di]
  1377:030C  or al, ah
  1377:030E  stosb byte ptr es:[di], al
loc_1377_030F:    ; <- jcc:1377:02CE jcc:1377:02D4 jcc:1377:02DD jcc:1377:02E3
  1377:030F  pop bp
  1377:0310  retf

; ===== func_1377_0311  bp-frame  callers: C=0 asm=0  seeds=vtab =====
func_1377_0311:
  1377:0311  push bp
  1377:0312  mov bp, sp
  1377:0314  mov ax, word ptr [bp + 6]
  1377:0317  cmp ax, word ptr [0x85fa]            ; ds:85FA
  1377:031B  jl loc_1377_0354
  1377:031D  cmp ax, word ptr [0x85fe]            ; ds:85FE
  1377:0321  jg loc_1377_0354
  1377:0323  mov bx, word ptr [bp + 8]
  1377:0326  cmp bx, word ptr [0x85fc]            ; ds:85FC
  1377:032A  jl loc_1377_0354
  1377:032C  cmp bx, word ptr [0x8600]            ; ds:8600
  1377:0330  jg loc_1377_0354
  1377:0332  shl bx, 1
  1377:0334  mov di, word ptr [bx - 0x79e4]
  1377:0338  mov cx, ax
  1377:033A  sar ax, 1
  1377:033C  add di, ax
  1377:033E  call func_1377_0229
  1377:0341  mov ah, 0xf0
  1377:0343  and cx, 1
  1377:0346  je loc_1377_034A
  1377:0348  not ah
loc_1377_034A:    ; <- jcc:1377:0346
  1377:034A  and al, ah
  1377:034C  not ah
  1377:034E  and ah, byte ptr es:[di]
  1377:0351  or al, ah
  1377:0353  stosb byte ptr es:[di], al
loc_1377_0354:    ; <- jcc:1377:031B jcc:1377:0321 jcc:1377:032A jcc:1377:0330
  1377:0354  pop bp
  1377:0355  retf

; ===== func_1377_0356  reg  callers: C=0 asm=0  seeds=call =====
func_1377_0356:
  1377:0356  mov bx, word ptr [0x9162]            ; ds:9162
  1377:035A  mov di, bx
  1377:035C  shr di, 1
  1377:035E  shr di, 1
  1377:0360  shr di, 1
  1377:0362  mov si, word ptr [0x9164]            ; ds:9164
  1377:0366  shl si, 1
  1377:0368  add di, word ptr [si - 0x79e4]
  1377:036C  mov dx, 0x3ce
  1377:036F  mov al, 8
  1377:0371  out dx, al
  1377:0372  inc dx
  1377:0373  and bx, 7
  1377:0376  mov al, byte ptr [bx - 0x6e80]
  1377:037A  ret

; ===== func_1377_037B  reg(saves)  callers: C=0 asm=0  seeds=vtab =====
func_1377_037B:
  1377:037B  push si
  1377:037C  push di
  1377:037D  mov ax, word ptr [0x861a]            ; ds:861A
  1377:0380  mov es, ax
  1377:0382  mov ax, word ptr [si]
  1377:0384  mov word ptr [0x9162], ax            ; ds:9162
  1377:0387  mov ax, word ptr [si + 8]
  1377:038A  mov word ptr [0x9166], ax            ; ds:9166
  1377:038D  mov ax, word ptr [si + 4]
  1377:0390  mov word ptr [0x9164], ax            ; ds:9164
  1377:0393  mov ax, word ptr [si + 0xc]
  1377:0396  mov word ptr [0x9168], ax            ; ds:9168
  1377:0399  mov ax, word ptr [0x9166]            ; ds:9166
  1377:039C  cmp ax, word ptr [0x9162]            ; ds:9162
  1377:03A0  jne loc_1377_03C0
  1377:03A2  mov ax, word ptr [0x9164]            ; ds:9164
  1377:03A5  cmp ax, word ptr [0x9168]            ; ds:9168
  1377:03A9  jne loc_1377_03DB
  1377:03AB  call func_1377_0356
  1377:03AE  out dx, al
  1377:03AF  mov ah, byte ptr es:[di]
  1377:03B2  mov al, 0x55
  1377:03B4  test si, 2
  1377:03B8  je loc_1377_03BC
  1377:03BA  rol al, 1
loc_1377_03BC:    ; <- jcc:1377:03B8
  1377:03BC  stosb byte ptr es:[di], al
  1377:03BD  pop di
  1377:03BE  pop si
  1377:03BF  ret
loc_1377_03C0:    ; <- jcc:1377:03A0
  1377:03C0  jae loc_1377_03DB
  1377:03C2  mov bx, word ptr [0x9162]            ; ds:9162
  1377:03C6  mov word ptr [0x9166], bx            ; ds:9166
  1377:03CA  mov word ptr [0x9162], ax            ; ds:9162
  1377:03CD  mov ax, word ptr [0x9168]            ; ds:9168
  1377:03D0  mov bx, word ptr [0x9164]            ; ds:9164
  1377:03D4  mov word ptr [0x9168], bx            ; ds:9168
  1377:03D8  mov word ptr [0x9164], ax            ; ds:9164
loc_1377_03DB:    ; <- jcc:1377:03A9 jcc:1377:03C0
  1377:03DB  mov bx, word ptr [0x9166]            ; ds:9166
  1377:03DF  sub bx, word ptr [0x9162]            ; ds:9162
  1377:03E3  mov word ptr [0x916a], bx            ; ds:916A
  1377:03E7  mov ax, word ptr [0x9168]            ; ds:9168
  1377:03EA  sub ax, word ptr [0x9164]            ; ds:9164
  1377:03EE  mov bp, word ptr [0x9172]            ; ds:9172
  1377:03F2  jns loc_1377_03FA
  1377:03F4  mov bp, word ptr [0x9174]            ; ds:9174
  1377:03F8  neg ax
loc_1377_03FA:    ; <- jcc:1377:03F2
  1377:03FA  mov word ptr [0x916c], ax            ; ds:916C
  1377:03FD  cmp ax, bx
  1377:03FF  ja loc_1377_0442
  1377:0401  call func_1377_0356
  1377:0404  mov cx, word ptr [0x916a]            ; ds:916A
  1377:0408  mov bx, cx
  1377:040A  inc bx
  1377:040B  shr bx, 1
  1377:040D  neg bx
  1377:040F  mov si, word ptr [0x916c]            ; ds:916C
  1377:0413  mov ah, al
  1377:0415  jmp loc_1377_0426
loc_1377_0417:    ; <- jcc:1377:042D
  1377:0417  sub bx, word ptr [0x916a]            ; ds:916A
  1377:041B  out dx, al
  1377:041C  cmp ah, byte ptr es:[di]
  1377:041F  stosb byte ptr es:[di], al
  1377:0420  ror ah, 1
  1377:0422  adc di, bp
loc_1377_0424:    ; <- jmp:1377:0438
  1377:0424  mov al, ah
loc_1377_0426:    ; <- jcc:1377:0431 jmp:1377:0415
  1377:0426  or al, ah
  1377:0428  dec cx
  1377:0429  js loc_1377_043A
  1377:042B  add bx, si
  1377:042D  jns loc_1377_0417
  1377:042F  ror ah, 1
  1377:0431  jae loc_1377_0426
  1377:0433  out dx, al
  1377:0434  cmp ah, byte ptr es:[di]
  1377:0437  stosb byte ptr es:[di], al
  1377:0438  jmp loc_1377_0424
loc_1377_043A:    ; <- jcc:1377:0429
  1377:043A  out dx, al
  1377:043B  cmp ah, byte ptr es:[di]
  1377:043E  stosb byte ptr es:[di], al
  1377:043F  pop di
  1377:0440  pop si
  1377:0441  ret
loc_1377_0442:    ; <- jcc:1377:03FF
  1377:0442  call func_1377_0356
  1377:0445  mov cx, word ptr [0x916c]            ; ds:916C
  1377:0449  mov bx, cx
  1377:044B  inc bx
  1377:044C  shr bx, 1
  1377:044E  neg bx
  1377:0450  mov si, word ptr [0x916a]            ; ds:916A
  1377:0454  jmp loc_1377_0458
loc_1377_0456:    ; <- jcc:1377:0462 jmp:1377:046A
  1377:0456  adc di, bp
loc_1377_0458:    ; <- jmp:1377:0454
  1377:0458  out dx, al
  1377:0459  mov ah, byte ptr es:[di]
  1377:045C  stosb byte ptr es:[di], al
  1377:045D  dec cx
  1377:045E  js loc_1377_046C
  1377:0460  add bx, si
  1377:0462  js loc_1377_0456
  1377:0464  sub bx, word ptr [0x916c]            ; ds:916C
  1377:0468  ror al, 1
  1377:046A  jmp loc_1377_0456
loc_1377_046C:    ; <- jcc:1377:045E
  1377:046C  pop di
  1377:046D  pop si
  1377:046E  ret

; ===== func_1377_046F  reg(saves)  callers: C=0 asm=0  seeds=vtab =====
func_1377_046F:
  1377:046F  push si
  1377:0470  push di
  1377:0471  mov ax, word ptr [0x861a]            ; ds:861A
  1377:0474  mov es, ax
  1377:0476  mov cx, word ptr [si + 0xc]
  1377:0479  mov di, word ptr [si + 4]
  1377:047C  mov bp, word ptr [si + 8]
  1377:047F  mov bx, word ptr [si]
  1377:0481  mov ax, cx
  1377:0483  sub ax, di
  1377:0485  cdq
  1377:0486  xor ax, dx
  1377:0488  sub ax, dx
  1377:048A  mov si, ax
  1377:048C  mov ax, bp
  1377:048E  sub ax, bx
  1377:0490  cdq
  1377:0491  xor ax, dx
  1377:0493  sub ax, dx
  1377:0495  mov dx, ax
  1377:0497  cmp si, dx
  1377:0499  ja loc_1377_04D7
  1377:049B  cmp bp, bx
  1377:049D  jge loc_1377_04A3
  1377:049F  xchg bx, bp
  1377:04A1  xchg di, cx
loc_1377_04A3:    ; <- jcc:1377:049D
  1377:04A3  mov ax, 0x140
  1377:04A6  cmp cx, di
  1377:04A8  jge loc_1377_04AC
  1377:04AA  neg ax
loc_1377_04AC:    ; <- jcc:1377:04A8
  1377:04AC  shl di, 1
  1377:04AE  mov di, word ptr [di - 0x79e4]
  1377:04B2  add di, bx
  1377:04B4  mov cx, bp
  1377:04B6  sub cx, bx
  1377:04B8  inc cx
  1377:04B9  mov bp, ax
  1377:04BB  mov bx, cx
  1377:04BD  shr bx, 1
  1377:04BF  neg bx
  1377:04C1  mov ax, word ptr [0x8606]            ; ds:8606
loc_1377_04C4:    ; <- jcc:1377:04C9 jcc:1377:04D2
  1377:04C4  stosb byte ptr es:[di], al
  1377:04C5  add bx, si
  1377:04C7  jns loc_1377_04CE
  1377:04C9  loop loc_1377_04C4
  1377:04CB  jmp loc_1377_04D4

; ----- data 1377:04CD .. 1377:04CD (1 bytes) -----
;   1377:04CD  90                                               .
loc_1377_04CE:    ; <- jcc:1377:04C7
  1377:04CE  add di, bp
  1377:04D0  sub bx, dx
  1377:04D2  loop loc_1377_04C4
loc_1377_04D4:    ; <- jmp:1377:04CB jmp:1377:050D jmp:1377:0515
  1377:04D4  pop di
  1377:04D5  pop si
  1377:04D6  ret
loc_1377_04D7:    ; <- jcc:1377:0499
  1377:04D7  xchg si, dx
  1377:04D9  cmp cx, di
  1377:04DB  jge loc_1377_04E1
  1377:04DD  xchg bx, bp
  1377:04DF  xchg di, cx
loc_1377_04E1:    ; <- jcc:1377:04DB
  1377:04E1  mov ax, 1
  1377:04E4  cmp bp, bx
  1377:04E6  jge loc_1377_04EA
  1377:04E8  neg ax
loc_1377_04EA:    ; <- jcc:1377:04E6
  1377:04EA  mov bp, ax
  1377:04EC  sub cx, di
  1377:04EE  inc cx
  1377:04EF  shl di, 1
  1377:04F1  mov di, word ptr [di - 0x79e4]
  1377:04F5  add di, bx
  1377:04F7  mov bx, cx
  1377:04F9  shr bx, 1
  1377:04FB  neg bx
  1377:04FD  mov ax, word ptr [0x8606]            ; ds:8606
loc_1377_0500:    ; <- jcc:1377:050B jcc:1377:0513
  1377:0500  mov byte ptr es:[di], al
  1377:0503  add di, 0x140
  1377:0507  add bx, si
  1377:0509  jns loc_1377_050F
  1377:050B  loop loc_1377_0500
  1377:050D  jmp loc_1377_04D4
loc_1377_050F:    ; <- jcc:1377:0509
  1377:050F  add di, bp
  1377:0511  sub bx, dx
  1377:0513  loop loc_1377_0500
  1377:0515  jmp loc_1377_04D4

; ===== func_1377_0517  reg(saves)  callers: C=0 asm=0  seeds=vtab =====
func_1377_0517:
  1377:0517  push si
  1377:0518  push di
  1377:0519  mov ax, word ptr [0x861a]            ; ds:861A
  1377:051C  mov es, ax
  1377:051E  mov cx, word ptr [si + 0xc]
  1377:0521  mov di, word ptr [si + 4]
  1377:0524  mov bp, word ptr [si + 8]
  1377:0527  mov bx, word ptr [si]
  1377:0529  mov ax, cx
  1377:052B  sub ax, di
  1377:052D  cdq
  1377:052E  xor ax, dx
  1377:0530  sub ax, dx
  1377:0532  mov si, ax
  1377:0534  mov ax, bp
  1377:0536  sub ax, bx
  1377:0538  cdq
  1377:0539  xor ax, dx
  1377:053B  sub ax, dx
  1377:053D  mov dx, ax
  1377:053F  cmp si, dx
  1377:0541  ja loc_1377_05AE
  1377:0543  cmp bp, bx
  1377:0545  jge loc_1377_054B
  1377:0547  xchg bx, bp
  1377:0549  xchg di, cx
loc_1377_054B:    ; <- jcc:1377:0545
  1377:054B  mov ax, 2
  1377:054E  cmp cx, di
  1377:0550  jge loc_1377_0554
  1377:0552  neg ax
loc_1377_0554:    ; <- jcc:1377:0550
  1377:0554  mov word ptr [0x9178], ax            ; ds:9178
  1377:0557  shl di, 1
  1377:0559  mov bp, di
  1377:055B  mov di, word ptr [di - 0x79e4]
  1377:055F  mov ax, bx
  1377:0561  shr ax, 1
  1377:0563  shr ax, 1
  1377:0565  add di, ax
  1377:0567  mov cx, dx
  1377:0569  inc cx
  1377:056A  and bx, 3
  1377:056D  mov ah, byte ptr [bx - 0x6e68]
  1377:0571  mov al, ah
  1377:0573  and al, byte ptr [0x917c]            ; ds:917C
  1377:0577  not ah
  1377:0579  mov bx, cx
  1377:057B  shr bx, 1
  1377:057D  neg bx
loc_1377_057F:    ; <- jcc:1377:0594 jcc:1377:05A9
  1377:057F  and byte ptr es:[di], ah
  1377:0582  or byte ptr es:[di], al
  1377:0585  ror al, 1
  1377:0587  ror al, 1
  1377:0589  ror ah, 1
  1377:058B  ror ah, 1
  1377:058D  jb loc_1377_0590
  1377:058F  inc di
loc_1377_0590:    ; <- jcc:1377:058D
  1377:0590  add bx, si
  1377:0592  jns loc_1377_0599
  1377:0594  loop loc_1377_057F
  1377:0596  jmp loc_1377_05AB

; ----- data 1377:0598 .. 1377:0598 (1 bytes) -----
;   1377:0598  90                                               .
loc_1377_0599:    ; <- jcc:1377:0592
  1377:0599  sub di, word ptr ds:[bp - 0x79e4]
  1377:059E  add bp, word ptr [0x9178]            ; ds:9178
  1377:05A2  add di, word ptr ds:[bp - 0x79e4]
  1377:05A7  sub bx, dx
  1377:05A9  loop loc_1377_057F
loc_1377_05AB:    ; <- jmp:1377:0596 jmp:1377:0606 jmp:1377:0617
  1377:05AB  pop di
  1377:05AC  pop si
  1377:05AD  ret
loc_1377_05AE:    ; <- jcc:1377:0541
  1377:05AE  xchg si, dx
  1377:05B0  cmp bp, bx
  1377:05B2  jge loc_1377_05B8
  1377:05B4  xchg bx, bp
  1377:05B6  xchg di, cx
loc_1377_05B8:    ; <- jcc:1377:05B2
  1377:05B8  mov ax, 2
  1377:05BB  cmp cx, di
  1377:05BD  jge loc_1377_05C1
  1377:05BF  neg ax
loc_1377_05C1:    ; <- jcc:1377:05BD
  1377:05C1  mov word ptr [0x9178], ax            ; ds:9178
  1377:05C4  shl di, 1
  1377:05C6  mov bp, di
  1377:05C8  mov di, word ptr [di - 0x79e4]
  1377:05CC  mov ax, bx
  1377:05CE  shr ax, 1
  1377:05D0  shr ax, 1
  1377:05D2  add di, ax
  1377:05D4  mov cx, dx
  1377:05D6  inc cx
  1377:05D7  and bx, 3
  1377:05DA  mov ah, byte ptr [bx - 0x6e68]
  1377:05DE  mov al, ah
  1377:05E0  and al, byte ptr [0x917c]            ; ds:917C
  1377:05E4  not ah
  1377:05E6  mov bx, cx
  1377:05E8  shr bx, 1
  1377:05EA  neg bx
loc_1377_05EC:    ; <- jcc:1377:0604 jcc:1377:0615
  1377:05EC  and byte ptr es:[di], ah
  1377:05EF  or byte ptr es:[di], al
  1377:05F2  sub di, word ptr ds:[bp - 0x79e4]
  1377:05F7  add bp, word ptr [0x9178]            ; ds:9178
  1377:05FB  add di, word ptr ds:[bp - 0x79e4]
  1377:0600  add bx, si
  1377:0602  jns loc_1377_0608
  1377:0604  loop loc_1377_05EC
  1377:0606  jmp loc_1377_05AB
loc_1377_0608:    ; <- jcc:1377:0602
  1377:0608  ror al, 1
  1377:060A  ror al, 1
  1377:060C  ror ah, 1
  1377:060E  ror ah, 1
  1377:0610  jb loc_1377_0613
  1377:0612  inc di
loc_1377_0613:    ; <- jcc:1377:0610
  1377:0613  sub bx, dx
  1377:0615  loop loc_1377_05EC
  1377:0617  jmp loc_1377_05AB

; ===== func_1377_0619  reg(saves)  callers: C=0 asm=0  seeds=vtab =====
func_1377_0619:
  1377:0619  push si
  1377:061A  push di
  1377:061B  mov ax, word ptr [0x861a]            ; ds:861A
  1377:061E  mov es, ax
  1377:0620  mov cx, word ptr [si + 0xc]
  1377:0623  mov di, word ptr [si + 4]
  1377:0626  mov bp, word ptr [si + 8]
  1377:0629  mov bx, word ptr [si]
  1377:062B  mov ax, cx
  1377:062D  sub ax, di
  1377:062F  cdq
  1377:0630  xor ax, dx
  1377:0632  sub ax, dx
  1377:0634  mov si, ax
  1377:0636  mov ax, bp
  1377:0638  sub ax, bx
  1377:063A  cdq
  1377:063B  xor ax, dx
  1377:063D  sub ax, dx
  1377:063F  mov dx, ax
  1377:0641  cmp si, dx
  1377:0643  ja loc_1377_06B8
  1377:0645  cmp bp, bx
  1377:0647  jge loc_1377_064D
  1377:0649  xchg bx, bp
  1377:064B  xchg di, cx
loc_1377_064D:    ; <- jcc:1377:0647
  1377:064D  mov ax, 2
  1377:0650  cmp cx, di
  1377:0652  jge loc_1377_0656
  1377:0654  neg ax
loc_1377_0656:    ; <- jcc:1377:0652
  1377:0656  mov word ptr [0x9178], ax            ; ds:9178
  1377:0659  shl di, 1
  1377:065B  mov bp, di
  1377:065D  mov di, word ptr [di - 0x79e4]
  1377:0661  mov ax, bx
  1377:0663  shr ax, 1
  1377:0665  add di, ax
  1377:0667  mov cx, dx
  1377:0669  inc cx
  1377:066A  mov ah, 0xf0
  1377:066C  and bx, 1
  1377:066F  je loc_1377_0673
  1377:0671  not ah
loc_1377_0673:    ; <- jcc:1377:066F
  1377:0673  mov al, ah
  1377:0675  and al, byte ptr [0x917e]            ; ds:917E
  1377:0679  not ah
  1377:067B  mov bx, cx
  1377:067D  shr bx, 1
  1377:067F  neg bx
loc_1377_0681:    ; <- jcc:1377:069E jcc:1377:06B3
  1377:0681  and byte ptr es:[di], ah
  1377:0684  or byte ptr es:[di], al
  1377:0687  ror al, 1
  1377:0689  ror al, 1
  1377:068B  ror ah, 1
  1377:068D  ror ah, 1
  1377:068F  ror al, 1
  1377:0691  ror al, 1
  1377:0693  ror ah, 1
  1377:0695  ror ah, 1
  1377:0697  jb loc_1377_069A
  1377:0699  inc di
loc_1377_069A:    ; <- jcc:1377:0697
  1377:069A  add bx, si
  1377:069C  jns loc_1377_06A3
  1377:069E  loop loc_1377_0681
  1377:06A0  jmp loc_1377_06B5

; ----- data 1377:06A2 .. 1377:06A2 (1 bytes) -----
;   1377:06A2  90                                               .
loc_1377_06A3:    ; <- jcc:1377:069C
  1377:06A3  sub di, word ptr ds:[bp - 0x79e4]
  1377:06A8  add bp, word ptr [0x9178]            ; ds:9178
  1377:06AC  add di, word ptr ds:[bp - 0x79e4]
  1377:06B1  sub bx, dx
  1377:06B3  loop loc_1377_0681
loc_1377_06B5:    ; <- jmp:1377:06A0 jmp:1377:0710 jmp:1377:0729
  1377:06B5  pop di
  1377:06B6  pop si
  1377:06B7  ret
loc_1377_06B8:    ; <- jcc:1377:0643
  1377:06B8  xchg si, dx
  1377:06BA  cmp bp, bx
  1377:06BC  jge loc_1377_06C2
  1377:06BE  xchg bx, bp
  1377:06C0  xchg di, cx
loc_1377_06C2:    ; <- jcc:1377:06BC
  1377:06C2  mov ax, 2
  1377:06C5  cmp cx, di
  1377:06C7  jge loc_1377_06CB
  1377:06C9  neg ax
loc_1377_06CB:    ; <- jcc:1377:06C7
  1377:06CB  mov word ptr [0x9178], ax            ; ds:9178
  1377:06CE  shl di, 1
  1377:06D0  mov bp, di
  1377:06D2  mov di, word ptr [di - 0x79e4]
  1377:06D6  mov ax, bx
  1377:06D8  shr ax, 1
  1377:06DA  add di, ax
  1377:06DC  mov cx, dx
  1377:06DE  inc cx
  1377:06DF  mov ah, 0xf0
  1377:06E1  and bx, 1
  1377:06E4  je loc_1377_06E8
  1377:06E6  not ah
loc_1377_06E8:    ; <- jcc:1377:06E4
  1377:06E8  mov al, ah
  1377:06EA  and al, byte ptr [0x917e]            ; ds:917E
  1377:06EE  not ah
  1377:06F0  mov bx, cx
  1377:06F2  shr bx, 1
  1377:06F4  neg bx
loc_1377_06F6:    ; <- jcc:1377:070E jcc:1377:0727
  1377:06F6  and byte ptr es:[di], ah
  1377:06F9  or byte ptr es:[di], al
  1377:06FC  sub di, word ptr ds:[bp - 0x79e4]
  1377:0701  add bp, word ptr [0x9178]            ; ds:9178
  1377:0705  add di, word ptr ds:[bp - 0x79e4]
  1377:070A  add bx, si
  1377:070C  jns loc_1377_0712
  1377:070E  loop loc_1377_06F6
  1377:0710  jmp loc_1377_06B5
loc_1377_0712:    ; <- jcc:1377:070C
  1377:0712  ror al, 1
  1377:0714  ror al, 1
  1377:0716  ror ah, 1
  1377:0718  ror ah, 1
  1377:071A  ror al, 1
  1377:071C  ror al, 1
  1377:071E  ror ah, 1
  1377:0720  ror ah, 1
  1377:0722  jb loc_1377_0725
  1377:0724  inc di
loc_1377_0725:    ; <- jcc:1377:0722
  1377:0725  sub bx, dx
  1377:0727  loop loc_1377_06F6
  1377:0729  jmp loc_1377_06B5

; ===== func_1377_072B  reg(saves)  callers: C=0 asm=1  seeds=far =====
func_1377_072B:
  1377:072B  push si
  1377:072C  push di
  1377:072D  mov ax, word ptr [si]
  1377:072F  mov dx, word ptr [si + 8]
  1377:0732  mov bx, word ptr [si + 4]
  1377:0735  mov si, word ptr [si + 0xc]
  1377:0738  cmp ax, dx
  1377:073A  jle loc_1377_073F
  1377:073C  xchg dx, ax
  1377:073D  xchg si, bx
loc_1377_073F:    ; <- jcc:1377:073A
  1377:073F  mov di, bx
  1377:0741  shl di, 1
  1377:0743  sub dx, ax
  1377:0745  mov bp, 2
  1377:0748  cmp si, bx
  1377:074A  jge loc_1377_0750
  1377:074C  neg bp
  1377:074E  xchg bx, si
loc_1377_0750:    ; <- jcc:1377:074A
  1377:0750  cmp bx, word ptr [0x85fc]            ; ds:85FC
  1377:0754  jl loc_1377_07B2
  1377:0756  cmp bx, word ptr [0x8600]            ; ds:8600
  1377:075A  jg loc_1377_07B2
  1377:075C  cmp si, word ptr [0x85fc]            ; ds:85FC
  1377:0760  jl loc_1377_07B2
  1377:0762  cmp si, word ptr [0x8600]            ; ds:8600
  1377:0766  jg loc_1377_07B2
  1377:0768  cmp bx, word ptr [0x9160]            ; ds:9160
  1377:076C  jge loc_1377_0772
  1377:076E  mov word ptr [0x9160], bx            ; ds:9160
loc_1377_0772:    ; <- jcc:1377:076C
  1377:0772  sub si, bx
  1377:0774  cmp si, dx
  1377:0776  ja loc_1377_07B5
  1377:0778  mov cx, dx
  1377:077A  inc cx
  1377:077B  mov bx, cx
  1377:077D  shr bx, 1
  1377:077F  neg bx
  1377:0781  jmp loc_1377_0796

; ----- data 1377:0783 .. 1377:0783 (1 bytes) -----
;   1377:0783  90                                               .
loc_1377_0784:    ; <- jcc:1377:07A2
  1377:0784  cmp ax, word ptr [di - 0x7262]
  1377:0788  jle loc_1377_078E
  1377:078A  mov word ptr [di - 0x7262], ax
loc_1377_078E:    ; <- jcc:1377:0788
  1377:078E  sub bx, dx
  1377:0790  dec cx
  1377:0791  je loc_1377_07B2
  1377:0793  inc ax
  1377:0794  add di, bp
loc_1377_0796:    ; <- jmp:1377:0781
  1377:0796  cmp ax, word ptr [di - 0x7624]
  1377:079A  jge loc_1377_07A0
  1377:079C  mov word ptr [di - 0x7624], ax
loc_1377_07A0:    ; <- jcc:1377:079A jcc:1377:07A5
  1377:07A0  add bx, si
  1377:07A2  jns loc_1377_0784
  1377:07A4  inc ax
  1377:07A5  loop loc_1377_07A0
  1377:07A7  dec ax
  1377:07A8  cmp ax, word ptr [di - 0x7262]
  1377:07AC  jle loc_1377_07B2
  1377:07AE  mov word ptr [di - 0x7262], ax
loc_1377_07B2:    ; <- jcc:1377:0754 jcc:1377:075A jcc:1377:0760 jcc:1377:0766 jcc:1377:0791
  1377:07B2  pop di
  1377:07B3  pop si
  1377:07B4  retf
loc_1377_07B5:    ; <- jcc:1377:0776
  1377:07B5  mov cx, si
  1377:07B7  inc cx
  1377:07B8  mov bx, cx
  1377:07BA  shr bx, 1
  1377:07BC  neg bx
  1377:07BE  jmp loc_1377_07C9

; ----- data 1377:07C0 .. 1377:07C0 (1 bytes) -----
;   1377:07C0  90                                               .
loc_1377_07C1:    ; <- jcc:1377:07DF
  1377:07C1  dec cx
  1377:07C2  je loc_1377_07E5
  1377:07C4  sub bx, si
  1377:07C6  inc ax
  1377:07C7  add di, bp
loc_1377_07C9:    ; <- jcc:1377:07E3 jmp:1377:07BE
  1377:07C9  cmp ax, word ptr [di - 0x7624]
  1377:07CD  jge loc_1377_07D3
  1377:07CF  mov word ptr [di - 0x7624], ax
loc_1377_07D3:    ; <- jcc:1377:07CD
  1377:07D3  cmp ax, word ptr [di - 0x7262]
  1377:07D7  jle loc_1377_07DD
  1377:07D9  mov word ptr [di - 0x7262], ax
loc_1377_07DD:    ; <- jcc:1377:07D7
  1377:07DD  add bx, dx
  1377:07DF  jns loc_1377_07C1
  1377:07E1  add di, bp
  1377:07E3  loop loc_1377_07C9
loc_1377_07E5:    ; <- jcc:1377:07C2
  1377:07E5  pop di
  1377:07E6  pop si
  1377:07E7  retf

; ===== func_1377_07E8  bp-frame  callers: C=0 asm=2  seeds=far =====
func_1377_07E8:
  1377:07E8  push bp
  1377:07E9  mov bp, sp
  1377:07EB  mov ax, word ptr [bp + 0xa]
  1377:07EE  mov bx, word ptr [bp + 6]
  1377:07F1  mov cx, word ptr [bp + 8]
  1377:07F4  cmp cx, bx
  1377:07F6  jge loc_1377_07FA
  1377:07F8  xchg cx, bx
loc_1377_07FA:    ; <- jcc:1377:07F6
  1377:07FA  cmp cx, word ptr [0x85fc]            ; ds:85FC
  1377:07FE  jle loc_1377_0844
  1377:0800  cmp bx, word ptr [0x8600]            ; ds:8600
  1377:0804  jge loc_1377_0844
  1377:0806  cmp bx, word ptr [0x85fc]            ; ds:85FC
  1377:080A  jge loc_1377_0810
  1377:080C  mov bx, word ptr [0x85fc]            ; ds:85FC
loc_1377_0810:    ; <- jcc:1377:080A
  1377:0810  cmp cx, word ptr [0x8600]            ; ds:8600
  1377:0814  jle loc_1377_081A
  1377:0816  mov cx, word ptr [0x8600]            ; ds:8600
loc_1377_081A:    ; <- jcc:1377:0814
  1377:081A  sub cx, bx
  1377:081C  jcxz loc_1377_0844
  1377:081E  cmp bx, word ptr [0x9160]            ; ds:9160
  1377:0822  jge loc_1377_0828
  1377:0824  mov word ptr [0x9160], bx            ; ds:9160
loc_1377_0828:    ; <- jcc:1377:0822
  1377:0828  inc cx
  1377:0829  shl bx, 1
loc_1377_082B:    ; <- jcc:1377:0842
  1377:082B  cmp ax, word ptr [bx - 0x7624]
  1377:082F  jge loc_1377_0835
  1377:0831  mov word ptr [bx - 0x7624], ax
loc_1377_0835:    ; <- jcc:1377:082F
  1377:0835  cmp ax, word ptr [bx - 0x7262]
  1377:0839  jle loc_1377_083F
  1377:083B  mov word ptr [bx - 0x7262], ax
loc_1377_083F:    ; <- jcc:1377:0839
  1377:083F  add bx, 2
  1377:0842  loop loc_1377_082B
loc_1377_0844:    ; <- jcc:1377:07FE jcc:1377:0804 jcc:1377:081C
  1377:0844  pop bp
  1377:0845  retf

; ===== func_1377_0846  reg  callers: C=0 asm=0  seeds=vtab =====
func_1377_0846:
  1377:0846  mov dx, 0x3c4
  1377:0849  mov ax, 0x802
  1377:084C  out dx, ax
  1377:084D  mov dx, 0x3ce
  1377:0850  mov ax, 1
  1377:0853  out dx, ax
  1377:0854  mov ax, 0x205
  1377:0857  out dx, ax
  1377:0858  mov byte ptr [0x9176], 0xff          ; ds:9176
  1377:085D  call func_1377_0886
  1377:0860  mov byte ptr [0x9176], 0             ; ds:9176
  1377:0865  mov dx, 0x3c4
  1377:0868  mov ax, 0xf02
  1377:086B  out dx, ax
  1377:086C  mov dx, 0x3ce
  1377:086F  mov ax, 5
  1377:0872  out dx, ax
  1377:0873  ret
loc_1377_0874:    ; <- jcc:1377:08B9 jcc:1377:08BF
  1377:0874  mov word ptr [si - 0x7624], 0x7fff
  1377:087A  mov word ptr [si - 0x7262], 0x8001
  1377:0880  add si, 2
  1377:0883  jmp loc_1377_08A3

; ----- data 1377:0885 .. 1377:0885 (1 bytes) -----
;   1377:0885  90                                               .

; ===== func_1377_0886  reg  callers: C=0 asm=0  seeds=call,vtab =====
func_1377_0886:
  1377:0886  mov si, word ptr [0x9160]            ; ds:9160
  1377:088A  cmp si, 0x7fff
  1377:088E  jae loc_1377_089C
  1377:0890  shl si, 1
  1377:0892  mov dx, 0x3ce
  1377:0895  mov al, 8
  1377:0897  out dx, al
  1377:0898  inc dx
  1377:0899  jmp loc_1377_08A3

; ----- data 1377:089B .. 1377:089B (1 bytes) -----
;   1377:089B  90                                               .
loc_1377_089C:    ; <- jcc:1377:088E jcc:1377:08B3 jmp:1377:0968
  1377:089C  mov word ptr [0x9160], 0x7fff        ; ds:9160
  1377:08A2  ret
loc_1377_08A3:    ; <- jmp:1377:0883 jmp:1377:0899 jmp:1377:0947
  1377:08A3  mov di, word ptr [si - 0x79e4]
  1377:08A7  mov bx, word ptr [si - 0x7624]
  1377:08AB  mov bp, word ptr [si - 0x7262]
  1377:08AF  cmp bx, 0x7fff
  1377:08B3  je loc_1377_089C
  1377:08B5  cmp bx, word ptr [0x85fe]            ; ds:85FE
  1377:08B9  jg loc_1377_0874
  1377:08BB  cmp bp, word ptr [0x85fa]            ; ds:85FA
  1377:08BF  jl loc_1377_0874
  1377:08C1  cmp bx, word ptr [0x85fa]            ; ds:85FA
  1377:08C5  jge loc_1377_08CB
  1377:08C7  mov bx, word ptr [0x85fa]            ; ds:85FA
loc_1377_08CB:    ; <- jcc:1377:08C5
  1377:08CB  cmp bp, word ptr [0x85fe]            ; ds:85FE
  1377:08CF  jle loc_1377_08D5
  1377:08D1  mov bp, word ptr [0x85fe]            ; ds:85FE
loc_1377_08D5:    ; <- jcc:1377:08CF
  1377:08D5  mov ax, bx
  1377:08D7  mov cx, bp
  1377:08D9  shr ax, 1
  1377:08DB  shr ax, 1
  1377:08DD  shr ax, 1
  1377:08DF  shr cx, 1
  1377:08E1  shr cx, 1
  1377:08E3  shr cx, 1
  1377:08E5  and bp, 7
  1377:08E8  and bx, 7
  1377:08EB  add di, ax
  1377:08ED  sub cx, ax
  1377:08EF  je loc_1377_094A
  1377:08F1  mov al, byte ptr [bx - 0x6e78]
  1377:08F5  out dx, al
  1377:08F6  mov ax, 0xff55
  1377:08F9  or al, byte ptr [0x9176]             ; ds:9176
  1377:08FD  test si, 2
  1377:0901  je loc_1377_0905
  1377:0903  rol al, 1
loc_1377_0905:    ; <- jcc:1377:0901
  1377:0905  cmp al, byte ptr es:[di]
  1377:0908  stosb byte ptr es:[di], al
  1377:0909  xchg ah, al
  1377:090B  out dx, al
  1377:090C  mov al, ah
  1377:090E  dec cx
  1377:090F  je loc_1377_0922
  1377:0911  test di, 1
  1377:0915  je loc_1377_0919
  1377:0917  stosb byte ptr es:[di], al
  1377:0918  dec cx
loc_1377_0919:    ; <- jcc:1377:0915
  1377:0919  shr cx, 1
  1377:091B  je loc_1377_091F
  1377:091D  rep stosw word ptr es:[di], ax
loc_1377_091F:    ; <- jcc:1377:091B
  1377:091F  jae loc_1377_0922
  1377:0921  stosb byte ptr es:[di], al
loc_1377_0922:    ; <- jcc:1377:090F jcc:1377:091F
  1377:0922  mov al, byte ptr ds:[bp - 0x6e70]
  1377:0927  out dx, al
  1377:0928  mov al, ah
  1377:092A  cmp ah, byte ptr es:[di]
  1377:092D  stosb byte ptr es:[di], al
loc_1377_092E:    ; <- jmp:1377:0966
  1377:092E  mov word ptr [si - 0x7624], 0x7fff
  1377:0934  mov word ptr [si - 0x7262], 0x8001
  1377:093A  add si, 2
  1377:093D  mov ax, si
  1377:093F  shr ax, 1
  1377:0941  cmp ax, word ptr [0x8600]            ; ds:8600
  1377:0945  ja loc_1377_0968
  1377:0947  jmp loc_1377_08A3
loc_1377_094A:    ; <- jcc:1377:08EF
  1377:094A  mov al, byte ptr [bx - 0x6e78]
  1377:094E  and al, byte ptr ds:[bp - 0x6e70]
  1377:0953  out dx, al
  1377:0954  mov al, 0x55
  1377:0956  or al, byte ptr [0x9176]             ; ds:9176
  1377:095A  test si, 2
  1377:095E  je loc_1377_0962
  1377:0960  rol al, 1
loc_1377_0962:    ; <- jcc:1377:095E
  1377:0962  cmp ah, byte ptr es:[di]
  1377:0965  stosb byte ptr es:[di], al
  1377:0966  jmp loc_1377_092E
loc_1377_0968:    ; <- jcc:1377:0945
  1377:0968  jmp loc_1377_089C
loc_1377_096B:    ; <- jmp:1377:0B38
  1377:096B  mov bx, word ptr [0x9160]            ; ds:9160
  1377:096F  cmp bx, 0x7fff
  1377:0973  jne loc_1377_0976
  1377:0975  ret
loc_1377_0976:    ; <- jcc:1377:0973
  1377:0976  mov word ptr [0x9160], 0x7fff        ; ds:9160
  1377:097C  shl bx, 1
loc_1377_097E:    ; <- jmp:1377:0995
  1377:097E  cmp word ptr [bx - 0x7624], 0x7fff
  1377:0984  je loc_1377_0997
  1377:0986  mov word ptr [bx - 0x7624], 0x7fff
  1377:098C  mov word ptr [bx - 0x7262], 0x8001
  1377:0992  add bx, 2
  1377:0995  jmp loc_1377_097E
loc_1377_0997:    ; <- jcc:1377:0984
  1377:0997  ret
loc_1377_0998:    ; <- jcc:1377:09A7 jcc:1377:09BB
  1377:0998  mov word ptr [0x9160], 0x7fff        ; ds:9160
  1377:099E  ret
loc_1377_099F:    ; <- jmp:1377:0B30
  1377:099F  mov bx, word ptr [0x9160]            ; ds:9160
  1377:09A3  cmp bx, 0x7fff
  1377:09A7  jae loc_1377_0998
  1377:09A9  shl bx, 1
loc_1377_09AB:    ; <- jmp:1377:0A07
  1377:09AB  mov di, word ptr [bx - 0x79e4]
  1377:09AF  mov si, word ptr [bx - 0x7624]
  1377:09B3  mov bp, word ptr [bx - 0x7262]
  1377:09B7  cmp si, 0x7fff
  1377:09BB  je loc_1377_0998
  1377:09BD  cmp si, word ptr [0x85fe]            ; ds:85FE
  1377:09C1  jg loc_1377_09F8
  1377:09C3  cmp bp, word ptr [0x85fa]            ; ds:85FA
  1377:09C7  jl loc_1377_09F8
  1377:09C9  cmp si, word ptr [0x85fa]            ; ds:85FA
  1377:09CD  jge loc_1377_09D3
  1377:09CF  mov si, word ptr [0x85fa]            ; ds:85FA
loc_1377_09D3:    ; <- jcc:1377:09CD
  1377:09D3  cmp bp, word ptr [0x85fe]            ; ds:85FE
  1377:09D7  jle loc_1377_09DD
  1377:09D9  mov bp, word ptr [0x85fe]            ; ds:85FE
loc_1377_09DD:    ; <- jcc:1377:09D7
  1377:09DD  add di, si
  1377:09DF  mov cx, bp
  1377:09E1  sub cx, si
  1377:09E3  shl si, 1
  1377:09E5  xor si, bx
  1377:09E7  test si, 2
  1377:09EB  jne loc_1377_09F1
  1377:09ED  inc di
  1377:09EE  dec cx
  1377:09EF  js loc_1377_09F8
loc_1377_09F1:    ; <- jcc:1377:09EB
  1377:09F1  shr cx, 1
  1377:09F3  inc cx
loc_1377_09F4:    ; <- jcc:1377:09F6
  1377:09F4  stosb byte ptr es:[di], al
  1377:09F5  inc di
  1377:09F6  loop loc_1377_09F4
loc_1377_09F8:    ; <- jcc:1377:09C1 jcc:1377:09C7 jcc:1377:09EF
  1377:09F8  mov word ptr [bx - 0x7624], 0x7fff
  1377:09FE  mov word ptr [bx - 0x7262], 0x8001
  1377:0A04  add bx, 2
  1377:0A07  jmp loc_1377_09AB
loc_1377_0A09:    ; <- jmp:1377:0B20
  1377:0A09  mov ah, al
  1377:0A0B  mov si, word ptr [0x9160]            ; ds:9160
  1377:0A0F  cmp si, 0x7fff
  1377:0A13  jne loc_1377_0A1C
loc_1377_0A15:    ; <- jcc:1377:0A2A
  1377:0A15  mov word ptr [0x9160], 0x7fff        ; ds:9160
  1377:0A1B  ret
loc_1377_0A1C:    ; <- jcc:1377:0A13
  1377:0A1C  shl si, 1
loc_1377_0A1E:    ; <- jmp:1377:0A87
  1377:0A1E  mov bx, word ptr [si - 0x7624]
  1377:0A22  mov cx, word ptr [si - 0x7262]
  1377:0A26  cmp bx, 0x7fff
  1377:0A2A  je loc_1377_0A15
  1377:0A2C  cmp bx, word ptr [0x85fe]            ; ds:85FE
  1377:0A30  jg loc_1377_0A78
  1377:0A32  cmp cx, word ptr [0x85fa]            ; ds:85FA
  1377:0A36  jl loc_1377_0A78
  1377:0A38  cmp bx, word ptr [0x85fa]            ; ds:85FA
  1377:0A3C  jge loc_1377_0A42
  1377:0A3E  mov bx, word ptr [0x85fa]            ; ds:85FA
loc_1377_0A42:    ; <- jcc:1377:0A3C
  1377:0A42  cmp cx, word ptr [0x85fe]            ; ds:85FE
  1377:0A46  jle loc_1377_0A4C
  1377:0A48  mov cx, word ptr [0x85fe]            ; ds:85FE
loc_1377_0A4C:    ; <- jcc:1377:0A46
  1377:0A4C  sub cx, bx
  1377:0A4E  inc cx
  1377:0A4F  mov di, word ptr [si - 0x79e4]
  1377:0A53  add di, bx
  1377:0A55  test di, 1
  1377:0A59  je loc_1377_0A62
  1377:0A5B  and byte ptr es:[di], al
  1377:0A5E  inc di
  1377:0A5F  dec cx
  1377:0A60  je loc_1377_0A78
loc_1377_0A62:    ; <- jcc:1377:0A59
  1377:0A62  mov bx, cx
  1377:0A64  shr cx, 1
  1377:0A66  je loc_1377_0A70
loc_1377_0A68:    ; <- jcc:1377:0A6E
  1377:0A68  and word ptr es:[di], ax
  1377:0A6B  add di, 2
  1377:0A6E  loop loc_1377_0A68
loc_1377_0A70:    ; <- jcc:1377:0A66
  1377:0A70  and bx, 1
  1377:0A73  je loc_1377_0A78
  1377:0A75  and byte ptr es:[di], al
loc_1377_0A78:    ; <- jcc:1377:0A30 jcc:1377:0A36 jcc:1377:0A60 jcc:1377:0A73
  1377:0A78  mov word ptr [si - 0x7624], 0x7fff
  1377:0A7E  mov word ptr [si - 0x7262], 0x8001
  1377:0A84  add si, 2
  1377:0A87  jmp loc_1377_0A1E
loc_1377_0A89:    ; <- jmp:1377:0B28
  1377:0A89  mov ah, al
  1377:0A8B  mov si, word ptr [0x9160]            ; ds:9160
  1377:0A8F  cmp si, 0x7fff
  1377:0A93  jne loc_1377_0A9C
loc_1377_0A95:    ; <- jcc:1377:0AAA
  1377:0A95  mov word ptr [0x9160], 0x7fff        ; ds:9160
  1377:0A9B  ret
loc_1377_0A9C:    ; <- jcc:1377:0A93
  1377:0A9C  shl si, 1
loc_1377_0A9E:    ; <- jmp:1377:0B07
  1377:0A9E  mov bx, word ptr [si - 0x7624]
  1377:0AA2  mov cx, word ptr [si - 0x7262]
  1377:0AA6  cmp bx, 0x7fff
  1377:0AAA  je loc_1377_0A95
  1377:0AAC  cmp bx, word ptr [0x85fe]            ; ds:85FE
  1377:0AB0  jg loc_1377_0AF8
  1377:0AB2  cmp cx, word ptr [0x85fa]            ; ds:85FA
  1377:0AB6  jl loc_1377_0AF8
  1377:0AB8  cmp bx, word ptr [0x85fa]            ; ds:85FA
  1377:0ABC  jge loc_1377_0AC2
  1377:0ABE  mov bx, word ptr [0x85fa]            ; ds:85FA
loc_1377_0AC2:    ; <- jcc:1377:0ABC
  1377:0AC2  cmp cx, word ptr [0x85fe]            ; ds:85FE
  1377:0AC6  jle loc_1377_0ACC
  1377:0AC8  mov cx, word ptr [0x85fe]            ; ds:85FE
loc_1377_0ACC:    ; <- jcc:1377:0AC6
  1377:0ACC  sub cx, bx
  1377:0ACE  inc cx
  1377:0ACF  mov di, word ptr [si - 0x79e4]
  1377:0AD3  add di, bx
  1377:0AD5  test di, 1
  1377:0AD9  je loc_1377_0AE2
  1377:0ADB  or byte ptr es:[di], al
  1377:0ADE  inc di
  1377:0ADF  dec cx
  1377:0AE0  je loc_1377_0AF8
loc_1377_0AE2:    ; <- jcc:1377:0AD9
  1377:0AE2  mov bx, cx
  1377:0AE4  shr cx, 1
  1377:0AE6  je loc_1377_0AF0
loc_1377_0AE8:    ; <- jcc:1377:0AEE
  1377:0AE8  or word ptr es:[di], ax
  1377:0AEB  add di, 2
  1377:0AEE  loop loc_1377_0AE8
loc_1377_0AF0:    ; <- jcc:1377:0AE6
  1377:0AF0  and bx, 1
  1377:0AF3  je loc_1377_0AF8
  1377:0AF5  or byte ptr es:[di], al
loc_1377_0AF8:    ; <- jcc:1377:0AB0 jcc:1377:0AB6 jcc:1377:0AE0 jcc:1377:0AF3
  1377:0AF8  mov word ptr [si - 0x7624], 0x7fff
  1377:0AFE  mov word ptr [si - 0x7262], 0x8001
  1377:0B04  add si, 2
  1377:0B07  jmp loc_1377_0A9E

; ===== func_1377_0B09  reg  callers: C=0 asm=0  seeds=vtab =====
func_1377_0B09:
  1377:0B09  mov ax, word ptr [0x8606]            ; ds:8606
  1377:0B0C  cmp ah, 0xfb
  1377:0B0F  jb loc_1377_0B3B
  1377:0B11  cmp ah, 0xff
  1377:0B14  jne loc_1377_0B1B
  1377:0B16  mov ah, al
  1377:0B18  jmp loc_1377_0B3B

; ----- data 1377:0B1A .. 1377:0B1A (1 bytes) -----
;   1377:0B1A  90                                               .
loc_1377_0B1B:    ; <- jcc:1377:0B14
  1377:0B1B  cmp ah, 0xfe
  1377:0B1E  jne loc_1377_0B23
  1377:0B20  jmp loc_1377_0A09
loc_1377_0B23:    ; <- jcc:1377:0B1E
  1377:0B23  cmp ah, 0xfd
  1377:0B26  jne loc_1377_0B2B
  1377:0B28  jmp loc_1377_0A89
loc_1377_0B2B:    ; <- jcc:1377:0B26
  1377:0B2B  cmp ah, 0xfc
  1377:0B2E  jne loc_1377_0B33
  1377:0B30  jmp loc_1377_099F
loc_1377_0B33:    ; <- jcc:1377:0B2E
  1377:0B33  cmp ah, 0xfb
  1377:0B36  jne loc_1377_0B3B
  1377:0B38  jmp loc_1377_096B
loc_1377_0B3B:    ; <- jcc:1377:0B0F jcc:1377:0B36 jmp:1377:0B18
  1377:0B3B  mov word ptr [0x9170], ax            ; ds:9170
  1377:0B3E  mov si, word ptr [0x9160]            ; ds:9160
  1377:0B42  cmp si, 0x7fff
  1377:0B46  jne loc_1377_0B4F
loc_1377_0B48:    ; <- jcc:1377:0B61
  1377:0B48  mov word ptr [0x9160], 0x7fff        ; ds:9160
  1377:0B4E  ret
loc_1377_0B4F:    ; <- jcc:1377:0B46
  1377:0B4F  shl si, 1
loc_1377_0B51:    ; <- jmp:1377:0BC3
  1377:0B51  mov di, word ptr [si - 0x79e4]
  1377:0B55  mov bx, word ptr [si - 0x7624]
  1377:0B59  mov bp, word ptr [si - 0x7262]
  1377:0B5D  cmp bx, 0x7fff
  1377:0B61  je loc_1377_0B48
  1377:0B63  cmp bx, word ptr [0x85fe]            ; ds:85FE
  1377:0B67  jg loc_1377_0BB4
  1377:0B69  cmp bp, word ptr [0x85fa]            ; ds:85FA
  1377:0B6D  jl loc_1377_0BB4
  1377:0B6F  cmp bx, word ptr [0x85fa]            ; ds:85FA
  1377:0B73  jge loc_1377_0B79
  1377:0B75  mov bx, word ptr [0x85fa]            ; ds:85FA
loc_1377_0B79:    ; <- jcc:1377:0B73
  1377:0B79  cmp bp, word ptr [0x85fe]            ; ds:85FE
  1377:0B7D  jle loc_1377_0B83
  1377:0B7F  mov bp, word ptr [0x85fe]            ; ds:85FE
loc_1377_0B83:    ; <- jcc:1377:0B7D
  1377:0B83  add di, bx
  1377:0B85  mov ax, word ptr [0x9170]            ; ds:9170
  1377:0B88  test si, 2
  1377:0B8C  jne loc_1377_0B90
  1377:0B8E  xchg ah, al
loc_1377_0B90:    ; <- jcc:1377:0B8C
  1377:0B90  test bx, 1
  1377:0B94  jne loc_1377_0B98
  1377:0B96  xchg ah, al
loc_1377_0B98:    ; <- jcc:1377:0B94
  1377:0B98  stosb byte ptr es:[di], al
  1377:0B99  mov cx, bp
  1377:0B9B  sub cx, bx
  1377:0B9D  je loc_1377_0BB4
  1377:0B9F  test di, 1
  1377:0BA3  je loc_1377_0BAB
  1377:0BA5  xchg ah, al
  1377:0BA7  stosb byte ptr es:[di], al
  1377:0BA8  dec cx
  1377:0BA9  je loc_1377_0BB4
loc_1377_0BAB:    ; <- jcc:1377:0BA3
  1377:0BAB  xchg ah, al
  1377:0BAD  shr cx, 1
  1377:0BAF  rep stosw word ptr es:[di], ax
  1377:0BB1  jae loc_1377_0BB4
  1377:0BB3  stosb byte ptr es:[di], al
loc_1377_0BB4:    ; <- jcc:1377:0B67 jcc:1377:0B6D jcc:1377:0B9D jcc:1377:0BA9 jcc:1377:0BB1
  1377:0BB4  mov word ptr [si - 0x7624], 0x7fff
  1377:0BBA  mov word ptr [si - 0x7262], 0x8001
  1377:0BC0  add si, 2
  1377:0BC3  jmp loc_1377_0B51

; ===== func_1377_0BC5  reg  callers: C=0 asm=0  seeds=vtab =====
func_1377_0BC5:
  1377:0BC5  mov si, word ptr [0x9160]            ; ds:9160
  1377:0BC9  cmp si, 0x7fff
  1377:0BCD  jae loc_1377_0BD4
  1377:0BCF  shl si, 1
  1377:0BD1  jmp loc_1377_0BDB

; ----- data 1377:0BD3 .. 1377:0BD3 (1 bytes) -----
;   1377:0BD3  90                                               .
loc_1377_0BD4:    ; <- jcc:1377:0BCD jcc:1377:0BEB jmp:1377:0CB0
  1377:0BD4  mov word ptr [0x9160], 0x7fff        ; ds:9160
  1377:0BDA  ret
loc_1377_0BDB:    ; <- jmp:1377:0BD1 jmp:1377:0C87
  1377:0BDB  mov di, word ptr [si - 0x79e4]
  1377:0BDF  mov bx, word ptr [si - 0x7624]
  1377:0BE3  mov bp, word ptr [si - 0x7262]
  1377:0BE7  cmp bx, 0x7fff
  1377:0BEB  je loc_1377_0BD4
  1377:0BED  cmp bx, word ptr [0x85fe]            ; ds:85FE
  1377:0BF1  jle loc_1377_0BF6
  1377:0BF3  jmp loc_1377_0C72

; ----- data 1377:0BF5 .. 1377:0BF5 (1 bytes) -----
;   1377:0BF5  90                                               .
loc_1377_0BF6:    ; <- jcc:1377:0BF1
  1377:0BF6  cmp bp, word ptr [0x85fa]            ; ds:85FA
  1377:0BFA  jl loc_1377_0C72
  1377:0BFC  cmp bx, word ptr [0x85fa]            ; ds:85FA
  1377:0C00  jge loc_1377_0C06
  1377:0C02  mov bx, word ptr [0x85fa]            ; ds:85FA
loc_1377_0C06:    ; <- jcc:1377:0C00
  1377:0C06  cmp bp, word ptr [0x85fe]            ; ds:85FE
  1377:0C0A  jle loc_1377_0C10
  1377:0C0C  mov bp, word ptr [0x85fe]            ; ds:85FE
loc_1377_0C10:    ; <- jcc:1377:0C0A
  1377:0C10  mov ax, bx
  1377:0C12  mov cx, bp
  1377:0C14  shr ax, 1
  1377:0C16  shr ax, 1
  1377:0C18  shr cx, 1
  1377:0C1A  shr cx, 1
  1377:0C1C  and bp, 3
  1377:0C1F  and bx, 3
  1377:0C22  add di, ax
  1377:0C24  sub cx, ax
  1377:0C26  je loc_1377_0C8A
  1377:0C28  mov al, byte ptr [0x917a]            ; ds:917A
  1377:0C2B  test si, 2
  1377:0C2F  je loc_1377_0C35
  1377:0C31  rol al, 1
  1377:0C33  rol al, 1
loc_1377_0C35:    ; <- jcc:1377:0C2F
  1377:0C35  mov ah, byte ptr [bx - 0x6e68]
  1377:0C39  mov bl, byte ptr es:[di]
  1377:0C3C  mov bh, ah
  1377:0C3E  not bh
  1377:0C40  and ah, al
  1377:0C42  xchg al, ah
  1377:0C44  and bl, bh
  1377:0C46  or al, bl
  1377:0C48  stosb byte ptr es:[di], al
  1377:0C49  mov al, ah
  1377:0C4B  dec cx
  1377:0C4C  je loc_1377_0C5F
  1377:0C4E  test di, 1
  1377:0C52  je loc_1377_0C56
  1377:0C54  stosb byte ptr es:[di], al
  1377:0C55  dec cx
loc_1377_0C56:    ; <- jcc:1377:0C52
  1377:0C56  shr cx, 1
  1377:0C58  je loc_1377_0C5C
  1377:0C5A  rep stosw word ptr es:[di], ax
loc_1377_0C5C:    ; <- jcc:1377:0C58
  1377:0C5C  jae loc_1377_0C5F
  1377:0C5E  stosb byte ptr es:[di], al
loc_1377_0C5F:    ; <- jcc:1377:0C4C jcc:1377:0C5C
  1377:0C5F  mov ah, byte ptr ds:[bp - 0x6e68]
  1377:0C64  mov bl, byte ptr es:[di]
  1377:0C67  mov bh, ah
  1377:0C69  not bh
  1377:0C6B  and bl, bh
  1377:0C6D  and al, ah
  1377:0C6F  or al, bl
  1377:0C71  stosb byte ptr es:[di], al
loc_1377_0C72:    ; <- jcc:1377:0BFA jmp:1377:0BF3 jmp:1377:0CAE
  1377:0C72  mov word ptr [si - 0x7624], 0x7fff
  1377:0C78  mov word ptr [si - 0x7262], 0x8001
  1377:0C7E  add si, 2
  1377:0C81  cmp si, 0x190
  1377:0C85  ja loc_1377_0CB0
  1377:0C87  jmp loc_1377_0BDB
loc_1377_0C8A:    ; <- jcc:1377:0C26
  1377:0C8A  mov al, byte ptr [0x917a]            ; ds:917A
  1377:0C8D  test si, 2
  1377:0C91  je loc_1377_0C97
  1377:0C93  rol al, 1
  1377:0C95  rol al, 1
loc_1377_0C97:    ; <- jcc:1377:0C91
  1377:0C97  mov ah, byte ptr [bx - 0x6e68]
  1377:0C9B  and ah, byte ptr ds:[bp - 0x6e68]
  1377:0CA0  mov bh, ah
  1377:0CA2  not bh
  1377:0CA4  mov bl, byte ptr es:[di]
  1377:0CA7  and bl, bh
  1377:0CA9  and al, ah
  1377:0CAB  or al, bl
  1377:0CAD  stosb byte ptr es:[di], al
  1377:0CAE  jmp loc_1377_0C72
loc_1377_0CB0:    ; <- jcc:1377:0C85
  1377:0CB0  jmp loc_1377_0BD4

; ===== func_1377_0CB3  reg  callers: C=0 asm=0  seeds=vtab =====
func_1377_0CB3:
  1377:0CB3  mov si, word ptr [0x9160]            ; ds:9160
  1377:0CB7  cmp si, 0x7fff
  1377:0CBB  jae loc_1377_0CC2
  1377:0CBD  shl si, 1
  1377:0CBF  jmp loc_1377_0CC9

; ----- data 1377:0CC1 .. 1377:0CC1 (1 bytes) -----
;   1377:0CC1  90                                               .
loc_1377_0CC2:    ; <- jcc:1377:0CBB jcc:1377:0CD9 jmp:1377:0DB3
  1377:0CC2  mov word ptr [0x9160], 0x7fff        ; ds:9160
  1377:0CC8  ret
loc_1377_0CC9:    ; <- jmp:1377:0CBF jmp:1377:0D7E
  1377:0CC9  mov di, word ptr [si - 0x79e4]
  1377:0CCD  mov bx, word ptr [si - 0x7624]
  1377:0CD1  mov bp, word ptr [si - 0x7262]
  1377:0CD5  cmp bx, 0x7fff
  1377:0CD9  je loc_1377_0CC2
  1377:0CDB  cmp bx, word ptr [0x85fe]            ; ds:85FE
  1377:0CDF  jle loc_1377_0CE4
  1377:0CE1  jmp loc_1377_0D69
loc_1377_0CE4:    ; <- jcc:1377:0CDF
  1377:0CE4  cmp bp, word ptr [0x85fa]            ; ds:85FA
  1377:0CE8  jl loc_1377_0D69
  1377:0CEA  cmp bx, word ptr [0x85fa]            ; ds:85FA
  1377:0CEE  jge loc_1377_0CF4
  1377:0CF0  mov bx, word ptr [0x85fa]            ; ds:85FA
loc_1377_0CF4:    ; <- jcc:1377:0CEE
  1377:0CF4  cmp bp, word ptr [0x85fe]            ; ds:85FE
  1377:0CF8  jle loc_1377_0CFE
  1377:0CFA  mov bp, word ptr [0x85fe]            ; ds:85FE
loc_1377_0CFE:    ; <- jcc:1377:0CF8
  1377:0CFE  mov ax, bx
  1377:0D00  mov cx, bp
  1377:0D02  shr ax, 1
  1377:0D04  shr cx, 1
  1377:0D06  and bp, 1
  1377:0D09  and bx, 1
  1377:0D0C  add di, ax
  1377:0D0E  sub cx, ax
  1377:0D10  je loc_1377_0D81
  1377:0D12  mov al, byte ptr [0x8606]            ; ds:8606
  1377:0D15  test si, 2
  1377:0D19  je loc_1377_0D23
  1377:0D1B  rol al, 1
  1377:0D1D  rol al, 1
  1377:0D1F  rol al, 1
  1377:0D21  rol al, 1
loc_1377_0D23:    ; <- jcc:1377:0D19
  1377:0D23  mov ah, 0xf
  1377:0D25  and bl, 1
  1377:0D28  jne loc_1377_0D2C
  1377:0D2A  mov ah, 0xff
loc_1377_0D2C:    ; <- jcc:1377:0D28
  1377:0D2C  mov bl, byte ptr es:[di]
  1377:0D2F  mov bh, ah
  1377:0D31  not bh
  1377:0D33  and ah, al
  1377:0D35  xchg al, ah
  1377:0D37  and bl, bh
  1377:0D39  or al, bl
  1377:0D3B  stosb byte ptr es:[di], al
  1377:0D3C  mov al, ah
  1377:0D3E  dec cx
  1377:0D3F  je loc_1377_0D52
  1377:0D41  test di, 1
  1377:0D45  je loc_1377_0D49
  1377:0D47  stosb byte ptr es:[di], al
  1377:0D48  dec cx
loc_1377_0D49:    ; <- jcc:1377:0D45
  1377:0D49  shr cx, 1
  1377:0D4B  je loc_1377_0D4F
  1377:0D4D  rep stosw word ptr es:[di], ax
loc_1377_0D4F:    ; <- jcc:1377:0D4B
  1377:0D4F  jae loc_1377_0D52
  1377:0D51  stosb byte ptr es:[di], al
loc_1377_0D52:    ; <- jcc:1377:0D3F jcc:1377:0D4F
  1377:0D52  mov ah, 0xf0
  1377:0D54  and bp, 1
  1377:0D57  je loc_1377_0D5B
  1377:0D59  mov ah, 0xff
loc_1377_0D5B:    ; <- jcc:1377:0D57
  1377:0D5B  mov bl, byte ptr es:[di]
  1377:0D5E  mov bh, ah
  1377:0D60  not bh
  1377:0D62  and bl, bh
  1377:0D64  and al, ah
  1377:0D66  or al, bl
  1377:0D68  stosb byte ptr es:[di], al
loc_1377_0D69:    ; <- jcc:1377:0CE8 jmp:1377:0CE1 jmp:1377:0DB1
  1377:0D69  mov word ptr [si - 0x7624], 0x7fff
  1377:0D6F  mov word ptr [si - 0x7262], 0x8001
  1377:0D75  add si, 2
  1377:0D78  cmp si, 0x190
  1377:0D7C  ja loc_1377_0DB3
  1377:0D7E  jmp loc_1377_0CC9
loc_1377_0D81:    ; <- jcc:1377:0D10
  1377:0D81  mov ah, 0xf
  1377:0D83  and bl, 1
  1377:0D86  jne loc_1377_0D92
  1377:0D88  not ah
  1377:0D8A  and bp, 1
  1377:0D8D  je loc_1377_0D92
  1377:0D8F  or ah, 0xf
loc_1377_0D92:    ; <- jcc:1377:0D86 jcc:1377:0D8D
  1377:0D92  mov al, byte ptr [0x8606]            ; ds:8606
  1377:0D95  test si, 2
  1377:0D99  je loc_1377_0DA3
  1377:0D9B  rol al, 1
  1377:0D9D  rol al, 1
  1377:0D9F  rol al, 1
  1377:0DA1  rol al, 1
loc_1377_0DA3:    ; <- jcc:1377:0D99
  1377:0DA3  mov bh, ah
  1377:0DA5  not bh
  1377:0DA7  mov bl, byte ptr es:[di]
  1377:0DAA  and bl, bh
  1377:0DAC  and al, ah
  1377:0DAE  or al, bl
  1377:0DB0  stosb byte ptr es:[di], al
  1377:0DB1  jmp loc_1377_0D69
loc_1377_0DB3:    ; <- jcc:1377:0D7C
  1377:0DB3  jmp loc_1377_0CC2

; unresolved indirect transfers:
;   1377:0059  call word ptr cs:[bx + 6]
;   1377:0050  call word ptr cs:[bx + 4]
;   1377:0062  call word ptr cs:[bx + 8]
