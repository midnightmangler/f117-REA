; VGAME segment 1058  lin 10580..11322  size 3490 (code runs past the next paragraph value; listed here)  dgroup=1E42  (vgame_asm.py; capstone recursive descent)
; entries: 13   far-call sites into this segment: 7   unresolved indirect jumps/calls: 0

; ----- data 1058:0000 .. 1058:0009 (10 bytes) -----
;   1058:0000  8A F2 8A D4 D0 E0 13 DA C3 00                    ..........

; ===== func_1058_000A  jump/call stub  callers: C=1 asm=0  seeds=far =====
func_1058_000A:
  1058:000A  call func_1058_0016
  1058:000D  retf

; ===== func_1058_000E  jump/call stub  callers: C=1 asm=0  seeds=far =====
func_1058_000E:
  1058:000E  call func_1058_09D8
  1058:0011  retf

; ===== func_1058_0012  jump/call stub  callers: C=1 asm=0  seeds=far =====
func_1058_0012:
  1058:0012  call func_1058_0A2C
  1058:0015  retf

; ===== func_1058_0016  reg  callers: C=0 asm=0  seeds=call =====
func_1058_0016:
  1058:0016  call far func_1E42_01FB              ; T:01FB slot 45
  1058:001B  sub ah, ah
  1058:001D  mov word ptr [0x284c], ax            ; ds:284C
  1058:0020  mov word ptr [0x2862], ax            ; ds:2862
  1058:0023  mov word ptr [0x2878], ax            ; ds:2878
  1058:0026  mov word ptr [0x288e], ax            ; ds:288E
  1058:0029  mov word ptr [0x28c8], ax            ; ds:28C8
  1058:002C  mov word ptr [0x28aa], ax            ; ds:28AA
  1058:002F  mov word ptr [0x2904], ax            ; ds:2904
  1058:0032  mov word ptr [0x28e6], ax            ; ds:28E6
  1058:0035  cmp byte ptr [0x294a], 0             ; ds:294A
  1058:003A  je loc_1058_0049
  1058:003C  cmp byte ptr [0x294a], 1             ; ds:294A
  1058:0041  jne loc_1058_0046
  1058:0043  jmp loc_1058_00D9
loc_1058_0046:    ; <- jcc:1058:0041
  1058:0046  jmp loc_1058_0386
loc_1058_0049:    ; <- jcc:1058:003A
  1058:0049  mov bp, 0x284c
  1058:004C  mov ax, word ptr [0xb194]            ; ds:B194
  1058:004F  mov dh, 0x32
  1058:0051  div dh
  1058:0053  mov dl, al
  1058:0055  dec dl
  1058:0057  mov cl, byte ptr [0x2922]            ; ds:2922
  1058:005B  xchg ah, al
  1058:005D  sub ah, ah
  1058:005F  shl ax, cl
  1058:0061  mov dh, 5
  1058:0063  div dh
  1058:0065  add al, byte ptr [0x291d]            ; ds:291D
  1058:0069  mov byte ptr [0x2856], al            ; ds:2856
  1058:006C  mov byte ptr [0x2971], dl            ; ds:2971
  1058:0070  sub al, byte ptr [0x291f]            ; ds:291F
  1058:0074  mov byte ptr [0x2952], al            ; ds:2952
  1058:0077  shl dl, 1
  1058:0079  sub dh, dh
  1058:007B  mov di, dx
  1058:007D  mov byte ptr [0x2955], 5             ; ds:2955
loc_1058_0082:    ; <- jcc:1058:00C3 jmp:1058:00A3
  1058:0082  mov al, byte ptr [0x2920]            ; ds:2920
  1058:0085  sub byte ptr [0x2856], al            ; ds:2856
  1058:0089  mov ax, word ptr [0x2923]            ; ds:2923
  1058:008C  mov word ptr [0x2854], ax            ; ds:2854
  1058:008F  cmp di, 0x28
  1058:0092  jb loc_1058_00A5
  1058:0094  sub di, di
  1058:0096  dec byte ptr [0x2955]                ; ds:2955
  1058:009A  je loc_1058_00C5
  1058:009C  mov ax, word ptr [0x2920]            ; ds:2920
  1058:009F  sub word ptr [0x2952], ax            ; ds:2952
  1058:00A3  jmp loc_1058_0082
loc_1058_00A5:    ; <- jcc:1058:0092
  1058:00A5  mov ax, word ptr [di + 0x297e]
  1058:00A9  mov word ptr [0x296c], ax            ; ds:296C
  1058:00AC  mov ax, word ptr [di + 0x29ce]
  1058:00B0  mov word ptr [0x296e], ax            ; ds:296E
  1058:00B3  mov bx, 0x296c
  1058:00B6  push di
  1058:00B7  call far func_1E42_011F              ; T:011F slot 1
  1058:00BC  pop di
  1058:00BD  inc di
  1058:00BE  inc di
  1058:00BF  dec byte ptr [0x2955]                ; ds:2955
  1058:00C3  jne loc_1058_0082
loc_1058_00C5:    ; <- jcc:1058:009A
  1058:00C5  mov si, 0
  1058:00C8  mov bx, word ptr [0x2952]            ; ds:2952
  1058:00CC  mov cl, byte ptr [0x294b]            ; ds:294B
  1058:00D0  mov dl, byte ptr [0x2971]            ; ds:2971
  1058:00D4  call far func_1E42_0151              ; T:0151 slot 11
loc_1058_00D9:    ; <- jmp:1058:0043
  1058:00D9  mov ah, byte ptr [0x2ca0]            ; ds:2CA0
  1058:00DD  call far func_1E42_01BA              ; T:01BA slot 32
  1058:00E2  cmp byte ptr [0x294b], 0             ; ds:294B
  1058:00E7  je loc_1058_0126
  1058:00E9  cmp byte ptr [0x294a], 0             ; ds:294A
  1058:00EE  jne loc_1058_0112
  1058:00F0  mov ax, 0x7a
  1058:00F3  mov cx, 0x7c
  1058:00F6  mov bx, 0x3c
  1058:00F9  mov dx, 0x3c
  1058:00FC  call far func_1E42_01B5              ; T:01B5 slot 31
  1058:0101  mov ax, 0xc4
  1058:0104  mov cx, 0xc6
  1058:0107  mov bx, 0x3c
  1058:010A  mov dx, 0x3c
  1058:010D  call far func_1E42_01B5              ; T:01B5 slot 31
loc_1058_0112:    ; <- jcc:1058:00EE
  1058:0112  mov ax, 0x9f
  1058:0115  mov cx, 0x9f
  1058:0118  mov bx, 0x1d
  1058:011B  mov dx, 0x1e
  1058:011E  call far func_1E42_01B5              ; T:01B5 slot 31
  1058:0123  jmp loc_1058_0160

; ----- data 1058:0125 .. 1058:0125 (1 bytes) -----
;   1058:0125  90                                               .
loc_1058_0126:    ; <- jcc:1058:00E7
  1058:0126  cmp byte ptr [0x294a], 0             ; ds:294A
  1058:012B  jne loc_1058_014F
  1058:012D  mov ax, 0x49
  1058:0130  mov cx, 0x4c
  1058:0133  mov bx, 0x34
  1058:0136  mov dx, 0x34
  1058:0139  call far func_1E42_01B5              ; T:01B5 slot 31
  1058:013E  mov ax, 0xf3
  1058:0141  mov cx, 0xf6
  1058:0144  mov bx, 0x34
  1058:0147  mov dx, 0x34
  1058:014A  call far func_1E42_01B5              ; T:01B5 slot 31
loc_1058_014F:    ; <- jcc:1058:012B
  1058:014F  mov ax, 0x9f
  1058:0152  mov cx, 0x9f
  1058:0155  mov bx, 0x10
  1058:0158  mov dx, 0x12
  1058:015B  call far func_1E42_01B5              ; T:01B5 slot 31
loc_1058_0160:    ; <- jmp:1058:0123
  1058:0160  cmp byte ptr [0x294a], 0             ; ds:294A
  1058:0165  je loc_1058_0174
  1058:0167  cmp byte ptr [0x294a], 1             ; ds:294A
  1058:016C  jne loc_1058_0171
  1058:016E  jmp loc_1058_0273
loc_1058_0171:    ; <- jcc:1058:016C
  1058:0171  jmp loc_1058_0386
