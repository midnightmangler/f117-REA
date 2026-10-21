; VGAME segment 130D  lin 130D0..1377C  size 1708 (code runs past the next paragraph value; listed here)  dgroup=1E42  (vgame_asm.py; capstone recursive descent)
; entries: 19   far-call sites into this segment: 12   unresolved indirect jumps/calls: 0

; ----- data 130D:0000 .. 130D:0049 (74 bytes) -----
;   130D:0000  83 C7 10 83 C6 06 E2 8A 5D 07 5E 5F CB 00 55 8B  ........].^_..U.
;   130D:0010  EC 56 8D 36 EA 5E 8B 46 06 99 89 04 89 54 02 8B  .V.6.^.F.....T..
;   130D:0020  46 08 99 89 44 04 89 54 06 8B 46 0A 99 89 44 08  F...D..T..F...D.
;   130D:0030  89 54 0A 8B 46 0C 99 89 44 0C 89 54 0E 9A 3F 03  .T..F...D..T..?.
;   130D:0040  0D 13 9A 4A 00 0D 13 5E 5D CB                    ...J...^].
;   far pointers (offset,seg) at: 130D:003E 130D:0043

; ===== func_130D_004A  reg  callers: C=0 asm=3  seeds=far =====
func_130D_004A:
  130D:004A  mov ax, word ptr [si + 2]
  130D:004D  or word ptr [0x85e2], ax             ; ds:85E2
  130D:0051  mov ax, word ptr [si + 2]
  130D:0054  test al, 0x40
  130D:0056  je loc_130D_005B
  130D:0058  call func_130D_00EC
loc_130D_005B:    ; <- jcc:130D:0056
  130D:005B  mov ax, word ptr [si + 2]
  130D:005E  test al, 0x80
  130D:0060  jne loc_130D_009E
  130D:0062  or word ptr [0x85ec], 4              ; ds:85EC
  130D:0067  call far func_1377_072B              ; -> 1377:072B
  130D:006C  mov ax, word ptr [si + 2]
  130D:006F  test al, 3
  130D:0071  je loc_130D_0086
  130D:0073  mov bx, word ptr [si + 4]
  130D:0076  mov cx, word ptr [si + 6]
  130D:0079  test al, 2
  130D:007B  jne loc_130D_0083
  130D:007D  call func_130D_00D1
  130D:0080  jmp loc_130D_0086

; ----- data 130D:0082 .. 130D:0082 (1 bytes) -----
;   130D:0082  90                                               .
loc_130D_0083:    ; <- jcc:130D:007B
  130D:0083  call func_130D_00B6
loc_130D_0086:    ; <- jcc:130D:0071 jmp:130D:0080
  130D:0086  test al, 0xc
  130D:0088  je loc_130D_009D
  130D:008A  mov bx, word ptr [si + 0xc]
  130D:008D  mov cx, word ptr [si + 0xe]
  130D:0090  test al, 8
  130D:0092  jne loc_130D_009A
  130D:0094  call func_130D_00D1
  130D:0097  jmp loc_130D_009D

; ----- data 130D:0099 .. 130D:0099 (1 bytes) -----
;   130D:0099  90                                               .
loc_130D_009A:    ; <- jcc:130D:0092
  130D:009A  call func_130D_00B6
loc_130D_009D:    ; <- jcc:130D:0088 jcc:130D:00A0 jmp:130D:0097 jmp:130D:00AF jmp:130D:00B4
  130D:009D  retf
loc_130D_009E:    ; <- jcc:130D:0060
  130D:009E  test al, 3
  130D:00A0  je loc_130D_009D
  130D:00A2  mov bx, word ptr [si + 6]
  130D:00A5  mov cx, word ptr [si + 0xe]
  130D:00A8  test al, 2
  130D:00AA  jne loc_130D_00B1
  130D:00AC  call func_130D_00D1
  130D:00AF  jmp loc_130D_009D
loc_130D_00B1:    ; <- jcc:130D:00AA
  130D:00B1  call func_130D_00B6
  130D:00B4  jmp loc_130D_009D

; ===== func_130D_00B6  reg  callers: C=0 asm=0  seeds=call =====
func_130D_00B6:
  130D:00B6  cmp cx, bx
  130D:00B8  jge loc_130D_00BC
  130D:00BA  xchg bx, cx
loc_130D_00BC:    ; <- jcc:130D:00B8
  130D:00BC  cmp cx, word ptr [0x85e6]            ; ds:85E6
  130D:00C0  jl loc_130D_00C6
  130D:00C2  mov word ptr [0x85e6], cx            ; ds:85E6
loc_130D_00C6:    ; <- jcc:130D:00C0
  130D:00C6  cmp bx, word ptr [0x85e4]            ; ds:85E4
  130D:00CA  jge loc_130D_00D0
  130D:00CC  mov word ptr [0x85e4], bx            ; ds:85E4
loc_130D_00D0:    ; <- jcc:130D:00CA
  130D:00D0  ret

; ===== func_130D_00D1  reg  callers: C=0 asm=0  seeds=call =====
func_130D_00D1:
  130D:00D1  cmp cx, bx
  130D:00D3  jge loc_130D_00D7
  130D:00D5  xchg bx, cx
loc_130D_00D7:    ; <- jcc:130D:00D3
  130D:00D7  cmp cx, word ptr [0x85ea]            ; ds:85EA
  130D:00DB  jl loc_130D_00E1
  130D:00DD  mov word ptr [0x85ea], cx            ; ds:85EA
