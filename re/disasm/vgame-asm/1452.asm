; VGAME segment 1452  lin 14520..14C20  size 1792  dgroup=1E42  (vgame_asm.py; capstone recursive descent)
; entries: 21   far-call sites into this segment: 36   unresolved indirect jumps/calls: 0

; ----- data 1452:0000 .. 1452:0005 (6 bytes) -----
;   1452:0000  AA EB B6 E9 0C FF                                ......

; ===== func_1452_0006  bp-frame  callers: C=0 asm=6  seeds=far =====
func_1452_0006:
  1452:0006  push bp
  1452:0007  mov bp, sp
  1452:0009  push es
  1452:000A  mov bx, 0x14d1                       ; seg 14D1
  1452:000D  mov es, bx
  1452:000F  mov ax, word ptr [bp + 6]
  1452:0012  mov bx, ax
  1452:0014  shr bx, 1
  1452:0016  shr bx, 1
  1452:0018  test ah, 0x40
  1452:001B  je loc_1452_001F
  1452:001D  not bx
loc_1452_001F:    ; <- jcc:1452:001B
  1452:001F  and bx, 0xffe
  1452:0023  mov bx, word ptr es:[bx]
  1452:0028  or ah, ah
  1452:002A  jns loc_1452_002E
  1452:002C  neg bx
loc_1452_002E:    ; <- jcc:1452:002A
  1452:002E  mov ax, bx
  1452:0030  pop es
  1452:0031  pop bp
  1452:0032  retf

; ===== func_1452_0033  bp-frame  callers: C=0 asm=6  seeds=far =====
func_1452_0033:
  1452:0033  push bp
  1452:0034  mov bp, sp
  1452:0036  push es
  1452:0037  mov bx, 0x14d1                       ; seg 14D1
  1452:003A  mov es, bx
  1452:003C  mov ax, word ptr [bp + 6]
  1452:003F  mov bx, ax
  1452:0041  shr bx, 1
  1452:0043  shr bx, 1
  1452:0045  test ah, 0x40
  1452:0048  jne loc_1452_004C
  1452:004A  not bx
loc_1452_004C:    ; <- jcc:1452:0048
  1452:004C  and bx, 0xffe
  1452:0050  mov bx, word ptr es:[bx]
  1452:0055  add ah, 0x40
  1452:0058  or ah, ah
  1452:005A  jns loc_1452_005E
  1452:005C  neg bx
loc_1452_005E:    ; <- jcc:1452:005A
  1452:005E  mov ax, bx
  1452:0060  pop es
  1452:0061  pop bp
  1452:0062  retf

; ===== func_1452_0063  bp-frame  callers: C=0 asm=3  seeds=far =====
func_1452_0063:
  1452:0063  push bp
  1452:0064  mov bp, sp
  1452:0066  push es
  1452:0067  mov bx, 0x14d1                       ; seg 14D1
  1452:006A  mov es, bx
  1452:006C  sub ax, ax
  1452:006E  sub bx, bx
  1452:0070  mov cx, word ptr [bp + 8]
  1452:0073  mov dx, word ptr [bp + 6]
  1452:0076  or cx, cx
  1452:0078  jns loc_1452_007F
  1452:007A  add bl, 8
  1452:007D  neg cx
loc_1452_007F:    ; <- jcc:1452:0078
  1452:007F  or dx, dx
  1452:0081  jns loc_1452_0088
  1452:0083  add bl, 4
  1452:0086  neg dx
loc_1452_0088:    ; <- jcc:1452:0081
  1452:0088  cmp cx, dx
  1452:008A  jae loc_1452_0091
  1452:008C  add bl, 2
  1452:008F  xchg dx, cx
loc_1452_0091:    ; <- jcc:1452:008A
  1452:0091  cmp dx, cx
  1452:0093  jae loc_1452_00C6
  1452:0095  or cx, cx
  1452:0097  je loc_1452_00C6
  1452:0099  div cx
  1452:009B  cdq
  1452:009C  or ax, ax
  1452:009E  mov dx, word ptr [bx - 0x6e58]
  1452:00A2  mov bl, ah
  1452:00A4  shl al, 1
  1452:00A6  rcl bx, 1
  1452:00A8  shl al, 1
  1452:00AA  rcl bx, 1
  1452:00AC  shl al, 1
  1452:00AE  rcl bx, 1
  1452:00B0  shl al, 1
  1452:00B2  rcl bx, 1
  1452:00B4  shl bx, 1
loc_1452_00B6:    ; <- jmp:1452:00CD
  1452:00B6  or dl, dl
  1452:00B8  js loc_1452_00CF
  1452:00BA  sub dl, dl
  1452:00BC  add dx, word ptr es:[bx + 0x1000]
  1452:00C1  mov ax, dx
  1452:00C3  pop es
  1452:00C4  pop bp
  1452:00C5  retf
loc_1452_00C6:    ; <- jcc:1452:0093 jcc:1452:0097
  1452:00C6  mov dx, word ptr [bx - 0x6e58]
  1452:00CA  mov bx, 0x1ffe
  1452:00CD  jmp loc_1452_00B6
