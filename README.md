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

## Supported video modes (CEA VIC)

Select the mode with **`VIC=<n>`** when building. Default is **VIC=1**.

| VIC | Resolution | Refresh rate | Pixel clock | `make` example |
|-----|------------|--------------|-------------|----------------|
| **1** (default) | 640×480 | 60 Hz | 25.2 MHz | `make bitstream` |
| **4** | 1280×720 | ~60 Hz | ~74 MHz | `make VIC=4 bitstream` |
| **34** | 1920×1080 | ~30 Hz | ~74 MHz | `make VIC=34 bitstream` |

VIC 4 and 34 share the same HD PLL (~74 MHz pixel, close to the CEA nominal 74.25 MHz). Bitstreams are written under `build/<board>/vic<n>/`. HD builds use `--timing-allow-fail` on the TMDS serial clock; if needed, run `make clean && make VIC=4 bitstream` again (random seed).

Audio: **440 Hz** test tone at **48 kHz** LPCM in all modes. `CLK_HZ` in [`boards/common/video_config.vh`](boards/common/video_config.vh) must match the PLL pixel clock so the sample rate stays 48 kHz.

## Build and program (test application)

**ULX3S** (25 MHz clock, `fujprog`):

```bash
cd boards/ulx3s
make VIC=1 prog             # 640x480 60Hz
make VIC=4 prog             # 720p 60Hz
make VIC=34 prog            # 1080p 30Hz
make VIC=1 prog-flash       # 640x480 60Hz SPI flash
```

**IcePi Zero** rev **1.2** (50 MHz clock @ pin M1, [openFPGALoader](https://github.com/trabucayre/openFPGALoader)):

```bash
cd boards/icepi_zero
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

## HDMI licensing note

This design is for development and education. Commercial products with HDMI connectors may require HDMI Adopter licensing.

## Attribution

Portions of the HDMI transmitter stack are derived from hdl-util/hdmi:
  https://github.com/hdl-util/hdmi
  SPDX-License-Identifier: MIT OR Apache-2.0
  Copyright (c) Sameer Puri and contributors

ECP5 TMDS serializer adapted from BrunoLevy/learn-fpga ULX3S_hdmi examples.
