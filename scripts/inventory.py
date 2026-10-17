#!/usr/bin/env python3
"""Phase 0 inventory: hash every file, parse INF files, summarize PE binaries.

usage: inventory.py <root_dir> <out_dir>
"""
import hashlib
import json
import os
import re
import sys

import pefile

MACHINES = {0x14C: "x86", 0x8664: "x64", 0x1C0: "arm", 0xAA64: "arm64"}


def sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def read_text(path):
    raw = open(path, "rb").read()
    for enc in ("utf-16", "utf-8", "latin-1"):
        try:
            return raw.decode(enc)
        except UnicodeError:
            continue
    return raw.decode("latin-1", "replace")


def parse_inf(path):
    text = read_text(path)
    keep = re.compile(r"(VID_|USB\\|^\s*(Class|ClassGuid|Provider|DriverVer|CatalogFile|NTamd64|NTarm64|NTx86)\b|\.sys|\.bin)", re.I)
    return [ln.strip() for ln in text.splitlines() if keep.search(ln)][:300]


def parse_pe(path):
    try:
        pe = pefile.PE(path, fast_load=False)
    except Exception as exc:  # not a PE
        return {"error": str(exc)}
    info = {
        "machine": MACHINES.get(pe.FILE_HEADER.Machine, hex(pe.FILE_HEADER.Machine)),
        "subsystem": pe.OPTIONAL_HEADER.Subsystem,
        "timestamp": pe.FILE_HEADER.TimeDateStamp,
        "sections": [(s.Name.rstrip(b"\0").decode("latin-1"), s.Misc_VirtualSize, s.SizeOfRawData) for s in pe.sections],
        "imports": {},
    }
    for entry in getattr(pe, "DIRECTORY_ENTRY_IMPORT", []):
        info["imports"][entry.dll.decode("latin-1")] = [i.name.decode("latin-1") for i in entry.imports if i.name][:400]
    return info


def interesting_strings(path, limit=200):
    data = open(path, "rb").read()
    pat = re.compile(rb"[\x20-\x7e]{6,}")
    key = re.compile(rb"(rtl|8188|firmware|\.bin|wlan|usb|efuse|ndis|WdfDriver|Realtek)", re.I)
    out = []
    for m in pat.finditer(data):
        s = m.group()
        if key.search(s):
            out.append(s.decode("ascii"))
            if len(out) >= limit:
                break
    return out


def main(root, out_dir):
    os.makedirs(out_dir, exist_ok=True)
    files, infs, pes = [], {}, {}
    for dp, _, names in os.walk(root):
        for n in sorted(names):
            p = os.path.join(dp, n)
            rel = os.path.relpath(p, root)
            files.append({"path": rel, "size": os.path.getsize(p), "sha256": sha256(p)})
            low = n.lower()
            if low.endswith(".inf"):
                infs[rel] = parse_inf(p)
            elif low.endswith((".sys", ".dll", ".exe")):
                pes[rel] = parse_pe(p)
                pes[rel]["strings"] = interesting_strings(p)
    json.dump({"files": files, "inf": infs, "pe": pes}, open(os.path.join(out_dir, "inventory.json"), "w"), indent=1)

    lines = ["# Inventory of " + root, "", "## Files", "| size | sha256 | path |", "| --- | --- | --- |"]
    lines += [f"| {f['size']} | `{f['sha256'][:16]}` | {f['path']} |" for f in files]
    lines += ["", "## INF (filtered)"]
    for k, v in infs.items():
        lines += [f"### {k}", "```", *v[:60], "```"]
    lines += ["", "## PE"]
    for k, v in pes.items():
        lines.append(f"- `{k}`: {v.get('machine', v.get('error'))}, imports from {len(v.get('imports', {}))} DLLs, {len(v.get('strings', []))} key strings")
    open(os.path.join(out_dir, "inventory.md"), "w").write("\n".join(lines) + "\n")


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
