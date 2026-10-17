# Strategy

## Core facts
- The TL-WN722N v3 is a **SoftMAC USB** adapter (Realtek RTL8188EUS). The chip does not run the 802.11 stack; the
  driver builds frames and runs the MAC logic. So a Windows driver must implement a lot, not just forward packets.
- An x86 `.sys` cannot be loaded on ARM64. A kernel driver has to be **recompiled/rewritten** for ARM64. No emulation
  path exists for kernel drivers.
- The official driver is a *reference for hardware behaviour* (init sequence, firmware, descriptors), not code to
  re-use directly. Linux sources (rtl8xxxu, aircrack-ng rtl8188eus) are the open-source reference for the same.
- Windows driver model for new Wi-Fi: **WiFiCx** (WDF class extension, WDI-based) on KMDF/NetAdapterCx.

## Approach
1. Learn the hardware from three independent sources: official binary (RE), Linux source, live USB trace.
   Facts confirmed by 2+ sources go into `docs/hw/`.
2. Build only on CI (GitHub Actions, windows runner with WDK, ARM64 target). Nothing is compiled on the user's PCs.
3. Test only on real hardware (Pi), automatically via MCP server, so no human steps.
4. Small vertical slices: device attach -> EFUSE/MAC -> firmware -> scan -> connect -> data.

## Language decision (Rust vs C/C++)
- Rust: hardware protocol layer, parsers, the MCP server, RE helper tools. Kernel Rust on Windows uses
  `windows-drivers-rs` (KMDF). It has no WiFiCx bindings.
- C/C++: WiFiCx / NetAdapterCx glue (headers are C/C++ only).
- Decision point at Phase 4: try a Rust `no_std` hardware core behind a C ABI; fall back to plain C++ if ARM64 CI
  cannot build it. The result is recorded here.

## Remote control (Phase M)
Rust MCP server over HTTP, exposed by a Cloudflare quick tunnel (no signup, free). Security: long random token in the
URL path, bind 127.0.0.1 only, tool allow-list logging, token rotation script. Added to Claude as a custom connector.
It controls the user's own test machines only.

## Risks
- Kernel driver bugs can BSOD the Pi: test only the Pi USB drive install, never the NUC; keep Ethernet untouched.
- Test-signing only; no production signing.
- Firmware blob redistribution: take it from the user's official driver package, do not republish it blindly.
