; VGAME segment 114A  lin 114A0..11B87  size 1767 (code runs past the next paragraph value; listed here)  dgroup=1E42  (vgame_asm.py; capstone recursive descent)
; entries: 12   far-call sites into this segment: 69   unresolved indirect jumps/calls: 0

; ----- data 114A:0000 .. 114A:0005 (6 bytes) -----
;   114A:0000  EA 00 00 00 00 00                                ......

; ===== func_114A_0006  bp-frame  callers: C=19 asm=0  seeds=far =====
func_114A_0006:
  114A:0006  enter 4, 0
  114A:000A  mov bx, word ptr [0x4010]            ; ds:4010
  114A:000E  mov ax, word ptr [bx + 0x14]
  114A:0011  sub ax, word ptr [bx + 0x12]
  114A:0014  inc ax
  114A:0015  mov word ptr [bp - 4], ax
  114A:0018  mov ax, word ptr [bx + 0x10]
  114A:001B  sub ax, word ptr [bx + 0xe]
  114A:001E  inc ax
  114A:001F  mov word ptr [bp - 2], ax
  114A:0022  push word ptr [bx + 0xe]
  114A:0025  push word ptr [bx + 0x12]
  114A:0028  call far func_1E42_0250              ; T:0250 slot 62
  114A:002D  pop bx
  114A:002E  pop bx
  114A:002F  push ax
  114A:0030  call far func_1E42_019C              ; T:019C slot 26
  114A:0035  pop bx
  114A:0036  mov ax, word ptr [bp - 4]
  114A:0039  dec ax
  114A:003A  mov word ptr [0x2293], ax            ; ds:2293
  114A:003D  mov ax, word ptr [bp - 2]
  114A:0040  dec ax
  114A:0041  mov word ptr [0x2295], ax            ; ds:2295
  114A:0044  mov bx, word ptr [0x4010]            ; ds:4010
  114A:0048  push word ptr [bx + 4]
  114A:004B  call far func_1E42_01BF              ; T:01BF slot 33
  114A:0050  pop bx
  114A:0051  mov ax, word ptr [bp + 6]
  114A:0054  mov word ptr [0x2299], ax            ; ds:2299
  114A:0057  mov ax, word ptr [bp + 8]
  114A:005A  mov word ptr [0x229d], ax            ; ds:229D
  114A:005D  mov ax, word ptr [bp + 0xa]
  114A:0060  mov word ptr [0x229b], ax            ; ds:229B
  114A:0063  mov ax, word ptr [bp + 0xc]
  114A:0066  mov word ptr [0x229f], ax            ; ds:229F
  114A:0069  call far func_0FB2_0324              ; -> 0FB2:0324
  114A:006E  leave
  114A:006F  retf

