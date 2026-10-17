#!/usr/bin/env bash
# Phase 0: download official TP-Link packages, unpack (nested too), inventory, clone Linux reference driver.
set -euo pipefail
UA="Mozilla/5.0"
mkdir -p work out
cd work

curl -fL -A "$UA" -o win.zip   "https://static.tp-link.com/2018/201808/20180820/TL-WN722N(EUUSES)_V3_180807_Win.zip"
curl -fL -A "$UA" -o linux.zip "https://static.tp-link.com/2018/201805/20180521/TP-Link_Driver_Linux_series7_beta.zip"
sha256sum win.zip linux.zip | tee ../out/zip_sha256.txt

mkdir -p win linux
unzip -q -o win.zip -d win
unzip -q -o linux.zip -d linux

# unpack nested archives / installers (best effort, up to 2 levels)
for round in 1 2; do
  find win linux -type f \( -iname '*.zip' -o -iname '*.exe' -o -iname '*.msi' -o -iname '*.cab' -o -iname '*.tar.gz' \) | while read -r f; do
    d="${f}_x"
    [ -d "$d" ] && continue
    mkdir -p "$d"
    7z x -y -o"$d" "$f" >/dev/null 2>&1 || rmdir "$d" 2>/dev/null || true
  done
done

git clone --depth 1 https://github.com/aircrack-ng/rtl8188eus aircrack
cd ..

python3 scripts/inventory.py work/win out/win
python3 scripts/inventory.py work/linux out/linux
find work/aircrack -type f | sort > out/aircrack_files.txt
grep -rIl "2357" work/aircrack --include='*.c' --include='*.h' --include='Makefile' | head -20 > out/aircrack_tplink_refs.txt || true
grep -rIn "0x010C\|0x010c" work/aircrack --include='*.c' --include='*.h' | head -20 >> out/aircrack_tplink_refs.txt || true

{
  echo "## Phase 0 inventory"
  echo '```'; cat out/zip_sha256.txt; echo '```'
  echo "### Windows package"; head -80 out/win/inventory.md
  echo "### Linux package"; head -40 out/linux/inventory.md
  echo "### aircrack-ng refs to TP-Link IDs"; echo '```'; cat out/aircrack_tplink_refs.txt; echo '```'
} > out/SUMMARY.md
