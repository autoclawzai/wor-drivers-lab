# Chronology

## 2026-10-18 (Sunday)
- Fresh start decided: new repo `autoclawzai/wor-drivers-lab`; older experimental repo ignored.
- Claude cannot create GitHub repos from its session (API blocked: sessions bound to configured repos); user created the empty repo, Claude attached it.
- Phase 0 started: read `rea` README (MCP/CLI over Ghidra/Hopper/IDA, Node >= 22), confirmed WoR status (Wi-Fi/GPU not working on Pi 4/400), found Linux references (aircrack-ng/rtl8188eus), WiFiCx as target driver model.
- Docs skeleton + Phase 0 CI workflow written (see `docs/log/2026-10-18.md`).
- Phase 0 CI inventory ran (ubuntu): Windows zip = NSIS installer -> nested InstallShield exe (7z cannot open it). Linux zip = official Realtek source `rtl8188EUS_linux_v5.2.2.4_25483.20171222`.
- Sandbox cannot reach static.tp-link.com (proxy 403) and cannot download CI artifacts/logs (403). Decision with user: CI only for heavy work (and for the one TP-Link download), everything else in the sandbox.
- `fetch-vendor` CI committed 4 official zips into `vendor/tplink/`.
- Wrote `scripts/extract_installshield.py` (overlay parser) and extracted the driver locally: `rtwlanu.sys` Win10 x64 (5,395,504 B, machine 0x8664) and x86, `netrtwlanu.inf` (DriverVer 09/06/2016, 1030.9.0303.2016, Realtek multi-chip INF), `Rtlihvs.dll`, `RtlExtUI.dll`, `rtlCoInst.dll`, TX power tables.
- A Windows-runner extraction attempt (phase0c) hung on the GUI installer and was cancelled; superseded by the local method.
