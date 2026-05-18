# ECP5 HDMI Audio + Video Transmitter

This project is an **HDMI audio + video transmitter** written in **Verilog-2001** for Lattice ECP5 FPGAs with a GPDI connector. The `rtl/` tree holds the reusable transmitter stack (video timing, TMDS encoding, audio packets, and an ECP5 serializer).

It also includes a small **test application** for two boards:

- **ULX3S** — 25 MHz input clock
- **IcePi Zero** rev 1.2 — 50 MHz input clock @ pin M1

The demo drives **EIA-189A color bars** at 640×480 and a **440 Hz** stereo sine at **48 kHz** over HDMI, so you can verify video and audio on real hardware.

## Prerequisites

```bash
source ~/oss-cad-suite/environment
```

Tools: `yosys`, `nextpnr-ecp5`, `ecppack`, plus a board programmer (`fujprog` or `openFPGALoader`).

## Build and program (test application)

**ULX3S** (25 MHz clock, `fujprog`):

```bash
cd boards/ulx3s
make bitstream
make prog          # SRAM
make prog-flash    # SPI flash
```

**IcePi Zero** rev **1.2** (50 MHz clock @ pin M1, [openFPGALoader](https://github.com/trabucayre/openFPGALoader)):

```bash
cd boards/icepi_zero
make bitstream
make prog          # SRAM
make prog-flash    # SPI flash
```

Connect an HDMI display/TV with speakers to the GPDI port.

## Project layout

| Path | Description |
|------|-------------|
| `rtl/` | HDMI transmitter (`hdmi_*` modules, ported from [hdl-util/hdmi](https://github.com/hdl-util/hdmi)) |
| `boards/common/` | Test-app generators (color bars, sine) |
| `boards/ulx3s/` | ULX3S test top, PLL, LPF, Makefile |
| `boards/icepi_zero/` | IcePi Zero test top, PLL, LPF, Makefile |

## HDMI licensing note

This design is for development and education. Commercial products with HDMI connectors may require HDMI Adopter licensing.

## Attribution

Portions of the HDMI transmitter stack are derived from hdl-util/hdmi:
  https://github.com/hdl-util/hdmi
  SPDX-License-Identifier: MIT OR Apache-2.0
  Copyright (c) Sameer Puri and contributors

ECP5 TMDS serializer adapted from BrunoLevy/learn-fpga ULX3S_hdmi examples.

