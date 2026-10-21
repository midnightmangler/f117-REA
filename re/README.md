# re/ — reverse-engineering workspace

Text lives here (GitHub wins): `docs/` (everything learned), `tools/` (decoders, stdlib + PIL/numpy/capstone),
`strings/`, `decomp/` (pseudo-C per function, written before porting).

Derived or copyrighted material stays in Dropbox `Game Projects/F117-REA/re/` and is not committed:
`unpacked/` (LZEXE-unpacked EXEs), `disasm/` (listings, 6 MB), `out/` (decoded assets, 868 files).
Original game files: Dropbox `Game Projects/F117-REA/reference/F-117A/F-117A/` (read only).

Tools take the reference and output directories from the `F117_REF` / `F117_RE` environment variables
when the Dropbox defaults do not apply. See `docs/00-conventions.md`.