loc_1452_00CF:    ; <- jcc:1452:00B8
  1452:00CF  sub dl, dl
  1452:00D1  sub dx, word ptr es:[bx + 0x1000]
  1452:00D6  mov ax, dx
  1452:00D8  pop es
  1452:00D9  pop bp
  1452:00DA  retf

; ===== func_1452_00DB  bp-frame  callers: C=0 asm=0  seeds=sweep =====
func_1452_00DB:
  1452:00DB  push bp
  1452:00DC  mov bp, sp
  1452:00DE  push es
  1452:00DF  mov bx, 0x14d1                       ; seg 14D1
  1452:00E2  mov es, bx
  1452:00E4  mov ax, word ptr [bp + 8]
  1452:00E7  mov dx, word ptr [bp + 6]
  1452:00EA  mov bx, ax
  1452:00EC  shr bx, 1
  1452:00EE  shr bx, 1
  1452:00F0  test ah, 0x40
  1452:00F3  je loc_1452_00F7
  1452:00F5  not bx
loc_1452_00F7:    ; <- jcc:1452:00F3
  1452:00F7  and bx, 0xffe
  1452:00FB  mov bx, word ptr es:[bx]
  1452:0100  or ah, ah
  1452:0102  jns loc_1452_0106
  1452:0104  neg bx
loc_1452_0106:    ; <- jcc:1452:0102
  1452:0106  mov ax, bx
  1452:0108  imul dx
  1452:010A  mov bh, ah
  1452:010C  shl ax, 1
  1452:010E  rcl dx, 1
  1452:0110  or bh, bh
  1452:0112  jns loc_1452_0117
  1452:0114  or dl, 1
loc_1452_0117:    ; <- jcc:1452:0112
  1452:0117  mov ax, dx
  1452:0119  pop es
  1452:011A  pop bp
  1452:011B  retf

; ===== func_1452_011C  bp-frame  callers: C=0 asm=0  seeds=sweep =====
func_1452_011C:
  1452:011C  push bp
  1452:011D  mov bp, sp
  1452:011F  push es
  1452:0120  mov bx, 0x14d1                       ; seg 14D1
  1452:0123  mov es, bx
  1452:0125  mov ax, word ptr [bp + 8]
  1452:0128  mov dx, word ptr [bp + 6]
  1452:012B  mov bx, ax
  1452:012D  shr bx, 1
  1452:012F  shr bx, 1
  1452:0131  test ah, 0x40
  1452:0134  jne loc_1452_0138
  1452:0136  not bx
loc_1452_0138:    ; <- jcc:1452:0134
  1452:0138  and bx, 0xffe
  1452:013C  mov bx, word ptr es:[bx]
  1452:0141  add ah, 0x40
  1452:0144  or ah, ah
  1452:0146  jns loc_1452_014A
  1452:0148  neg bx
loc_1452_014A:    ; <- jcc:1452:0146
  1452:014A  mov ax, bx
  1452:014C  imul dx
  1452:014E  mov bh, ah
  1452:0150  shl ax, 1
  1452:0152  rcl dx, 1
  1452:0154  or bh, bh
  1452:0156  jns loc_1452_015B
  1452:0158  or dl, 1
loc_1452_015B:    ; <- jcc:1452:0156
  1452:015B  mov ax, dx
  1452:015D  pop es
  1452:015E  pop bp
  1452:015F  retf

; ===== func_1452_0160  bp-frame  callers: C=0 asm=1  seeds=far =====
func_1452_0160:
  1452:0160  push bp
  1452:0161  mov bp, sp
  1452:0163  push es
  1452:0164  mov bx, 0x14d1                       ; seg 14D1
  1452:0167  mov es, bx
  1452:0169  mov ax, word ptr [bp + 6]
  1452:016C  mov bx, ax
  1452:016E  or ax, ax
  1452:0170  jns loc_1452_0174
  1452:0172  neg bx
loc_1452_0174:    ; <- jcc:1452:0170
  1452:0174  shr bx, 1
  1452:0176  shr bx, 1
  1452:0178  shr bx, 1
  1452:017A  shr bx, 1
  1452:017C  and bx, 0x7fe
  1452:0180  mov bx, word ptr es:[bx + 0x3202]
  1452:0185  or ax, ax
  1452:0187  jns loc_1452_018B
  1452:0189  neg bx
loc_1452_018B:    ; <- jcc:1452:0187
  1452:018B  mov ax, bx
  1452:018D  pop es
  1452:018E  pop bp
  1452:018F  retf

; ===== func_1452_0190  bp-frame  callers: C=0 asm=2  seeds=far =====
func_1452_0190:
  1452:0190  push bp
  1452:0191  mov bp, sp
  1452:0193  push es
  1452:0194  mov bx, 0x14d1                       ; seg 14D1
  1452:0197  mov es, bx
  1452:0199  mov ax, word ptr [bp + 6]
  1452:019C  mov bx, word ptr [bp + 8]
  1452:019F  cdq
  1452:01A0  xor ax, dx
  1452:01A2  sub ax, dx
  1452:01A4  xchg bx, ax
  1452:01A5  cdq
  1452:01A6  xor ax, dx
  1452:01A8  sub ax, dx
  1452:01AA  cmp ax, bx
  1452:01AC  je loc_1452_01DA
  1452:01AE  jb loc_1452_01B1
  1452:01B0  xchg bx, ax
