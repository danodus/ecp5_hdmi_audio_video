# ULX3S HDMI color bars + 440 Hz tone demo (ECP5-85F, PCB v3.1.7 / v316 LPF)
# Prerequisite: source ~/oss-cad-suite/environment
# Run from: boards/ulx3s

TOP       := ulx3s_top
VIC       ?= 1
SUPPORTED_VICS := 1 4 34

ifneq ($(filter $(VIC),$(SUPPORTED_VICS)),$(VIC))
  $(error Unsupported VIC=$(VIC). Supported: $(SUPPORTED_VICS))
endif

BUILD     := ../../build/ulx3s/vic$(VIC)
JSON      := $(BUILD)/top.json
CONFIG    := $(BUILD)/top.config
BIT       := $(BUILD)/top.bit
LPF       := ulx3s_v316.lpf
SYNTH_YS  := $(BUILD)/synth.ys
YOSYS_DATDIR := $(shell yosys-config --datdir)

ifeq ($(VIC),1)
  PLL_V         := hdmi_pll.v
  YOSYS_DEFINES :=
else
  PLL_V         := hdmi_pll_hd.v
  YOSYS_DEFINES := -DVIC_$(VIC)
endif

COMMON_V  := ../common/color_bars.v ../common/sine_gen.v
BOARD_V   := ulx3s_top.v
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
	@echo 'read_verilog ../../../boards/ulx3s/$(PLL_V)' >> $(SYNTH_YS)
	@echo 'read_verilog ../../../boards/common/color_bars.v' >> $(SYNTH_YS)
	@echo 'read_verilog ../../../boards/common/sine_gen.v' >> $(SYNTH_YS)
	@echo 'read_verilog ../../../boards/ulx3s/ulx3s_top.v' >> $(SYNTH_YS)
	@for f in ../../rtl/*.v; do echo "read_verilog ../../../rtl/$$(basename $$f)" >> $(SYNTH_YS); done
	@echo 'hierarchy -check -top ulx3s_top' >> $(SYNTH_YS)
	@echo 'synth_ecp5 -top ulx3s_top' >> $(SYNTH_YS)
	@echo 'write_json top.json' >> $(SYNTH_YS)

$(JSON): $(SYNTH_YS)
	cd $(BUILD) && yosys -q synth.ys

ifeq ($(VIC),1)
  NEXTPNR_EXTRA :=
else
  NEXTPNR_EXTRA := --randomize-seed --timing-allow-fail
endif

$(CONFIG): $(JSON) $(LPF)
	nextpnr-ecp5 --85k --package CABGA381 --freq 25 $(NEXTPNR_EXTRA) \
		--json $(JSON) --lpf $(LPF) --textcfg $(CONFIG)

$(BIT): $(CONFIG)
	ecppack --compress $(CONFIG) $(BIT)

bitstream: $(BIT)

prog: $(BIT)
	fujprog $(BIT)

prog-flash: $(BIT)
	fujprog -j flash $(BIT)

clean:
	rm -rf ../../build/ulx3s