loc_1058_0174:    ; <- jcc:1058:0165
  1058:0174  mov ax, word ptr [0x2df6]            ; ds:2DF6
  1058:0177  sub dx, dx
  1058:0179  mov cx, 0x3e8
  1058:017C  div cx
  1058:017E  mov bx, ax
  1058:0180  dec bx
  1058:0181  mov ax, dx
  1058:0183  mov word ptr [0x294c], dx            ; ds:294C
  1058:0187  sub dx, dx
  1058:0189  mov cl, byte ptr [0x2922]            ; ds:2922
  1058:018D  shl ax, cl
  1058:018F  mov cx, 0x64
  1058:0192  div cx
  1058:0194  shl bx, 1
  1058:0196  mov di, bx
  1058:0198  mov bp, 0x284c
  1058:019B  mov byte ptr [0x2955], 5             ; ds:2955
  1058:01A0  cmp di, 0
  1058:01A3  jge loc_1058_021B
  1058:01A5  mov ax, word ptr [0x294c]            ; ds:294C
  1058:01A8  mov dh, 0x64
  1058:01AA  div dh
  1058:01AC  mov dl, al
  1058:01AE  dec dl
  1058:01B0  mov cl, byte ptr [0x2922]            ; ds:2922
  1058:01B4  xchg ah, al
  1058:01B6  sub ah, ah
  1058:01B8  shl ax, cl
  1058:01BA  mov dh, 0xa
  1058:01BC  div dh
  1058:01BE  add al, byte ptr [0x291d]            ; ds:291D
  1058:01C2  mov byte ptr [0x2856], al            ; ds:2856
  1058:01C5  mov byte ptr [0x2971], dl            ; ds:2971
  1058:01C9  sub al, byte ptr [0x291f]            ; ds:291F
  1058:01CD  mov byte ptr [0x2952], al            ; ds:2952
  1058:01D0  shl dl, 1
  1058:01D2  sub dh, dh
  1058:01D4  mov di, dx
loc_1058_01D6:    ; <- jcc:1058:0213 jmp:1058:01F5
  1058:01D6  mov al, byte ptr [0x2920]            ; ds:2920
  1058:01D9  sub byte ptr [0x2856], al            ; ds:2856
  1058:01DD  mov ax, word ptr [0x2925]            ; ds:2925
  1058:01E0  mov word ptr [0x2854], ax            ; ds:2854
  1058:01E3  cmp di, 0x28
  1058:01E6  jb loc_1058_01F7
  1058:01E8  sub di, di
  1058:01EA  dec byte ptr [0x2955]                ; ds:2955
  1058:01EE  mov ax, word ptr [0x2920]            ; ds:2920
  1058:01F1  sub word ptr [0x2952], ax            ; ds:2952
  1058:01F5  jmp loc_1058_01D6
loc_1058_01F7:    ; <- jcc:1058:01E6
  1058:01F7  mov al, byte ptr [di + 0x2a1f]
  1058:01FB  mov byte ptr [0x2976], al            ; ds:2976
  1058:01FE  mov bx, 0x2976
  1058:0201  push di
  1058:0202  call far func_1E42_011F              ; T:011F slot 1
  1058:0207  pop di
  1058:0208  inc di
  1058:0209  inc di
  1058:020A  dec byte ptr [0x2955]                ; ds:2955
  1058:020E  je loc_1058_025F
  1058:0210  cmp di, 0x14
  1058:0213  jb loc_1058_01D6
  1058:0215  mov di, 2
  1058:0218  jmp loc_1058_022E

; ----- data 1058:021A .. 1058:021A (1 bytes) -----
;   1058:021A  90                                               .
loc_1058_021B:    ; <- jcc:1058:01A3
  1058:021B  add ax, word ptr [0x291d]            ; ds:291D
  1058:021F  mov word ptr [0x2856], ax            ; ds:2856
  1058:0222  mov byte ptr [0x2971], 2             ; ds:2971
  1058:0227  sub al, byte ptr [0x291f]            ; ds:291F
  1058:022B  mov byte ptr [0x2952], al            ; ds:2952
loc_1058_022E:    ; <- jcc:1058:025D jmp:1058:0218
  1058:022E  mov al, byte ptr [0x2920]            ; ds:2920
  1058:0231  sub byte ptr [0x2856], al            ; ds:2856
  1058:0235  mov ax, word ptr [0x2925]            ; ds:2925
  1058:0238  mov word ptr [0x2854], ax            ; ds:2854
  1058:023B  cmp di, 0
  1058:023E  jne loc_1058_0246
  1058:0240  mov bx, 0x297a
  1058:0243  jmp loc_1058_0250

; ----- data 1058:0245 .. 1058:0245 (1 bytes) -----
;   1058:0245  90                                               .
loc_1058_0246:    ; <- jcc:1058:023E
  1058:0246  mov ax, word ptr [di + 0x2a1e]
  1058:024A  mov word ptr [0x2972], ax            ; ds:2972
  1058:024D  mov bx, 0x2972
loc_1058_0250:    ; <- jmp:1058:0243
  1058:0250  push di
  1058:0251  call far func_1E42_011F              ; T:011F slot 1
  1058:0256  pop di
  1058:0257  inc di
  1058:0258  inc di
  1058:0259  dec byte ptr [0x2955]                ; ds:2955
  1058:025D  jne loc_1058_022E
loc_1058_025F:    ; <- jcc:1058:020E
  1058:025F  mov si, 2
  1058:0262  mov bx, word ptr [0x2952]            ; ds:2952
  1058:0266  mov cl, byte ptr [0x294b]            ; ds:294B
  1058:026A  mov dl, byte ptr [0x2971]            ; ds:2971
  1058:026E  call far func_1E42_0151              ; T:0151 slot 11
loc_1058_0273:    ; <- jmp:1058:016E
  1058:0273  mov ax, word ptr [0x2dee]            ; ds:2DEE
  1058:0276  sub ax, 0x2000
  1058:0279  mov dl, ah
  1058:027B  and ax, 0x1f80
  1058:027E  shl ax, 1
  1058:0280  xchg ah, al
  1058:0282  mov dh, byte ptr [0x2927]            ; ds:2927
  1058:0286  mul dh
  1058:0288  shr ax, 1
  1058:028A  shr ax, 1
  1058:028C  shr ax, 1
  1058:028E  shr ax, 1
  1058:0290  shr ax, 1
  1058:0292  shr ax, 1
  1058:0294  mov byte ptr [0x2954], al            ; ds:2954
  1058:0297  xchg ah, al
  1058:0299  mov al, byte ptr [0x291c]            ; ds:291C
  1058:029C  sub al, ah
  1058:029E  sub ah, ah
  1058:02A0  mov word ptr [0x2950], ax            ; ds:2950
  1058:02A3  mov word ptr [0x286a], ax            ; ds:286A
  1058:02A6  sub dh, dh
  1058:02A8  shr dx, 1
  1058:02AA  shr dx, 1
  1058:02AC  and dx, 0x38
  1058:02AF  mov word ptr [0x294e], dx            ; ds:294E
  1058:02B3  mov bx, 0x2aaa
  1058:02B6  add bx, dx
  1058:02B8  mov bp, 0x2862
  1058:02BB  call far func_1E42_0124              ; T:0124 slot 2
  1058:02C0  mov bx, 0x2aaa
  1058:02C3  add word ptr [0x294e], 8             ; ds:294E
  1058:02C8  and word ptr [0x294e], 0x3f          ; ds:294E
  1058:02CD  add bx, word ptr [0x294e]            ; ds:294E
  1058:02D1  mov ax, word ptr [0x2950]            ; ds:2950
  1058:02D4  add ax, word ptr [0x2927]            ; ds:2927
  1058:02D8  mov word ptr [0x2950], ax            ; ds:2950
  1058:02DB  mov word ptr [0x286a], ax            ; ds:286A
  1058:02DE  call far func_1E42_012E              ; T:012E slot 4
  1058:02E3  mov bx, 0x2aaa
  1058:02E6  add word ptr [0x294e], 8             ; ds:294E
  1058:02EB  and word ptr [0x294e], 0x3f          ; ds:294E
  1058:02F0  add bx, word ptr [0x294e]            ; ds:294E
  1058:02F4  mov ax, word ptr [0x2950]            ; ds:2950
  1058:02F7  add ax, word ptr [0x2927]            ; ds:2927
  1058:02FB  mov word ptr [0x2950], ax            ; ds:2950
  1058:02FE  mov word ptr [0x286a], ax            ; ds:286A
  1058:0301  call far func_1E42_012E              ; T:012E slot 4
  1058:0306  mov ax, word ptr [0x2929]            ; ds:2929
  1058:0309  cmp word ptr [0x2950], ax            ; ds:2950
  1058:030D  jae loc_1058_0386
  1058:030F  mov bx, 0x2aaa
  1058:0312  add word ptr [0x294e], 8             ; ds:294E
  1058:0317  and word ptr [0x294e], 0x3f          ; ds:294E
  1058:031C  add bx, word ptr [0x294e]            ; ds:294E
  1058:0320  mov ax, word ptr [bx]
  1058:0322  mov word ptr [bx + 4], ax
  1058:0325  mov ax, word ptr [bx + 2]
  1058:0328  mov word ptr [bx + 6], ax
  1058:032B  add bx, 4
  1058:032E  mov ax, word ptr [0x2950]            ; ds:2950
  1058:0331  add ax, word ptr [0x2927]            ; ds:2927
  1058:0335  mov word ptr [0x2950], ax            ; ds:2950
  1058:0338  mov word ptr [0x286a], ax            ; ds:286A
  1058:033B  call far func_1E42_0129              ; T:0129 slot 3
  1058:0340  mov al, byte ptr [0x2954]            ; ds:2954
  1058:0343  sub ah, ah
  1058:0345  mov dl, byte ptr [0x292b]            ; ds:292B
  1058:0349  div dl
  1058:034B  xchg ah, al
  1058:034D  sub ah, ah
  1058:034F  test word ptr [0x2dee], 0x2000       ; ds:2DEE
  1058:0355  je loc_1058_035B
  1058:0357  add ax, word ptr [0x292d]            ; ds:292D
