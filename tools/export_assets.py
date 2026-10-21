#!/usr/bin/env python3
"""
Export game-ready assets from the original F-117A files using the re/tools decoders.

usage: py -3 tools/export_assets.py
env:   F117_REF = original game dir (default Dropbox reference/F-117A/F-117A)
       F117_RE  = Dropbox re/ dir holding unpacked/ and out/ (default Dropbox re)

Writes (task card 0.2, re/docs/02-build-plan.md):
  assets/pic/<NAME>.png      52 PICs as 8-bit indexed PNG (palette = the one the game loads; indices kept)
  assets/palettes.json       12 *.PAL + 9 PALETTES.PAL entries, raw 6-bit VGA values
  assets/fonts.json          7 MGRAPHIC fonts (mgraphic_font.py output)
  assets/world/<XX>.json     WLD + 3DX + 3DG + 3DT per region; PHOTO.json, STFLT.json (3DX only)
  assets/pan/<NAME>.PAN      raw (361 KB total; decoded frames would be 4.5 MB) + pan.json (header info)
  assets/ss/LABSLOGO.SS      raw (12 KB) + labslogo.json (header, palette, frame table)
  assets/sound/ASOUND.117    raw driver (sequences + instrument bank) + asound.json (decoded tables)
  assets/sound/speech/*.wav  speech phrases + speech.json
  assets/manifest.json       every file with size and sha1
  tests/golden/              Python decoder outputs for the JS golden tests
"""
import hashlib
import json
import os
import re
import shutil
import struct
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
TOOLS = ROOT / "re" / "tools"
DROP = Path(r"C:\Dropbox\Game Projects\F117-REA")
REF = Path(os.environ.get("F117_REF", DROP / "reference" / "F-117A" / "F-117A"))
RE_DIR = Path(os.environ.get("F117_RE", DROP / "re"))
ASSETS = ROOT / "assets"
GOLDEN = ROOT / "tests" / "golden"
REGIONS = ["LB", "PG", "NC", "CE", "VN", "ME", "KU", "CU", "KO"]

sys.path.insert(0, str(TOOLS))
import pic      # noqa: E402
import pan      # noqa: E402
import ss       # noqa: E402
import world    # noqa: E402


def ref(name):
    p = pic.find_ci(str(REF), name)
    if not p:
        sys.exit(f"missing game file {name} in {REF}")
    return Path(p)


def dump_json(path, obj):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(obj, separators=(",", ":")), encoding="utf-8")


def clean(d):
    if d.exists():
        shutil.rmtree(d)
    d.mkdir(parents=True)


# ---------------------------------------------------------------- PIC / PAL
def export_pics():
    out = ASSETS / "pic"; out.mkdir()
    pals = str(ref("PALETTES.PAL"))
    index = []
    for f in sorted(os.listdir(REF)):
        if not f.upper().endswith(".PIC"):
            continue
        base = f[:-4].upper()
        data = ref(f).read_bytes()
        same = pic.find_ci(str(REF), base + ".PAL")
        si = pic.start_pal_index(base)
        if same:
            pal, pname = pic.load_pal(same), os.path.basename(same).upper()
        elif si is not None:
            pal, pname = pic.load_pal(pals, si), f"PALETTES.PAL:{si}"
        else:
            pal, pname = pic.load_pal(pals, 0), "PALETTES.PAL:0"
        pix, nib, mb = pic.decode(data)
        pic.to_png(pix, pal, str(out / f"{base}.png"))
        index.append(dict(name=base, palette=pname, bpp=4 if nib else 8, maxbits=mb,
                          sha1=hashlib.sha1(pix).hexdigest()))
    return index