; ===== func_114A_0070  bp-frame  callers: C=6 asm=0  seeds=call,far =====
func_114A_0070:
  114A:0070  enter 8, 0
  114A:0074  push di
  114A:0075  push si
  114A:0076  mov ax, word ptr [bp + 0x14]
  114A:0079  sub ax, word ptr [bp + 0x12]
  114A:007C  inc ax
  114A:007D  mov word ptr [bp - 2], ax
  114A:0080  push word ptr [bp + 0x12]
  114A:0083  push word ptr [bp + 0xe]
  114A:0086  call far func_1E42_0250              ; T:0250 slot 62
  114A:008B  pop bx
  114A:008C  pop bx
  114A:008D  push ax
  114A:008E  call far func_1E42_019C              ; T:019C slot 26
  114A:0093  pop bx
  114A:0094  mov ax, word ptr [bp + 0x10]
  114A:0097  sub ax, word ptr [bp + 0xe]
  114A:009A  mov word ptr [0x2293], ax            ; ds:2293
  114A:009D  mov ax, word ptr [bp - 2]
  114A:00A0  dec ax
  114A:00A1  mov word ptr [0x2295], ax            ; ds:2295
  114A:00A4  mov bx, word ptr [0x4010]            ; ds:4010
  114A:00A8  push word ptr [bx + 4]
  114A:00AB  call far func_1E42_01BF              ; T:01BF slot 33
  114A:00B0  pop bx
  114A:00B1  mov ax, word ptr [bp + 6]
  114A:00B4  sub ax, word ptr [bp + 0xe]
  114A:00B7  mov word ptr [0x2299], ax            ; ds:2299
  114A:00BA  mov cx, word ptr [bp + 8]
  114A:00BD  sub cx, word ptr [bp + 0x12]
  114A:00C0  mov word ptr [0x229d], cx            ; ds:229D
  114A:00C4  mov dx, word ptr [bp + 0xa]
  114A:00C7  sub dx, word ptr [bp + 0xe]
  114A:00CA  mov word ptr [0x229b], dx            ; ds:229B
  114A:00CE  mov bx, word ptr [bp + 0xc]
  114A:00D1  sub bx, word ptr [bp + 0x12]
  114A:00D4  mov word ptr [0x229f], bx            ; ds:229F
  114A:00D8  mov si, ax
  114A:00DA  mov di, cx
  114A:00DC  mov word ptr [bp - 6], dx
  114A:00DF  mov word ptr [bp - 8], bx
  114A:00E2  call far func_0FB2_0324              ; -> 0FB2:0324
  114A:00E7  cmp word ptr [bp + 0x16], 0
  114A:00EB  je loc_114A_0137
  114A:00ED  call far func_1E42_01FB              ; T:01FB slot 45
  114A:00F2  mov byte ptr [0x40b6], al            ; ds:40B6
  114A:00F5  cmp al, 1
  114A:00F7  sbb ax, ax
  114A:00F9  neg ax
  114A:00FB  push ax
  114A:00FC  call far func_1E42_0160              ; T:0160 slot 14
  114A:0101  pop bx
  114A:0102  mov bx, word ptr [0x4010]            ; ds:4010
  114A:0106  push word ptr [bx + 4]
  114A:0109  call far func_1E42_01BF              ; T:01BF slot 33
  114A:010E  pop bx
  114A:010F  mov word ptr [0x2299], si            ; ds:2299
  114A:0113  mov word ptr [0x229d], di            ; ds:229D
  114A:0117  mov ax, word ptr [bp - 6]
  114A:011A  mov word ptr [0x229b], ax            ; ds:229B
  114A:011D  mov ax, word ptr [bp - 8]
  114A:0120  mov word ptr [0x229f], ax            ; ds:229F
  114A:0123  call far func_0FB2_0324              ; -> 0FB2:0324
  114A:0128  cmp byte ptr [0x40b6], 1             ; ds:40B6
  114A:012D  sbb ax, ax
  114A:012F  inc ax
  114A:0130  push ax
  114A:0131  call far func_1E42_0160              ; T:0160 slot 14
  114A:0136  pop bx
loc_114A_0137:    ; <- jcc:114A:00EB
  114A:0137  mov word ptr [0x2293], 0x13f         ; ds:2293
  114A:013D  mov word ptr [0x2295], 0xc7          ; ds:2295
  114A:0143  push 0
  114A:0145  call far func_1E42_019C              ; T:019C slot 26
  114A:014A  pop bx
  114A:014B  pop si
  114A:014C  pop di
  114A:014D  leave
  114A:014E  retf

; ===== func_114A_014F  bp-frame  callers: C=3 asm=0  seeds=far =====
func_114A_014F:
  114A:014F  push bp
  114A:0150  mov bp, sp
  114A:0152  mov ax, word ptr [bp + 0xe]
  114A:0155  mov bx, word ptr [0x4010]            ; ds:4010
  114A:0159  mov word ptr [bx + 4], ax
  114A:015C  mov bx, word ptr [0x4028]            ; ds:4028
  114A:0160  mov word ptr [bx + 4], ax
  114A:0163  push 0
  114A:0165  push 0xc7
  114A:0168  push 0
  114A:016A  push 0x13f
  114A:016D  push 0
  114A:016F  push word ptr [bp + 8]
  114A:0172  push word ptr [bp + 0xa]
  114A:0175  push word ptr [bp + 8]
  114A:0178  push word ptr [bp + 6]
  114A:017B  push cs
  114A:017C  call func_114A_0070
  114A:017F  mov sp, bp
  114A:0181  push 0
  114A:0183  push 0xc7
  114A:0186  push 0
  114A:0188  push 0x13f
  114A:018B  push 0
  114A:018D  push word ptr [bp + 0xc]
  114A:0190  push word ptr [bp + 0xa]
  114A:0193  push word ptr [bp + 0xc]
  114A:0196  push word ptr [bp + 6]
  114A:0199  push cs
  114A:019A  call func_114A_0070
  114A:019D  mov sp, bp
  114A:019F  push 0
  114A:01A1  push 0xc7
  114A:01A4  push 0
  114A:01A6  push 0x13f
  114A:01A9  push 0
  114A:01AB  push word ptr [bp + 0xc]
  114A:01AE  push word ptr [bp + 6]
  114A:01B1  push word ptr [bp + 8]
  114A:01B4  push word ptr [bp + 6]
  114A:01B7  push cs
  114A:01B8  call func_114A_0070
  114A:01BB  mov sp, bp
  114A:01BD  push 0
  114A:01BF  push 0xc7
  114A:01C2  push 0
  114A:01C4  push 0x13f
  114A:01C7  push 0
  114A:01C9  push word ptr [bp + 0xc]
  114A:01CC  push word ptr [bp + 0xa]
  114A:01CF  push word ptr [bp + 8]
  114A:01D2  push word ptr [bp + 0xa]
  114A:01D5  push cs
  114A:01D6  call func_114A_0070
  114A:01D9  leave
  114A:01DA  retf