loc_1058_035B:    ; <- jcc:1058:0355
  1058:035B  cmp ax, word ptr [0x292b]            ; ds:292B
  1058:035F  jl loc_1058_0365
  1058:0361  sub ax, word ptr [0x292b]            ; ds:292B
loc_1058_0365:    ; <- jcc:1058:035F
  1058:0365  mov di, ax
  1058:0367  shl di, 1
  1058:0369  cmp byte ptr [0x294b], 1             ; ds:294B
  1058:036E  jne loc_1058_0377
  1058:0370  mov ax, word ptr [di + 0x2afe]
  1058:0374  jmp loc_1058_037B

; ----- data 1058:0376 .. 1058:0376 (1 bytes) -----
;   1058:0376  90                                               .
loc_1058_0377:    ; <- jcc:1058:036E
  1058:0377  mov ax, word ptr [di + 0x2aea]
loc_1058_037B:    ; <- jmp:1058:0374
  1058:037B  mov word ptr [0x28a8], ax            ; ds:28A8
  1058:037E  mov bp, 0x28a4
  1058:0381  call far func_1E42_0174              ; T:0174 slot 18
loc_1058_0386:    ; <- jcc:1058:030D jmp:1058:0046 jmp:1058:0171
  1058:0386  mov ah, 0xf
  1058:0388  call far func_1E42_01BA              ; T:01BA slot 32
  1058:038D  cmp byte ptr [0x294b], 0             ; ds:294B
  1058:0392  je loc_1058_0397
  1058:0394  jmp loc_1058_0418
loc_1058_0397:    ; <- jcc:1058:0392
  1058:0397  mov ax, 0x2e
  1058:039A  mov cx, 0x2e
  1058:039D  mov bx, 0x5a
  1058:03A0  mov dx, 0xe
  1058:03A3  call far func_1E42_01B5              ; T:01B5 slot 31
  1058:03A8  mov ax, 0x112
  1058:03AB  mov cx, 0x112
  1058:03AE  mov bx, 0x5a
  1058:03B1  mov dx, 0xe
  1058:03B4  call far func_1E42_01B5              ; T:01B5 slot 31
  1058:03B9  mov ah, 8
  1058:03BB  call far func_1E42_01BA              ; T:01BA slot 32
  1058:03C0  mov ax, 0x2d
  1058:03C3  mov cx, 0x2d
  1058:03C6  mov bx, 0x5a
  1058:03C9  mov dx, 0xe
  1058:03CC  call far func_1E42_01B5              ; T:01B5 slot 31
  1058:03D1  mov ax, 0x113
  1058:03D4  mov cx, 0x113
  1058:03D7  mov bx, 0x5a
  1058:03DA  mov dx, 0xe
  1058:03DD  call far func_1E42_01B5              ; T:01B5 slot 31
  1058:03E2  mov ax, 0x113
  1058:03E5  mov cx, 0xe8
  1058:03E8  mov bx, 0xe
  1058:03EB  mov dx, 2
  1058:03EE  call far func_1E42_01B5              ; T:01B5 slot 31
  1058:03F3  mov ax, 0xe8
  1058:03F6  mov cx, 0x5a
  1058:03F9  mov bx, 2
  1058:03FC  mov dx, 2
  1058:03FF  call far func_1E42_01B5              ; T:01B5 slot 31
  1058:0404  mov ax, 0x2d
  1058:0407  mov cx, 0x59
  1058:040A  mov bx, 0xe
  1058:040D  mov dx, 2
  1058:0410  call far func_1E42_01B5              ; T:01B5 slot 31
  1058:0415  jmp loc_1058_0496

; ----- data 1058:0417 .. 1058:0417 (1 bytes) -----
;   1058:0417  90                                               .
loc_1058_0418:    ; <- jmp:1058:0394
  1058:0418  mov ax, 0x62
  1058:041B  mov cx, 0x62
  1058:041E  mov bx, 0x5a
  1058:0421  mov dx, 0x1e
  1058:0424  call far func_1E42_01B5              ; T:01B5 slot 31
  1058:0429  mov ax, 0xdd
  1058:042C  mov cx, 0xdd
  1058:042F  mov bx, 0x5a
  1058:0432  mov dx, 0x1e
  1058:0435  call far func_1E42_01B5              ; T:01B5 slot 31
  1058:043A  mov ah, 8
  1058:043C  call far func_1E42_01BA              ; T:01BA slot 32
  1058:0441  mov ax, 0x61
  1058:0444  mov cx, 0x61
  1058:0447  mov bx, 0x5a
  1058:044A  mov dx, 0x1e
  1058:044D  call far func_1E42_01B5              ; T:01B5 slot 31
  1058:0452  mov ax, 0xde
  1058:0455  mov cx, 0xde
  1058:0458  mov bx, 0x5a
  1058:045B  mov dx, 0x1e
  1058:045E  call far func_1E42_01B5              ; T:01B5 slot 31
  1058:0463  mov ax, 0xde
  1058:0466  mov cx, 0xd1
  1058:0469  mov bx, 0x1e
  1058:046C  mov dx, 0x11
  1058:046F  call far func_1E42_01B5              ; T:01B5 slot 31
  1058:0474  mov ax, 0xd1
  1058:0477  mov cx, 0x6e
  1058:047A  mov bx, 0x11
  1058:047D  mov dx, 0x11
  1058:0480  call far func_1E42_01B5              ; T:01B5 slot 31
  1058:0485  mov ax, 0x6e
  1058:0488  mov cx, 0x61
  1058:048B  mov bx, 0x11
  1058:048E  mov dx, 0x1e
  1058:0491  call far func_1E42_01B5              ; T:01B5 slot 31
loc_1058_0496:    ; <- jmp:1058:0415
  1058:0496  cmp byte ptr [0x2956], 0             ; ds:2956
  1058:049B  je loc_1058_04A5
  1058:049D  mov bp, 0x28c2
  1058:04A0  call far func_1E42_0174              ; T:0174 slot 18
loc_1058_04A5:    ; <- jcc:1058:049B
  1058:04A5  mov bx, 0x9900
  1058:04A8  mov bp, 0x288e
  1058:04AB  mov ax, word ptr [0x2948]            ; ds:2948
  1058:04AE  mov word ptr [0x2896], ax            ; ds:2896
  1058:04B1  call far func_1E42_012E              ; T:012E slot 4
  1058:04B6  mov ax, word ptr [0x2df0]            ; ds:2DF0
  1058:04B9  cmp ax, 0
  1058:04BC  jge loc_1058_04C0
  1058:04BE  neg ax
loc_1058_04C0:    ; <- jcc:1058:04BC
  1058:04C0  shr ax, 1
  1058:04C2  shr ax, 1
  1058:04C4  shr ax, 1
  1058:04C6  shr ax, 1
  1058:04C8  shr ax, 1
  1058:04CA  shr ax, 1
  1058:04CC  mov bx, 0x168
  1058:04CF  mul bx
  1058:04D1  mov al, ah
  1058:04D3  mov ah, dl
  1058:04D5  mov bl, 0x28
  1058:04D7  div bl
  1058:04D9  mov ch, al
  1058:04DB  mov al, ah
  1058:04DD  sub ah, ah
  1058:04DF  mov bh, byte ptr [0x2937]            ; ds:2937
  1058:04E3  mul bh
  1058:04E5  mov bx, 0x28
  1058:04E8  mov dx, 0
  1058:04EB  div bx
  1058:04ED  cmp word ptr [0x2df0], 0             ; ds:2DF0
  1058:04F2  jge loc_1058_04FC
  1058:04F4  mov ah, byte ptr [0x2937]            ; ds:2937
  1058:04F8  sub ah, al
  1058:04FA  xchg al, ah
loc_1058_04FC:    ; <- jcc:1058:04F2
  1058:04FC  add al, byte ptr [0x2939]            ; ds:2939
  1058:0500  sub ah, ah
  1058:0502  mov bx, ax
  1058:0504  cmp word ptr [0x2df0], 0             ; ds:2DF0
  1058:0509  jge loc_1058_050F
  1058:050B  neg ch
  1058:050D  dec ch
loc_1058_050F:    ; <- jcc:1058:0509
  1058:050F  mov al, ch
  1058:0511  cwde
  1058:0512  sub ax, 2
  1058:0515  mov word ptr [0x2c2c], ax            ; ds:2C2C
  1058:0518  mov dx, ax
  1058:051A  mov cl, 5
  1058:051C  mov di, 0
  1058:051F  mov si, di
  1058:0521  mov ch, 0
loc_1058_0523:    ; <- jcc:1058:0596 jmp:1058:05F4 jmp:1058:0650 jmp:1058:0694 jmp:1058:0706
  1058:0523  cmp dl, 9
  1058:0526  je loc_1058_053B
  1058:0528  jg loc_1058_053E
  1058:052A  cmp dl, 0xf7
  1058:052D  je loc_1058_0544
  1058:052F  jl loc_1058_0541
  1058:0531  cmp dl, 0
  1058:0534  je loc_1058_0544
  1058:0536  jg loc_1058_059B
  1058:0538  jmp loc_1058_0709
loc_1058_053B:    ; <- jcc:1058:0526
  1058:053B  jmp loc_1058_0653
