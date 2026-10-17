#!/usr/bin/env python3
"""Extract the Disk1 files embedded in an InstallShield single-file Setup.exe (overlay format).

Entry layout (after the PE sections): name\0 Disk1\\name\0 version\0 size(ascii)\0 <size raw bytes>
usage: extract_installshield.py <Setup.exe> <out_dir> [overlay_offset]
Then: unshield -d <drv_dir> x <out_dir>/data1.cab   (needs data1.hdr next to it)
"""
import os
import struct
import sys


def overlay_offset(d):
    pe = struct.unpack_from("<I", d, 0x3C)[0]
    n = struct.unpack_from("<H", d, pe + 6)[0]
    opt = struct.unpack_from("<H", d, pe + 20)[0]
    end = 0
    for i in range(n):
        s = d[pe + 24 + opt + i * 40: pe + 24 + opt + (i + 1) * 40]
        _vs, _va, raw_size, raw_ptr = struct.unpack_from("<IIII", s, 8)
        end = max(end, raw_ptr + raw_size)
    return end


def main(exe, out, off=None):
    d = open(exe, "rb").read()
    p = int(off) if off else overlay_offset(d)
    os.makedirs(out, exist_ok=True)
    while p < len(d):
        q, f = p, []
        try:
            for _ in range(4):
                e = d.index(b"\0", q)
                f.append(d[q:e]); q = e + 1
            name, size = f[0].decode(), int(f[3])
        except (ValueError, UnicodeDecodeError):
            break
        open(os.path.join(out, name), "wb").write(d[q:q + size])
        print(name, size)
        p = q + size


if __name__ == "__main__":
    main(*sys.argv[1:])