loc_130D_00E1:    ; <- jcc:130D:00DB
  130D:00E1  cmp bx, word ptr [0x85e8]            ; ds:85E8
  130D:00E5  jge loc_130D_00EB
  130D:00E7  mov word ptr [0x85e8], bx            ; ds:85E8
loc_130D_00EB:    ; <- jcc:130D:00E5
  130D:00EB  ret

; ===== func_130D_00EC  reg  callers: C=0 asm=0  seeds=call =====
func_130D_00EC:
  130D:00EC  lea bx, [0x85b8]                     ; ds:85B8
  130D:00F0  cmp word ptr [0x85ee], 0             ; ds:85EE
  130D:00F5  je loc_130D_00FA
  130D:00F7  add bx, 8
loc_130D_00FA:    ; <- jcc:130D:00F5
  130D:00FA  inc word ptr [0x85ee]                ; ds:85EE
  130D:00FE  mov ax, word ptr [si + 0x10]
  130D:0101  mov word ptr [bx], ax
  130D:0103  mov ax, word ptr [si + 0x12]
  130D:0106  mov word ptr [bx + 2], ax
  130D:0109  mov ax, word ptr [si + 0x14]
  130D:010C  mov word ptr [bx + 4], ax
  130D:010F  mov ax, word ptr [si + 0x16]
  130D:0112  mov word ptr [bx + 6], ax
  130D:0115  ret

; ===== func_130D_0116  bp-frame  callers: C=0 asm=2  seeds=far =====
func_130D_0116:
  130D:0116  push bp
  130D:0117  mov bp, sp
  130D:0119  mov ax, word ptr [bp + 6]
  130D:011C  push ax
  130D:011D  call far func_1377_004C              ; -> 1377:004C
  130D:0122  add sp, 2
  130D:0125  cmp word ptr [0x85ee], 2             ; ds:85EE
  130D:012A  jne loc_130D_013C
  130D:012C  push si
  130D:012D  lea si, [0x85b8]                     ; ds:85B8
  130D:0131  call far func_130D_033F              ; -> 130D:033F
  130D:0136  call far func_130D_004A              ; -> 130D:004A
  130D:013B  pop si
loc_130D_013C:    ; <- jcc:130D:012A
  130D:013C  mov dx, word ptr [0x85ec]            ; ds:85EC
  130D:0140  or dx, dx
  130D:0142  je loc_130D_017E
  130D:0144  mov ax, word ptr [0x85e2]            ; ds:85E2
  130D:0147  test al, 5
  130D:0149  je loc_130D_014E
  130D:014B  call func_130D_0191
loc_130D_014E:    ; <- jcc:130D:0149
  130D:014E  mov ax, word ptr [0x85e2]            ; ds:85E2
  130D:0151  test al, 0xa
  130D:0153  je loc_130D_0158
  130D:0155  call func_130D_01A7
loc_130D_0158:    ; <- jcc:130D:0153 jmp:130D:018F
  130D:0158  mov ax, word ptr [bp + 6]
  130D:015B  call far func_1377_005E              ; -> 1377:005E
loc_130D_0160:    ; <- jcc:130D:0183 jcc:130D:0187
  130D:0160  mov ax, 0x7fff
  130D:0163  mov word ptr [0x85e8], ax            ; ds:85E8
  130D:0166  mov word ptr [0x85e4], ax            ; ds:85E4
  130D:0169  not ax
  130D:016B  mov word ptr [0x85ea], ax            ; ds:85EA
  130D:016E  mov word ptr [0x85e6], ax            ; ds:85E6
  130D:0171  sub ax, ax
  130D:0173  mov word ptr [0x85ec], ax            ; ds:85EC
  130D:0176  mov word ptr [0x85e2], ax            ; ds:85E2
  130D:0179  mov word ptr [0x85ee], ax            ; ds:85EE
  130D:017C  pop bp
  130D:017D  retf
loc_130D_017E:    ; <- jcc:130D:0142
  130D:017E  mov ax, word ptr [0x85e2]            ; ds:85E2
  130D:0181  test al, 5
  130D:0183  je loc_130D_0160
  130D:0185  test al, 0xa
  130D:0187  je loc_130D_0160
  130D:0189  call func_130D_0191
  130D:018C  call func_130D_01A7
  130D:018F  jmp loc_130D_0158

; ===== func_130D_0191  reg  callers: C=0 asm=0  seeds=call =====
func_130D_0191:
  130D:0191  mov ax, word ptr [0x85fe]            ; ds:85FE
  130D:0194  inc ax
  130D:0195  push ax
  130D:0196  push word ptr [0x85e8]               ; ds:85E8
  130D:019A  push word ptr [0x85ea]               ; ds:85EA
  130D:019E  call far func_1377_07E8              ; -> 1377:07E8
  130D:01A3  add sp, 6
  130D:01A6  ret

; ===== func_130D_01A7  reg  callers: C=0 asm=0  seeds=call =====
func_130D_01A7:
  130D:01A7  mov ax, word ptr [0x85fa]            ; ds:85FA
  130D:01AA  dec ax
  130D:01AB  push ax
  130D:01AC  push word ptr [0x85e4]               ; ds:85E4
  130D:01B0  push word ptr [0x85e6]               ; ds:85E6
  130D:01B4  call far func_1377_07E8              ; -> 1377:07E8
  130D:01B9  add sp, 6
  130D:01BC  ret

