# Sources

## Hardware
- TL-WN722N v3 support: https://www.tp-link.com/in/support/download/tl-wn722n/v3/
- Datasheet (US V3): https://static.tp-link.com/2020/202010/20201019/TL-WN722N(EU&US)_3.0_datasheet.pdf
- Official Windows driver (180807): https://static.tp-link.com/2018/201808/20180820/TL-WN722N(EUUSES)_V3_180807_Win.zip
- Official Linux driver (beta, monitor mode on Ubuntu/Mint): https://static.tp-link.com/2018/201805/20180521/TP-Link_Driver_Linux_series7_beta.zip
- Newer official Win10/11 build listed by TP-Link: `TL-WN722N(EU)_V3_190409_Win10/11` (2019-04-18, 37.65 MB, Win10/11 32/64-bit)

## Open-source Realtek references
- aircrack-ng/rtl8188eus (monitor mode + injection): https://github.com/aircrack-ng/rtl8188eus
- Linux kernel `rtl8xxxu` (in-tree)

## Windows on Raspberry
- Install guide: https://worproject.com/guides/how-to-install/from-windows
- Prebuilt drivers: https://github.com/worproject/RPi-Windows-Drivers/releases (repo archived 2025-02-04, releases only)
- Driver status: https://github.com/worproject/RPi-Windows-Drivers
  - Pi 4/400: Wi-Fi (CYW43455) not working, VC4 GPU not working (roskmd loads but unfinished), HDMI audio partial, audio jack working, Ethernet GENET working, basic display working.
- Source for some drivers: https://github.com/raspberrypi/windows-drivers
- UEFI: https://github.com/pftf/RPi4/releases

## Tools
- rea: https://github.com/morluto/rea
- Claude custom connector page: https://claude.ai/customize/connectors?modal=add-custom-connector

## Windows Wi-Fi driver model
- WiFiCx intro: https://learn.microsoft.com/windows-hardware/drivers/netcx/wifi-wdf-class-extension-wificx
- WDI miniport design guide: https://learn.microsoft.com/windows-hardware/drivers/network/wdi-miniport-driver-design-guide
