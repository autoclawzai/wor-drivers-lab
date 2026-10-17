#!/usr/bin/env bash
# Phase 0b: dig the Realtek driver (.sys/.inf/.cat/firmware) out of the nested InstallShield package.
set -uo pipefail
UA="Mozilla/5.0"
mkdir -p work out/drv && cd work
curl -fL -A "$UA" -o win.zip "https://static.tp-link.com/2018/201808/20180820/TL-WN722N(EUUSES)_V3_180807_Win.zip"
unzip -q -o win.zip -d win
7z x -y -owin/outer win/Setup.exe >/dev/null            # NSIS outer installer
IS="win/outer/\$PLUGINSDIR/Driver Files/Setup.exe"
ls -la "$IS"
7z x -y -owin/is "$IS" >/dev/null 2>&1 || echo "7z could not open InstallShield exe directly"
find win/is -maxdepth 3 -type f | head -50 | tee ../out/is_top.txt
for cab in $(find win/is -iname '*.cab' -o -iname 'data1.hdr' | grep -i cab); do
  unshield -d win/unshield x "$cab" || true
done
# any further nested archives
find win -type f \( -iname '*.cab' -o -iname '*.msi' \) -print0 | while IFS= read -r -d '' f; do
  7z x -y -o"${f}_x" "$f" >/dev/null 2>&1 || true
done
cd ..
find work/win -type f \( -iname '*.sys' -o -iname '*.inf' -o -iname '*.cat' -o -iname '*.bin' -o -iname '*.dll' \) \
  -not -path '*PLUGINSDIR/*.dll' > out/driver_candidates.txt
cat out/driver_candidates.txt
while IFS= read -r f; do cp --parents "$f" out/drv/ 2>/dev/null; done < <(grep -Ei '\.(sys|inf|cat)$' out/driver_candidates.txt)
mkdir -p out/inv && python3 scripts/inventory.py work/win out/inv
