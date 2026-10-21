; VGAME segment 11ED  lin 11ED0..120A7  size 471 (code runs past the next paragraph value; listed here)  dgroup=1E42  (vgame_asm.py; capstone recursive descent)
; entries: 5   far-call sites into this segment: 3   unresolved indirect jumps/calls: 1

; ----- data 11ED:0000 .. 11ED:0005 (6 bytes) -----
;   11ED:0000  5F 8B E5 5D CB C3                                _..]..

; ===== func_11ED_0006  reg(saves)  callers: C=0 asm=3  seeds=far =====
func_11ED_0006:
  11ED:0006  push es
  11ED:0007  push ds
  11ED:0008  pop es
  11ED:0009  cld
  11ED:000A  mov si, word ptr [0x4660]            ; ds:4660
  11ED:000E  add si, 0x43f8
  11ED:0012  shr di, 1
  11ED:0014  jne loc_11ED_0019
  11ED:0016  call func_11ED_0030
loc_11ED_0019:    ; <- jcc:11ED:0014
  11ED:0019  mov cx, 0x140
  11ED:001C  mov word ptr [0x968a], cx            ; ds:968A
  11ED:0020  mov di, 0x9546
  11ED:0023  call func_11ED_00AE
  11ED:0026  sub si, 0x43f8
  11ED:002A  mov word ptr [0x4660], si            ; ds:4660
  11ED:002E  pop es
  11ED:002F  retf

; ===== func_11ED_0030  reg  callers: C=0 asm=0  seeds=call =====
func_11ED_0030:
  11ED:0030  mov ax, 0x43f8
  11ED:0033  add ax, 0x200
  11ED:0036  mov word ptr [0x9686], ax            ; ds:9686
  11ED:0039  mov ax, 0x989b
  11ED:003C  mov word ptr [0x9688], ax            ; ds:9688
  11ED:003F  mov byte ptr [0x968c], 0             ; ds:968C
  11ED:0044  mov byte ptr [0x968d], 0             ; ds:968D
  11ED:0049  cmp si, word ptr [0x9686]            ; ds:9686
  11ED:004D  jb loc_11ED_005D
  11ED:004F  push bx
  11ED:0050  push cx
  11ED:0051  push dx
  11ED:0052  call far func_11B8_0153              ; -> 11B8:0153
  11ED:0057  pop dx
  11ED:0058  pop cx
  11ED:0059  pop bx
  11ED:005A  mov si, 0x43f8
loc_11ED_005D:    ; <- jcc:11ED:004D
  11ED:005D  lodsw ax, word ptr [si]
  11ED:005E  mov word ptr [0x9694], ax            ; ds:9694
  11ED:0061  mov byte ptr [0x9696], 8             ; ds:9696
  11ED:0066  mov byte ptr [0x9697], 1             ; ds:9697
  11ED:006B  or al, al
  11ED:006D  jns loc_11ED_0075
  11ED:006F  dec byte ptr [0x9697]                ; ds:9697
  11ED:0073  neg al
loc_11ED_0075:    ; <- jcc:11ED:006D
  11ED:0075  mov byte ptr [0x968f], al            ; ds:968F

; ===== func_11ED_0078  reg  callers: C=0 asm=0  seeds=call =====
func_11ED_0078:
  11ED:0078  mov byte ptr [0x968e], 9             ; ds:968E
  11ED:007D  mov word ptr [0x9690], 0x1ff         ; ds:9690
  11ED:0083  mov dx, 0x100
  11ED:0086  mov word ptr [0x9692], dx            ; ds:9692
  11ED:008A  mov ax, 0xffff
  11ED:008D  xor bx, bx
  11ED:008F  mov cx, 0x800
loc_11ED_0092:    ; <- jcc:11ED:0099
  11ED:0092  mov word ptr [bx - 0x394c], ax
  11ED:0096  add bx, 3
  11ED:0099  loop loc_11ED_0092
  11ED:009B  mov al, 0
  11ED:009D  xor bx, bx
  11ED:009F  mov cx, 0x100
loc_11ED_00A2:    ; <- jcc:11ED:00AB
  11ED:00A2  mov byte ptr [bx - 0x394a], al
  11ED:00A6  inc al
  11ED:00A8  add bx, 3
  11ED:00AB  loop loc_11ED_00A2
  11ED:00AD  ret