loc_1058_053E:    ; <- jcc:1058:0528
  1058:053E  jmp loc_1058_05F7
loc_1058_0541:    ; <- jcc:1058:052F
  1058:0541  jmp loc_1058_0697
loc_1058_0544:    ; <- jcc:1058:052D jcc:1058:0534
  1058:0544  mov ax, word ptr [0x292f]            ; ds:292F
  1058:0547  mov word ptr [di + 0x2b12], ax
  1058:054B  mov ax, word ptr [0x2931]            ; ds:2931
  1058:054E  mov word ptr [di + 0x2b14], ax
  1058:0552  mov ax, word ptr [0x2933]            ; ds:2933
  1058:0555  mov word ptr [di + 0x2b16], ax
  1058:0559  mov ax, word ptr [0x2935]            ; ds:2935
  1058:055C  mov word ptr [di + 0x2b18], ax
  1058:0560  mov word ptr [di + 0x2b82], bx
  1058:0564  mov word ptr [di + 0x2b84], bx
  1058:0568  mov word ptr [di + 0x2b86], bx
  1058:056C  mov word ptr [di + 0x2b88], bx
  1058:0570  mov byte ptr [si + 0x2bf2], 1
  1058:0575  mov byte ptr [si + 0x2bf3], 1
  1058:057A  mov word ptr [si + 0x2c0e], di
  1058:057E  add di, 6
  1058:0581  mov word ptr [si + 0x2c0f], di
  1058:0585  add di, 2
  1058:0588  add si, 2
  1058:058B  sub bx, word ptr [0x2937]            ; ds:2937
  1058:058F  add ch, 2
  1058:0592  inc dl
  1058:0594  dec cl
  1058:0596  jne loc_1058_0523
  1058:0598  jmp loc_1058_0778
loc_1058_059B:    ; <- jcc:1058:0536
  1058:059B  mov ax, word ptr [0x292f]            ; ds:292F
  1058:059E  mov word ptr [di + 0x2b12], ax
  1058:05A2  mov word ptr [di + 0x2b14], ax
  1058:05A6  mov ax, word ptr [0x2935]            ; ds:2935
  1058:05A9  mov word ptr [di + 0x2b16], ax
  1058:05AD  mov word ptr [di + 0x2b18], ax
  1058:05B1  mov word ptr [di + 0x2b84], bx
  1058:05B5  mov word ptr [di + 0x2b86], bx
  1058:05B9  mov ax, bx
  1058:05BB  add ax, 5
  1058:05BE  mov word ptr [di + 0x2b82], ax
  1058:05C2  mov word ptr [di + 0x2b88], ax
  1058:05C6  mov byte ptr [si + 0x2bf2], 3
  1058:05CB  mov byte ptr [si + 0x2bf3], 0
  1058:05D0  add di, 2
  1058:05D3  mov word ptr [si + 0x2c0e], di
  1058:05D7  add di, 2
  1058:05DA  mov word ptr [si + 0x2c0f], di
  1058:05DE  add di, 4
  1058:05E1  add si, 2
  1058:05E4  sub bx, word ptr [0x2937]            ; ds:2937
  1058:05E8  add ch, 3
  1058:05EB  inc dl
  1058:05ED  dec cl
  1058:05EF  jne loc_1058_05F4
  1058:05F1  jmp loc_1058_0778
loc_1058_05F4:    ; <- jcc:1058:05EF
  1058:05F4  jmp loc_1058_0523
loc_1058_05F7:    ; <- jmp:1058:053E
  1058:05F7  mov ax, word ptr [0x292f]            ; ds:292F
  1058:05FA  mov word ptr [di + 0x2b12], ax
  1058:05FE  mov word ptr [di + 0x2b14], ax
  1058:0602  mov ax, word ptr [0x2935]            ; ds:2935
  1058:0605  mov word ptr [di + 0x2b16], ax
  1058:0609  mov word ptr [di + 0x2b18], ax
  1058:060D  mov word ptr [di + 0x2b84], bx
  1058:0611  mov word ptr [di + 0x2b86], bx
  1058:0615  mov ax, bx
  1058:0617  sub ax, 5
  1058:061A  mov word ptr [di + 0x2b82], ax
  1058:061E  mov word ptr [di + 0x2b88], ax
  1058:0622  mov byte ptr [si + 0x2bf2], 3
  1058:0627  mov byte ptr [si + 0x2bf3], 0
  1058:062C  add di, 2
  1058:062F  mov word ptr [si + 0x2c0e], di
  1058:0633  add di, 2
  1058:0636  mov word ptr [si + 0x2c0f], di
  1058:063A  add di, 4
  1058:063D  add si, 2
  1058:0640  sub bx, word ptr [0x2937]            ; ds:2937
  1058:0644  add ch, 3
  1058:0647  inc dl
  1058:0649  dec cl
  1058:064B  jne loc_1058_0650
  1058:064D  jmp loc_1058_0778
loc_1058_0650:    ; <- jcc:1058:064B
  1058:0650  jmp loc_1058_0523
loc_1058_0653:    ; <- jmp:1058:053B
  1058:0653  mov ax, word ptr [0x292f]            ; ds:292F
  1058:0656  mov word ptr [di + 0x2b12], ax
  1058:065A  mov ax, word ptr [0x2935]            ; ds:2935
  1058:065D  mov word ptr [di + 0x2b14], ax
  1058:0661  mov word ptr [di + 0x2b82], bx
  1058:0665  mov word ptr [di + 0x2b84], bx
  1058:0669  mov byte ptr [si + 0x2bf2], 1
  1058:066E  mov byte ptr [si + 0x2bf3], 0
  1058:0673  mov word ptr [si + 0x2c0e], di
  1058:0677  add di, 2
  1058:067A  mov word ptr [si + 0x2c0f], di
  1058:067E  add di, 2
  1058:0681  add si, 2
  1058:0684  sub bx, word ptr [0x2937]            ; ds:2937
  1058:0688  add ch, 1
  1058:068B  inc dl
  1058:068D  dec cl
  1058:068F  jne loc_1058_0694
  1058:0691  jmp loc_1058_0778
loc_1058_0694:    ; <- jcc:1058:068F
  1058:0694  jmp loc_1058_0523
loc_1058_0697:    ; <- jmp:1058:0541
  1058:0697  mov ax, word ptr [0x292f]            ; ds:292F
  1058:069A  mov word ptr [di + 0x2b12], ax
  1058:069E  mov word ptr [di + 0x2b14], ax
  1058:06A2  mov ax, word ptr [0x2931]            ; ds:2931
  1058:06A5  mov word ptr [di + 0x2b16], ax
  1058:06A9  mov ax, word ptr [0x2933]            ; ds:2933
  1058:06AC  mov word ptr [di + 0x2b18], ax
  1058:06B0  mov ax, word ptr [0x2935]            ; ds:2935
  1058:06B3  mov word ptr [di + 0x2b1a], ax
  1058:06B7  mov word ptr [di + 0x2b1c], ax
  1058:06BB  mov word ptr [di + 0x2b84], bx
  1058:06BF  mov word ptr [di + 0x2b86], bx
  1058:06C3  mov word ptr [di + 0x2b88], bx
  1058:06C7  mov word ptr [di + 0x2b8a], bx
  1058:06CB  mov ax, bx
  1058:06CD  add ax, 5
  1058:06D0  mov word ptr [di + 0x2b82], ax
  1058:06D4  mov word ptr [di + 0x2b8c], ax
  1058:06D8  mov byte ptr [si + 0x2bf2], 2
  1058:06DD  mov byte ptr [si + 0x2bf3], 2
  1058:06E2  add di, 2
  1058:06E5  mov word ptr [si + 0x2c0e], di
  1058:06E9  add di, 6
  1058:06EC  mov word ptr [si + 0x2c0f], di
  1058:06F0  add di, 4
  1058:06F3  add si, 2
  1058:06F6  sub bx, word ptr [0x2937]            ; ds:2937
  1058:06FA  add ch, 4
  1058:06FD  inc dl
  1058:06FF  dec cl
  1058:0701  jne loc_1058_0706
  1058:0703  jmp loc_1058_0778

; ----- data 1058:0705 .. 1058:0705 (1 bytes) -----
;   1058:0705  90                                               .
loc_1058_0706:    ; <- jcc:1058:0701
  1058:0706  jmp loc_1058_0523
