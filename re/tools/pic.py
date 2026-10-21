"""F-117A (START.EXE) .PIC / .PAL decoder.

Format (see re/docs/format-pic.md):
  byte 0      : signed max LZW code width. <0 -> 8-bit pixels, width=-b ; >=0 -> 4-bit pixels (2/byte, low nibble first)
  byte 1..    : LSB-first LZW bit stream, 9-bit codes growing to max width, no clear/stop codes,
                table reset (to 9 bits) when width would exceed max. Output is RLE (0x90 n) coded.
  image       : always 320x200 (decoder emits 200 rows of 0x140 pixels; func_0000_8782).
Mirrors func_0000_8782 / 885F / 8889 / 88D4 / 890A / 8983 in START.EXE exactly.

usage: py -3 -I pic.py IN.PIC OUT.PNG [PALETTE.PAL[:index]]
       py -3 -I pic.py --all
"""
import os
import sys

W, H = 320, 200
_DROP = r"C:\Dropbox\Game Projects\F117-REA"
REF = os.environ.get("F117_REF", os.path.join(_DROP, "reference", "F-117A", "F-117A"))
OUT = os.path.join(os.environ.get("F117_RE", os.path.join(_DROP, "re")), "out", "pic")


class PicError(Exception):
    pass


def _lzw_bytes(data):
    """Generator of LZW-decoded bytes (func_0000_8983). data[0] = header byte."""
    hdr = data[0]
    maxbits = 256 - hdr if hdr & 0x80 else hdr
    if maxbits > 11:
        raise PicError("max code width %d > 11 (table is 0x800 entries)" % maxbits)
    # 0x800 entries of (prefix word, char byte) at ds:7420. char of entries >=0x100 is never cleared.
    prefix = [0xFFFF] * 0x800
    char = [0] * 0x800

    def reset():  # func_0000_88D4
        for i in range(0x800):
            prefix[i] = 0xFFFF
        for i in range(0x100):
            char[i] = i
        return 9, 0x1FF, 0x100

    width, mask, nxt = reset()
    old = 0          # ds:8D7E (initial value assumed 0)
    lastfirst = 0    # ds:8D80
    pos = 1          # bit stream starts after header byte (8 bits left in first word)
    bitbuf = 0
    nbits = 0
    n = len(data)
    while True:
        while nbits < width:
            b = data[pos] if pos < n else 0
            if pos >= n + 4:
                return
            pos += 1
            bitbuf |= b << nbits
            nbits += 8
        code = bitbuf & mask
        bitbuf >>= width
        nbits -= width
        stack = []
        cur = code
        c = code
        if code >= nxt:          # KwKwK
            c = nxt
            cur = old
            stack.append(lastfirst)
        guard = 0
        while prefix[cur] != 0xFFFF:
            stack.append(char[cur])
            cur = prefix[cur]
            guard += 1
            if guard > 0x1000:
                raise PicError("LZW chain loop")
        first = char[cur]
        lastfirst = first
        stack.append(first)
        # add entry (old, first) at nxt
        char[nxt] = first
        prefix[nxt] = old
        nxt += 1
        if nxt > mask:
            width += 1
            mask = mask * 2 + 1
        if width > maxbits:
            width, mask, nxt = reset()
        old = c
        for v in reversed(stack):
            yield v


def decode(data):
    """Return (pixels bytes 320*200, nibble_mode, maxbits)."""
    hdr = data[0]
    nibble = not (hdr & 0x80)
    maxbits = 256 - hdr if hdr & 0x80 else hdr
    src = _lzw_bytes(data)
    out = bytearray()
    need = W * H // 2 if nibble else W * H
    produced = 0
    last = 0
    run = 0
    try:
        while produced < need:     # func_0000_890A (RLE)
            if run:
                v = last
                run -= 1
            else:
                v = next(src)
                if v == 0x90:
                    cnt = next(src)
                    if cnt == 0:
                        v = 0x90
                        last = 0x90
                    else:
                        run = cnt - 1
                        v = last
                        run -= 1
                else:
                    last = v
            if nibble:
                out.append(v & 0x0F)
                out.append(v >> 4)
            else:
                out.append(v)
            produced += 1
    except StopIteration:
        raise PicError("data ran out after %d of %d bytes" % (produced, need))
    return bytes(out), nibble, maxbits


