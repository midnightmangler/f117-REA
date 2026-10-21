; VGAME segment 14C2  lin 14C20..14D00  size 224  dgroup=1E42  (vgame_asm.py; capstone recursive descent)
; entries: 2   far-call sites into this segment: 8   unresolved indirect jumps/calls: 0

; ===== func_14C2_0000  bp-frame  callers: C=2 asm=5  seeds=far =====
func_14C2_0000:
  14C2:0000  push bp
  14C2:0001  mov bp, sp
  14C2:0003  push si
  14C2:0004  push di
  14C2:0005  push ds
  14C2:0006  mov bx, word ptr [bp + 6]
  14C2:0009  mov cx, word ptr [bp + 8]
  14C2:000C  lds si, ptr [bp + 0xa]
  14C2:000F  xor ax, ax
  14C2:0011  mov es, ax
  14C2:0013  test byte ptr es:[0x489], 2
  14C2:0019  jne loc_14C2_005F
loc_14C2_001B:    ; <- jcc:14C2:002C
  14C2:001B  mov dx, 0x3da
loc_14C2_001E:    ; <- jcc:14C2:0021
  14C2:001E  in al, dx
  14C2:001F  test al, 8
  14C2:0021  je loc_14C2_001E
  14C2:0023  mov bp, 0
  14C2:0026  jmp loc_14C2_0035

; ----- data 14C2:0028 .. 14C2:0028 (1 bytes) -----
;   14C2:0028  90                                               .
loc_14C2_0029:    ; <- jcc:14C2:004C
  14C2:0029  inc bp
  14C2:002A  js loc_14C2_0035
  14C2:002C  je loc_14C2_001B
  14C2:002E  mov dl, 0xda
  14C2:0030  in al, dx
  14C2:0031  test al, 8
  14C2:0033  je loc_14C2_0053
loc_14C2_0035:    ; <- jcc:14C2:002A jmp:14C2:0026 jmp:14C2:005D
  14C2:0035  cli
  14C2:0036  mov dl, 0xc8
  14C2:0038  mov al, bl
  14C2:003A  inc bx
  14C2:003B  out dx, al
  14C2:003C  jmp loc_14C2_003E
loc_14C2_003E:    ; <- jmp:14C2:003C
  14C2:003E  jmp loc_14C2_0040
loc_14C2_0040:    ; <- jmp:14C2:003E
  14C2:0040  inc dx
  14C2:0041  lodsb al, byte ptr [si]
  14C2:0042  out dx, al
  14C2:0043  jmp loc_14C2_0045
loc_14C2_0045:    ; <- jmp:14C2:0043
  14C2:0045  lodsb al, byte ptr [si]
  14C2:0046  out dx, al
  14C2:0047  jmp loc_14C2_0049
loc_14C2_0049:    ; <- jmp:14C2:0047
  14C2:0049  lodsb al, byte ptr [si]
  14C2:004A  out dx, al
  14C2:004B  sti
  14C2:004C  loop loc_14C2_0029
  14C2:004E  pop ds
  14C2:004F  pop di
  14C2:0050  pop si
  14C2:0051  pop bp
  14C2:0052  retf
loc_14C2_0053:    ; <- jcc:14C2:0033
  14C2:0053  mov ax, bp
  14C2:0055  mov ah, 0xd
  14C2:0057  mul ah
  14C2:0059  neg ax
  14C2:005B  mov bp, ax
  14C2:005D  jmp loc_14C2_0035
loc_14C2_005F:    ; <- jcc:14C2:0019 jcc:14C2:00B0
  14C2:005F  mov dx, 0x4ccd
  14C2:0062  lodsb al, byte ptr [si]
  14C2:0063  xor ah, ah
  14C2:0065  mul dx
  14C2:0067  mov di, ax
  14C2:0069  mov bp, dx
  14C2:006B  mov dx, 0x970a
  14C2:006E  lodsb al, byte ptr [si]
  14C2:006F  xor ah, ah
  14C2:0071  mul dx
  14C2:0073  add di, ax
  14C2:0075  adc bp, dx
  14C2:0077  mov dx, 0x1c29
  14C2:007A  lodsb al, byte ptr [si]
  14C2:007B  xor ah, ah
  14C2:007D  mul dx
  14C2:007F  add ax, di
  14C2:0081  adc dx, bp
  14C2:0083  shl ax, 1
  14C2:0085  adc dx, 0
  14C2:0088  mov bh, dl
  14C2:008A  jmp loc_14C2_0092

; ----- data 14C2:008C .. 14C2:008C (1 bytes) -----
;   14C2:008C  90                                               .
loc_14C2_008D:    ; <- jcc:14C2:0090 jcc:14C2:0098
  14C2:008D  in al, dx
  14C2:008E  test al, 8
  14C2:0090  je loc_14C2_008D
loc_14C2_0092:    ; <- jmp:14C2:008A
  14C2:0092  mov dx, 0x3da
  14C2:0095  in al, dx
  14C2:0096  test al, 1
  14C2:0098  je loc_14C2_008D
  14C2:009A  cli
  14C2:009B  mov dl, 0xc8
  14C2:009D  mov al, bl
  14C2:009F  inc bx
  14C2:00A0  out dx, al
  14C2:00A1  jmp loc_14C2_00A3
loc_14C2_00A3:    ; <- jmp:14C2:00A1
  14C2:00A3  jmp loc_14C2_00A5
loc_14C2_00A5:    ; <- jmp:14C2:00A3
  14C2:00A5  inc dx
  14C2:00A6  mov al, bh
  14C2:00A8  out dx, al
  14C2:00A9  jmp loc_14C2_00AB
loc_14C2_00AB:    ; <- jmp:14C2:00A9
  14C2:00AB  out dx, al
  14C2:00AC  jmp loc_14C2_00AE
loc_14C2_00AE:    ; <- jmp:14C2:00AC
  14C2:00AE  out dx, al
  14C2:00AF  sti
  14C2:00B0  loop loc_14C2_005F
  14C2:00B2  pop ds
  14C2:00B3  pop di
  14C2:00B4  pop si
  14C2:00B5  pop bp
  14C2:00B6  retf

; ===== func_14C2_00B7  bp-frame  callers: C=0 asm=1  seeds=far =====
func_14C2_00B7:
  14C2:00B7  push bp
  14C2:00B8  mov bp, sp
  14C2:00BA  push di
  14C2:00BB  cli
  14C2:00BC  mov dx, 0x3da
loc_14C2_00BF:    ; <- jcc:14C2:00C2
  14C2:00BF  in al, dx
  14C2:00C0  test al, 8
  14C2:00C2  je loc_14C2_00BF
  14C2:00C4  les di, ptr [bp + 6]
  14C2:00C7  mov cx, 0x300
  14C2:00CA  mov dl, 0xc7
  14C2:00CC  mov al, 0
  14C2:00CE  out dx, al
  14C2:00CF  jmp loc_14C2_00D1
loc_14C2_00D1:    ; <- jmp:14C2:00CF
  14C2:00D1  mov dl, 0xc9
loc_14C2_00D3:    ; <- jcc:14C2:00D5
  14C2:00D3  in al, dx
  14C2:00D4  stosb byte ptr es:[di], al
  14C2:00D5  loop loc_14C2_00D3
  14C2:00D7  sti
  14C2:00D8  pop di
  14C2:00D9  pop bp
  14C2:00DA  retf

; ----- data 14C2:00DB .. 14C2:00DF (5 bytes) -----
;   14C2:00DB  00 00 00 00 00                                   .....