loc_1058_0709:    ; <- jmp:1058:0538
  1058:0709  mov ax, word ptr [0x292f]            ; ds:292F
  1058:070C  mov word ptr [di + 0x2b12], ax
  1058:0710  mov word ptr [di + 0x2b14], ax
  1058:0714  mov ax, word ptr [0x2931]            ; ds:2931
  1058:0717  mov word ptr [di + 0x2b16], ax
  1058:071B  mov ax, word ptr [0x2933]            ; ds:2933
  1058:071E  mov word ptr [di + 0x2b18], ax
  1058:0722  mov ax, word ptr [0x2935]            ; ds:2935
  1058:0725  mov word ptr [di + 0x2b1a], ax
  1058:0729  mov word ptr [di + 0x2b1c], ax
  1058:072D  mov word ptr [di + 0x2b84], bx
  1058:0731  mov word ptr [di + 0x2b86], bx
  1058:0735  mov word ptr [di + 0x2b88], bx
  1058:0739  mov word ptr [di + 0x2b8a], bx
  1058:073D  mov ax, bx
  1058:073F  sub ax, 5
  1058:0742  mov word ptr [di + 0x2b82], ax
  1058:0746  mov word ptr [di + 0x2b8c], ax
  1058:074A  mov byte ptr [si + 0x2bf2], 2
  1058:074F  mov byte ptr [si + 0x2bf3], 2
  1058:0754  add di, 2
  1058:0757  mov word ptr [si + 0x2c0e], di
  1058:075B  add di, 6
  1058:075E  mov word ptr [si + 0x2c0f], di
  1058:0762  add di, 4
  1058:0765  add si, 2
  1058:0768  sub bx, word ptr [0x2937]            ; ds:2937
  1058:076C  add ch, 4
  1058:076F  inc dl
  1058:0771  dec cl
  1058:0773  je loc_1058_0778
  1058:0775  jmp loc_1058_0523
loc_1058_0778:    ; <- jcc:1058:0773 jmp:1058:0598 jmp:1058:05F1 jmp:1058:064D jmp:1058:0691
  1058:0778  mov byte ptr [0x2c2b], ch            ; ds:2C2B
  1058:077C  sub di, 2
  1058:077F  mov bx, word ptr [0x2df2]            ; ds:2DF2
  1058:0783  neg bx
  1058:0785  add bx, 0x4000
  1058:0789  call far func_104E_0082              ; -> 104E:0082
  1058:078E  mov bp, bx
  1058:0790  mov bx, word ptr [0x2df2]            ; ds:2DF2
  1058:0794  neg bx
  1058:0796  call far func_104E_0082              ; -> 104E:0082
loc_1058_079B:    ; <- jcc:1058:07F2
  1058:079B  mov ax, bp
  1058:079D  imul word ptr [di + 0x2b12]
  1058:07A1  shl ax, 1
  1058:07A3  rcl dx, 1
  1058:07A5  mov si, dx
  1058:07A7  mov ax, bp
  1058:07A9  imul word ptr [di + 0x2b82]
  1058:07AD  push bx
  1058:07AE  push cx
  1058:07AF  mov bx, ax
  1058:07B1  mov cx, dx
  1058:07B3  shl ax, 1
  1058:07B5  rcl dx, 1
  1058:07B7  add ax, bx
  1058:07B9  adc dx, cx
  1058:07BB  sar dx, 1
  1058:07BD  pop cx
  1058:07BE  pop bx
  1058:07BF  mov cx, dx
  1058:07C1  mov ax, bx
  1058:07C3  imul word ptr [di + 0x2b82]
  1058:07C7  shl ax, 1
  1058:07C9  rcl dx, 1
  1058:07CB  sub si, dx
  1058:07CD  mov ax, bx
  1058:07CF  imul word ptr [di + 0x2b12]
  1058:07D3  push bx
  1058:07D4  push cx
  1058:07D5  mov bx, ax
  1058:07D7  mov cx, dx
  1058:07D9  shl ax, 1
  1058:07DB  rcl dx, 1
  1058:07DD  add ax, bx
  1058:07DF  adc dx, cx
  1058:07E1  sar dx, 1
  1058:07E3  pop cx
  1058:07E4  pop bx
  1058:07E5  add cx, dx
  1058:07E7  mov word ptr [di + 0x2b12], si
  1058:07EB  mov word ptr [di + 0x2b82], cx
  1058:07EF  sub di, 2
  1058:07F2  jns loc_1058_079B
  1058:07F4  push word ptr [0x2293]               ; ds:2293
  1058:07F8  push word ptr [0x2295]               ; ds:2295
  1058:07FC  cmp byte ptr [0xe56e], 0             ; ds:E56E
  1058:0801  jne loc_1058_0806
  1058:0803  jmp loc_1058_09CA
loc_1058_0806:    ; <- jcc:1058:0801
  1058:0806  mov ah, byte ptr [0x2ca1]            ; ds:2CA1
  1058:080A  call far func_1E42_01BA              ; T:01BA slot 32
  1058:080F  mov ax, word ptr [0x2942]            ; ds:2942
  1058:0812  call far func_1E42_01A1              ; T:01A1 slot 27
  1058:0817  mov ax, word ptr [0x2944]            ; ds:2944
  1058:081A  mov word ptr [0x2293], ax            ; ds:2293
  1058:081D  mov ax, word ptr [0x2946]            ; ds:2946
  1058:0820  mov word ptr [0x2295], ax            ; ds:2295
  1058:0823  mov di, 0
  1058:0826  mov si, di
  1058:0828  mov byte ptr [0x2c2a], 0             ; ds:2C2A
loc_1058_082D:    ; <- jcc:1058:086D jcc:1058:0883
  1058:082D  mov ax, word ptr [di + 0x2b12]
  1058:0831  add ax, word ptr [0x293a]            ; ds:293A
  1058:0835  mov word ptr [0x2299], ax            ; ds:2299
  1058:0838  mov ax, word ptr [di + 0x2b82]
  1058:083C  add ax, word ptr [0x293c]            ; ds:293C
  1058:0840  mov word ptr [0x229d], ax            ; ds:229D
  1058:0843  mov ax, word ptr [di + 0x2b14]
  1058:0847  add ax, word ptr [0x293a]            ; ds:293A
  1058:084B  mov word ptr [0x229b], ax            ; ds:229B
  1058:084E  mov ax, word ptr [di + 0x2b84]
  1058:0852  add ax, word ptr [0x293c]            ; ds:293C
  1058:0856  mov word ptr [0x229f], ax            ; ds:229F
  1058:0859  push di
  1058:085A  push si
  1058:085B  call far func_0FB2_0320              ; -> 0FB2:0320
  1058:0860  pop si
  1058:0861  pop di
  1058:0862  add di, 2
  1058:0865  inc byte ptr [0x2c2a]                ; ds:2C2A
  1058:0869  dec byte ptr [si + 0x2bf2]
  1058:086D  jne loc_1058_082D
  1058:086F  add di, 2
  1058:0872  inc si
  1058:0873  cmp byte ptr [si + 0x2bf2], 0
  1058:0878  jne loc_1058_087B
  1058:087A  inc si
loc_1058_087B:    ; <- jcc:1058:0878
  1058:087B  mov bl, byte ptr [0x2c2b]            ; ds:2C2B
  1058:087F  cmp byte ptr [0x2c2a], bl            ; ds:2C2A
  1058:0883  jl loc_1058_082D
  1058:0885  add word ptr [0x2c2c], 0xb           ; ds:2C2C
  1058:088A  mov si, 0
  1058:088D  mov word ptr [0x2c2e], 5             ; ds:2C2E
  1058:0893  mov bp, 0x2878
  1058:0896  mov ax, word ptr [0x2df2]            ; ds:2DF2
  1058:0899  shr ah, 1
  1058:089B  shr ah, 1
  1058:089D  xchg al, ah
  1058:089F  sub ah, ah
  1058:08A1  mov di, ax
  1058:08A3  shl di, 1
  1058:08A5  mov ax, word ptr [di + 0x264c]
  1058:08A9  add ax, 2
  1058:08AC  mov word ptr [0x2c98], ax            ; ds:2C98
  1058:08AF  mov ax, word ptr [di + 0x26cc]
  1058:08B3  mov word ptr [0x2c9a], ax            ; ds:2C9A
  1058:08B6  mov ax, word ptr [di + 0x274c]
  1058:08BA  add ax, 2
  1058:08BD  mov word ptr [0x2c9c], ax            ; ds:2C9C
  1058:08C0  mov ax, word ptr [di + 0x27cc]
  1058:08C4  mov word ptr [0x2c9e], ax            ; ds:2C9E
  1058:08C7  mov ax, word ptr [0x2df2]            ; ds:2DF2
  1058:08CA  add ah, 0x80
  1058:08CD  shr ah, 1
  1058:08CF  shr ah, 1
  1058:08D1  xchg al, ah
  1058:08D3  sub ah, ah
  1058:08D5  mov di, ax
  1058:08D7  shl di, 1
  1058:08D9  mov ax, word ptr [di + 0x264c]
  1058:08DD  sub ax, 1
  1058:08E0  mov word ptr [0x2c90], ax            ; ds:2C90
  1058:08E3  mov ax, word ptr [di + 0x26cc]
  1058:08E7  mov word ptr [0x2c92], ax            ; ds:2C92
  1058:08EA  mov ax, word ptr [di + 0x274c]
  1058:08EE  sub ax, 1
  1058:08F1  mov word ptr [0x2c94], ax            ; ds:2C94
  1058:08F4  mov ax, word ptr [di + 0x27cc]
  1058:08F8  mov word ptr [0x2c96], ax            ; ds:2C96
loc_1058_08FB:    ; <- jmp:1058:09C7
  1058:08FB  mov di, word ptr [0x2c2c]            ; ds:2C2C
  1058:08FF  shl di, 1
  1058:0901  shl di, 1
  1058:0903  mov ax, word ptr [di + 0x2c30]
  1058:0907  mov word ptr [0x2c8c], ax            ; ds:2C8C
  1058:090A  mov ax, word ptr [di + 0x2c32]
  1058:090E  mov word ptr [0x2c8e], ax            ; ds:2C8E
  1058:0911  mov bx, di
  1058:0913  mov di, word ptr [si + 0x2c0e]
  1058:0917  and di, 0xff
  1058:091B  mov ax, word ptr [di + 0x2b12]
  1058:091F  cmp bx, 0x2c
  1058:0922  jge loc_1058_092B
  1058:0924  add ax, word ptr [0x2c94]            ; ds:2C94
  1058:0928  jmp loc_1058_092F