loc_1452_01B1:    ; <- jcc:1452:01AE
  1452:01B1  mov cx, bx
  1452:01B3  mov dx, ax
  1452:01B5  sub ax, ax
  1452:01B7  div bx
  1452:01B9  cdq
  1452:01BA  or ax, ax
  1452:01BC  mov dx, bx
  1452:01BE  mov bl, ah
  1452:01C0  sub bh, bh
  1452:01C2  shl bx, 1
  1452:01C4  mov ax, word ptr es:[bx + 0x3000]
  1452:01C9  mov bx, dx
loc_1452_01CB:    ; <- jmp:1452:01E0
  1452:01CB  mul bx
  1452:01CD  mov ax, dx
  1452:01CF  add ax, bx
  1452:01D1  cmp ax, cx
  1452:01D3  jae loc_1452_01D7
  1452:01D5  mov ax, cx
loc_1452_01D7:    ; <- jcc:1452:01D3
  1452:01D7  pop es
  1452:01D8  pop bp
  1452:01D9  retf
loc_1452_01DA:    ; <- jcc:1452:01AC
  1452:01DA  mov cx, bx
  1452:01DC  mov ax, word ptr es:[0x3200]
  1452:01E0  jmp loc_1452_01CB

; ===== func_1452_01E2  bp-frame  callers: C=0 asm=0  seeds=sweep =====
func_1452_01E2:
  1452:01E2  push bp
  1452:01E3  mov bp, sp
  1452:01E5  push es
  1452:01E6  mov ax, word ptr [bp + 6]
  1452:01E9  mov bx, word ptr [bp + 8]
  1452:01EC  push bx
  1452:01ED  push ax
  1452:01EE  call far func_1452_0190              ; -> 1452:0190
  1452:01F3  add sp, 4
  1452:01F6  or ax, ax
  1452:01F8  js loc_1452_020A
  1452:01FA  mov bx, word ptr [bp + 0xa]
  1452:01FD  push bx
  1452:01FE  push ax
  1452:01FF  call far func_1452_0190              ; -> 1452:0190
  1452:0204  add sp, 4
  1452:0207  pop es
  1452:0208  pop bp
  1452:0209  retf
loc_1452_020A:    ; <- jcc:1452:01F8
  1452:020A  mov bx, ax
  1452:020C  mov ax, word ptr [bp + 0xa]
  1452:020F  cdq
  1452:0210  xor ax, dx
  1452:0212  sub ax, dx
  1452:0214  shr ax, 1
  1452:0216  add ax, bx
  1452:0218  pop es
  1452:0219  pop bp
  1452:021A  retf

; ===== func_1452_021B  bp-frame  callers: C=0 asm=4  seeds=far =====
func_1452_021B:
  1452:021B  push bp
  1452:021C  mov bp, sp
  1452:021E  push si
  1452:021F  push di
  1452:0220  mov si, word ptr [bp + 6]
  1452:0223  mov di, word ptr [bp + 8]
  1452:0226  mov bx, word ptr [si]
  1452:0228  mov cx, word ptr [si + 2]
  1452:022B  mov bp, word ptr [si + 4]
  1452:022E  mov ax, bx
  1452:0230  imul word ptr [di]
  1452:0232  mov word ptr [si], dx
  1452:0234  mov ax, bx
  1452:0236  imul word ptr [di + 2]
  1452:0239  mov word ptr [si + 2], dx
  1452:023C  mov ax, bx
  1452:023E  imul word ptr [di + 4]
  1452:0241  mov word ptr [si + 4], dx
  1452:0244  mov ax, cx
  1452:0246  imul word ptr [di + 6]
  1452:0249  mov bx, dx
  1452:024B  mov ax, bp
  1452:024D  imul word ptr [di + 0xc]
  1452:0250  add bx, dx
  1452:0252  add bx, word ptr [si]
  1452:0254  shl bx, 1
  1452:0256  mov word ptr [si], bx
  1452:0258  mov ax, cx
  1452:025A  imul word ptr [di + 8]
  1452:025D  mov bx, dx
  1452:025F  mov ax, bp
  1452:0261  imul word ptr [di + 0xe]
  1452:0264  add bx, dx
  1452:0266  add bx, word ptr [si + 2]
  1452:0269  shl bx, 1
  1452:026B  mov word ptr [si + 2], bx
  1452:026E  mov ax, cx
  1452:0270  imul word ptr [di + 0xa]
  1452:0273  mov bx, dx
  1452:0275  mov ax, bp
  1452:0277  imul word ptr [di + 0x10]
  1452:027A  add bx, dx
  1452:027C  add bx, word ptr [si + 4]
  1452:027F  shl bx, 1
  1452:0281  mov word ptr [si + 4], bx
  1452:0284  pop di
  1452:0285  pop si
  1452:0286  pop bp
  1452:0287  retf

