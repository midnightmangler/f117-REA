; VGAME segment 1039  lin 10390..104E0  size 336  dgroup=1E42  (vgame_asm.py; capstone recursive descent)
; entries: 7   far-call sites into this segment: 11   unresolved indirect jumps/calls: 0

; ===== func_1039_0000  reg  callers: C=2 asm=0  seeds=far =====
func_1039_0000:
  1039:0000  mov ax, ds
  1039:0002  mov es, ax
  1039:0004  push si
  1039:0005  push di
  1039:0006  cmp byte ptr [0xd47], 2              ; ds:0D47
  1039:000B  je loc_1039_004F
  1039:000D  mov cx, 0x30
  1039:0010  mov si, 0x1f4a
  1039:0013  mov di, 0x179a
  1039:0016  rep movsb byte ptr es:[di], byte ptr [si]
  1039:0018  mov cx, 0x30
  1039:001B  mov si, 0x1fda
  1039:001E  mov di, 0x182a
  1039:0021  rep movsb byte ptr es:[di], byte ptr [si]
  1039:0023  mov cx, 0x30
  1039:0026  mov si, 0x1f7a
  1039:0029  mov di, 0x1a9a
  1039:002C  rep movsb byte ptr es:[di], byte ptr [si]
  1039:002E  mov cx, 0x30
  1039:0031  mov si, 0x200a
  1039:0034  mov di, 0x1b2a
  1039:0037  rep movsb byte ptr es:[di], byte ptr [si]
  1039:0039  mov cx, 0x30
  1039:003C  mov si, 0x1faa
  1039:003F  mov di, 0x1d9a
  1039:0042  rep movsb byte ptr es:[di], byte ptr [si]
  1039:0044  mov cx, 0x30
  1039:0047  mov si, 0x203a
  1039:004A  mov di, 0x1e2a
  1039:004D  rep movsb byte ptr es:[di], byte ptr [si]
loc_1039_004F:    ; <- jcc:1039:000B
  1039:004F  mov cx, 0x300
  1039:0052  mov di, 0x104a
  1039:0055  cmp word ptr [0x43dc], 0             ; ds:43DC
  1039:005A  jne loc_1039_006B
  1039:005C  mov si, 0x1c4a
  1039:005F  cmp word ptr [0x368a], 0             ; ds:368A
  1039:0064  je loc_1039_0078
  1039:0066  mov si, 0x194a
  1039:0069  jmp loc_1039_0078
loc_1039_006B:    ; <- jcc:1039:005A
  1039:006B  mov si, 0x164a
  1039:006E  cmp word ptr [0x368a], 0             ; ds:368A
  1039:0073  je loc_1039_0078
  1039:0075  mov si, 0x1c4a
loc_1039_0078:    ; <- jcc:1039:0064 jcc:1039:0073 jmp:1039:0069
  1039:0078  rep movsb byte ptr es:[di], byte ptr [si]
  1039:007A  pop di
  1039:007B  pop si
  1039:007C  sub bx, bx
  1039:007E  mov cx, 0x100
  1039:0081  mov dx, 0x104a
  1039:0084  push es
  1039:0085  push dx
  1039:0086  push cx
  1039:0087  push bx
  1039:0088  call far func_14C2_0000              ; -> 14C2:0000
  1039:008D  add sp, 8
  1039:0090  mov ax, word ptr [0x368c]            ; ds:368C
  1039:0093  and ax, ax
  1039:0095  je loc_1039_009C
  1039:0097  call far func_1039_009D              ; -> 1039:009D
loc_1039_009C:    ; <- jcc:1039:0095
  1039:009C  retf

; ===== func_1039_009D  reg  callers: C=2 asm=1  seeds=far =====
func_1039_009D:
  1039:009D  mov ax, ds
  1039:009F  mov es, ax
  1039:00A1  mov bx, 0x98
  1039:00A4  mov cx, 8
  1039:00A7  mov dx, 0x206a
  1039:00AA  push es
  1039:00AB  push dx
  1039:00AC  push cx
  1039:00AD  push bx
  1039:00AE  call far func_14C2_0000              ; -> 14C2:0000
  1039:00B3  add sp, 8
  1039:00B6  retf