; ----- data 1058:092A .. 1058:092A (1 bytes) -----
;   1058:092A  90                                               .
loc_1058_092B:    ; <- jcc:1058:0922
  1058:092B  add ax, word ptr [0x2c90]            ; ds:2C90
loc_1058_092F:    ; <- jmp:1058:0928
  1058:092F  add ax, word ptr [0x2940]            ; ds:2940
  1058:0933  mov word ptr [0x2880], ax            ; ds:2880
  1058:0936  mov ax, word ptr [di + 0x2b82]
  1058:093A  cmp di, 0x2c
  1058:093D  jge loc_1058_0946
  1058:093F  add ax, word ptr [0x2c96]            ; ds:2C96
  1058:0943  jmp loc_1058_094A

; ----- data 1058:0945 .. 1058:0945 (1 bytes) -----
;   1058:0945  90                                               .
loc_1058_0946:    ; <- jcc:1058:093D
  1058:0946  add ax, word ptr [0x2c92]            ; ds:2C92
loc_1058_094A:    ; <- jmp:1058:0943
  1058:094A  add ax, word ptr [0x293e]            ; ds:293E
  1058:094E  mov word ptr [0x2882], ax            ; ds:2882
  1058:0951  mov bx, 0x2c8c
  1058:0954  push si
  1058:0955  call far func_1E42_0138              ; T:0138 slot 6
  1058:095A  pop si
  1058:095B  inc si
  1058:095C  mov di, word ptr [0x2c2c]            ; ds:2C2C
  1058:0960  shl di, 1
  1058:0962  shl di, 1
  1058:0964  mov ax, word ptr [di + 0x2c30]
  1058:0968  mov word ptr [0x2c8c], ax            ; ds:2C8C
  1058:096B  mov ax, word ptr [di + 0x2c32]
  1058:096F  mov word ptr [0x2c8e], ax            ; ds:2C8E
  1058:0972  mov bx, di
  1058:0974  mov di, word ptr [si + 0x2c0e]
  1058:0978  and di, 0xff
  1058:097C  mov ax, word ptr [di + 0x2b12]
  1058:0980  cmp bx, 0x2c
  1058:0983  jge loc_1058_098C
  1058:0985  add ax, word ptr [0x2c9c]            ; ds:2C9C
  1058:0989  jmp loc_1058_0990

; ----- data 1058:098B .. 1058:098B (1 bytes) -----
;   1058:098B  90                                               .
loc_1058_098C:    ; <- jcc:1058:0983
  1058:098C  add ax, word ptr [0x2c98]            ; ds:2C98
loc_1058_0990:    ; <- jmp:1058:0989
  1058:0990  add ax, word ptr [0x2940]            ; ds:2940
  1058:0994  mov word ptr [0x2880], ax            ; ds:2880
  1058:0997  mov ax, word ptr [di + 0x2b82]
  1058:099B  cmp di, 0x2c
  1058:099E  jge loc_1058_09A7
  1058:09A0  add ax, word ptr [0x2c9e]            ; ds:2C9E
  1058:09A4  jmp loc_1058_09AB

; ----- data 1058:09A6 .. 1058:09A6 (1 bytes) -----
;   1058:09A6  90                                               .
loc_1058_09A7:    ; <- jcc:1058:099E
  1058:09A7  add ax, word ptr [0x2c9a]            ; ds:2C9A
loc_1058_09AB:    ; <- jmp:1058:09A4
  1058:09AB  add ax, word ptr [0x293e]            ; ds:293E
  1058:09AF  mov word ptr [0x2882], ax            ; ds:2882
  1058:09B2  mov bx, 0x2c8c
  1058:09B5  push si
  1058:09B6  call far func_1E42_0138              ; T:0138 slot 6
  1058:09BB  pop si
  1058:09BC  inc si
  1058:09BD  inc word ptr [0x2c2c]                ; ds:2C2C
  1058:09C1  dec word ptr [0x2c2e]                ; ds:2C2E
  1058:09C5  je loc_1058_09CA
  1058:09C7  jmp loc_1058_08FB
loc_1058_09CA:    ; <- jcc:1058:09C5 jmp:1058:0803
  1058:09CA  pop word ptr [0x2295]                ; ds:2295
  1058:09CE  pop word ptr [0x2293]                ; ds:2293
  1058:09D2  call far func_1E42_0197              ; T:0197 slot 25
  1058:09D7  ret

; ===== func_1058_09D8  reg  callers: C=0 asm=0  seeds=call =====
func_1058_09D8:
  1058:09D8  mov ax, word ptr [0xe584]            ; ds:E584
  1058:09DB  mov word ptr [0x28a4], ax            ; ds:28A4
  1058:09DE  mov word ptr [0x28c2], ax            ; ds:28C2
  1058:09E1  mov word ptr [0x28e0], ax            ; ds:28E0
  1058:09E4  mov word ptr [0x28fe], ax            ; ds:28FE
  1058:09E7  cmp word ptr [0x43de], 0             ; ds:43DE
  1058:09EC  je loc_1058_0A0E
  1058:09EE  mov ax, 0xa
  1058:09F1  mov word ptr [0x2850], ax            ; ds:2850
  1058:09F4  mov word ptr [0x2866], ax            ; ds:2866
  1058:09F7  mov word ptr [0x2892], ax            ; ds:2892
  1058:09FA  mov byte ptr [0x28bd], al            ; ds:28BD
  1058:09FD  mov byte ptr [0x28db], al            ; ds:28DB
  1058:0A00  mov byte ptr [0x2ca0], al            ; ds:2CA0
  1058:0A03  mov ax, 0x2f
  1058:0A06  mov word ptr [0x287c], ax            ; ds:287C
  1058:0A09  mov byte ptr [0x2ca1], al            ; ds:2CA1
  1058:0A0C  jmp func_1058_0A2C
loc_1058_0A0E:    ; <- jcc:1058:09EC
  1058:0A0E  mov ax, 0xf
  1058:0A11  mov word ptr [0x2850], ax            ; ds:2850
  1058:0A14  mov word ptr [0x2866], ax            ; ds:2866
  1058:0A17  mov word ptr [0x2892], ax            ; ds:2892
  1058:0A1A  mov byte ptr [0x28bd], al            ; ds:28BD
  1058:0A1D  mov byte ptr [0x28db], al            ; ds:28DB
  1058:0A20  mov byte ptr [0x2ca0], al            ; ds:2CA0
  1058:0A23  mov ax, 7
  1058:0A26  mov word ptr [0x287c], ax            ; ds:287C
  1058:0A29  mov byte ptr [0x2ca1], al            ; ds:2CA1

; ===== func_1058_0A2C  reg  callers: C=0 asm=0  seeds=call =====
func_1058_0A2C:
  1058:0A2C  cmp byte ptr [0x294b], 1             ; ds:294B
  1058:0A31  je loc_1058_0A36
  1058:0A33  jmp loc_1058_0B4A