; ===== func_1452_0288  bp-frame  callers: C=0 asm=1  seeds=far =====
func_1452_0288:
  1452:0288  push bp
  1452:0289  mov bp, sp
  1452:028B  push si
  1452:028C  push di
  1452:028D  mov si, word ptr [bp + 6]
  1452:0290  mov bx, word ptr [bp + 8]
  1452:0293  mov di, word ptr [bp + 0xa]
  1452:0296  call func_1452_02AC
  1452:0299  add si, 6
  1452:029C  call func_1452_02AC
  1452:029F  add si, 6
  1452:02A2  call func_1452_02AC
  1452:02A5  add si, 6
  1452:02A8  pop di
  1452:02A9  pop si
  1452:02AA  pop bp
  1452:02AB  retf

; ===== func_1452_02AC  reg  callers: C=0 asm=0  seeds=call =====
func_1452_02AC:
  1452:02AC  mov cx, 3
loc_1452_02AF:    ; <- jcc:1452:02DE
  1452:02AF  mov ax, word ptr [si]
  1452:02B1  imul word ptr [bx]
  1452:02B3  mov bp, dx
  1452:02B5  mov word ptr [0x919a], ax            ; ds:919A
  1452:02B8  mov ax, word ptr [si + 2]
  1452:02BB  imul word ptr [bx + 6]
  1452:02BE  add word ptr [0x919a], ax            ; ds:919A
  1452:02C2  adc bp, dx
  1452:02C4  mov ax, word ptr [si + 4]
  1452:02C7  imul word ptr [bx + 0xc]
  1452:02CA  add word ptr [0x919a], ax            ; ds:919A
  1452:02CE  adc dx, bp
  1452:02D0  shl word ptr [0x919a], 1             ; ds:919A
  1452:02D4  rcl dx, 1
  1452:02D6  mov word ptr [di], dx
  1452:02D8  add di, 2
  1452:02DB  add bx, 2
  1452:02DE  loop loc_1452_02AF
  1452:02E0  sub bx, 6
  1452:02E3  ret

; ===== func_1452_02E4  bp-frame  callers: C=0 asm=2  seeds=far =====
func_1452_02E4:
  1452:02E4  push bp
  1452:02E5  mov bp, sp
  1452:02E7  push si
  1452:02E8  push di
  1452:02E9  mov si, word ptr [bp + 6]
  1452:02EC  mov di, word ptr [bp + 8]
  1452:02EF  lodsw ax, word ptr [si]
  1452:02F0  mov word ptr [di], ax
  1452:02F2  lodsw ax, word ptr [si]
  1452:02F3  mov word ptr [di + 6], ax
  1452:02F6  lodsw ax, word ptr [si]
  1452:02F7  mov word ptr [di + 0xc], ax
  1452:02FA  lodsw ax, word ptr [si]
  1452:02FB  mov word ptr [di + 2], ax
  1452:02FE  lodsw ax, word ptr [si]
  1452:02FF  mov word ptr [di + 8], ax
  1452:0302  lodsw ax, word ptr [si]
  1452:0303  mov word ptr [di + 0xe], ax
  1452:0306  lodsw ax, word ptr [si]
  1452:0307  mov word ptr [di + 4], ax
  1452:030A  lodsw ax, word ptr [si]
  1452:030B  mov word ptr [di + 0xa], ax
  1452:030E  lodsw ax, word ptr [si]
  1452:030F  mov word ptr [di + 0x10], ax
  1452:0312  pop di
  1452:0313  pop si
  1452:0314  pop bp
  1452:0315  retf

; ===== func_1452_0316  bp-frame  callers: C=0 asm=1  seeds=far =====
func_1452_0316:
  1452:0316  push bp
  1452:0317  mov bp, sp
  1452:0319  push es
  1452:031A  push si
  1452:031B  push di
  1452:031C  mov ax, ds
  1452:031E  mov es, ax
  1452:0320  mov si, word ptr [bp + 6]
  1452:0323  mov di, word ptr [bp + 8]
  1452:0326  mov cx, 9
  1452:0329  rep movsw word ptr es:[di], word ptr [si]
  1452:032B  pop di
  1452:032C  pop si
  1452:032D  pop es
  1452:032E  pop bp
  1452:032F  retf

