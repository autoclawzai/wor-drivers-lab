# Official driver recon (TP-Link TL-WN722N v3, package 180807)

All facts below are `[RE]` (static, from the extracted files in `vendor/extracted/win180807/`).

## Package layout
- `Setup.exe` (NSIS) -> `Driver Files/Setup.exe` (InstallShield, files stored raw in the PE overlay) -> `data1.cab`/`data2.cab`.
- Driver sets: XP, Win7, Win8, Win8.1, Win10, each 32/64-bit. We use `Driver_RTL8188EUS_Win10_64` (x64) and `_32`.
- Same package also contains the Realtek `Rtlihvs.dll` (IHV extension), `RtlExtUI.dll`, `rtlCoInst.dll`, `TP_TXPWR_LMT_Enc.txt`, `TP_PHY_REG_PG_Enc.txt` (encrypted TX power limit / PHY tables).

## INF (`netrtwlanu.inf`, DriverVer 09/06/2016, 1030.9.0303.2016)
- Class Net, Provider TP-Link, multi-chip Realtek INF (8188EU, 8192EU, 8811AU, ...).
- **`USB\VID_2357&PID_010C` -> section `TplinkDisTxPwrTrain_RTL8188eu.ndi`** (TL-WN722N v3). Generic RTL8188EU IDs 0BDA:8179 / 0179 / A179 map to `RTL8188eu.ndi`.

## `rtwlanu.sys` (Win10 x64, 5,395,504 B, machine 0x8664)
- Built from `...\Windows_Server\v1030.8\PLATFORM\NDIS6\USB\obj\x64\rtwlanu.pdb` (path string).
- Imports: ntoskrnl (62), HAL (2), **NDIS.SYS (49)**, WDFLDR (4). Uses `NdisMDeregisterWdiMiniportDriver` -> it is an **NDIS 6 / WDI (Native Wi-Fi) miniport**, i.e. it implements the full WDI command set itself, on top of KMDF for USB.
- Sections: `.text` 2.9 MB, `.data` 2.1 MB (large: firmware arrays and register tables live here), `.rdata`, `.pdata`, `PAGE`, `INIT`.
- Strings: "Firmware for NIC", "Firmware for NIC BT", "Firmware for WoWLAN", FW_DEBUG_TRACE, P2P provision-discovery handlers (N63C...).

## What this means for the port
- The x86/x64 binary cannot run on ARM64; the code must be rewritten/recompiled for ARM64.
- The official driver is WDI; the modern route for us is **WiFiCx** (simpler than raw WDI, supported on Win11 ARM64).
- Hardware knowledge needed from the binary: firmware image (in `.data`), register init tables, TX/RX descriptor formats, EFUSE layout, TX-power tables (encrypted `.txt` files; TP-Link specific).
- The Linux package contains the full vendor source (`rtl8188EUS_linux_v5.2.2.4_25483.20171222`, in `vendor/tplink/TL-WN722N_V3_180510_Linux_beta.zip`) and aircrack-ng/rtl8188eus is a maintained fork: use as the primary readable reference, confirm with the binary.

## Next (Phase 1)
1. Locate the RTL8188E firmware array in `.data` (compare with `rtl8188e` firmware in the Linux source) and extract it.
2. Dump register init tables (MAC/BB/RF/AGC) and compare with Linux.
3. Decompile with radare2 (sandbox) / Ghidra via CI only if needed.