; ===== func_114A_01DB  bp-frame  callers: C=4 asm=0  seeds=far =====
func_114A_01DB:
  114A:01DB  enter 4, 0
  114A:01DF  push di
  114A:01E0  push si
  114A:01E1  mov ax, word ptr [bp + 0xa]
  114A:01E4  mov bx, word ptr [0x4010]            ; ds:4010
  114A:01E8  mov word ptr [bx + 4], ax
  114A:01EB  mov bx, word ptr [0x4028]            ; ds:4028
  114A:01EF  mov word ptr [bx + 4], ax
  114A:01F2  push 0
  114A:01F4  push 0xc7
  114A:01F7  push 0
  114A:01F9  push 0x13f
  114A:01FC  push 0
  114A:01FE  mov ax, word ptr [bp + 8]
  114A:0201  sub ax, 3
  114A:0204  push ax
  114A:0205  mov cx, word ptr [bp + 6]
  114A:0208  add cx, 4
  114A:020B  push cx
  114A:020C  push ax
  114A:020D  mov dx, word ptr [bp + 6]
  114A:0210  sub dx, 4
  114A:0213  push dx
  114A:0214  mov si, ax
  114A:0216  mov di, cx
  114A:0218  mov word ptr [bp - 2], dx
  114A:021B  push cs
  114A:021C  call func_114A_0070
  114A:021F  add sp, 0x12
  114A:0222  push 0
  114A:0224  push 0xc7
  114A:0227  push 0
  114A:0229  push 0x13f
  114A:022C  push 0
  114A:022E  mov ax, word ptr [bp + 8]
  114A:0231  add ax, 3
  114A:0234  push ax
  114A:0235  push di
  114A:0236  push si
  114A:0237  push di
  114A:0238  mov word ptr [bp - 4], ax
  114A:023B  push cs
  114A:023C  call func_114A_0070
  114A:023F  add sp, 0x12
  114A:0242  push 0
  114A:0244  push 0xc7
  114A:0247  push 0
  114A:0249  push 0x13f
  114A:024C  push 0
  114A:024E  push word ptr [bp - 4]
  114A:0251  push word ptr [bp - 2]
  114A:0254  push word ptr [bp - 4]
  114A:0257  push di
  114A:0258  push cs
  114A:0259  call func_114A_0070
  114A:025C  add sp, 0x12
  114A:025F  push 0
  114A:0261  push 0xc7
  114A:0264  push 0
  114A:0266  push 0x13f
  114A:0269  push 0
  114A:026B  push si
  114A:026C  push word ptr [bp - 2]
  114A:026F  push word ptr [bp - 4]
  114A:0272  push word ptr [bp - 2]
  114A:0275  push cs
  114A:0276  call func_114A_0070
  114A:0279  add sp, 0x12
  114A:027C  pop si
  114A:027D  pop di
  114A:027E  leave
  114A:027F  retf

; ===== func_114A_0280  bp-frame  callers: C=8 asm=0  seeds=far =====
func_114A_0280:
  114A:0280  enter 2, 0
  114A:0284  mov ax, word ptr [bp + 8]
  114A:0287  mov bx, word ptr [0x4010]            ; ds:4010
  114A:028B  mov word ptr [bx + 4], ax
  114A:028E  mov bx, word ptr [0x4028]            ; ds:4028
  114A:0292  mov word ptr [bx + 4], ax
  114A:0295  cmp word ptr [bp + 6], 1
  114A:0299  jne loc_114A_02B1
  114A:029B  push 0xa9
  114A:029E  push 0x96
  114A:02A1  push 0x6e
  114A:02A3  push 0x4a
  114A:02A5  cmp byte ptr [0x40b6], 0             ; ds:40B6
  114A:02AA  je loc_114A_02C3
