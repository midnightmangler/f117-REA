#!/usr/bin/env python3
"""
Bundle index.src.html into a single file.

Inlines every <script src="..."> (in order) and every <link rel="stylesheet" href="...">
into dist/f117-rea.html, then copies it to the project's Dropbox builds/ folder as
f117-rea-YYYY-MM-DD.html and latest.html (the file the iPad opens).

usage: py -3 tools/bundle.py [--no-dropbox]
Standard library only. Exit 1 if a referenced file is missing.
"""
import datetime
import json
import os
import re
import shutil
import sys
from pathlib import Path

SLUG = "f117-rea"
DROPBOX_FOLDER = "F117-REA"           # Dropbox: Game Projects/<DROPBOX_FOLDER>/builds/
ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "index.src.html"
DIST = ROOT / "dist" / f"{SLUG}.html"

SCRIPT_RE = re.compile(r'<script\s+[^>]*src="([^"]+)"[^>]*>\s*</script>', re.I)
LINK_RE = re.compile(r'<link\s+[^>]*rel="stylesheet"[^>]*href="([^"]+)"[^>]*>', re.I)


def read(rel):
    p = ROOT / rel
    if not p.is_file():
        sys.exit(f"bundle.py: missing {rel}")
    return p.read_text(encoding="utf-8")


def bundle(html):
    def script(m):
        body = read(m.group(1)).replace("</script", "<\\/script")
        return f"<script>\n// ---- {m.group(1)} ----\n{body}\n</script>"

    def link(m):
        return f"<style>\n/* ---- {m.group(1)} ---- */\n{read(m.group(1))}\n</style>"

    html = SCRIPT_RE.sub(script, html)
    html = LINK_RE.sub(link, html)
    return html


def dropbox_root():
    """Find the Dropbox root: env var, Dropbox's info.json, then common folders."""
    env = os.environ.get("DROPBOX_ROOT")
    if env and Path(env).is_dir():
        return Path(env)
    for info in (Path(os.environ.get("LOCALAPPDATA", "")) / "Dropbox" / "info.json",
                 Path.home() / ".dropbox" / "info.json"):
        try:
            data = json.loads(info.read_text(encoding="utf-8"))
            for acct in data.values():
                p = Path(acct.get("path", ""))
                if p.is_dir():
                    return p
        except (OSError, ValueError):
            pass
    for p in (Path("C:/Dropbox"), Path.home() / "Dropbox"):
        if p.is_dir():
            return p
    return None


def main(argv):
    html = bundle(SRC.read_text(encoding="utf-8"))
    DIST.parent.mkdir(exist_ok=True)
    DIST.write_text(html, encoding="utf-8")
    print(f"wrote {DIST.relative_to(ROOT)} ({DIST.stat().st_size // 1024} KB)")

    if "--no-dropbox" in argv:
        return 0
    root = dropbox_root()
    if root is None:
        print("Dropbox not found; skipped builds/ copy")
        return 0
    builds = root / "Game Projects" / DROPBOX_FOLDER / "builds"
    builds.mkdir(parents=True, exist_ok=True)
    dated = builds / f"{SLUG}-{datetime.date.today().isoformat()}.html"
    shutil.copyfile(DIST, dated)
    shutil.copyfile(DIST, builds / "latest.html")
    print(f"copied to {dated} and latest.html")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