def load_pal(path, index=0):
    d = open(path, "rb").read()
    d = d[index * 768:(index + 1) * 768]
    if len(d) < 768:
        raise PicError("palette too short")
    return [(v * 255 + 31) // 63 if v < 64 else 255 for v in d]


def grey_pal():
    return [i for i in range(256) for _ in range(3)]


def to_png(pix, pal, path):
    from PIL import Image
    im = Image.frombytes("P", (W, H), pix)
    im.putpalette(pal)
    im.save(path)


def find_ci(folder, name):
    for f in os.listdir(folder):
        if f.lower() == name.lower():
            return os.path.join(folder, f)
    return None


# START.EXE name table ds:0CBA (index -> "%s.pic"); func_0000_3641 loads PALETTES.PAL[min(index,8)]
# (func_0000_826C).  Sprite sheets are shown under the palette of the screen that loads them.
START_PICS = ["air_id", "armsscrn", "brefscrn", "folder1", "hangscrn", "homescrn", "ordrscrn",
              "rostscrn", "breficon", "folder2", "ordrsprt", "requestr", "rostsprt", "weapons1",
              "weapons2", "weapons3", "libya", "persian", "n_cape", "c_europe", "vietnam",
              "mid_east", "kuwait", "cuba", "korea", "planes1", "planes2", "planes3", "planes4",
              "planes5", "hangsprt", "adv", "climbin"]
SHEET_PAL = {
    "planes1": 0, "planes2": 0, "planes3": 0, "planes4": 0, "planes5": 0,   # air_id screen (0:0713 -> 0:057E)
    "weapons1": 1, "weapons2": 1, "weapons3": 1, "requestr": 1,             # arms screen func_0000_0963 / 07EE
    "breficon": 2, "libya": 2, "persian": 2, "n_cape": 2, "c_europe": 2, "vietnam": 2,
    "mid_east": 2, "kuwait": 2, "cuba": 2, "korea": 2,                     # briefing: 826C(2) at 0:0F8E / 0:24BB
    "folder2": 3,                                                          # 826C(3) at 0:2219
    "hangsprt": 4, "ordrsprt": 6, "rostsprt": 7,                           # callbacks of 3641(4/6/7)
}


def start_pal_index(base):
    b = base.lower()
    if b in SHEET_PAL:
        return SHEET_PAL[b]
    if b in START_PICS:
        return min(START_PICS.index(b), 8)
    return None


def run_all():
    os.makedirs(OUT, exist_ok=True)
    lines = ["name\twidth\theight\tflags\tpalette\tstatus"]
    pals = find_ci(REF, "PALETTES.PAL")
    for f in sorted(os.listdir(REF)):
        if not f.upper().endswith(".PIC"):
            continue
        base = f[:-4]
        data = open(os.path.join(REF, f), "rb").read()
        same = find_ci(REF, base + ".PAL")
        si = start_pal_index(base)
        if same:
            pal, pname = load_pal(same), os.path.basename(same)
        elif pals and si is not None:
            pal, pname = load_pal(pals, si), "PALETTES.PAL:%d" % si
        elif pals:
            pal, pname = load_pal(pals, 0), "PALETTES.PAL:0"
        else:
            pal, pname = grey_pal(), "grey"
        try:
            pix, nib, mb = decode(data)
            to_png(pix, pal, os.path.join(OUT, base + ".png"))
            status = "ok"
        except PicError as e:
            nib, mb, status = not (data[0] & 0x80), None, "FAIL: %s" % e
        flags = "hdr=%02X maxbits=%s %s" % (data[0], mb, "4bpp" if nib else "8bpp")
        lines.append("%s\t%d\t%d\t%s\t%s\t%s" % (f, W, H, flags, pname, status))
        print(lines[-1])
    with open(os.path.join(OUT, "index.txt"), "w") as fh:
        fh.write("\n".join(lines) + "\n")


def main(argv):
    if len(argv) >= 1 and argv[0] == "--all":
        run_all()
        return 0
    if len(argv) < 2:
        print(__doc__)
        return 1
    data = open(argv[0], "rb").read()
    pix, nib, mb = decode(data)
    if len(argv) > 2:
        p, sep, idx = argv[2].rpartition(":")
        if not (sep and idx.isdigit()):
            p, idx = argv[2], "0"
        pal = load_pal(p, int(idx))
    else:
        pal = grey_pal()
    to_png(pix, pal, argv[1])
    print("%s: %dx%d %s maxbits=%d" % (argv[0], W, H, "4bpp" if nib else "8bpp", mb))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
