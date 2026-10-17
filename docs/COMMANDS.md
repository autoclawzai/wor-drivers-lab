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

## Reading CI results from the sandbox
Artifact and log downloads are blocked by the sandbox proxy (HTTP 403), so workflows commit their readable outputs to `results/<phase>/` and Claude reads them after `git pull`.
```bash
git fetch origin main && git merge --ff-only origin/main
```

## Phase 0 (done) - get the official driver out of the TP-Link package (local sandbox)
Sandbox cannot reach static.tp-link.com, so CI workflow `fetch-vendor` downloads the zips and commits them to `vendor/tplink/` (checksums in `SHA256SUMS.txt`).
```bash
apt-get install -y p7zip-full unshield cabextract
unzip -q vendor/tplink/TL-WN722N_V3_180807_Win.zip -d zip
7z x -y -oouter zip/Setup.exe                                   # NSIS outer installer
python3 scripts/extract_installshield.py 'outer/$PLUGINSDIR/Driver Files/Setup.exe' disk1   # InstallShield overlay -> data1.cab/.hdr, data2.cab, setup.inx
unshield -d drv x disk1/data1.cab                               # -> Driver_RTL8188EUS_Win10_64/rtwlanu.sys, netrtwlanu.inf ...
```
Result committed in `vendor/extracted/win180807/` (Win10 x64 + x86 sets only).

## Phase 1 - full decompilation (CI, heavy)
Workflow `phase1-decompile` (manual inputs: `driver`, `tag`). Steps it runs:
```bash
npm install --global rea-agents                       # REA CLI/MCP (Node 22)
# Ghidra 12.1.4 (exact release REA supports) + JDK 21 (temurin)
export GHIDRA_INSTALL_DIR=/opt/ghidra_12.1.4_PUBLIC REA_ANALYSIS_PROVIDER=ghidra
rea doctor --json ; rea providers --json
rea analyze <rtwlanu.sys> --provider ghidra --json --snapshot out/rea_snapshot.json
rea search  <rtwlanu.sys> "Firmware" --provider ghidra --json
$GHIDRA_INSTALL_DIR/support/analyzeHeadless proj p1 -import <rtwlanu.sys> \
   -scriptPath scripts/ghidra -postScript DecompileAll.java out/ghidra -deleteProject
```
Outputs (committed to `results/phase1/<tag>/`): `decompiled.c.gz.part*` (cat + gunzip), `functions.csv.gz`, `callgraph.csv.gz`, `strings.csv.gz`, `externals.csv.gz`, `segments.csv.gz`, REA json outputs, log tail.
Rebuild locally: `cat decompiled.c.gz.part* | gunzip > decompiled.c`.
Note: REA's Ghidra provider documents only non-DLL x86-64 PE applications, so a `.sys` may be rejected by `rea analyze`; the direct Ghidra export is the fallback and the outcome is recorded in the notes.