; ===== func_1452_0330  bp-frame  callers: C=0 asm=4  seeds=far =====
func_1452_0330:
  1452:0330  push bp
  1452:0331  mov bp, sp
  1452:0333  push si
  1452:0334  push di
  1452:0335  mov si, word ptr [bp + 6]
  1452:0338  mov di, word ptr [bp + 8]
  1452:033B  mov bx, word ptr [si]
  1452:033D  mov cx, word ptr [si + 2]
  1452:0340  mov ax, word ptr [si + 4]
  1452:0343  mov si, word ptr [bp + 0xa]
  1452:0346  mov bp, ax
  1452:0348  mov ax, bx
  1452:034A  imul word ptr [di]
  1452:034C  mov word ptr [si], ax
  1452:034E  mov word ptr [si + 2], dx
  1452:0351  mov ax, bx
  1452:0353  imul word ptr [di + 2]
  1452:0356  mov word ptr [si + 4], ax
  1452:0359  mov word ptr [si + 6], dx
  1452:035C  mov ax, bx
  1452:035E  imul word ptr [di + 4]
  1452:0361  mov word ptr [si + 8], ax
  1452:0364  mov word ptr [si + 0xa], dx
  1452:0367  mov ax, cx
  1452:0369  imul word ptr [di + 6]
  1452:036C  add word ptr [si], ax
  1452:036E  adc word ptr [si + 2], dx
  1452:0371  mov ax, cx
  1452:0373  imul word ptr [di + 8]
  1452:0376  add word ptr [si + 4], ax
  1452:0379  adc word ptr [si + 6], dx
  1452:037C  mov ax, cx
  1452:037E  imul word ptr [di + 0xa]
  1452:0381  add word ptr [si + 8], ax
  1452:0384  adc word ptr [si + 0xa], dx
  1452:0387  mov ax, bp
  1452:0389  imul word ptr [di + 0xc]
  1452:038C  add word ptr [si], ax
  1452:038E  adc word ptr [si + 2], dx
  1452:0391  mov ax, bp
  1452:0393  imul word ptr [di + 0xe]
  1452:0396  add word ptr [si + 4], ax
  1452:0399  adc word ptr [si + 6], dx
  1452:039C  mov ax, bp
  1452:039E  imul word ptr [di + 0x10]
  1452:03A1  add word ptr [si + 8], ax
  1452:03A4  adc word ptr [si + 0xa], dx
  1452:03A7  pop di
  1452:03A8  pop si
  1452:03A9  pop bp
  1452:03AA  retf

; ===== func_1452_03AB  bp-frame  callers: C=5 asm=1  seeds=far =====
func_1452_03AB:
  1452:03AB  push bp
  1452:03AC  mov bp, sp
  1452:03AE  push di
  1452:03AF  mov di, word ptr [bp + 0xc]
  1452:03B2  push word ptr [bp + 6]
  1452:03B5  call far func_1452_0006              ; -> 1452:0006
  1452:03BA  mov word ptr [0x919c], ax            ; ds:919C
  1452:03BD  call far func_1452_0033              ; -> 1452:0033
  1452:03C2  mov word ptr [0x919e], ax            ; ds:919E
  1452:03C5  add sp, 2
  1452:03C8  push word ptr [bp + 0xa]
  1452:03CB  call far func_1452_0006              ; -> 1452:0006
  1452:03D0  mov word ptr [0x91a4], ax            ; ds:91A4
  1452:03D3  call far func_1452_0033              ; -> 1452:0033
  1452:03D8  mov word ptr [0x91a6], ax            ; ds:91A6
  1452:03DB  add sp, 2
  1452:03DE  push word ptr [bp + 8]
  1452:03E1  call far func_1452_0006              ; -> 1452:0006
  1452:03E6  mov word ptr [0x91a0], ax            ; ds:91A0
  1452:03E9  call far func_1452_0033              ; -> 1452:0033
  1452:03EE  mov word ptr [0x91a2], ax            ; ds:91A2
  1452:03F1  add sp, 2
  1452:03F4  mov ax, word ptr [0x91a4]            ; ds:91A4
  1452:03F7  imul word ptr [0x91a0]               ; ds:91A0
  1452:03FB  shl ax, 1
  1452:03FD  rcl dx, 1
  1452:03FF  mov ax, dx
  1452:0401  imul word ptr [0x919c]               ; ds:919C
  1452:0405  shl ax, 1
  1452:0407  rcl dx, 1
  1452:0409  neg dx
  1452:040B  mov cx, dx
  1452:040D  mov ax, word ptr [0x91a6]            ; ds:91A6
  1452:0410  imul word ptr [0x919e]               ; ds:919E
  1452:0414  shl ax, 1
  1452:0416  rcl dx, 1
  1452:0418  add dx, cx
  1452:041A  mov word ptr [di], dx
  1452:041C  mov ax, word ptr [0x91a6]            ; ds:91A6
  1452:041F  imul word ptr [0x91a0]               ; ds:91A0
  1452:0423  shl ax, 1
  1452:0425  rcl dx, 1
  1452:0427  mov ax, dx
  1452:0429  imul word ptr [0x919c]               ; ds:919C
  1452:042D  shl ax, 1
  1452:042F  rcl dx, 1
  1452:0431  mov cx, dx
  1452:0433  mov ax, word ptr [0x91a4]            ; ds:91A4
  1452:0436  imul word ptr [0x919e]               ; ds:919E
  1452:043A  shl ax, 1
  1452:043C  rcl dx, 1
  1452:043E  add dx, cx
  1452:0440  mov word ptr [di + 2], dx
  1452:0443  mov ax, word ptr [0x91a2]            ; ds:91A2
  1452:0446  imul word ptr [0x919c]               ; ds:919C
  1452:044A  shl ax, 1
  1452:044C  rcl dx, 1
  1452:044E  neg dx
  1452:0450  mov word ptr [di + 4], dx
  1452:0453  mov ax, word ptr [0x91a4]            ; ds:91A4
  1452:0456  imul word ptr [0x91a2]               ; ds:91A2
  1452:045A  shl ax, 1
  1452:045C  rcl dx, 1
  1452:045E  neg dx
  1452:0460  mov word ptr [di + 6], dx
  1452:0463  mov ax, word ptr [0x91a6]            ; ds:91A6
  1452:0466  imul word ptr [0x91a2]               ; ds:91A2
  1452:046A  shl ax, 1
  1452:046C  rcl dx, 1
  1452:046E  mov word ptr [di + 8], dx
  1452:0471  mov dx, word ptr [0x91a0]            ; ds:91A0
  1452:0475  mov word ptr [di + 0xa], dx
  1452:0478  mov ax, word ptr [0x91a4]            ; ds:91A4
  1452:047B  imul word ptr [0x91a0]               ; ds:91A0
  1452:047F  shl ax, 1
  1452:0481  rcl dx, 1
  1452:0483  mov ax, dx
  1452:0485  imul word ptr [0x919e]               ; ds:919E
  1452:0489  shl ax, 1
  1452:048B  rcl dx, 1
  1452:048D  mov cx, dx
  1452:048F  mov ax, word ptr [0x91a6]            ; ds:91A6
  1452:0492  imul word ptr [0x919c]               ; ds:919C
  1452:0496  shl ax, 1
  1452:0498  rcl dx, 1
  1452:049A  add dx, cx
  1452:049C  mov word ptr [di + 0xc], dx
  1452:049F  mov ax, word ptr [0x91a6]            ; ds:91A6
  1452:04A2  imul word ptr [0x91a0]               ; ds:91A0
  1452:04A6  shl ax, 1
  1452:04A8  rcl dx, 1
  1452:04AA  mov ax, dx
  1452:04AC  imul word ptr [0x919e]               ; ds:919E
  1452:04B0  shl ax, 1
  1452:04B2  rcl dx, 1
  1452:04B4  neg dx
  1452:04B6  mov cx, dx
  1452:04B8  mov ax, word ptr [0x91a4]            ; ds:91A4
  1452:04BB  imul word ptr [0x919c]               ; ds:919C
  1452:04BF  shl ax, 1
  1452:04C1  rcl dx, 1
  1452:04C3  add dx, cx
  1452:04C5  mov word ptr [di + 0xe], dx
  1452:04C8  mov ax, word ptr [0x91a2]            ; ds:91A2
  1452:04CB  imul word ptr [0x919e]               ; ds:919E
  1452:04CF  shl ax, 1
  1452:04D1  rcl dx, 1
  1452:04D3  mov word ptr [di + 0x10], dx
  1452:04D6  pop di
  1452:04D7  pop bp
  1452:04D8  retf