loc_114A_02AC:    ; <- jcc:114A:02C1
  114A:02AC  mov ax, word ptr [0x4028]            ; ds:4028
  114A:02AF  jmp loc_114A_02C6
loc_114A_02B1:    ; <- jcc:114A:0299
  114A:02B1  push 0xa9
  114A:02B4  push 0xf5
  114A:02B7  push 0x6e
  114A:02B9  push 0xa9
  114A:02BC  cmp byte ptr [0x40b6], 0             ; ds:40B6
  114A:02C1  jne loc_114A_02AC
loc_114A_02C3:    ; <- jcc:114A:02AA
  114A:02C3  mov ax, word ptr [0x4010]            ; ds:4010
loc_114A_02C6:    ; <- jmp:114A:02AF
  114A:02C6  push ax
  114A:02C7  call far func_0FB2_0246              ; -> 0FB2:0246
  114A:02CC  leave
  114A:02CD  retf

; ===== func_114A_02CE  bp-frame  callers: C=3 asm=0  seeds=far =====
func_114A_02CE:
  114A:02CE  push bp
  114A:02CF  mov bp, sp
  114A:02D1  push word ptr [bp + 0xc]
  114A:02D4  push word ptr [bp + 0xa]
  114A:02D7  push word ptr [bp + 8]
  114A:02DA  push word ptr [bp + 6]
  114A:02DD  push word ptr [0x4010]               ; ds:4010
  114A:02E1  call far func_0FB2_0246              ; -> 0FB2:0246
  114A:02E6  mov sp, bp
  114A:02E8  push word ptr [bp + 0xc]
  114A:02EB  push word ptr [bp + 0xa]
  114A:02EE  push word ptr [bp + 8]
  114A:02F1  push word ptr [bp + 6]
  114A:02F4  push word ptr [0x4028]               ; ds:4028
  114A:02F8  call far func_0FB2_0246              ; -> 0FB2:0246
  114A:02FD  leave
  114A:02FE  retf

; ===== func_114A_02FF  bp-frame  callers: C=4 asm=0  seeds=far =====
func_114A_02FF:
  114A:02FF  push bp
  114A:0300  mov bp, sp
  114A:0302  push word ptr [bp + 0xc]
  114A:0305  push word ptr [bp + 0xa]
  114A:0308  push word ptr [bp + 8]
  114A:030B  push word ptr [bp + 6]
  114A:030E  push 0
  114A:0310  push word ptr [bp + 8]
  114A:0313  push word ptr [bp + 6]
  114A:0316  push 2
  114A:0318  call far func_1E42_01EC              ; T:01EC slot 42
  114A:031D  mov sp, bp
  114A:031F  push word ptr [bp + 0xc]
  114A:0322  push word ptr [bp + 0xa]
  114A:0325  push word ptr [bp + 8]
  114A:0328  push word ptr [bp + 6]
  114A:032B  push 1
  114A:032D  push word ptr [bp + 8]
  114A:0330  push word ptr [bp + 6]
  114A:0333  push 2
  114A:0335  call far func_1E42_01EC              ; T:01EC slot 42
  114A:033A  leave
  114A:033B  retf

; ===== func_114A_033C  bp-frame  callers: C=4 asm=0  seeds=far =====
func_114A_033C:
  114A:033C  push bp
  114A:033D  mov bp, sp
  114A:033F  cmp word ptr [0x368c], 0             ; ds:368C
  114A:0344  je loc_114A_03AB
  114A:0346  mov ax, word ptr [bp + 8]
  114A:0349  mov bx, word ptr [0x4010]            ; ds:4010
  114A:034D  mov word ptr [bx + 4], ax
  114A:0350  cmp word ptr [bp + 6], 0
  114A:0354  jle loc_114A_037F
  114A:0356  mov ax, word ptr [bp + 0xc]
  114A:0359  add ax, 0xbb
  114A:035C  push ax
  114A:035D  mov ax, word ptr [bp + 6]
  114A:0360  cdq
  114A:0361  sub ax, dx
  114A:0363  sar ax, 1
  114A:0365  add ax, 0x56
  114A:0368  push ax
  114A:0369  mov ax, word ptr [bp + 0xa]
  114A:036C  add ax, 0xbb
  114A:036F  push ax
  114A:0370  push 0x56
  114A:0372  push word ptr [0x4010]               ; ds:4010
  114A:0376  call far func_0FB2_0246              ; -> 0FB2:0246
  114A:037B  mov sp, bp
  114A:037D  leave
  114A:037E  retf
