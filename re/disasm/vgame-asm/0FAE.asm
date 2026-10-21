; VGAME segment 0FAE  lin 0FAE0..0FB20  size 64  dgroup=1E42  (vgame_asm.py; capstone recursive descent)
; entries: 1   far-call sites into this segment: 3   unresolved indirect jumps/calls: 0

; ----- data 0FAE:0000 .. 0FAE:0001 (2 bytes) -----
;   0FAE:0000  C3 00                                            ..

; ===== func_0FAE_0002  bp-frame  callers: C=3 asm=0  seeds=far =====
func_0FAE_0002:
  0FAE:0002  push bp
  0FAE:0003  mov bp, sp
  0FAE:0005  push di
  0FAE:0006  push si
  0FAE:0007  mov dx, word ptr [bp + 6]
  0FAE:000A  mov es, dx
  0FAE:000C  mov bx, 0x11a
  0FAE:000F  mov di, 0x1c
  0FAE:0012  mov ax, word ptr es:[di]
  0FAE:0015  mov dl, 5
  0FAE:0017  mul dl
  0FAE:0019  add bx, ax
  0FAE:001B  mov di, 0x22
  0FAE:001E  mov cx, word ptr es:[di]
  0FAE:0021  mov si, 0x24
  0FAE:0024  mov di, 0x18
  0FAE:0027  mov di, word ptr es:[di]
loc_0FAE_002A:    ; <- jcc:0FAE:0039
  0FAE:002A  mov ax, word ptr es:[si]
  0FAE:002D  mov word ptr [bx + 1], ax
  0FAE:0030  mov word ptr [bx + 3], di
  0FAE:0033  add si, 2
  0FAE:0036  add bx, 5
  0FAE:0039  loop loc_0FAE_002A
  0FAE:003B  pop si
  0FAE:003C  pop di
  0FAE:003D  pop bp
  0FAE:003E  retf

; ----- data 0FAE:003F .. 0FAE:003F (1 bytes) -----
;   0FAE:003F  00                                               .
