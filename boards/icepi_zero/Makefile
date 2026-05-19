# IcePi Zero HDMI color bars + 440 Hz tone demo (ECP5-25F, CABGA256)
# Prerequisite: source ~/oss-cad-suite/environment
# Run from: boards/icepi_zero

TOP       := icepi_zero_top
VIC       ?= 1
SUPPORTED_VICS := 0 1 4 34

ifneq ($(filter $(VIC),$(SUPPORTED_VICS)),$(VIC))
  $(error Unsupported VIC=$(VIC). Supported: $(SUPPORTED_VICS))
endif

BUILD     := ../../build/icepi_zero/vic$(VIC)
JSON      := $(BUILD)/top.json
CONFIG    := $(BUILD)/top.config
BIT       := $(BUILD)/top.bit
LPF       := icepi_zero.lpf
SYNTH_YS  := $(BUILD)/synth.ys
YOSYS_DATDIR := $(shell yosys-config --datdir)

OPENFPGA_LOADER ?= openFPGALoader
OFL_CABLE       ?= -cft231X --pins=7:3:5:6

ifeq ($(VIC),1)
  PLL_V         := hdmi_pll.v
  YOSYS_DEFINES :=
else ifeq ($(VIC),0)
  PLL_V         := hdmi_pll_50.v
  YOSYS_DEFINES := -DVIC_0
else
  PLL_V         := hdmi_pll_hd.v
  YOSYS_DEFINES := -DVIC_$(VIC)
endif

COMMON_V  := ../common/color_bars.v ../common/sine_gen.v
BOARD_V   := icepi_zero_top.v
BOARD_SRC := $(PLL_V) $(BOARD_V) $(COMMON_V)
RTL_V     := $(wildcard ../../rtl/*.v)

.PHONY: all bitstream prog prog-flash clean

all: bitstream

$(SYNTH_YS): $(BOARD_SRC) $(RTL_V) ../common/video_config.vh Makefile
	mkdir -p $(BUILD)
	@echo 'read_verilog -lib $(YOSYS_DATDIR)/lattice/cells_bb_ecp5.v' > $(SYNTH_YS)
	@if [ -n "$(YOSYS_DEFINES)" ]; then \
		echo 'verilog_defaults -add $(YOSYS_DEFINES)' >> $(SYNTH_YS); \
	fi
	@echo 'read_verilog ../../../boards/icepi_zero/$(PLL_V)' >> $(SYNTH_YS)
	@echo 'read_verilog ../../../boards/common/color_bars.v' >> $(SYNTH_YS)
	@echo 'read_verilog ../../../boards/common/sine_gen.v' >> $(SYNTH_YS)
	@echo 'read_verilog ../../../boards/icepi_zero/icepi_zero_top.v' >> $(SYNTH_YS)
	@for f in ../../rtl/*.v; do echo "read_verilog ../../../rtl/$$(basename $$f)" >> $(SYNTH_YS); done
	@echo 'hierarchy -check -top icepi_zero_top' >> $(SYNTH_YS)
	@echo 'synth_ecp5 -top icepi_zero_top' >> $(SYNTH_YS)
	@echo 'write_json top.json' >> $(SYNTH_YS)

$(JSON): $(SYNTH_YS)
	cd $(BUILD) && yosys -q synth.ys

ifeq ($(VIC),1)
  NEXTPNR_EXTRA :=
else
  NEXTPNR_EXTRA := --randomize-seed --timing-allow-fail
endif

$(CONFIG): $(JSON) $(LPF)
	nextpnr-ecp5 --25k --package CABGA256 $(NEXTPNR_EXTRA) \
		--json $(JSON) --lpf $(LPF) --textcfg $(CONFIG)

$(BIT): $(CONFIG)
	ecppack --compress $(CONFIG) $(BIT)

bitstream: $(BIT)

prog: $(BIT)
	$(OPENFPGA_LOADER) $(OFL_CABLE) $(BIT)

prog-flash: $(BIT)
	$(OPENFPGA_LOADER) $(OFL_CABLE) $(BIT) --write-flash

clean:
	rm -rf ../../build/icepi_zero
