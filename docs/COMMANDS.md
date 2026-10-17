# Commands (full, copy-paste)

## Phase 0 - run the inventory on CI
GitHub Actions workflow `phase0-inventory` (manual run or on push to `scripts/` or `.github/workflows/phase0-inventory.yml`).

What it executes (see `scripts/phase0_inventory.sh`):
```bash
curl -fL -A "Mozilla/5.0" -o win.zip  "https://static.tp-link.com/2018/201808/20180820/TL-WN722N(EUUSES)_V3_180807_Win.zip"
curl -fL -A "Mozilla/5.0" -o linux.zip "https://static.tp-link.com/2018/201805/20180521/TP-Link_Driver_Linux_series7_beta.zip"
unzip -q win.zip -d work/win && unzip -q linux.zip -d work/linux
sha256sum win.zip linux.zip
find work -type f | sort
python3 scripts/inventory.py work/win   # INF, PE arch, imports, strings
git clone --depth 1 https://github.com/aircrack-ng/rtl8188eus work/aircrack
```
Results: workflow artifact `phase0-inventory` and the job summary.

Download the result with:
```bash
gh run download -R autoclawzai/wor-drivers-lab -n phase0-inventory
```
