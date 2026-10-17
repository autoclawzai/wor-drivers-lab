# Tools

| Tool | Purpose | Where it runs |
| --- | --- | --- |
| GitHub Actions | compile, download packages, reverse engineering | cloud |
| `rea` (morluto/rea, `npm i -g rea-agents`) | MCP/CLI over Ghidra/Hopper/IDA for binary analysis. Needs Node >= 22 and Ghidra. README does not claim kernel-driver/ARM64 specifics; we use it on x86 PE first. | CI / sandbox |
| Ghidra (headless) | decompile official `.sys` | CI |
| Python `pefile`, `lief` | PE headers, imports, resources | CI |
| 7-Zip, `unzip`, `strings`, `sha256sum` | unpack and inventory | CI |
| WDK (windows-2022 runner) + MSBuild | build ARM64 drivers | CI |
| Rust (`windows-drivers-rs`, `cargo`) | driver core, MCP server | CI |
| Wireshark + USBPcap | USB trace on the NUC | NUC |
| `cloudflared` | free no-signup tunnel for the MCP server | Pi / NUC |
| Claude (custom MCP connector) | brain, drives everything | cloud |

Versions are recorded in the CI logs and copied here when a tool is first used.