; ===== func_130D_01BD  bp-frame  callers: C=0 asm=0  seeds=sweep =====
func_130D_01BD:
  130D:01BD  push bp
  130D:01BE  mov bp, sp
  130D:01C0  push si
  130D:01C1  mov ax, word ptr [bp + 0xe]
  130D:01C4  push ax
  130D:01C5  call far func_1377_004C              ; -> 1377:004C
  130D:01CA  add sp, 2
  130D:01CD  lea si, [0x5eea]                     ; ds:5EEA
  130D:01D1  mov ax, word ptr [bp + 6]
  130D:01D4  cdq
  130D:01D5  mov word ptr [si], ax
  130D:01D7  mov word ptr [si + 2], dx
  130D:01DA  mov ax, word ptr [bp + 8]
  130D:01DD  cdq
  130D:01DE  mov word ptr [si + 4], ax
  130D:01E1  mov word ptr [si + 6], dx
  130D:01E4  mov ax, word ptr [bp + 0xa]
  130D:01E7  cdq
  130D:01E8  mov word ptr [si + 8], ax
  130D:01EB  mov word ptr [si + 0xa], dx
  130D:01EE  mov ax, word ptr [bp + 0xc]
  130D:01F1  cdq
  130D:01F2  mov word ptr [si + 0xc], ax
  130D:01F5  mov word ptr [si + 0xe], dx
  130D:01F8  call far func_130D_033F              ; -> 130D:033F
  130D:01FD  call far func_130D_0205              ; -> 130D:0205
  130D:0202  pop si
  130D:0203  pop bp
  130D:0204  retf

; ===== func_130D_0205  reg  callers: C=0 asm=1  seeds=far =====
func_130D_0205:
  130D:0205  mov ax, word ptr [si + 2]
  130D:0208  test al, 0x80
  130D:020A  jne loc_130D_0213
  130D:020C  push es
  130D:020D  call far func_1377_0055              ; -> 1377:0055
  130D:0212  pop es
loc_130D_0213:    ; <- jcc:130D:020A
  130D:0213  retf

; ===== func_130D_0214  jump/call stub  callers: C=0 asm=0  seeds=jmp =====
func_130D_0214:
  130D:0214  jmp loc_130D_0471

; ===== func_130D_0217  reg(saves)  callers: C=0 asm=0  seeds=call =====
func_130D_0217:
  130D:0217  push bx
  130D:0218  mov bx, cx
  130D:021A  test al, 1
  130D:021C  je loc_130D_0222
  130D:021E  mov bx, word ptr [0x85fc]            ; ds:85FC
loc_130D_0222:    ; <- jcc:130D:021C
  130D:0222  test al, 2
  130D:0224  je loc_130D_022A
  130D:0226  mov bx, word ptr [0x8600]            ; ds:8600
loc_130D_022A:    ; <- jcc:130D:0224
  130D:022A  mov word ptr [si + 6], bx
  130D:022D  mov bx, bp
  130D:022F  test ah, 1
  130D:0232  je loc_130D_0238
  130D:0234  mov bx, word ptr [0x85fc]            ; ds:85FC
loc_130D_0238:    ; <- jcc:130D:0232
  130D:0238  test ah, 2
  130D:023B  je loc_130D_0241
  130D:023D  mov bx, word ptr [0x8600]            ; ds:8600
loc_130D_0241:    ; <- jcc:130D:023B
  130D:0241  mov word ptr [si + 0xe], bx
  130D:0244  sub bl, bl
  130D:0246  test al, 8
  130D:0248  je loc_130D_024D
  130D:024A  or bl, 1
loc_130D_024D:    ; <- jcc:130D:0248
  130D:024D  test al, 4
  130D:024F  je loc_130D_0254
  130D:0251  or bl, 2
loc_130D_0254:    ; <- jcc:130D:024F
  130D:0254  test ah, 8
  130D:0257  je loc_130D_025C
  130D:0259  or bl, 4
loc_130D_025C:    ; <- jcc:130D:0257
  130D:025C  test ah, 4
  130D:025F  je loc_130D_0264
  130D:0261  or bl, 8
loc_130D_0264:    ; <- jcc:130D:025F
  130D:0264  mov bh, bl
  130D:0266  mov word ptr [si + 2], bx
  130D:0269  pop bx
  130D:026A  ret
loc_130D_026B:    ; <- jcc:130D:0273
  130D:026B  mov bp, bx
  130D:026D  mov dx, cx
  130D:026F  clc
  130D:0270  ret

; ===== func_130D_0271  reg  callers: C=0 asm=0  seeds=call =====
func_130D_0271:
  130D:0271  or al, al
  130D:0273  je loc_130D_026B
  130D:0275  test al, 0xc
  130D:0277  je loc_130D_02A5
  130D:0279  mov bp, word ptr [0x85fe]            ; ds:85FE
  130D:027D  test al, 4
  130D:027F  je loc_130D_0285
  130D:0281  mov bp, word ptr [0x85fa]            ; ds:85FA