; ===== func_1452_04D9  bp-frame  callers: C=0 asm=0  seeds=sweep =====
func_1452_04D9:
  1452:04D9  push bp
  1452:04DA  mov bp, sp
  1452:04DC  push di
  1452:04DD  mov di, word ptr [bp + 6]
  1452:04E0  mov ax, word ptr [di + 0xa]
  1452:04E3  push ax
  1452:04E4  call far func_1452_0160              ; -> 1452:0160
  1452:04E9  add sp, 2
  1452:04EC  push ax
  1452:04ED  cdq
  1452:04EE  xor ax, dx
  1452:04F0  sub ax, dx
  1452:04F2  cmp ax, 0x3e80
  1452:04F5  ja loc_1452_0530
  1452:04F7  mov bx, word ptr [di + 0x10]
  1452:04FA  mov cx, word ptr [di + 4]
  1452:04FD  neg cx
  1452:04FF  push bx
  1452:0500  push cx
  1452:0501  call far func_1452_0063              ; -> 1452:0063
  1452:0506  add sp, 4
  1452:0509  push ax
  1452:050A  mov bx, word ptr [di + 8]
  1452:050D  mov cx, word ptr [di + 6]
  1452:0510  neg cx
  1452:0512  push bx
  1452:0513  push cx
  1452:0514  call far func_1452_0063              ; -> 1452:0063
  1452:0519  add sp, 4
loc_1452_051C:    ; <- jmp:1452:0542
  1452:051C  mov di, word ptr [bp + 0xc]
  1452:051F  mov word ptr [di], ax
  1452:0521  pop ax
  1452:0522  mov di, word ptr [bp + 8]
  1452:0525  mov word ptr [di], ax
  1452:0527  pop ax
  1452:0528  mov di, word ptr [bp + 0xa]
  1452:052B  mov word ptr [di], ax
  1452:052D  pop di
  1452:052E  pop bp
  1452:052F  retf
loc_1452_0530:    ; <- jcc:1452:04F5
  1452:0530  mov bx, word ptr [di]
  1452:0532  mov cx, word ptr [di + 0xc]
  1452:0535  push bx
  1452:0536  push cx
  1452:0537  call far func_1452_0063              ; -> 1452:0063
  1452:053C  add sp, 4
  1452:053F  push ax
  1452:0540  sub ax, ax
  1452:0542  jmp loc_1452_051C

