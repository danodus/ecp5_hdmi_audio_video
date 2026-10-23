# ECP5 HDMI Audio + Video Transmitter

This project is an **HDMI audio + video transmitter** written in **Verilog-2001** for Lattice ECP5 FPGAs with a GPDI connector. The `rtl/` tree holds the reusable transmitter stack (video timing, TMDS encoding, audio packets, and an ECP5 serializer).

It also includes a small **test application** for two boards:

- **ULX3S** — 25 MHz input clock
- **IcePi Zero** rev 1.2 — 50 MHz input clock @ pin M1

The demo drives **EIA-189A color bars** and a **440 Hz** stereo sine at **48 kHz** over HDMI (same audio pitch in every video mode).

## Prerequisites

```bash
source ~/oss-cad-suite/environment
```

Tools: `yosys`, `nextpnr-ecp5`, `ecppack`, plus a board programmer (`fujprog` or `openFPGALoader`).

## Supported video modes (VIC)

Select the mode with **`VIC=<n>`** when building. Default is **VIC=1**.

| VIC | Resolution | Refresh rate | Pixel clock | `make` example |
|-----|------------|--------------|-------------|----------------|
| **0** | 1024×600 (custom) | ~61 Hz | 50 MHz | `make VIC=0 bitstream` |
| **1** (default) | 640×480 | 60 Hz | 25.2 MHz | `make bitstream` |
| **4** | 1280×720 | ~60 Hz | ~74 MHz | `make VIC=4 bitstream` |
| **34** | 1920×1080 | ~30 Hz | ~74 MHz | `make VIC=34 bitstream` |

**VIC 0** is a non-CEA 1024×600 mode; the AVI infoframe reports VIC 0. It uses `hdmi_pll_50.v` (50 MHz pixel, 250 MHz serial).

VIC 4 and 34 share `hdmi_pll_hd.v` (~74 MHz pixel, close to the CEA nominal 74.25 MHz). Bitstreams are written under `build/<board>/vic<n>/`. VIC 0, 4, and 34 use `--timing-allow-fail` on the TMDS serial clock; if needed, run `make clean && make VIC=4 bitstream` again (random seed).

Audio: **440 Hz** test tone at **48 kHz** LPCM in all modes. `CLK_HZ` in [`boards/common/video_config.vh`](boards/common/video_config.vh) must match the PLL pixel clock so the sample rate stays 48 kHz.

## Build and program (test application)

**ULX3S** (25 MHz clock, `fujprog`):

```bash
cd boards/ulx3s
make VIC=0 prog             # 1024x600 custom
make VIC=1 prog             # 640x480 60Hz
make VIC=4 prog             # 720p 60Hz
make VIC=34 prog            # 1080p 30Hz
make VIC=1 prog-flash       # 640x480 60Hz SPI flash
```

**IcePi Zero** rev **1.2** (50 MHz clock @ pin M1, [openFPGALoader](https://github.com/trabucayre/openFPGALoader)):

```bash
cd boards/icepi_zero
make VIC=0 prog             # 1024x600 custom
make VIC=1 prog             # 640x480 60Hz
make VIC=4 prog             # 720p 60Hz
make VIC=34 prog            # 1080p 30Hz
make VIC=1 prog-flash       # 640x480 60Hz SPI flash
```

Connect an HDMI display/TV with speakers to the GPDI port.

## Project layout

| Path | Description |
|------|-------------|
| `rtl/` | HDMI transmitter (`hdmi_*` modules, ported from [hdl-util/hdmi](https://github.com/hdl-util/hdmi)) |
| `boards/common/` | Test-app generators (color bars, sine), `video_config.vh` per VIC |
| `boards/ulx3s/` | ULX3S test top, PLLs, LPF, Makefile |
| `boards/icepi_zero/` | IcePi Zero test top, PLLs, LPF, Makefile |

## HDMI Licensing and Compliance Disclaimer

**This gateware IP design is provided strictly for educational, research, and prototyping purposes.** 

HDMI is a proprietary technology managed by HDMI Licensing Administrator, Inc. (HDMI LA), and is subject to strict patent and trademark licensing agreements. While developers are legally permitted to use this repository for benchtop development, testing, and academic evaluation:

1. **Commercial Product Liability:** Any entity that incorporates this design into a physical commercial product sold to end-users assumes full and exclusive legal responsibility for HDMI licensing. The manufacturer of the finished end-user device must be an official, licensed HDMI Adopter and pay all applicable annual fees and per-unit royalties.
2. **The "GPDI / DVI" Naming Exception:** Labeling a physical physical connector as "GPDI" (General-Purpose Differential Interface), "Digital Video," or "DVI" on a PCB does **not** exempt a commercial product from HDMI licensing if the underlying hardware transmits proprietary HDMI data packets, info-frames, or audio streams to standard consumer displays. 
3. **Compliance Testing:** Any commercial hardware utilizing this implementation must fully satisfy the requirements defined in the HDMI Adopter Agreement, including mandatory compliance testing at an Authorized Test Center (ATC) or authorized self-testing.

The author of this repository accepts no liability for patent or trademark infringement resulting from the unauthorized or unlicensed commercial distribution of physical hardware utilizing this source code.

## Attribution

Portions of the HDMI transmitter stack are derived from hdl-util/hdmi:
  https://github.com/hdl-util/hdmi
  SPDX-License-Identifier: MIT OR Apache-2.0
  Copyright (c) Sameer Puri and contributors

ECP5 TMDS serializer adapted from BrunoLevy/learn-fpga ULX3S_hdmi examples.