; ===== func_11ED_00AE  reg  callers: C=0 asm=0  seeds=call =====
func_11ED_00AE:
  11ED:00AE  cmp byte ptr [0x9697], 0             ; ds:9697
  11ED:00B3  je loc_11ED_00B9
  11ED:00B5  shr word ptr [0x968a], 1             ; ds:968A
loc_11ED_00B9:    ; <- jcc:11ED:00B3
  11ED:00B9  mov ax, word ptr [0x9688]            ; ds:9688
  11ED:00BC  mov word ptr [0x9688], sp            ; ds:9688
  11ED:00C0  mov sp, ax
  11ED:00C2  mov dx, word ptr [0x9692]            ; ds:9692
loc_11ED_00C6:    ; <- jcc:11ED:010D jcc:11ED:0117
  11ED:00C6  cmp byte ptr [0x968c], 0             ; ds:968C
  11ED:00CB  jne loc_11ED_00EE
  11ED:00CD  call func_11ED_0127
  11ED:00D0  cmp al, 0x90
  11ED:00D2  je loc_11ED_00DA
  11ED:00D4  mov byte ptr [0x968d], al            ; ds:968D
  11ED:00D7  jmp loc_11ED_00F5

; ----- data 11ED:00D9 .. 11ED:00D9 (1 bytes) -----
;   11ED:00D9  90                                               .
loc_11ED_00DA:    ; <- jcc:11ED:00D2
  11ED:00DA  call func_11ED_0127
  11ED:00DD  or al, al
  11ED:00DF  jne loc_11ED_00E9
  11ED:00E1  mov al, 0x90
  11ED:00E3  mov byte ptr [0x968d], al            ; ds:968D
  11ED:00E6  jmp loc_11ED_00F5

; ----- data 11ED:00E8 .. 11ED:00E8 (1 bytes) -----
;   11ED:00E8  90                                               .
loc_11ED_00E9:    ; <- jcc:11ED:00DF
  11ED:00E9  dec al
  11ED:00EB  mov byte ptr [0x968c], al            ; ds:968C
loc_11ED_00EE:    ; <- jcc:11ED:00CB
  11ED:00EE  mov al, byte ptr [0x968d]            ; ds:968D
  11ED:00F1  dec byte ptr [0x968c]                ; ds:968C
loc_11ED_00F5:    ; <- jmp:11ED:00D7 jmp:11ED:00E6
  11ED:00F5  cmp byte ptr [0x9697], 0             ; ds:9697
  11ED:00FA  je loc_11ED_0112
  11ED:00FC  mov ah, al
  11ED:00FE  and al, 0xf
  11ED:0100  shr ah, 1
  11ED:0102  shr ah, 1
  11ED:0104  shr ah, 1
  11ED:0106  shr ah, 1
  11ED:0108  stosw word ptr es:[di], ax
  11ED:0109  dec word ptr [0x968a]                ; ds:968A
  11ED:010D  jne loc_11ED_00C6
  11ED:010F  jmp loc_11ED_0119

; ----- data 11ED:0111 .. 11ED:0111 (1 bytes) -----
;   11ED:0111  90                                               .
loc_11ED_0112:    ; <- jcc:11ED:00FA
  11ED:0112  stosb byte ptr es:[di], al
  11ED:0113  dec word ptr [0x968a]                ; ds:968A
  11ED:0117  jne loc_11ED_00C6
loc_11ED_0119:    ; <- jmp:11ED:010F
  11ED:0119  mov word ptr [0x9692], dx            ; ds:9692
  11ED:011D  mov ax, word ptr [0x9688]            ; ds:9688
  11ED:0120  mov word ptr [0x9688], sp            ; ds:9688
  11ED:0124  mov sp, ax
  11ED:0126  ret

; ===== func_11ED_0127  reg  callers: C=0 asm=0  seeds=call =====
func_11ED_0127:
  11ED:0127  pop bp
  11ED:0128  cmp sp, 0x989b
  11ED:012C  je loc_11ED_0131
loc_11ED_012E:    ; <- jmp:11ED:01D4
  11ED:012E  pop ax
  11ED:012F  jmp bp