loc_130D_0285:    ; <- jcc:130D:027F
  130D:0285  mov ax, bp
  130D:0287  sub ax, bx
  130D:0289  imul word ptr [0x85de]               ; ds:85DE
  130D:028D  idiv word ptr [0x85dc]               ; ds:85DC
  130D:0291  add ax, cx
  130D:0293  mov dx, ax
  130D:0295  mov al, 1
  130D:0297  cmp dx, word ptr [0x85fc]            ; ds:85FC
  130D:029B  jl loc_130D_02A5
  130D:029D  cmp dx, word ptr [0x8600]            ; ds:8600
  130D:02A1  jg loc_130D_02AD
  130D:02A3  clc
  130D:02A4  ret
loc_130D_02A5:    ; <- jcc:130D:0277 jcc:130D:029B
  130D:02A5  mov bp, word ptr [0x85fc]            ; ds:85FC
  130D:02A9  test al, 1
  130D:02AB  jne loc_130D_02B1
loc_130D_02AD:    ; <- jcc:130D:02A1
  130D:02AD  mov bp, word ptr [0x8600]            ; ds:8600
loc_130D_02B1:    ; <- jcc:130D:02AB
  130D:02B1  mov ax, bp
  130D:02B3  sub ax, cx
  130D:02B5  imul word ptr [0x85dc]               ; ds:85DC
  130D:02B9  idiv word ptr [0x85de]               ; ds:85DE
  130D:02BD  add ax, bx
  130D:02BF  mov dx, ax
  130D:02C1  xchg bp, dx
  130D:02C3  cmp bp, word ptr [0x85fa]            ; ds:85FA
  130D:02C7  jl loc_130D_02D7
  130D:02C9  cmp bp, word ptr [0x85fe]            ; ds:85FE
  130D:02CD  jg loc_130D_02D1
  130D:02CF  clc
  130D:02D0  ret
loc_130D_02D1:    ; <- jcc:130D:02CD
  130D:02D1  mov al, 5
  130D:02D3  mov ah, al
  130D:02D5  stc
  130D:02D6  ret
loc_130D_02D7:    ; <- jcc:130D:02C7
  130D:02D7  mov al, 0xa
  130D:02D9  mov ah, al
  130D:02DB  stc
  130D:02DC  ret

; ===== func_130D_02DD  reg  callers: C=0 asm=0  seeds=call =====
func_130D_02DD:
  130D:02DD  sub al, al
  130D:02DF  cmp bx, word ptr [0x85fa]            ; ds:85FA
  130D:02E3  jo loc_130D_030D
loc_130D_02E5:    ; <- jmp:130D:0312
  130D:02E5  jl loc_130D_02FE
loc_130D_02E7:    ; <- jmp:130D:0300
  130D:02E7  cmp bx, word ptr [0x85fe]            ; ds:85FE
  130D:02EB  jg loc_130D_0302
loc_130D_02ED:    ; <- jmp:130D:0304
  130D:02ED  cmp cx, word ptr [0x85fc]            ; ds:85FC
  130D:02F1  jo loc_130D_0314
loc_130D_02F3:    ; <- jmp:130D:0319
  130D:02F3  jl loc_130D_0306
loc_130D_02F5:    ; <- jmp:130D:0308
  130D:02F5  cmp cx, word ptr [0x8600]            ; ds:8600
  130D:02F9  jg loc_130D_030A
  130D:02FB  or al, al
  130D:02FD  ret
loc_130D_02FE:    ; <- jcc:130D:02E5
  130D:02FE  or al, 4
  130D:0300  jmp loc_130D_02E7
loc_130D_0302:    ; <- jcc:130D:02EB
  130D:0302  or al, 8
  130D:0304  jmp loc_130D_02ED
loc_130D_0306:    ; <- jcc:130D:02F3
  130D:0306  or al, 1
  130D:0308  jmp loc_130D_02F5
loc_130D_030A:    ; <- jcc:130D:02F9
  130D:030A  or al, 2
  130D:030C  ret
loc_130D_030D:    ; <- jcc:130D:02E3
  130D:030D  mov byte ptr [0x85f0], 1             ; ds:85F0
  130D:0312  jmp loc_130D_02E5
loc_130D_0314:    ; <- jcc:130D:02F1
  130D:0314  mov byte ptr [0x85f0], 1             ; ds:85F0
  130D:0319  jmp loc_130D_02F3
loc_130D_031B:    ; <- jcc:130D:038A
  130D:031B  sub ax, ax
  130D:031D  mov word ptr [si + 2], ax
  130D:0320  ret
loc_130D_0321:    ; <- jmp:130D:04F8
  130D:0321  mov ax, word ptr [si]
  130D:0323  cdq
  130D:0324  mov word ptr [si + 2], dx
  130D:0327  mov ax, word ptr [si + 4]
  130D:032A  cdq
  130D:032B  mov word ptr [si + 6], dx
  130D:032E  mov ax, word ptr [si + 8]
  130D:0331  cdq
  130D:0332  mov word ptr [si + 0xa], dx
  130D:0335  mov ax, word ptr [si + 0xc]
  130D:0338  cdq
  130D:0339  mov word ptr [si + 0xe], dx
  130D:033C  jmp loc_130D_0365

; ----- data 130D:033E .. 130D:033E (1 bytes) -----
;   130D:033E  90                                               .