loc_1058_0A36:    ; <- jcc:1058:0A31
  1058:0A36  mov ax, 0x4e
  1058:0A39  mov word ptr [0x291d], ax            ; ds:291D
  1058:0A3C  mov al, 8
  1058:0A3E  mov byte ptr [0x291f], al            ; ds:291F
  1058:0A41  mov ax, 0xa
  1058:0A44  mov word ptr [0x2920], ax            ; ds:2920
  1058:0A47  mov al, 0
  1058:0A49  mov byte ptr [0x2922], al            ; ds:2922
  1058:0A4C  mov ax, 0x66
  1058:0A4F  mov word ptr [0x2923], ax            ; ds:2923
  1058:0A52  mov ax, 0xcc
  1058:0A55  mov word ptr [0x2925], ax            ; ds:2925
  1058:0A58  mov al, 0x88
  1058:0A5A  mov byte ptr [0x291c], al            ; ds:291C
  1058:0A5D  mov ax, 0x12
  1058:0A60  mov word ptr [0x2927], ax            ; ds:2927
  1058:0A63  mov ax, 0xaf
  1058:0A66  mov word ptr [0x2929], ax            ; ds:2929
  1058:0A69  mov ax, 4
  1058:0A6C  mov word ptr [0x292b], ax            ; ds:292B
  1058:0A6F  mov ax, 2
  1058:0A72  mov word ptr [0x292d], ax            ; ds:292D
  1058:0A75  mov ax, 0xffe9
  1058:0A78  mov word ptr [0x292f], ax            ; ds:292F
  1058:0A7B  mov ax, 0xfff8
  1058:0A7E  mov word ptr [0x2931], ax            ; ds:2931
  1058:0A81  mov ax, 9
  1058:0A84  mov word ptr [0x2933], ax            ; ds:2933
  1058:0A87  mov ax, 0x17
  1058:0A8A  mov word ptr [0x2935], ax            ; ds:2935
  1058:0A8D  mov ax, 0x1a
  1058:0A90  mov word ptr [0x2937], ax            ; ds:2937
  1058:0A93  mov al, 0x34
  1058:0A95  mov byte ptr [0x2939], al            ; ds:2939
  1058:0A98  mov ax, 0x1f
  1058:0A9B  mov word ptr [0x293a], ax            ; ds:293A
  1058:0A9E  mov ax, 0x20
  1058:0AA1  mov word ptr [0x293c], ax            ; ds:293C
  1058:0AA4  mov ax, 0x3c
  1058:0AA7  mov word ptr [0x293e], ax            ; ds:293E
  1058:0AAA  mov ax, 0x9f
  1058:0AAD  mov word ptr [0x2940], ax            ; ds:2940
  1058:0AB0  mov ax, 0x2380
  1058:0AB3  mov word ptr [0x2942], ax            ; ds:2942
  1058:0AB6  mov ax, 0x42
  1058:0AB9  mov word ptr [0x2944], ax            ; ds:2944
  1058:0ABC  mov ax, 0x3c
  1058:0ABF  mov word ptr [0x2946], ax            ; ds:2946
  1058:0AC2  mov ax, 0x6c
  1058:0AC5  mov word ptr [0x2948], ax            ; ds:2948
  1058:0AC8  mov ax, 0x22
  1058:0ACB  mov word ptr [0x285a], ax            ; ds:285A
  1058:0ACE  mov ax, 0x4a
  1058:0AD1  mov word ptr [0x285c], ax            ; ds:285C
  1058:0AD4  mov ax, 2
  1058:0AD7  mov word ptr [0x2858], ax            ; ds:2858
  1058:0ADA  mov word ptr [0x286e], ax            ; ds:286E
  1058:0ADD  mov word ptr [0x2884], ax            ; ds:2884
  1058:0AE0  mov word ptr [0x289a], ax            ; ds:289A
  1058:0AE3  mov ax, 0x14
  1058:0AE6  mov word ptr [0x286c], ax            ; ds:286C
  1058:0AE9  mov ax, 0x82
  1058:0AEC  mov word ptr [0x2874], ax            ; ds:2874
  1058:0AEF  mov ax, 0xbc
  1058:0AF2  mov word ptr [0x2876], ax            ; ds:2876
  1058:0AF5  mov ax, 0x36
  1058:0AF8  mov word ptr [0x28c4], ax            ; ds:28C4
  1058:0AFB  mov ax, 0x4c
  1058:0AFE  mov word ptr [0x28c6], ax            ; ds:28C6
  1058:0B01  mov ax, 0x99
  1058:0B04  mov word ptr [0x28ca], ax            ; ds:28CA
  1058:0B07  mov ax, 0x37
  1058:0B0A  mov word ptr [0x28cc], ax            ; ds:28CC
  1058:0B0D  mov ax, 0xd
  1058:0B10  mov word ptr [0x28ce], ax            ; ds:28CE
  1058:0B13  mov ax, 9
  1058:0B16  mov word ptr [0x28d0], ax            ; ds:28D0
  1058:0B19  mov ax, 0x82
  1058:0B1C  mov word ptr [0x28ac], ax            ; ds:28AC
  1058:0B1F  mov ax, 0x19
  1058:0B22  mov word ptr [0x28ae], ax            ; ds:28AE
  1058:0B25  mov ax, 0x3b
  1058:0B28  mov word ptr [0x28b0], ax            ; ds:28B0
  1058:0B2B  mov ax, 2
  1058:0B2E  mov word ptr [0x28b2], ax            ; ds:28B2
  1058:0B31  mov ax, 0x1c
  1058:0B34  mov word ptr [0x2886], ax            ; ds:2886
  1058:0B37  mov ax, 0x7e
  1058:0B3A  mov word ptr [0x288a], ax            ; ds:288A
  1058:0B3D  mov ax, 0xc3
  1058:0B40  mov word ptr [0x288c], ax            ; ds:288C
  1058:0B43  mov ax, 0x16
  1058:0B46  mov word ptr [0x2898], ax            ; ds:2898
  1058:0B49  ret
loc_1058_0B4A:    ; <- jmp:1058:0A33
  1058:0B4A  mov ax, 0x5a
  1058:0B4D  mov word ptr [0x291d], ax            ; ds:291D
  1058:0B50  mov al, 0x11
  1058:0B52  mov byte ptr [0x291f], al            ; ds:291F
  1058:0B55  mov ax, 0x14
  1058:0B58  mov word ptr [0x2920], ax            ; ds:2920
  1058:0B5B  mov al, 1
  1058:0B5D  mov byte ptr [0x2922], al            ; ds:2922
  1058:0B60  mov ax, 0x31
  1058:0B63  mov word ptr [0x2923], ax            ; ds:2923
  1058:0B66  mov ax, 0xff
  1058:0B69  mov word ptr [0x2925], ax            ; ds:2925
  1058:0B6C  mov al, 0x6d
  1058:0B6E  mov byte ptr [0x291c], al            ; ds:291C
  1058:0B71  mov ax, 0x2d
  1058:0B74  mov word ptr [0x2927], ax            ; ds:2927
  1058:0B77  mov ax, 0xf8
  1058:0B7A  mov word ptr [0x2929], ax            ; ds:2929
  1058:0B7D  mov ax, 0xa
  1058:0B80  mov word ptr [0x292b], ax            ; ds:292B
  1058:0B83  mov ax, 5
  1058:0B86  mov word ptr [0x292d], ax            ; ds:292D
  1058:0B89  mov ax, 0xffce
  1058:0B8C  mov word ptr [0x292f], ax            ; ds:292F
  1058:0B8F  mov ax, 0xfff4
  1058:0B92  mov word ptr [0x2931], ax            ; ds:2931
  1058:0B95  mov ax, 0xd
  1058:0B98  mov word ptr [0x2933], ax            ; ds:2933
  1058:0B9B  mov ax, 0x32
  1058:0B9E  mov word ptr [0x2935], ax            ; ds:2935
  1058:0BA1  mov ax, 0x34
  1058:0BA4  mov word ptr [0x2937], ax            ; ds:2937
  1058:0BA7  mov al, 0x68
  1058:0BA9  mov byte ptr [0x2939], al            ; ds:2939
  1058:0BAC  mov ax, 0x4f
  1058:0BAF  mov word ptr [0x293a], ax            ; ds:293A
  1058:0BB2  mov ax, 0x24
  1058:0BB5  mov word ptr [0x293c], ax            ; ds:293C
  1058:0BB8  mov ax, 0x34
  1058:0BBB  mov word ptr [0x293e], ax            ; ds:293E
  1058:0BBE  mov ax, 0x9f
  1058:0BC1  mov word ptr [0x2940], ax            ; ds:2940
  1058:0BC4  call far func_1E42_01AB              ; T:01AB slot 29
  1058:0BC9  mov word ptr [0x2942], ax            ; ds:2942
  1058:0BCC  mov ax, 0xa0
  1058:0BCF  mov word ptr [0x2944], ax            ; ds:2944
  1058:0BD2  mov ax, 0x44
  1058:0BD5  mov word ptr [0x2946], ax            ; ds:2946
  1058:0BD8  mov ax, 0x3c
  1058:0BDB  mov word ptr [0x2948], ax            ; ds:2948
  1058:0BDE  mov ax, 0x16
  1058:0BE1  mov word ptr [0x285a], ax            ; ds:285A
  1058:0BE4  mov ax, 0x52
  1058:0BE7  mov word ptr [0x285c], ax            ; ds:285C
  1058:0BEA  mov ax, 0
  1058:0BED  mov word ptr [0x2858], ax            ; ds:2858
  1058:0BF0  mov word ptr [0x286e], ax            ; ds:286E
  1058:0BF3  mov word ptr [0x2884], ax            ; ds:2884
  1058:0BF6  mov word ptr [0x289a], ax            ; ds:289A
  1058:0BF9  mov ax, 6
  1058:0BFC  mov word ptr [0x286c], ax            ; ds:286C
  1058:0BFF  mov ax, 0x5a
  1058:0C02  mov word ptr [0x2874], ax            ; ds:2874
  1058:0C05  mov ax, 0xe6
  1058:0C08  mov word ptr [0x2876], ax            ; ds:2876
  1058:0C0B  mov ax, 0x45
  1058:0C0E  mov word ptr [0x28c4], ax            ; ds:28C4
  1058:0C11  mov ax, 0x49
  1058:0C14  mov word ptr [0x28c6], ax            ; ds:28C6
  1058:0C17  mov ax, 0x93
  1058:0C1A  mov word ptr [0x28ca], ax            ; ds:28CA
  1058:0C1D  mov ax, 0x2c
  1058:0C20  mov word ptr [0x28cc], ax            ; ds:28CC
  1058:0C23  mov ax, 0x19
  1058:0C26  mov word ptr [0x28ce], ax            ; ds:28CE
  1058:0C29  mov ax, 0xf
  1058:0C2C  mov word ptr [0x28d0], ax            ; ds:28D0
  1058:0C2F  mov ax, 0x5a
  1058:0C32  mov word ptr [0x28ac], ax            ; ds:28AC
  1058:0C35  mov ax, 0xc
  1058:0C38  mov word ptr [0x28ae], ax            ; ds:28AE
  1058:0C3B  mov ax, 0x8d
  1058:0C3E  mov word ptr [0x28b0], ax            ; ds:28B0
  1058:0C41  mov ax, 3
  1058:0C44  mov word ptr [0x28b2], ax            ; ds:28B2
  1058:0C47  mov ax, 0x14
  1058:0C4A  mov word ptr [0x2886], ax            ; ds:2886
  1058:0C4D  mov ax, 0x4e
  1058:0C50  mov word ptr [0x288a], ax            ; ds:288A
  1058:0C53  mov ax, 0xf1
  1058:0C56  mov word ptr [0x288c], ax            ; ds:288C
  1058:0C59  mov ax, 0x10
  1058:0C5C  mov word ptr [0x2898], ax            ; ds:2898
  1058:0C5F  ret

