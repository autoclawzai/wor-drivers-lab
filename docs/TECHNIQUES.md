# Techniques

| Technique | Used for | Phase |
| --- | --- | --- |
| Package inventory (hashes, INF parse, PE headers, imports, strings) | find USB IDs, driver model, firmware | 0 |
| Static decompilation with Ghidra (headless, via `rea`) | init sequences, register writes, descriptor layout | 1 |
| Firmware extraction from driver data sections | RTL8188E firmware image + header | 1 |
| Diffing against Linux driver tables | confirm register map and init order | 2 |
| USB capture (Wireshark + USBPcap, filter by device) | golden trace of control transfers and bulk traffic | 3 |
| Replay of recorded control transfers | prove init sequence on real HW before writing a driver | 3-4 |
| WDK build on CI for ARM64, test-signed | produce installable driver | 4 |
| Registry `Log_*` counters, ETW/WPP tracing | observe the driver on the Pi without a debugger | 4-6 |
| MCP remote run of scripts on the Pi | automated, human-free testing | M |