; ===== func_130D_033F  reg  callers: C=0 asm=6  seeds=far =====
func_130D_033F:
  130D:033F  mov ax, word ptr [si]
  130D:0341  cdq
  130D:0342  cmp dx, word ptr [si + 2]
  130D:0345  jne loc_130D_0365
  130D:0347  mov ax, word ptr [si + 8]
  130D:034A  cdq
  130D:034B  cmp dx, word ptr [si + 0xa]
  130D:034E  jne loc_130D_0365
  130D:0350  mov ax, word ptr [si + 4]
  130D:0353  cdq
  130D:0354  cmp dx, word ptr [si + 6]
  130D:0357  jne loc_130D_0365
  130D:0359  mov ax, word ptr [si + 0xc]
  130D:035C  cdq
  130D:035D  cmp dx, word ptr [si + 0xe]
  130D:0360  jne loc_130D_0365
  130D:0362  jmp loc_130D_0471
loc_130D_0365:    ; <- jcc:130D:0345 jcc:130D:034E jcc:130D:0357 jcc:130D:0360 jmp:130D:033C
  130D:0365  mov ax, word ptr [si + 8]
  130D:0368  mov dx, word ptr [si + 0xa]
  130D:036B  mov bx, word ptr [si + 0xc]
  130D:036E  mov cx, word ptr [si + 0xe]
  130D:0371  call func_130D_0671
  130D:0374  mov di, bp
  130D:0376  mov ax, word ptr [si]
  130D:0378  mov dx, word ptr [si + 2]
  130D:037B  mov bx, word ptr [si + 4]
  130D:037E  mov cx, word ptr [si + 6]
  130D:0381  call func_130D_0671
  130D:0384  mov ax, bp
  130D:0386  mov bx, di
  130D:0388  or ax, bx
  130D:038A  je loc_130D_031B
  130D:038C  mov ax, bp
  130D:038E  test bx, ax
  130D:0390  je loc_130D_03AE
  130D:0392  and ax, bx
  130D:0394  test ax, 3
  130D:0397  jne loc_130D_03A6
  130D:0399  mov di, bx
  130D:039B  call func_130D_05E5
  130D:039E  or al, 0x80
  130D:03A0  mov ah, al
  130D:03A2  mov word ptr [si + 2], ax
  130D:03A5  retf
loc_130D_03A6:    ; <- jcc:130D:0397
  130D:03A6  mov al, 0x80
  130D:03A8  mov ah, al
  130D:03AA  mov word ptr [si + 2], ax
  130D:03AD  retf
loc_130D_03AE:    ; <- jcc:130D:0390
  130D:03AE  push bp
  130D:03AF  push di
  130D:03B0  push si
  130D:03B1  mov di, 0x8598
  130D:03B4  push es
  130D:03B5  mov ax, ds
  130D:03B7  mov es, ax
  130D:03B9  mov cx, 8
  130D:03BC  rep movsw word ptr es:[di], word ptr [si]
  130D:03BE  sub si, 0x10
  130D:03C1  mov cx, 8
  130D:03C4  rep movsw word ptr es:[di], word ptr [si]
  130D:03C6  pop es
  130D:03C7  pop si
  130D:03C8  pop di
  130D:03C9  pop bp
  130D:03CA  call func_130D_05E5
  130D:03CD  mov ah, al
  130D:03CF  mov word ptr [si + 2], ax
  130D:03D2  or di, di
  130D:03D4  je loc_130D_03EE
  130D:03D6  or bp, bp
  130D:03D8  jne loc_130D_0401
  130D:03DA  push si
  130D:03DB  mov si, 0x8598
  130D:03DE  mov di, si
  130D:03E0  add di, 8
  130D:03E3  call func_130D_0577
  130D:03E6  pop si
  130D:03E7  mov word ptr [si + 8], ax
  130D:03EA  mov word ptr [si + 0xc], bx
  130D:03ED  retf
loc_130D_03EE:    ; <- jcc:130D:03D4
  130D:03EE  push si
  130D:03EF  mov si, 0x8598
  130D:03F2  mov di, si
  130D:03F4  add si, 8
  130D:03F7  call func_130D_0577
  130D:03FA  pop si
  130D:03FB  mov word ptr [si], ax
  130D:03FD  mov word ptr [si + 4], bx
  130D:0400  retf
loc_130D_0401:    ; <- jcc:130D:03D8
  130D:0401  mov word ptr [0x85d8], bp            ; ds:85D8
  130D:0405  mov word ptr [0x85da], di            ; ds:85DA
  130D:0409  push si
  130D:040A  mov si, 0x8598
  130D:040D  mov di, si
  130D:040F  add di, 8
  130D:0412  call func_130D_04FB
  130D:0415  pop si
  130D:0416  jb loc_130D_0453
  130D:0418  sub di, 8
  130D:041B  mov word ptr [di], ax
  130D:041D  mov word ptr [di + 2], dx
  130D:0420  mov word ptr [di + 4], bx
  130D:0423  mov word ptr [di + 6], cx
  130D:0426  push si
  130D:0427  mov si, di
  130D:0429  add di, 0x10
  130D:042C  call func_130D_0577
  130D:042F  mov di, si
  130D:0431  pop si
  130D:0432  mov word ptr [si], ax
  130D:0434  mov word ptr [di], ax
  130D:0436  mov word ptr [di + 2], dx
  130D:0439  mov word ptr [si + 4], bx
  130D:043C  mov word ptr [di + 4], bx
  130D:043F  mov word ptr [di + 6], cx
  130D:0442  push si
  130D:0443  mov si, di
  130D:0445  add di, 0x18
  130D:0448  call func_130D_0577
  130D:044B  pop si
  130D:044C  mov word ptr [si + 8], ax
  130D:044F  mov word ptr [si + 0xc], bx
  130D:0452  retf
