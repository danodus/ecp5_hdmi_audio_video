# IcePi Zero HDMI color bars + 440 Hz tone demo (ECP5-25F, CABGA256)
# Prerequisite: source ~/oss-cad-suite/environment
# Run from: boards/icepi_zero

TOP       := icepi_zero_top
BUILD     := ../../build/icepi_zero
JSON      := $(BUILD)/top.json
CONFIG    := $(BUILD)/top.config
BIT       := $(BUILD)/top.bit
LPF       := icepi_zero.lpf
YS        := $(BUILD)/top.ys
SYNTH_YS  := $(BUILD)/synth.ys
YOSYS_DATDIR := $(shell yosys-config --datdir)

OPENFPGA_LOADER ?= openFPGALoader
OFL_CABLE       ?= -cft231X --pins=7:3:5:6

PLL_V     := hdmi_pll.v
COMMON_V  := ../common/color_bars.v ../common/sine_gen.v
BOARD_V   := icepi_zero_top.v
BOARD_SRC := $(PLL_V) $(BOARD_V) $(COMMON_V)
RTL_V     := $(wildcard ../../rtl/*.v)

.PHONY: all bitstream prog prog-flash clean

all: bitstream

$(SYNTH_YS): $(YS) $(BOARD_SRC) $(RTL_V)
	mkdir -p $(BUILD)
	@echo 'read_verilog -lib $(YOSYS_DATDIR)/lattice/cells_bb_ecp5.v' > $(SYNTH_YS)
	@cat $(YS) >> $(SYNTH_YS)

$(JSON): $(SYNTH_YS)
	cd $(BUILD) && yosys -q synth.ys

$(CONFIG): $(JSON) $(LPF)
	nextpnr-ecp5 --25k --package CABGA256 \
		--json $(JSON) --lpf $(LPF) --textcfg $(CONFIG)

$(BIT): $(CONFIG)
	ecppack --compress $(CONFIG) $(BIT)

bitstream: $(BIT)

# Program FPGA SRAM (lost on power-off)
prog: $(BIT)
	$(OPENFPGA_LOADER) $(OFL_CABLE) $(BIT)

# Program SPI flash (persists across power cycles)
prog-flash: $(BIT)
	$(OPENFPGA_LOADER) $(OFL_CABLE) $(BIT) --write-flash

clean:
	rm -f $(SYNTH_YS) $(JSON) $(CONFIG) $(BIT)