; ===== func_1039_00B7  reg  callers: C=1 asm=0  seeds=far =====
func_1039_00B7:
  1039:00B7  mov ax, ds
  1039:00B9  mov es, ax
  1039:00BB  mov bx, 0x98
  1039:00BE  mov cx, 8
  1039:00C1  mov dx, 0x1212
  1039:00C4  push es
  1039:00C5  push dx
  1039:00C6  push cx
  1039:00C7  push bx
  1039:00C8  call far func_14C2_0000              ; -> 14C2:0000
  1039:00CD  add sp, 8
  1039:00D0  retf

; ===== func_1039_00D1  reg  callers: C=1 asm=0  seeds=far =====
func_1039_00D1:
  1039:00D1  mov ax, ds
  1039:00D3  mov es, ax
  1039:00D5  sub bx, bx
  1039:00D7  mov cx, 0x100
  1039:00DA  mov dx, 0xd4a
  1039:00DD  push es
  1039:00DE  push dx
  1039:00DF  call far func_14C2_00B7              ; -> 14C2:00B7
  1039:00E4  add sp, 4
  1039:00E7  retf

; ===== func_1039_00E8  reg  callers: C=1 asm=0  seeds=far =====
func_1039_00E8:
  1039:00E8  mov ax, ds
  1039:00EA  mov es, ax
  1039:00EC  sub bx, bx
  1039:00EE  mov cx, 0x100
  1039:00F1  mov dx, 0xd4a
  1039:00F4  push es
  1039:00F5  push dx
  1039:00F6  push cx
  1039:00F7  push bx
  1039:00F8  call far func_14C2_0000              ; -> 14C2:0000
  1039:00FD  add sp, 8
  1039:0100  retf

; ===== func_1039_0101  reg  callers: C=1 asm=0  seeds=far =====
func_1039_0101:
  1039:0101  mov ax, ds
  1039:0103  mov es, ax
  1039:0105  sub bx, bx
  1039:0107  mov cx, 0x100
  1039:010A  mov dx, 0x134a
  1039:010D  push es
  1039:010E  push dx
  1039:010F  push cx
  1039:0110  push bx
  1039:0111  call far func_14C2_0000              ; -> 14C2:0000
  1039:0116  add sp, 8
  1039:0119  retf

; ===== func_1039_011A  reg  callers: C=2 asm=0  seeds=far =====
func_1039_011A:
  1039:011A  sub ah, ah
  1039:011C  mov al, byte ptr [0x7d8e]            ; ds:7D8E
  1039:011F  or al, al
  1039:0121  jne loc_1039_014B
  1039:0123  mov al, byte ptr [0x4993]            ; ds:4993
  1039:0126  cwde
  1039:0127  not ah
  1039:0129  and al, ah
  1039:012B  sub ah, ah
  1039:012D  shr ax, 1
  1039:012F  mov ah, al
  1039:0131  sub ah, byte ptr [0x49aa]            ; ds:49AA
  1039:0135  jns loc_1039_0139
  1039:0137  sub ah, ah
loc_1039_0139:    ; <- jcc:1039:0135
  1039:0139  cmp ah, 0x1f
  1039:013C  jle loc_1039_0140
  1039:013E  mov ah, 0x1f
loc_1039_0140:    ; <- jcc:1039:013C
  1039:0140  shr ax, 1
  1039:0142  mov al, byte ptr [0x43e6]            ; ds:43E6
  1039:0145  or al, al
  1039:0147  jne loc_1039_014B
  1039:0149  sub ah, ah
loc_1039_014B:    ; <- jcc:1039:0121 jcc:1039:0147
  1039:014B  mov al, ah
  1039:014D  sub ah, ah
  1039:014F  retf