loc_130D_0453:    ; <- jcc:130D:0416
  130D:0453  mov al, 0x8a
  130D:0455  test bp, 4
  130D:0459  jne loc_130D_045D
  130D:045B  xor al, 0xf
loc_130D_045D:    ; <- jcc:130D:0459
  130D:045D  mov ah, al
  130D:045F  mov word ptr [si + 2], ax
  130D:0462  retf
loc_130D_0463:    ; <- jcc:130D:0490
  130D:0463  sub ax, ax
  130D:0465  mov word ptr [si + 2], ax
  130D:0468  retf
loc_130D_0469:    ; <- jcc:130D:049D
  130D:0469  mov al, 0x80
  130D:046B  mov ah, al
  130D:046D  mov word ptr [si + 2], ax
  130D:0470  retf
loc_130D_0471:    ; <- jmp:130D:0214 jmp:130D:0362
  130D:0471  mov byte ptr [0x85f0], 0             ; ds:85F0
  130D:0476  nop
  130D:0477  mov bx, word ptr [si + 8]
  130D:047A  mov cx, word ptr [si + 0xc]
  130D:047D  call func_130D_02DD
  130D:0480  mov ah, al
  130D:0482  mov dx, bx
  130D:0484  mov bp, cx
  130D:0486  mov bx, word ptr [si]
  130D:0488  mov cx, word ptr [si + 4]
  130D:048B  call func_130D_02DD
  130D:048E  or ax, ax
  130D:0490  je loc_130D_0463
  130D:0492  test al, ah
  130D:0494  je loc_130D_04B0
  130D:0496  push ax
  130D:0497  and ah, al
  130D:0499  test ah, 3
  130D:049C  pop ax
  130D:049D  jne loc_130D_0469
  130D:049F  call func_130D_0217
  130D:04A2  mov bl, 0x85
  130D:04A4  test al, 8
  130D:04A6  jne loc_130D_04AA
  130D:04A8  mov bl, 0x8a
loc_130D_04AA:    ; <- jcc:130D:04A6
  130D:04AA  mov bh, bl
  130D:04AC  mov word ptr [si + 2], bx
  130D:04AF  retf
loc_130D_04B0:    ; <- jcc:130D:0494
  130D:04B0  call func_130D_0217
  130D:04B3  sub dx, bx
  130D:04B5  jo loc_130D_04CE
  130D:04B7  mov word ptr [0x85dc], dx            ; ds:85DC
  130D:04BB  sub bp, cx
  130D:04BD  jo loc_130D_04CE
  130D:04BF  mov word ptr [0x85de], bp            ; ds:85DE
  130D:04C3  mov byte ptr [0x85f1], ah            ; ds:85F1
  130D:04C7  test byte ptr [0x85f0], 1            ; ds:85F0
  130D:04CC  je loc_130D_04D1
loc_130D_04CE:    ; <- jcc:130D:04B5 jcc:130D:04BD
  130D:04CE  jmp loc_130D_04F8

; ----- data 130D:04D0 .. 130D:04D0 (1 bytes) -----
;   130D:04D0  90                                               .
loc_130D_04D1:    ; <- jcc:130D:04CC
  130D:04D1  call func_130D_0271
  130D:04D4  jb loc_130D_04F0
  130D:04D6  mov word ptr [si], bp
  130D:04D8  mov word ptr [si + 4], dx
  130D:04DB  mov bx, word ptr [si + 8]
  130D:04DE  mov cx, word ptr [si + 0xc]
  130D:04E1  mov al, byte ptr [0x85f1]            ; ds:85F1
  130D:04E4  call func_130D_0271
  130D:04E7  jb loc_130D_04F0
  130D:04E9  mov word ptr [si + 8], bp
  130D:04EC  mov word ptr [si + 0xc], dx
  130D:04EF  retf
loc_130D_04F0:    ; <- jcc:130D:04D4 jcc:130D:04E7
  130D:04F0  or al, 0x80
  130D:04F2  mov ah, al
  130D:04F4  mov word ptr [si + 2], ax
  130D:04F7  retf
loc_130D_04F8:    ; <- jmp:130D:04CE
  130D:04F8  jmp loc_130D_0321

; ===== func_130D_04FB  reg  callers: C=0 asm=0  seeds=call =====
func_130D_04FB:
  130D:04FB  mov word ptr [0x85e0], 0x20          ; ds:85E0
  130D:0501  mov ax, word ptr [di]
  130D:0503  mov dx, word ptr [di + 2]
  130D:0506  mov bx, word ptr [di + 4]
  130D:0509  mov cx, word ptr [di + 6]