def export_palettes():
    pals = {}
    for f in sorted(os.listdir(REF)):
        if not f.upper().endswith(".PAL"):
            continue
        d = ref(f).read_bytes()
        name = f.upper()
        if name == "PALETTES.PAL":
            for i in range(len(d) // 768):
                pals[f"PALETTES.PAL:{i}"] = list(d[i * 768:(i + 1) * 768])
        else:
            pals[name] = list(d[:768])
    dump_json(ASSETS / "palettes.json", dict(note="raw 6-bit VGA DAC values, 256 x RGB; rgb8 = (v*255+31)//63",
                                              palettes=pals))
    return len(pals)


# ---------------------------------------------------------------- world
def lod_json(b):
    return dict(off=b.off, radius=b.radius, nparts=b.nparts, partAnim=[list(x) for x in b.part_anim],
                partPivot=[list(x) for x in b.part_pivot], nverts=b.nverts, nplanes=b.nplanes,
                planes=[list(p) if p[0] != "plane" else ["plane", list(p[1]), p[2]] for p in b.planes],
                usage=b.usage, bsp=list(b.bsp) if b.bsp is not None else None,
                verts=[list(v) for v in b.verts], vref=b.vref, edges=[list(e) for e in b.edges],
                lists=[[pi, [list(c) for c in lst]] for pi, lst in b.lists], end=b.end)


def parse_3dx_json(d):
    n, offs, attrs, objs, vec = world.parse_3dx(d)
    blocks = {}
    for lods in objs:
        for t, lo in lods:
            if str(lo) not in blocks:
                blocks[str(lo)] = lod_json(world.parse_lod(d, lo))
    return dict(count=n, objects=[dict(off=offs[i], attr=attrs[i],
                                       lods=[dict(maxDepth=t, block=lo) for t, lo in objs[i]])
                                  for i in range(n)],
                vectors=[list(v) for v in vec], blocks=blocks, size=len(d))


def parse_3dg_json(d):
    tiles = {}
    for name, base in (("level2", 274), ("level1", 786), ("level0", 1298)):
        tiles[name] = [list(d[base + 16 * t:base + 16 * t + 16]) for t in range(32)]
    return dict(w0=world.u16(d, 0), skipped=list(d[2:18]), grid3=list(d[18:274]), tiles=tiles)


def parse_3dt_json(d):
    cnt = struct.unpack_from("<5H", d, 2); p = 12; m = []
    for i in range(5):
        m.append(struct.unpack_from("<%dH" % cnt[i], d, p)); p += 2 * cnt[i]
    levels = []
    for lv in range(5):
        tiles = []
        for t in range(cnt[lv]):
            recs = []
            for _ in range(m[lv][t]):
                x, y, z, s = struct.unpack_from("<3hH", d, p); p += 8
                recs.append([x, y, z, s])
            tiles.append(recs)
        levels.append(tiles)
    return dict(w0=world.u16(d, 0), counts=list(cnt), levels=levels, end=p, size=len(d))


def wld_json(d):
    w = world.parse_wld(d)
    return dict(sideShapes=[w["side_shape0"], w["side_shape1"]], h2=w["h2"], h3=w["h3"],
                objects=[list(o) for o in w["objs"]], units=[list(u) for u in w["units"]],
                typeflags=list(w["typeflags"]), tab2=list(w["tab2"]), tab3=list(w["tab3"]),
                grid=list(w["grid"]), strings=w["strings"], poolLen=w["pool_len"])


def export_world():
    out = ASSETS / "world"; out.mkdir()
    for xx in REGIONS:
        dump_json(out / f"{xx}.json", dict(
            region=xx, wld=wld_json(ref(f"{xx}.WLD").read_bytes()),
            x3d=parse_3dx_json(ref(f"{xx}.3DX").read_bytes()),
            grid=parse_3dg_json(ref(f"{xx}.3DG").read_bytes()),
            props=parse_3dt_json(ref(f"{xx}.3DT").read_bytes())))
    for nm in ("PHOTO", "STFLT"):
        dump_json(out / f"{nm}.json", dict(region=nm, x3d=parse_3dx_json(ref(f"{nm}.3DX").read_bytes())))
    return len(REGIONS) + 2


# ---------------------------------------------------------------- PAN / SS
def export_pan():
    out = ASSETS / "pan"; out.mkdir()
    gold = GOLDEN / "pan"
    info = {}
    for f in sorted(os.listdir(REF)):
        if not f.upper().endswith(".PAN"):
            continue
        name = f[:-4].upper()
        shutil.copyfile(ref(f), out / f"{name}.PAN")
        r = pan.decode(str(ref(f)))
        nf = len(r["frames"])
        info[name] = dict(bytes=r["raw"], unpacked=r["unpacked"], cels=r["cels"], frames=nf, rate=r["rate"],
                          ticksPerFrame=60 // r["rate"] if r["rate"] else None, segments=len(r["segs"]) + 1,
                          frameSha1=[hashlib.sha1(fr).hexdigest() for fr in r["frames"]])
        g = gold / name; g.mkdir(parents=True)
        (g / "cels.txt").write_text("\n".join(r["log"]) + "\n", encoding="utf-8")
        for i in sorted({0, nf // 2, nf - 1}):
            pan.to_img(r["frames"][i], r["pal"]).save(g / f"frame_{i:04d}.png")
    dump_json(out / "pan.json", dict(note="raw .PAN files, decoded at runtime (format-pan.md); "
                                          "frameSha1 = sha1 of each 64000-byte screen after cel i", files=info))
    return len(info)


def export_ss():
    out = ASSETS / "ss"; out.mkdir()
    src = ref("LABSLOGO.SS")
    shutil.copyfile(src, out / "LABSLOGO.SS")
    s = ss.load(str(src))
    base = ss.TYPE_BASE.get(s["type"], 1)
    frames = []
    screen = bytearray(64000)
    gold = GOLDEN / "ss"; gold.mkdir(parents=True)
    for i, f in enumerate(s["frames"]):
        def put(x, y, v, f=f):
            X, Y = f["x"] + x, f["y"] + y
            if 0 <= X < 320 and 0 <= Y < 200:
                screen[Y * 320 + X] = (base + v - 1) & 255
        st = ss.draw(s["data"], f["off"], put)
        frames.append(dict(off=f["off"], delay=f["delay"], x=f["x"], y=f["y"], w=f["w"], h=f["h"],
                           rows=st["rows"], maxw=st["maxw"], end=st["end"],
                           screenSha1=hashlib.sha1(bytes(screen)).hexdigest()))
    (gold / "screen_final.bin").write_bytes(bytes(screen))
    dump_json(out / "labslogo.json", dict(
        note="raw LABSLOGO.SS decoded at runtime (format-ss.md); palette entries are RGB+flag 6-bit, "
             "loaded at DAC index base+i; pixel value v -> DAC base+v-1; screenSha1 = sha1 of 64000-byte "
             "screen after drawing frame i cumulatively",
        name=s["name"], count=s["count"], dataSize=s["datasize"], hdr0C=s["f0c"], hdr0E=s["f0e"],
        type=s["type"], base=base, palette=[list(p) for p in s["pal"]], dataOffset=s["data_off"], frames=frames))
    return s["count"]


# ---------------------------------------------------------------- sound
OP_RE = re.compile(r"(\w+)=(\d+)")


def parse_sound_txt(outdir):
    ids = []
    for line in (outdir / "asound_ids.txt").read_text().splitlines()[2:]:
        m = re.match(r"\s*(\d+)\s+([0-9A-F]{4})\s+(.*)", line)
        if not m:
            continue
        idn, handler, rest = int(m.group(1)), int(m.group(2), 16), m.group(3)
        body, _, notes = rest.partition(";")
        voices = [dict(voice=int(v), seq=int(sq, 16)) for v, sq in re.findall(r"v(\d)<-([0-9A-F]{4})", body)]
        ids.append(dict(id=idn, handler=handler, voices=voices,
                        special=None if voices else body.strip(), notes=notes.strip() or None))

    instr, cur = [], None
    for line in (outdir / "asound_instruments.txt").read_text().splitlines():
        m = re.match(r"\s*(\d+) @([0-9A-F]{4})(.*)", line)
        if m:
            cur = dict(index=int(m.group(1)), off=int(m.group(2), 16),
                       unreferenced="unreferenced" in m.group(3), ops=[], noise=None)
            instr.append(cur); continue
        if cur is None:
            continue
        if line.strip().startswith("op"):
            cur["ops"].append({k: int(v) for k, v in OP_RE.findall(line)})
        elif line.strip().startswith("noise:"):
            mk, bs, stp = re.search(r"mask=([0-9A-F]+) base=([0-9A-F]+) step=(-?\d+)", line).groups()
            cur["noise"] = dict(mask=int(mk, 16), base=int(bs, 16), step=int(stp))
        elif line.startswith("F-number"):
            fnum = [int(x, 16) for x in line.split(":")[1].split()]
        elif line.startswith("channel->operator"):
            chop = [int(x) for x in line.split(":")[1].split()]
        elif line.startswith("slot->register"):
            slotreg = [int(x, 16) for x in line.split(":")[1].split()]

    seqs, cur = {}, None
    for line in (outdir / "asound_sequences.txt").read_text().splitlines():
        m = re.match(r"seq ([0-9A-F]{4})\s+\(voices ([\d,]*)\)", line)
        if m:
            cur = dict(voices=[int(v) for v in m.group(2).split(",") if v], events=[])
            seqs[str(int(m.group(1), 16))] = cur; continue
        m = re.match(r"\s+([0-9A-F]{4})\s+([0-9A-F]{2}) (\S+)\s*(.*)", line)
        if not m or cur is None:
            continue
        addr, b0, tok, rest = int(m.group(1), 16), int(m.group(2), 16), m.group(3), m.group(4)
        if b0 >= 0xF3:
            args = rest if tok == "RANDPATCH" else [int(x) for x in re.sub(r"\(.*?\)", "", rest).split()]
            cur["events"].append(dict(addr=addr, cmd=tok, args=args))
        else:
            dur = int(tok, 16)
            cur["events"].append(dict(addr=addr, note=b0, dur=dur) if b0 and dur else
                                 dict(addr=addr, note=b0, dur=dur, end=dur == 0))

    speech = []
    for line in (outdir / "speech_phrases.txt").read_text().splitlines()[1:]:
        m = re.match(r"id (\d+) table cs:([0-9A-F]{4}): (.*)", line)
        if m:
            segs = [[int(a, 16), int(b, 16)] for a, b in re.findall(r"\[([0-9A-F]+)\.\.([0-9A-F]+)\)", m.group(3))]
            speech.append(dict(id=int(m.group(1)), table=int(m.group(2), 16), segments=segs))
        m = re.match(r"\s+-> (\S+) \((\d+) samples", line)
        if m:
            speech[-1].update(file=m.group(1), samples=int(m.group(2)))
    return ids, instr, fnum, chop, slotreg, seqs, speech


def export_sound():
    out = ASSETS / "sound"; out.mkdir()
    sound_out = RE_DIR / "out" / "sound"
    subprocess.run([sys.executable, "-I", str(TOOLS / "sound.py"), str(RE_DIR / "unpacked"), str(REF),
                    str(sound_out)], check=True, capture_output=True)
    shutil.copyfile(ref("ASOUND.117"), out / "ASOUND.117")
    ids, instr, fnum, chop, slotreg, seqs, speech = parse_sound_txt(sound_out)
    dump_json(out / "asound.json", dict(
        note="decoded from ASOUND.117 by re/tools/sound.py; offsets are image offsets (file+0x200), "
             "handlers are code-segment offsets; see re/docs/sound.md",
        ids=ids, instruments=instr, fnumTable=fnum, channelOps=chop, slotRegs=slotreg, sequences=seqs))
    sp = out / "speech"; sp.mkdir()
    for s in speech:
        shutil.copyfile(sound_out / s["file"], sp / s["file"])
    dump_json(sp / "speech.json", dict(note="8-bit unsigned mono 8000 Hz slices of SPEECH.117", phrases=speech))
    gold = GOLDEN / "sound"; gold.mkdir(parents=True)
    for f in ("asound_ids.txt", "asound_instruments.txt", "asound_sequences.txt", "speech_phrases.txt"):
        shutil.copyfile(sound_out / f, gold / f)
    return len(ids), len(speech)


# ---------------------------------------------------------------- fonts
def export_fonts():
    subprocess.run([sys.executable, "-I", str(TOOLS / "mgraphic_font.py"), str(RE_DIR)],
                   check=True, capture_output=True)
    src = RE_DIR / "out" / "mgraphic" / "fonts.json"
    fonts = json.loads(src.read_text())
    dump_json(ASSETS / "fonts.json", dict(note="MGRAPHIC.EXE fonts; rows are 16-bit big-endian glyph rows, "
                                               "MSB = leftmost pixel; see mgraphic-api.md", fonts=fonts))
    return len(fonts)


# ---------------------------------------------------------------- golden copies
def export_golden():
    for sub in ("world", "mgraphic"):
        d = GOLDEN / sub; d.mkdir(parents=True, exist_ok=True)
    # world text dumps, regenerated by world.py
    files = [str(ref(f"{xx}.{ext}")) for xx in REGIONS for ext in ("WLD", "3DX", "3DG", "3DT")]
    files += [str(ref("PHOTO.3DX")), str(ref("STFLT.3DX"))]
    subprocess.run([sys.executable, "-I", str(TOOLS / "world.py")] + files, check=True, capture_output=True)
    for f in (RE_DIR / "out" / "world").glob("*.txt"):
        shutil.copyfile(f, GOLDEN / "world" / f.name)
    shutil.copyfile(RE_DIR / "out" / "mgraphic" / "fonts.json", GOLDEN / "mgraphic" / "fonts.json")


def manifest(pic_index):
    files = []
    for p in sorted(ASSETS.rglob("*")):
        if p.is_file() and p.name != "manifest.json":
            files.append(dict(path=p.relative_to(ASSETS).as_posix(), bytes=p.stat().st_size,
                              sha1=hashlib.sha1(p.read_bytes()).hexdigest()))
    big = [f for f in files if f["bytes"] > 2 * 1024 * 1024]
    if big:
        sys.exit("asset over 2 MB: " + ", ".join(f["path"] for f in big))
    dump_json(ASSETS / "manifest.json", dict(
        source="F-117A Nighthawk Stealth Fighter 2.0 (GOG), exported by tools/export_assets.py",
        notes=["pic/*.png are 8-bit indexed PNGs: the JS loader must read palette indices, not RGBA",
               "pan/*.PAN, ss/LABSLOGO.SS and sound/ASOUND.117 are raw originals, decoded at runtime",
               "world/*.json carry the parsed WLD/3DX/3DG/3DT structures (format-3d.md)"],
        pics=pic_index, files=files, totalBytes=sum(f["bytes"] for f in files)))
    return len(files), sum(f["bytes"] for f in files)


def main():
    if not REF.is_dir():
        sys.exit(f"game dir not found: {REF} (set F117_REF)")
    clean(ASSETS); clean(GOLDEN)
    (ASSETS / ".gitkeep").unlink(missing_ok=True)
    pics = export_pics();            print(f"pic: {len(pics)}")
    print(f"palettes: {export_palettes()}")
    print(f"fonts: {export_fonts()}")
    print(f"world: {export_world()}")
    print(f"pan: {export_pan()}")
    print(f"ss frames: {export_ss()}")
    nid, nsp = export_sound();       print(f"sound ids: {nid}, speech: {nsp}")
    export_golden()
    n, total = manifest(pics)
    print(f"manifest: {n} files, {total // 1024} KB")


if __name__ == "__main__":
    main()
