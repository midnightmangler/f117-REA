; VGAME segment 104E  lin 104E0..10589  size 169 (code runs past the next paragraph value; listed here)  dgroup=1E42  (vgame_asm.py; capstone recursive descent)
; entries: 8   far-call sites into this segment: 112   unresolved indirect jumps/calls: 0

; ===== func_104E_0000  reg  callers: C=60 asm=27  seeds=far =====
func_104E_0000:
  104E:0000  mov bx, sp
  104E:0002  mov ax, word ptr ss:[bx + 4]
  104E:0006  imul word ptr ss:[bx + 6]
  104E:000A  shl ax, 1
  104E:000C  rcl dx, 1
  104E:000E  shl ax, 1
  104E:0010  adc dx, 0
  104E:0013  mov ax, dx
  104E:0015  retf

; ===== func_104E_0016  reg  callers: C=0 asm=0  seeds=seed =====
func_104E_0016:
  104E:0016  mov bx, sp
  104E:0018  mov ax, word ptr ss:[bx + 4]
  104E:001C  imul word ptr ss:[bx + 6]
  104E:0020  shl ax, 1
  104E:0022  rcl dx, 1
  104E:0024  retf

; ===== func_104E_0025  reg  callers: C=0 asm=0  seeds=seed =====
func_104E_0025:
  104E:0025  mov bx, sp
  104E:0027  mov ax, word ptr ss:[bx + 4]
  104E:002B  cdq
  104E:002C  mov dl, ah
  104E:002E  mov ah, al
  104E:0030  sub al, al
  104E:0032  mov bx, word ptr ss:[bx + 6]
  104E:0036  or bx, bx
  104E:0038  jle loc_104E_004D
  104E:003A  mov cx, dx
  104E:003C  or cx, cx
  104E:003E  jns loc_104E_0042
  104E:0040  neg cx
loc_104E_0042:    ; <- jcc:104E:003E
  104E:0042  shr bx, 1
  104E:0044  cmp cx, bx
  104E:0046  jae loc_104E_004D
  104E:0048  rcl bx, 1
  104E:004A  idiv bx
  104E:004C  retf
loc_104E_004D:    ; <- jcc:104E:0038 jcc:104E:0046
  104E:004D  mov ax, 0x7fff
  104E:0050  or dx, dx
  104E:0052  jns loc_104E_0056
  104E:0054  neg ax
loc_104E_0056:    ; <- jcc:104E:0052
  104E:0056  retf

; ===== func_104E_0057  reg  callers: C=0 asm=0  seeds=seed =====
func_104E_0057:
  104E:0057  mov bx, sp
  104E:0059  mov ax, word ptr ss:[bx + 4]
  104E:005D  imul word ptr ss:[bx + 6]
  104E:0061  idiv word ptr ss:[bx + 8]
  104E:0065  retf

; ===== func_104E_0066  reg  callers: C=11 asm=0  seeds=far =====
func_104E_0066:
  104E:0066  mov bx, sp
  104E:0068  mov bx, word ptr ss:[bx + 4]
  104E:006C  add bx, 0x4000
  104E:0070  call func_104E_008A
  104E:0073  mov ax, bx
  104E:0075  retf

; ===== func_104E_0076  reg  callers: C=12 asm=0  seeds=far =====
func_104E_0076:
  104E:0076  mov bx, sp
  104E:0078  mov bx, word ptr ss:[bx + 4]
  104E:007C  call func_104E_008A
  104E:007F  mov ax, bx
  104E:0081  retf

; ===== func_104E_0082  jump/call stub  callers: C=0 asm=2  seeds=far =====
func_104E_0082:
  104E:0082  call func_104E_008A
  104E:0085  retf

; ----- data 104E:0086 .. 104E:0089 (4 bytes) -----
;   104E:0086  81 C3 00 40                                      ...@

; ===== func_104E_008A  reg  callers: C=0 asm=0  seeds=call =====
func_104E_008A:
  104E:008A  mov dl, bl
  104E:008C  sub dh, dh
  104E:008E  mov bl, bh
  104E:0090  mov bh, dh
  104E:0092  shl bx, 1
  104E:0094  mov ax, word ptr [bx + 0x2086]
  104E:0098  mov bx, word ptr [bx + 0x2084]
  104E:009C  sub ax, bx
  104E:009E  imul dx
  104E:00A0  mov dh, dl
  104E:00A2  mov dl, ah
  104E:00A4  shl al, 1
  104E:00A6  adc bx, dx
  104E:00A8  ret