loc_130D_050C:    ; <- jmp:130D:0546 jmp:130D:0559
  130D:050C  dec word ptr [0x85e0]                ; ds:85E0
  130D:0510  js loc_130D_055D
  130D:0512  add ax, word ptr [si]
  130D:0514  adc dx, word ptr [si + 2]
  130D:0517  add bx, word ptr [si + 4]
  130D:051A  adc cx, word ptr [si + 6]
  130D:051D  sar dx, 1
  130D:051F  rcr ax, 1
  130D:0521  sar cx, 1
  130D:0523  rcr bx, 1
  130D:0525  call func_130D_0671
  130D:0528  je loc_130D_055B
  130D:052A  test word ptr [0x85da], bp           ; ds:85DA
  130D:052E  jne loc_130D_0548
  130D:0530  mov word ptr [si], ax
  130D:0532  mov word ptr [si + 2], dx
  130D:0535  mov word ptr [si + 4], bx
  130D:0538  mov word ptr [si + 6], cx
  130D:053B  mov ax, word ptr [di]
  130D:053D  mov dx, word ptr [di + 2]
  130D:0540  mov bx, word ptr [di + 4]
  130D:0543  mov cx, word ptr [di + 6]
  130D:0546  jmp loc_130D_050C
loc_130D_0548:    ; <- jcc:130D:052E
  130D:0548  test word ptr [0x85d8], bp           ; ds:85D8
  130D:054C  jne loc_130D_055D
  130D:054E  mov word ptr [di], ax
  130D:0550  mov word ptr [di + 2], dx
  130D:0553  mov word ptr [di + 4], bx
  130D:0556  mov word ptr [di + 6], cx
  130D:0559  jmp loc_130D_050C
loc_130D_055B:    ; <- jcc:130D:0528
  130D:055B  clc
  130D:055C  ret
loc_130D_055D:    ; <- jcc:130D:0510 jcc:130D:054C
  130D:055D  stc
  130D:055E  ret
loc_130D_055F:    ; <- jcc:130D:059B
  130D:055F  cmp ax, 0xffff
  130D:0562  jne loc_130D_05A1
  130D:0564  sub ax, ax
  130D:0566  sub dx, dx
  130D:0568  jmp loc_130D_05A1

; ----- data 130D:056A .. 130D:056A (1 bytes) -----
;   130D:056A  90                                               .
loc_130D_056B:    ; <- jcc:130D:05A3
  130D:056B  cmp bx, -1
  130D:056E  jne loc_130D_05A9
  130D:0570  sub bx, bx
  130D:0572  sub cx, cx
  130D:0574  jmp loc_130D_05A9

; ----- data 130D:0576 .. 130D:0576 (1 bytes) -----
;   130D:0576  90                                               .

; ===== func_130D_0577  reg  callers: C=0 asm=0  seeds=call =====
func_130D_0577:
  130D:0577  mov word ptr [0x85e0], 0x20          ; ds:85E0
  130D:057D  mov ax, word ptr [di]
  130D:057F  mov dx, word ptr [di + 2]
  130D:0582  mov bx, word ptr [di + 4]
  130D:0585  mov cx, word ptr [di + 6]
loc_130D_0588:    ; <- jmp:130D:05C9 jmp:130D:05D6
  130D:0588  dec word ptr [0x85e0]                ; ds:85E0
  130D:058C  js loc_130D_05D9
  130D:058E  add ax, word ptr [si]
  130D:0590  adc dx, word ptr [si + 2]
  130D:0593  add bx, word ptr [si + 4]
  130D:0596  adc cx, word ptr [si + 6]
  130D:0599  cmp ax, dx
  130D:059B  je loc_130D_055F
  130D:059D  sar dx, 1
  130D:059F  rcr ax, 1
loc_130D_05A1:    ; <- jcc:130D:0562 jmp:130D:0568
  130D:05A1  cmp bx, cx
  130D:05A3  je loc_130D_056B
  130D:05A5  sar cx, 1
  130D:05A7  rcr bx, 1
loc_130D_05A9:    ; <- jcc:130D:056E jmp:130D:0574
  130D:05A9  call func_130D_0671
  130D:05AC  jne loc_130D_05CB
  130D:05AE  call func_130D_064A
  130D:05B1  jne loc_130D_05D8
  130D:05B3  mov word ptr [si], ax
  130D:05B5  mov word ptr [si + 2], dx
  130D:05B8  mov word ptr [si + 4], bx
  130D:05BB  mov word ptr [si + 6], cx
  130D:05BE  mov ax, word ptr [di]
  130D:05C0  mov dx, word ptr [di + 2]
  130D:05C3  mov bx, word ptr [di + 4]
  130D:05C6  mov cx, word ptr [di + 6]
  130D:05C9  jmp loc_130D_0588
loc_130D_05CB:    ; <- jcc:130D:05AC
  130D:05CB  mov word ptr [di], ax
  130D:05CD  mov word ptr [di + 2], dx
  130D:05D0  mov word ptr [di + 4], bx
  130D:05D3  mov word ptr [di + 6], cx
  130D:05D6  jmp loc_130D_0588
loc_130D_05D8:    ; <- jcc:130D:05B1
  130D:05D8  ret
loc_130D_05D9:    ; <- jcc:130D:058C
  130D:05D9  mov ax, word ptr [si]
  130D:05DB  mov dx, word ptr [si + 2]
  130D:05DE  mov bx, word ptr [si + 4]
  130D:05E1  mov cx, word ptr [si + 6]
  130D:05E4  ret

; ===== func_130D_05E5  reg  callers: C=0 asm=0  seeds=call =====
func_130D_05E5:
  130D:05E5  test bp, 1
  130D:05E9  jne loc_130D_05F7
  130D:05EB  test bp, 2
  130D:05EF  jne loc_130D_05FE
  130D:05F1  mov bx, word ptr [si + 4]
  130D:05F4  jmp loc_130D_0602

