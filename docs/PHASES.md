# Phases

Status: `todo` / `doing` / `done`. Updated every session.

| # | Phase | Output | Status |
| --- | --- | --- | --- |
| 0 | Recon: chip ID, collect official drivers, open-source references, WoR driver status | `vendor/`, `docs/re/00-official-driver-recon.md` | done |
| 1 | Static RE of the official driver (radare2/Ghidra, `rea`): INF, USB endpoints, init sequence, firmware blob, TX/RX descriptors | `docs/re/` notes + extracted tables | doing |
| 2 | Cross-reference with Linux drivers (rtl8xxxu / aircrack-ng rtl8188eus): register map, EFUSE, firmware load, rate table | `docs/hw/rtl8188eus.md` | todo |
| 3 | Golden trace: Wireshark USBPcap on the NUC while the official driver initializes and connects | `traces/*.pcapng` + analysis | todo |
| 4 | ARM64 driver skeleton on CI (WDK, KMDF + WiFiCx), loads on the Pi in test mode, USB device attach, EFUSE/MAC read | signed test build | todo |
| 5 | Bring-up: firmware, scan, connect (open, WPA2), data path | working Wi-Fi | todo |
| 6 | Stability + speed: reconnect stress, sleep/resume, throughput | release `v0.1` | todo |
| M | Remote test MCP server (Rust) + Cloudflare quick tunnel + token auth, runs on Pi and NUC | `mcp/` | todo |
| 7 | Next drivers: audio, GPU (same method) | per-driver docs | todo |

Phase M runs in parallel from the start of Phase 4, so real tests need no human steps.

## Exit criteria per phase
Each phase ends with: results documented, commands recorded in `docs/COMMANDS.md`, entry in `docs/CHRONOLOGY.md`, committed.