loc_11ED_0131:    ; <- jcc:11ED:012C
  11ED:0131  mov bx, word ptr [0x9694]            ; ds:9694
  11ED:0135  mov cl, 0x10
  11ED:0137  mov ch, byte ptr [0x9696]            ; ds:9696
  11ED:013B  sub cl, ch
  11ED:013D  shr bx, cl
  11ED:013F  mov cl, ch
loc_11ED_0141:    ; <- jmp:11ED:0166
  11ED:0141  cmp cl, byte ptr [0x968e]            ; ds:968E
  11ED:0145  jge loc_11ED_0168
  11ED:0147  cmp si, word ptr [0x9686]            ; ds:9686
  11ED:014B  jb loc_11ED_015B
  11ED:014D  push bx
  11ED:014E  push cx
  11ED:014F  push dx
  11ED:0150  call far func_11B8_0153              ; -> 11B8:0153
  11ED:0155  pop dx
  11ED:0156  pop cx
  11ED:0157  pop bx
  11ED:0158  mov si, 0x43f8
loc_11ED_015B:    ; <- jcc:11ED:014B
  11ED:015B  lodsw ax, word ptr [si]
  11ED:015C  mov word ptr [0x9694], ax            ; ds:9694
  11ED:015F  shl ax, cl
  11ED:0161  or bx, ax
  11ED:0163  add cl, 0x10
  11ED:0166  jmp loc_11ED_0141
loc_11ED_0168:    ; <- jcc:11ED:0145
  11ED:0168  sub cl, byte ptr [0x968e]            ; ds:968E
  11ED:016C  mov byte ptr [0x9696], cl            ; ds:9696
  11ED:0170  mov ax, bx
  11ED:0172  and ax, word ptr [0x9690]            ; ds:9690
  11ED:0176  mov cx, ax
  11ED:0178  cmp ax, dx
  11ED:017A  jl loc_11ED_0186
  11ED:017C  mov cx, dx
  11ED:017E  mov ax, word ptr [0x9698]            ; ds:9698
  11ED:0181  mov bl, byte ptr [0x969a]            ; ds:969A
  11ED:0185  push bx
loc_11ED_0186:    ; <- jcc:11ED:017A jmp:11ED:0199
  11ED:0186  mov bx, ax
  11ED:0188  add bx, ax
  11ED:018A  add bx, ax
  11ED:018C  mov ax, word ptr [bx - 0x394c]
  11ED:0190  inc ax
  11ED:0191  je loc_11ED_019B
  11ED:0193  dec ax
  11ED:0194  mov bl, byte ptr [bx - 0x394a]
  11ED:0198  push bx
  11ED:0199  jmp loc_11ED_0186
loc_11ED_019B:    ; <- jcc:11ED:0191
  11ED:019B  mov al, byte ptr [bx - 0x394a]
  11ED:019F  mov byte ptr [0x969a], al            ; ds:969A
  11ED:01A2  push ax
  11ED:01A3  mov bx, dx
  11ED:01A5  add bx, dx
  11ED:01A7  add bx, dx
  11ED:01A9  mov byte ptr [bx - 0x394a], al
  11ED:01AD  mov ax, word ptr [0x9698]            ; ds:9698
  11ED:01B0  mov word ptr [bx - 0x394c], ax
  11ED:01B4  inc dx
  11ED:01B5  cmp dx, word ptr [0x9690]            ; ds:9690
  11ED:01B9  jle loc_11ED_01C4
  11ED:01BB  inc byte ptr [0x968e]                ; ds:968E
  11ED:01BF  stc
  11ED:01C0  rcl word ptr [0x9690]                ; ds:9690
loc_11ED_01C4:    ; <- jcc:11ED:01B9
  11ED:01C4  mov al, byte ptr [0x968e]            ; ds:968E
  11ED:01C7  cmp al, byte ptr [0x968f]            ; ds:968F
  11ED:01CB  jle loc_11ED_01D0
  11ED:01CD  call func_11ED_0078
loc_11ED_01D0:    ; <- jcc:11ED:01CB
  11ED:01D0  mov word ptr [0x9698], cx            ; ds:9698
  11ED:01D4  jmp loc_11ED_012E

; unresolved indirect transfers:
;   11ED:012F  jmp bp