loc_114A_037F:    ; <- jcc:114A:0354
  114A:037F  cmp word ptr [bp + 6], 0
  114A:0383  jge loc_114A_03AB
  114A:0385  mov ax, word ptr [bp + 0xc]
  114A:0388  add ax, 0xbb
  114A:038B  push ax
  114A:038C  push 0x88
  114A:038F  mov ax, word ptr [bp + 0xa]
  114A:0392  add ax, 0xbb
  114A:0395  push ax
  114A:0396  mov ax, word ptr [bp + 6]
  114A:0399  cdq
  114A:039A  sub ax, dx
  114A:039C  sar ax, 1
  114A:039E  add ax, 0x88
  114A:03A1  push ax
  114A:03A2  push word ptr [0x4010]               ; ds:4010
  114A:03A6  call far func_0FB2_0246              ; -> 0FB2:0246
loc_114A_03AB:    ; <- jcc:114A:0344 jcc:114A:0383
  114A:03AB  leave
  114A:03AC  retf

; ===== func_114A_03AD  bp-frame  callers: C=4 asm=0  seeds=far =====
func_114A_03AD:
  114A:03AD  push bp
  114A:03AE  mov bp, sp
  114A:03B0  mov ax, word ptr [0xe584]            ; ds:E584
  114A:03B3  mov word ptr [0x4072], ax            ; ds:4072
  114A:03B6  mov ax, word ptr [bp + 6]
  114A:03B9  shl ax, 3
  114A:03BC  inc ax
  114A:03BD  mov word ptr [0x4074], ax            ; ds:4074
  114A:03C0  mov ax, word ptr [bp + 8]
  114A:03C3  shl ax, 3
  114A:03C6  add ax, 0x29
  114A:03C9  mov word ptr [0x4076], ax            ; ds:4076
  114A:03CC  cmp byte ptr [0x40b6], 1             ; ds:40B6
  114A:03D1  sbb ax, ax
  114A:03D3  inc ax
  114A:03D4  mov word ptr [0x4078], ax            ; ds:4078
  114A:03D7  mov ax, word ptr [bp + 0xa]
  114A:03DA  sub ax, 3
  114A:03DD  mov word ptr [0x407a], ax            ; ds:407A
  114A:03E0  mov ax, word ptr [bp + 0xc]
  114A:03E3  sub ax, 3
  114A:03E6  mov word ptr [0x407c], ax            ; ds:407C
  114A:03E9  mov ax, 7
  114A:03EC  mov word ptr [0x407e], ax            ; ds:407E
  114A:03EF  mov word ptr [0x4080], ax            ; ds:4080
  114A:03F2  push 0x4072
  114A:03F5  call far func_1E42_027D              ; T:027D slot 71
  114A:03FA  pop bx
  114A:03FB  leave
  114A:03FC  retf

; ===== func_114A_03FD  bp-frame  callers: C=11 asm=0  seeds=far =====
func_114A_03FD:
  114A:03FD  push bp
  114A:03FE  mov bp, sp
  114A:0400  mov ax, word ptr [0xe584]            ; ds:E584
  114A:0403  mov word ptr [0x4090], ax            ; ds:4090
  114A:0406  mov ax, word ptr [bp + 0xa]
  114A:0409  mov word ptr [0x4092], ax            ; ds:4092
  114A:040C  mov ax, word ptr [bp + 0xc]
  114A:040F  mov word ptr [0x4094], ax            ; ds:4094
  114A:0412  cmp byte ptr [0x40b6], 1             ; ds:40B6
  114A:0417  sbb ax, ax
  114A:0419  inc ax
  114A:041A  mov word ptr [0x4096], ax            ; ds:4096
  114A:041D  mov ax, word ptr [bp + 6]
  114A:0420  mov word ptr [0x4098], ax            ; ds:4098
  114A:0423  mov ax, word ptr [bp + 8]
  114A:0426  mov word ptr [0x409a], ax            ; ds:409A
  114A:0429  mov ax, word ptr [bp + 0xe]
  114A:042C  mov word ptr [0x409c], ax            ; ds:409C
  114A:042F  mov ax, word ptr [bp + 0x10]
  114A:0432  mov word ptr [0x409e], ax            ; ds:409E
  114A:0435  mov al, byte ptr [bp + 0x12]
  114A:0438  mov byte ptr [0x40a9], al            ; ds:40A9
  114A:043B  cmp word ptr [bp + 0x12], 0
  114A:043F  je loc_114A_0451
  114A:0441  mov byte ptr [0x40a8], 1             ; ds:40A8
  114A:0446  push 0x4090
  114A:0449  call far func_1E42_027D              ; T:027D slot 71
  114A:044E  pop bx
  114A:044F  leave
  114A:0450  retf