; ===== func_1452_0544  bp-frame  callers: C=0 asm=0  seeds=sweep =====
func_1452_0544:
  1452:0544  push bp
  1452:0545  mov bp, sp
  1452:0547  mov ax, word ptr [bp + 6]
  1452:054A  imul word ptr [bp + 8]
  1452:054D  shl ax, 1
  1452:054F  rcl dx, 1
  1452:0551  mov ax, dx
  1452:0553  cdq
  1452:0554  pop bp
  1452:0555  retf

; ===== func_1452_0556  bp-frame  callers: C=0 asm=0  seeds=sweep =====
func_1452_0556:
  1452:0556  push bp
  1452:0557  mov bp, sp
  1452:0559  mov ax, word ptr [bp + 0xa]
  1452:055C  cdq
  1452:055D  xor ax, dx
  1452:055F  sub ax, dx
  1452:0561  jne loc_1452_0566
  1452:0563  inc word ptr [bp + 0xa]
loc_1452_0566:    ; <- jcc:1452:0561
  1452:0566  mov cx, ax
  1452:0568  mov ax, word ptr [bp + 8]
  1452:056B  cdq
  1452:056C  xor ax, dx
  1452:056E  sub ax, dx
  1452:0570  cmp ax, cx
  1452:0572  jae loc_1452_0582
  1452:0574  mov ax, word ptr [bp + 6]
  1452:0577  imul word ptr [bp + 8]
  1452:057A  idiv word ptr [bp + 0xa]
  1452:057D  cdq
  1452:057E  or ax, ax
  1452:0580  pop bp
  1452:0581  retf
loc_1452_0582:    ; <- jcc:1452:0572
  1452:0582  mov ax, word ptr [bp + 8]
  1452:0585  cdq
  1452:0586  idiv word ptr [bp + 0xa]
  1452:0589  cdq
  1452:058A  or ax, ax
  1452:058C  imul word ptr [bp + 6]
  1452:058F  pop bp
  1452:0590  retf

; ===== func_1452_0591  bp-frame  callers: C=0 asm=0  seeds=sweep =====
func_1452_0591:
  1452:0591  push bp
  1452:0592  mov bp, sp
  1452:0594  mov ax, word ptr [bp + 0xa]
  1452:0597  cdq
  1452:0598  xor ax, dx
  1452:059A  sub ax, dx
  1452:059C  jne loc_1452_05A1
  1452:059E  inc word ptr [bp + 0xa]
loc_1452_05A1:    ; <- jcc:1452:059C
  1452:05A1  mov cx, ax
  1452:05A3  mov ax, word ptr [bp + 8]
  1452:05A6  cdq
  1452:05A7  xor ax, dx
  1452:05A9  sub ax, dx
  1452:05AB  inc ax
  1452:05AC  shl ax, 1
  1452:05AE  cmp ax, cx
  1452:05B0  ja loc_1452_05BF
  1452:05B2  mov ax, word ptr [bp + 6]
  1452:05B5  mov dx, word ptr [bp + 8]
  1452:05B8  idiv cx
  1452:05BA  cdq
  1452:05BB  or ax, ax
  1452:05BD  pop bp
  1452:05BE  retf
loc_1452_05BF:    ; <- jcc:1452:05B0
  1452:05BF  mov ax, 0x7fff
  1452:05C2  xor ax, dx
  1452:05C4  sub ax, dx
  1452:05C6  pop bp
  1452:05C7  retf

; ===== func_1452_05C8  bp-frame  callers: C=0 asm=0  seeds=sweep =====
func_1452_05C8:
  1452:05C8  push bp
  1452:05C9  mov bp, sp
  1452:05CB  mov ax, word ptr [bp + 6]
  1452:05CE  imul word ptr [bp + 8]
  1452:05D1  pop bp
  1452:05D2  retf

