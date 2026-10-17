# wor-drivers-lab

Missing Windows 11 ARM64 drivers for the Raspberry Pi 400 (Windows on Raspberry), built with AI-driven reverse
engineering, GitHub CI for the heavy compute, and real hardware for testing.

**Target 1 (first): TP-Link TL-WN722N v3** (Realtek RTL8188EUS, USB 2357:010C). TP-Link ships a Windows driver for
x86/x64 only. Goal: a native Win11 ARM64 Wi-Fi driver.

Later targets: audio, GPU acceleration, others from the WoR "not working" list.

## Hardware
| Role | Device |
| --- | --- |
| Target | Raspberry Pi 400, Win11 ARM64 (WoR) on a separate USB drive, test-signing ON |
| Reference | Intel NUC, Windows 11 x64 + Wireshark (USBPcap) |
| Adapter | TP-Link TL-WN722N v3 |
| Compute | GitHub Actions (build, reverse engineering) |
| Brain | Claude |

## Docs (start here)
- [docs/PHASES.md](docs/PHASES.md) - multi-phase plan and status
- [docs/STRATEGY.md](docs/STRATEGY.md) - why this approach
- [docs/METHODOLOGY.md](docs/METHODOLOGY.md) - how each phase is done and verified
- [docs/TECHNIQUES.md](docs/TECHNIQUES.md) - RE and driver techniques used
- [docs/TOOLS.md](docs/TOOLS.md) - every tool, version, purpose
- [docs/COMMANDS.md](docs/COMMANDS.md) - full commands, copy-paste
- [docs/CHRONOLOGY.md](docs/CHRONOLOGY.md) - dated timeline
- [docs/SOURCES.md](docs/SOURCES.md) - links and references
- [docs/log/](docs/log/) - per-day session logs

## Rules for this repo
1. Everything done is documented the same day (tool, full command, result, timestamp).
2. Fresh repo: nothing is imported from older experiments.
3. Rust where it is practical, otherwise C/C++ (WiFiCx glue), decision recorded in STRATEGY.md.