; ----- data 1058:0C60 .. 1058:0C90 (49 bytes) -----
;   1058:0C60  BB 5C 29 8B D0 B1 0C D3 F8 D7 A2 57 29 8B C2 25  .\)........W)..%
;   1058:0C70  00 0F B1 08 D3 F8 D7 A2 58 29 8B C2 25 F0 00 B1  ........X)..%...
;   1058:0C80  04 D3 F8 D7 A2 59 29 8B C2 25 0F 00 D7 A2 5A 29  .....Y)..%....Z)
;   1058:0C90  C3                                               .

; ===== func_1058_0C91  jump/call stub  callers: C=1 asm=0  seeds=far =====
func_1058_0C91:
  1058:0C91  call func_1058_0CC1
  1058:0C94  sub si, si
  1058:0C96  call func_1058_0C9F
  1058:0C99  inc si
  1058:0C9A  inc si
  1058:0C9B  call func_1058_0C9F
  1058:0C9E  retf

; ===== func_1058_0C9F  reg(saves)  callers: C=0 asm=0  seeds=call =====
func_1058_0C9F:
  1058:0C9F  push ax
  1058:0CA0  mov ax, word ptr [si + 0x2cca]
  1058:0CA4  mov word ptr [si + 0x2cb2], ax
  1058:0CA8  mov word ptr [si + 0x2ca2], ax
  1058:0CAC  mov word ptr [si + 0x2caa], ax
  1058:0CB0  pop ax
  1058:0CB1  ret

; ===== func_1058_0CB2  jump/call stub  callers: C=1 asm=0  seeds=far =====
func_1058_0CB2:
  1058:0CB2  call func_1058_0CC1
  1058:0CB5  sub si, si
  1058:0CB7  call func_1058_0D09
  1058:0CBA  mov si, 1
  1058:0CBD  call func_1058_0D09
  1058:0CC0  retf

; ===== func_1058_0CC1  reg(saves)  callers: C=0 asm=0  seeds=call =====
func_1058_0CC1:
  1058:0CC1  push ax
  1058:0CC2  push bx
  1058:0CC3  push cx
  1058:0CC4  push dx
  1058:0CC5  push si
  1058:0CC6  push di
  1058:0CC7  push bp
  1058:0CC8  sub bp, bp
  1058:0CCA  sub cx, cx
  1058:0CCC  sub di, di
  1058:0CCE  mov dx, 0x201
  1058:0CD1  mov bx, 3
  1058:0CD4  cli
  1058:0CD5  out dx, al
  1058:0CD6  jmp loc_1058_0CD8
loc_1058_0CD8:    ; <- jmp:1058:0CD6
  1058:0CD8  jmp loc_1058_0CDB

; ----- data 1058:0CDA .. 1058:0CDA (1 bytes) -----
;   1058:0CDA  90                                               .
loc_1058_0CDB:    ; <- jcc:1058:0CEC jmp:1058:0CD8
  1058:0CDB  in al, dx
  1058:0CDC  and ax, bx
  1058:0CDE  mov si, ax
  1058:0CE0  and al, 1
  1058:0CE2  add bp, ax
  1058:0CE4  mov ax, si
  1058:0CE6  shr ax, 1
  1058:0CE8  add di, ax
  1058:0CEA  or si, si
  1058:0CEC  loopne loc_1058_0CDB
  1058:0CEE  je loc_1058_0CF8
  1058:0CF0  sub bp, bp
  1058:0CF2  not bp
  1058:0CF4  sub di, di
  1058:0CF6  not di
loc_1058_0CF8:    ; <- jcc:1058:0CEE
  1058:0CF8  sti
  1058:0CF9  mov word ptr [0x2cca], bp            ; ds:2CCA
  1058:0CFD  mov word ptr [0x2ccc], di            ; ds:2CCC
  1058:0D01  pop bp
  1058:0D02  pop di
  1058:0D03  pop si
  1058:0D04  pop dx
  1058:0D05  pop cx
  1058:0D06  pop bx
  1058:0D07  pop ax
  1058:0D08  ret

; ===== func_1058_0D09  reg(saves)  callers: C=0 asm=0  seeds=call =====
func_1058_0D09:
  1058:0D09  push ax
  1058:0D0A  push dx
  1058:0D0B  push ds
  1058:0D0C  shl si, 1
  1058:0D0E  mov ax, word ptr [si + 0x2cca]
  1058:0D12  mov dx, ax
  1058:0D14  sub ax, word ptr [si + 0x2cb2]
  1058:0D18  jne loc_1058_0D1F
  1058:0D1A  mov ah, 0x7f
  1058:0D1C  jmp loc_1058_0D44

; ----- data 1058:0D1E .. 1058:0D1E (1 bytes) -----
;   1058:0D1E  90                                               .
loc_1058_0D1F:    ; <- jcc:1058:0D18
  1058:0D1F  ja loc_1058_0D4E
  1058:0D21  cmp dx, word ptr [si + 0x2ca2]
  1058:0D25  ja loc_1058_0D36
  1058:0D27  mov word ptr [si + 0x2ca2], dx
  1058:0D2B  neg ax
  1058:0D2D  mov word ptr [si + 0x2cba], ax
  1058:0D31  sub ax, ax
  1058:0D33  jmp loc_1058_0D44

; ----- data 1058:0D35 .. 1058:0D35 (1 bytes) -----
;   1058:0D35  90                                               .
loc_1058_0D36:    ; <- jcc:1058:0D25
  1058:0D36  neg ax
  1058:0D38  mov dx, ax
  1058:0D3A  sub ax, ax
  1058:0D3C  div word ptr [si + 0x2cba]
  1058:0D40  not ax
  1058:0D42  shr ax, 1
loc_1058_0D44:    ; <- jmp:1058:0D1C jmp:1058:0D33
  1058:0D44  shr si, 1
  1058:0D46  mov byte ptr [si + 0x2cd2], ah
  1058:0D4A  pop ds
  1058:0D4B  pop dx
  1058:0D4C  pop ax
  1058:0D4D  ret
loc_1058_0D4E:    ; <- jcc:1058:0D1F
  1058:0D4E  cmp dx, word ptr [si + 0x2caa]
  1058:0D52  jb loc_1058_0D63
  1058:0D54  mov word ptr [si + 0x2caa], dx
  1058:0D58  mov word ptr [si + 0x2cc2], ax
  1058:0D5C  sub ax, ax
  1058:0D5E  not ax
  1058:0D60  jmp loc_1058_0D70

; ----- data 1058:0D62 .. 1058:0D62 (1 bytes) -----
;   1058:0D62  90                                               .
loc_1058_0D63:    ; <- jcc:1058:0D52
  1058:0D63  mov dx, ax
  1058:0D65  sub ax, ax
  1058:0D67  div word ptr [si + 0x2cc2]
  1058:0D6B  shr ax, 1
  1058:0D6D  add ah, 0x80
loc_1058_0D70:    ; <- jmp:1058:0D60
  1058:0D70  shr si, 1
  1058:0D72  mov byte ptr [si + 0x2cd2], ah
  1058:0D76  pop ds
  1058:0D77  pop dx
  1058:0D78  pop ax
  1058:0D79  ret

; ===== func_1058_0D7A  bp-frame  callers: C=1 asm=0  seeds=far =====
func_1058_0D7A:
  1058:0D7A  push bp
  1058:0D7B  mov bp, sp
  1058:0D7D  push es
  1058:0D7E  les di, ptr [bp + 6]
  1058:0D81  mov cx, 0x14
  1058:0D84  mov si, 0x2ca2
  1058:0D87  rep movsw word ptr es:[di], word ptr [si]
  1058:0D89  pop es
  1058:0D8A  pop bp
  1058:0D8B  retf

; ===== func_1058_0D8C  bp-frame  callers: C=1 asm=0  seeds=far =====
func_1058_0D8C:
  1058:0D8C  push bp
  1058:0D8D  mov bp, sp
  1058:0D8F  push es
  1058:0D90  push ds
  1058:0D91  push ds
  1058:0D92  pop es
  1058:0D93  lds si, ptr [bp + 6]
  1058:0D96  mov cx, 0x14
  1058:0D99  mov di, 0x2ca2
  1058:0D9C  rep movsw word ptr es:[di], word ptr [si]
  1058:0D9E  pop ds
  1058:0D9F  pop es
  1058:0DA0  pop bp
  1058:0DA1  retf