loc_114A_0451:    ; <- jcc:114A:043F
  114A:0451  mov byte ptr [0x40a8], 0x10          ; ds:40A8
  114A:0456  push 0x4090
  114A:0459  call far func_1E42_0287              ; T:0287 slot 73
  114A:045E  pop bx
  114A:045F  leave
  114A:0460  retf

; ===== func_114A_0461  bp-frame  callers: C=2 asm=0  seeds=far =====
func_114A_0461:
  114A:0461  push bp
  114A:0462  mov bp, sp
  114A:0464  mov ax, word ptr [bp + 6]
  114A:0467  or ax, ax
  114A:0469  je loc_114A_0476
  114A:046B  dec ax
  114A:046C  je loc_114A_047B
  114A:046E  dec ax
  114A:046F  je loc_114A_048D
  114A:0471  dec ax
  114A:0472  je loc_114A_049A
  114A:0474  jmp loc_114A_04AF
loc_114A_0476:    ; <- jcc:114A:0469
  114A:0476  sar word ptr [bp + 8], 1
  114A:0479  jmp loc_114A_04AF
loc_114A_047B:    ; <- jcc:114A:046C
  114A:047B  mov ax, word ptr [bp + 8]
  114A:047E  sar ax, 1
  114A:0480  mov cx, word ptr [bp + 8]
  114A:0483  sar cx, 3
loc_114A_0486:    ; <- jmp:114A:0498 jmp:114A:04AD
  114A:0486  add ax, cx
  114A:0488  mov word ptr [bp + 8], ax
  114A:048B  jmp loc_114A_04AF
loc_114A_048D:    ; <- jcc:114A:046F
  114A:048D  mov ax, word ptr [bp + 8]
  114A:0490  sar ax, 1
  114A:0492  mov cx, word ptr [bp + 8]
  114A:0495  sar cx, 2
  114A:0498  jmp loc_114A_0486
loc_114A_049A:    ; <- jcc:114A:0472
  114A:049A  mov ax, word ptr [bp + 8]
  114A:049D  sar ax, 1
  114A:049F  mov cx, word ptr [bp + 8]
  114A:04A2  sar cx, 2
  114A:04A5  mov dx, word ptr [bp + 8]
  114A:04A8  sar dx, 3
  114A:04AB  add cx, dx
  114A:04AD  jmp loc_114A_0486
loc_114A_04AF:    ; <- jmp:114A:0474 jmp:114A:0479 jmp:114A:048B
  114A:04AF  mov ax, word ptr [bp + 8]
  114A:04B2  leave
  114A:04B3  retf

