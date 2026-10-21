# RE workspace conventions

Workspace: `C:\Dropbox\Game Projects\F117-REA\re\`

```
re/
  tools/      unlzexe.py, strings.py, disasm.py, format decoders (python, stdlib + PIL/numpy only)
  unpacked/   LZEXE-unpacked executables (analyse these, never the originals)
  disasm/     NAME.asm (listing), NAME.funcs.txt, NAME.segs.txt, NAME.data.txt (string xrefs)
  strings/    printable strings with file offsets (offset = file offset in unpacked EXE, header included)
  docs/       everything learned. One topic per file. Markdown.
  out/        decoded assets (PNG etc.) produced by tools
```

Original game files: `C:\Dropbox\Game Projects\F117-REA\reference\F-117A\F-117A\` (read only).

## Addressing
- Listings use `SEG:OFF` where SEG is the load-relative paragraph (image starts at 0000:0000).
  Linear = SEG*16+OFF. File offset in the *unpacked* EXE = linear + header size
  (START 784, VGAME 2352, END 592, PLAYER 128, SETUP 176, DSWAP 176, MPS_LOGO 560).
- Function names in listings are `func_SEG_OFF`. Keep using those names in docs; add a
  descriptive alias in the form `func_0000_35FC = pic_load()`.
- `dgroup` is the C data segment. `ds:XXXX` in comments = offset in DGROUP.
  DGROUP linear base: START 0A950, VGAME 1E420, END 05FA0, PLAYER 02A30, SETUP 024C0, DSWAP 02250, MPS_LOGO 03320 (the listing header says 00DA — wrong; functions in MPS_LOGO.asm are mis-split, re-run disasm with dgroup override if needed).

## Compiler facts (verified)
- Microsoft C 6.0 (1990 runtime), 80186+ code (`push imm`, `enter/leave`, `shl r,imm`).
- START/END/PLAYER/SETUP/DSWAP: small model (one code segment, near calls). Args pushed right to left,
  caller cleans (`add sp,N`). Return in AX (DX:AX for long). `[bp+4]`=arg1, `[bp+6]`=arg2 ... locals `[bp-N]`.
- VGAME: C code in segment 0000 (64K), assembly modules in segments 0FAE..14C2, far data in 14D1/1872/1D6F.
- `_C_FILE_INFO`, `R6000`, `<<NMSG>>` etc. = C runtime; ignore. Functions above ~0000:E6BE in VGAME,
  ~0000:8000 in START, ~0000:3F44 in END are mostly runtime/library (printf, file I/O, memory).

## Known listing defects (disasm.py)
- MGRAPHIC.asm is wrong (data decoded as code); use `re/out/mgraphic/MGRAPHIC_code.asm` (made by `re/tools/mgraphic_disasm.py`).
- VGAME assembly modules in segments 0FB2, 1058, 11D8 are partly mis-disassembled (register-convention
  calls, data interleaved). Treat those listings as a starting point only; re-disassemble per module when needed.
- MPS_LOGO.asm functions are mis-split (real DGROUP 0332).

## Doc rules
- No guesses: every claim about behaviour cites the function address and, where it matters, the instruction offsets.
- Mark uncertain readings `(?)`. Mark verified-by-decoding `[verified]`.
- Record constants as hex and decimal. Record table addresses in DGROUP.
- Keep each doc focused; link to others by filename.