; ===== func_1452_05D3  bp-frame  callers: C=0 asm=0  seeds=sweep =====
func_1452_05D3:
  1452:05D3  push bp
  1452:05D4  mov bp, sp
  1452:05D6  push di
  1452:05D7  mov di, word ptr [bp + 0xc]
  1452:05DA  push word ptr [bp + 0xa]
  1452:05DD  call far func_1452_0006              ; -> 1452:0006
  1452:05E2  mov word ptr [0x919c], ax            ; ds:919C
  1452:05E5  call far func_1452_0033              ; -> 1452:0033
  1452:05EA  mov word ptr [0x919e], ax            ; ds:919E
  1452:05ED  add sp, 2
  1452:05F0  push word ptr [bp + 6]
  1452:05F3  call far func_1452_0006              ; -> 1452:0006
  1452:05F8  mov word ptr [0x91a4], ax            ; ds:91A4
  1452:05FB  call far func_1452_0033              ; -> 1452:0033
  1452:0600  mov word ptr [0x91a6], ax            ; ds:91A6
  1452:0603  add sp, 2
  1452:0606  push word ptr [bp + 8]
  1452:0609  call far func_1452_0006              ; -> 1452:0006
  1452:060E  mov word ptr [0x91a0], ax            ; ds:91A0
  1452:0611  call far func_1452_0033              ; -> 1452:0033
  1452:0616  mov word ptr [0x91a2], ax            ; ds:91A2
  1452:0619  add sp, 2
  1452:061C  mov ax, word ptr [0x919c]            ; ds:919C
  1452:061F  imul word ptr [0x91a0]               ; ds:91A0
  1452:0623  shl ax, 1
  1452:0625  rcl dx, 1
  1452:0627  mov ax, dx
  1452:0629  imul word ptr [0x91a4]               ; ds:91A4
  1452:062D  shl ax, 1
  1452:062F  rcl dx, 1
  1452:0631  mov cx, dx
  1452:0633  mov ax, word ptr [0x919e]            ; ds:919E
  1452:0636  imul word ptr [0x91a6]               ; ds:91A6
  1452:063A  shl ax, 1
  1452:063C  rcl dx, 1
  1452:063E  add dx, cx
  1452:0640  mov word ptr [di], dx
  1452:0642  mov ax, word ptr [0x91a2]            ; ds:91A2
  1452:0645  imul word ptr [0x91a4]               ; ds:91A4
  1452:0649  shl ax, 1
  1452:064B  rcl dx, 1
  1452:064D  mov word ptr [di + 2], dx
  1452:0650  mov ax, word ptr [0x919e]            ; ds:919E
  1452:0653  imul word ptr [0x91a0]               ; ds:91A0
  1452:0657  shl ax, 1
  1452:0659  rcl dx, 1
  1452:065B  mov ax, dx
  1452:065D  imul word ptr [0x91a4]               ; ds:91A4
  1452:0661  shl ax, 1
  1452:0663  rcl dx, 1
  1452:0665  mov cx, dx
  1452:0667  mov ax, word ptr [0x919c]            ; ds:919C
  1452:066A  imul word ptr [0x91a6]               ; ds:91A6
  1452:066E  shl ax, 1
  1452:0670  rcl dx, 1
  1452:0672  neg dx
  1452:0674  add dx, cx
  1452:0676  mov word ptr [di + 4], dx
  1452:0679  mov ax, word ptr [0x919c]            ; ds:919C
  1452:067C  imul word ptr [0x91a0]               ; ds:91A0
  1452:0680  shl ax, 1
  1452:0682  rcl dx, 1
  1452:0684  mov ax, dx
  1452:0686  imul word ptr [0x91a6]               ; ds:91A6
  1452:068A  shl ax, 1
  1452:068C  rcl dx, 1
  1452:068E  mov cx, dx
  1452:0690  mov ax, word ptr [0x919e]            ; ds:919E
  1452:0693  imul word ptr [0x91a4]               ; ds:91A4
  1452:0697  shl ax, 1
  1452:0699  rcl dx, 1
  1452:069B  neg dx
  1452:069D  add dx, cx
  1452:069F  mov word ptr [di + 6], dx
  1452:06A2  mov ax, word ptr [0x91a2]            ; ds:91A2
  1452:06A5  imul word ptr [0x91a6]               ; ds:91A6
  1452:06A9  shl ax, 1
  1452:06AB  rcl dx, 1
  1452:06AD  mov word ptr [di + 8], dx
  1452:06B0  mov ax, word ptr [0x919e]            ; ds:919E
  1452:06B3  imul word ptr [0x91a0]               ; ds:91A0
  1452:06B7  shl ax, 1
  1452:06B9  rcl dx, 1
  1452:06BB  mov ax, dx
  1452:06BD  imul word ptr [0x91a6]               ; ds:91A6
  1452:06C1  shl ax, 1
  1452:06C3  rcl dx, 1
  1452:06C5  mov cx, dx
  1452:06C7  mov ax, word ptr [0x919c]            ; ds:919C
  1452:06CA  imul word ptr [0x91a4]               ; ds:91A4
  1452:06CE  shl ax, 1
  1452:06D0  rcl dx, 1
  1452:06D2  add dx, cx
  1452:06D4  mov word ptr [di + 0xa], dx
  1452:06D7  mov ax, word ptr [0x919c]            ; ds:919C
  1452:06DA  imul word ptr [0x91a2]               ; ds:91A2
  1452:06DE  shl ax, 1
  1452:06E0  rcl dx, 1
  1452:06E2  mov word ptr [di + 0xc], dx
  1452:06E5  mov dx, word ptr [0x91a0]            ; ds:91A0
  1452:06E9  neg dx
  1452:06EB  mov word ptr [di + 0xe], dx
  1452:06EE  mov ax, word ptr [0x919e]            ; ds:919E
  1452:06F1  imul word ptr [0x91a2]               ; ds:91A2
  1452:06F5  shl ax, 1
  1452:06F7  rcl dx, 1
  1452:06F9  mov word ptr [di + 0x10], dx
  1452:06FC  pop di
  1452:06FD  pop bp
  1452:06FE  retf

; ----- data 1452:06FF .. 1452:06FF (1 bytes) -----
;   1452:06FF  00                                               .