; ===== func_114A_04B4  bp-frame  callers: C=1 asm=0  seeds=far =====
func_114A_04B4:
  114A:04B4  push bp
  114A:04B5  mov bp, sp
  114A:04B7  push di
  114A:04B8  push si
  114A:04B9  mov bx, word ptr [bp + 8]
  114A:04BC  push word ptr [bx + 6]
  114A:04BF  mov si, word ptr [bp + 6]
  114A:04C2  push word ptr [si + 2]
  114A:04C5  call far func_104E_0000              ; -> 104E:0000
  114A:04CA  pop bx
  114A:04CB  pop bx
  114A:04CC  mov bx, word ptr [bp + 8]
  114A:04CF  push word ptr [bx]
  114A:04D1  push word ptr [si]
  114A:04D3  mov di, ax
  114A:04D5  call far func_104E_0000              ; -> 104E:0000
  114A:04DA  pop bx
  114A:04DB  pop bx
  114A:04DC  mov bx, word ptr [bp + 8]
  114A:04DF  push word ptr [bx + 0xc]
  114A:04E2  push word ptr [si + 4]
  114A:04E5  mov si, ax
  114A:04E7  call far func_104E_0000              ; -> 104E:0000
  114A:04EC  pop bx
  114A:04ED  pop bx
  114A:04EE  add si, ax
  114A:04F0  add di, si
  114A:04F2  mov bx, word ptr [bp + 0xa]
  114A:04F5  mov word ptr [bx], di
  114A:04F7  mov si, word ptr [bp + 8]
  114A:04FA  push word ptr [si + 2]
  114A:04FD  mov di, word ptr [bp + 6]
  114A:0500  push word ptr [di]
  114A:0502  call far func_104E_0000              ; -> 104E:0000
  114A:0507  pop bx
  114A:0508  pop bx
  114A:0509  push word ptr [si + 0xe]
  114A:050C  push word ptr [di + 4]
  114A:050F  mov si, ax
  114A:0511  call far func_104E_0000              ; -> 104E:0000
  114A:0516  pop bx
  114A:0517  pop bx
  114A:0518  mov bx, word ptr [bp + 8]
  114A:051B  push word ptr [bx + 8]
  114A:051E  push word ptr [di + 2]
  114A:0521  mov di, ax
  114A:0523  call far func_104E_0000              ; -> 104E:0000
  114A:0528  pop bx
  114A:0529  pop bx
  114A:052A  add di, ax
  114A:052C  add si, di
  114A:052E  mov bx, word ptr [bp + 0xa]
  114A:0531  mov word ptr [bx + 2], si
  114A:0534  mov si, word ptr [bp + 8]
  114A:0537  push word ptr [si + 4]
  114A:053A  mov di, word ptr [bp + 6]
  114A:053D  push word ptr [di]
  114A:053F  call far func_104E_0000              ; -> 104E:0000
  114A:0544  pop bx
  114A:0545  pop bx
  114A:0546  push word ptr [si + 0x10]
  114A:0549  push word ptr [di + 4]
  114A:054C  mov si, ax
  114A:054E  call far func_104E_0000              ; -> 104E:0000
  114A:0553  pop bx
  114A:0554  pop bx
  114A:0555  mov bx, word ptr [bp + 8]
  114A:0558  push word ptr [bx + 0xa]
  114A:055B  push word ptr [di + 2]
  114A:055E  mov di, ax
  114A:0560  call far func_104E_0000              ; -> 104E:0000
  114A:0565  pop bx
  114A:0566  pop bx
  114A:0567  add di, ax
  114A:0569  add si, di
  114A:056B  mov bx, word ptr [bp + 0xa]
  114A:056E  mov word ptr [bx + 4], si
  114A:0571  mov si, word ptr [bp + 8]
  114A:0574  push word ptr [si + 6]
  114A:0577  mov di, word ptr [bp + 6]
  114A:057A  push word ptr [di + 8]
  114A:057D  call far func_104E_0000              ; -> 104E:0000
  114A:0582  pop bx
  114A:0583  pop bx
  114A:0584  push word ptr [si]
  114A:0586  push word ptr [di + 6]
  114A:0589  mov si, ax
  114A:058B  call far func_104E_0000              ; -> 104E:0000
  114A:0590  pop bx
  114A:0591  pop bx
  114A:0592  mov bx, word ptr [bp + 8]
  114A:0595  push word ptr [bx + 0xc]
  114A:0598  push word ptr [di + 0xa]
  114A:059B  mov di, ax
  114A:059D  call far func_104E_0000              ; -> 104E:0000
  114A:05A2  pop bx
  114A:05A3  pop bx
  114A:05A4  add di, ax
  114A:05A6  add si, di
  114A:05A8  mov bx, word ptr [bp + 0xa]
  114A:05AB  mov word ptr [bx + 6], si
  114A:05AE  mov si, word ptr [bp + 8]
  114A:05B1  push word ptr [si + 2]
  114A:05B4  mov di, word ptr [bp + 6]
  114A:05B7  push word ptr [di + 6]
  114A:05BA  call far func_104E_0000              ; -> 104E:0000
  114A:05BF  pop bx
  114A:05C0  pop bx
  114A:05C1  push word ptr [si + 0xe]
  114A:05C4  push word ptr [di + 0xa]
  114A:05C7  mov si, ax
  114A:05C9  call far func_104E_0000              ; -> 104E:0000
  114A:05CE  pop bx
  114A:05CF  pop bx
  114A:05D0  mov bx, word ptr [bp + 8]
  114A:05D3  push word ptr [bx + 8]
  114A:05D6  push word ptr [di + 8]
  114A:05D9  mov di, ax
  114A:05DB  call far func_104E_0000              ; -> 104E:0000
  114A:05E0  pop bx
  114A:05E1  pop bx
  114A:05E2  add di, ax
  114A:05E4  add si, di
  114A:05E6  mov bx, word ptr [bp + 0xa]
  114A:05E9  mov word ptr [bx + 8], si
  114A:05EC  mov si, word ptr [bp + 8]
  114A:05EF  push word ptr [si + 4]
  114A:05F2  mov di, word ptr [bp + 6]
  114A:05F5  push word ptr [di + 6]
  114A:05F8  call far func_104E_0000              ; -> 104E:0000
  114A:05FD  pop bx
  114A:05FE  pop bx
  114A:05FF  push word ptr [si + 0x10]
  114A:0602  push word ptr [di + 0xa]
  114A:0605  mov si, ax
  114A:0607  call far func_104E_0000              ; -> 104E:0000
  114A:060C  pop bx
  114A:060D  pop bx
  114A:060E  mov bx, word ptr [bp + 8]
  114A:0611  push word ptr [bx + 0xa]
  114A:0614  push word ptr [di + 8]
  114A:0617  mov di, ax
  114A:0619  call far func_104E_0000              ; -> 104E:0000
  114A:061E  pop bx
  114A:061F  pop bx
  114A:0620  add di, ax
  114A:0622  add si, di
  114A:0624  mov bx, word ptr [bp + 0xa]
  114A:0627  mov word ptr [bx + 0xa], si
  114A:062A  mov si, word ptr [bp + 8]
  114A:062D  push word ptr [si + 6]
  114A:0630  mov di, word ptr [bp + 6]
  114A:0633  push word ptr [di + 0xe]
  114A:0636  call far func_104E_0000              ; -> 104E:0000
  114A:063B  pop bx
  114A:063C  pop bx
  114A:063D  push word ptr [si]
  114A:063F  push word ptr [di + 0xc]
  114A:0642  mov si, ax
  114A:0644  call far func_104E_0000              ; -> 104E:0000
  114A:0649  pop bx
  114A:064A  pop bx
  114A:064B  mov bx, word ptr [bp + 8]
  114A:064E  push word ptr [bx + 0xc]
  114A:0651  push word ptr [di + 0x10]
  114A:0654  mov di, ax
  114A:0656  call far func_104E_0000              ; -> 104E:0000
  114A:065B  pop bx
  114A:065C  pop bx
  114A:065D  add di, ax
  114A:065F  add si, di
  114A:0661  mov bx, word ptr [bp + 0xa]
  114A:0664  mov word ptr [bx + 0xc], si
  114A:0667  mov si, word ptr [bp + 8]
  114A:066A  push word ptr [si + 2]
  114A:066D  mov di, word ptr [bp + 6]
  114A:0670  push word ptr [di + 0xc]
  114A:0673  call far func_104E_0000              ; -> 104E:0000
  114A:0678  pop bx
  114A:0679  pop bx
  114A:067A  push word ptr [si + 0xe]
  114A:067D  push word ptr [di + 0x10]
  114A:0680  mov si, ax
  114A:0682  call far func_104E_0000              ; -> 104E:0000
  114A:0687  pop bx
  114A:0688  pop bx
  114A:0689  mov bx, word ptr [bp + 8]
  114A:068C  push word ptr [bx + 8]
  114A:068F  push word ptr [di + 0xe]
  114A:0692  mov di, ax
  114A:0694  call far func_104E_0000              ; -> 104E:0000
  114A:0699  pop bx
  114A:069A  pop bx
  114A:069B  add di, ax
  114A:069D  add si, di
  114A:069F  mov bx, word ptr [bp + 0xa]
  114A:06A2  mov word ptr [bx + 0xe], si
  114A:06A5  mov si, word ptr [bp + 8]
  114A:06A8  push word ptr [si + 4]
  114A:06AB  mov di, word ptr [bp + 6]
  114A:06AE  push word ptr [di + 0xc]
  114A:06B1  call far func_104E_0000              ; -> 104E:0000
  114A:06B6  pop bx
  114A:06B7  pop bx
  114A:06B8  push word ptr [si + 0x10]
  114A:06BB  push word ptr [di + 0x10]
  114A:06BE  mov si, ax
  114A:06C0  call far func_104E_0000              ; -> 104E:0000
  114A:06C5  pop bx
  114A:06C6  pop bx
  114A:06C7  mov bx, word ptr [bp + 8]
  114A:06CA  push word ptr [bx + 0xa]
  114A:06CD  push word ptr [di + 0xe]
  114A:06D0  mov di, ax
  114A:06D2  call far func_104E_0000              ; -> 104E:0000
  114A:06D7  pop bx
  114A:06D8  pop bx
  114A:06D9  add di, ax
  114A:06DB  add si, di
  114A:06DD  mov bx, word ptr [bp + 0xa]
  114A:06E0  mov word ptr [bx + 0x10], si
  114A:06E3  pop si
  114A:06E4  pop di
  114A:06E5  leave
  114A:06E6  retf