; ----- data 130D:05F6 .. 130D:05F6 (1 bytes) -----
;   130D:05F6  90                                               .
loc_130D_05F7:    ; <- jcc:130D:05E9
  130D:05F7  mov bx, word ptr [0x85fc]            ; ds:85FC
  130D:05FB  jmp loc_130D_0602

; ----- data 130D:05FD .. 130D:05FD (1 bytes) -----
;   130D:05FD  90                                               .
loc_130D_05FE:    ; <- jcc:130D:05EF
  130D:05FE  mov bx, word ptr [0x8600]            ; ds:8600
loc_130D_0602:    ; <- jmp:130D:05F4 jmp:130D:05FB
  130D:0602  mov word ptr [si + 6], bx
  130D:0605  test di, 1
  130D:0609  jne loc_130D_0617
  130D:060B  test di, 2
  130D:060F  jne loc_130D_061E
  130D:0611  mov bx, word ptr [si + 0xc]
  130D:0614  jmp loc_130D_0622

; ----- data 130D:0616 .. 130D:0616 (1 bytes) -----
;   130D:0616  90                                               .
loc_130D_0617:    ; <- jcc:130D:0609
  130D:0617  mov bx, word ptr [0x85fc]            ; ds:85FC
  130D:061B  jmp loc_130D_0622

; ----- data 130D:061D .. 130D:061D (1 bytes) -----
;   130D:061D  90                                               .
loc_130D_061E:    ; <- jcc:130D:060F
  130D:061E  mov bx, word ptr [0x8600]            ; ds:8600
loc_130D_0622:    ; <- jmp:130D:0614 jmp:130D:061B
  130D:0622  mov word ptr [si + 0xe], bx
  130D:0625  sub al, al
  130D:0627  test bp, 8
  130D:062B  je loc_130D_062F
  130D:062D  or al, 1
loc_130D_062F:    ; <- jcc:130D:062B
  130D:062F  test bp, 4
  130D:0633  je loc_130D_0637
  130D:0635  or al, 2
loc_130D_0637:    ; <- jcc:130D:0633
  130D:0637  test di, 8
  130D:063B  je loc_130D_063F
  130D:063D  or al, 4
loc_130D_063F:    ; <- jcc:130D:063B
  130D:063F  test di, 4
  130D:0643  je loc_130D_0647
  130D:0645  or al, 8
loc_130D_0647:    ; <- jcc:130D:0643
  130D:0647  mov ah, al
  130D:0649  ret

; ===== func_130D_064A  reg  callers: C=0 asm=0  seeds=call =====
func_130D_064A:
  130D:064A  sub bp, bp
  130D:064C  or dx, dx
  130D:064E  jne loc_130D_066C
  130D:0650  or cx, cx
  130D:0652  jne loc_130D_066C
  130D:0654  cmp ax, word ptr [0x85fa]            ; ds:85FA
  130D:0658  je loc_130D_066F
  130D:065A  cmp ax, word ptr [0x85fe]            ; ds:85FE
  130D:065E  je loc_130D_066F
  130D:0660  cmp bx, word ptr [0x85fc]            ; ds:85FC
  130D:0664  je loc_130D_066F
  130D:0666  cmp bx, word ptr [0x8600]            ; ds:8600
  130D:066A  je loc_130D_066F
loc_130D_066C:    ; <- jcc:130D:064E jcc:130D:0652
  130D:066C  or bp, bp
  130D:066E  ret
loc_130D_066F:    ; <- jcc:130D:0658 jcc:130D:065E jcc:130D:0664 jcc:130D:066A
  130D:066F  inc bp
  130D:0670  ret

; ===== func_130D_0671  reg  callers: C=0 asm=0  seeds=call =====
func_130D_0671:
  130D:0671  sub bp, bp
  130D:0673  or dx, dx
  130D:0675  js loc_130D_069A
  130D:0677  jne loc_130D_069F
  130D:0679  cmp ax, word ptr [0x85fa]            ; ds:85FA
  130D:067D  jb loc_130D_069A
  130D:067F  cmp ax, word ptr [0x85fe]            ; ds:85FE
  130D:0683  ja loc_130D_069F
loc_130D_0685:    ; <- jmp:130D:069D jmp:130D:06A2
  130D:0685  or cx, cx
  130D:0687  js loc_130D_06A4
  130D:0689  jne loc_130D_06A8
  130D:068B  cmp bx, word ptr [0x85fc]            ; ds:85FC
  130D:068F  jb loc_130D_06A4
  130D:0691  cmp bx, word ptr [0x8600]            ; ds:8600
  130D:0695  ja loc_130D_06A8
  130D:0697  or bp, bp
  130D:0699  ret
loc_130D_069A:    ; <- jcc:130D:0675 jcc:130D:067D
  130D:069A  or bp, 4
  130D:069D  jmp loc_130D_0685
loc_130D_069F:    ; <- jcc:130D:0677 jcc:130D:0683
  130D:069F  or bp, 8
  130D:06A2  jmp loc_130D_0685
loc_130D_06A4:    ; <- jcc:130D:0687 jcc:130D:068F
  130D:06A4  or bp, 1
  130D:06A7  ret
loc_130D_06A8:    ; <- jcc:130D:0689 jcc:130D:0695
  130D:06A8  or bp, 2
  130D:06AB  ret
