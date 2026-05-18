# ULX3S HDMI color bars + 440 Hz tone demo (ECP5-85F, PCB v3.1.7 / v316 LPF)
# Prerequisite: source ~/oss-cad-suite/environment
# Run from: boards/ulx3s

TOP       := ulx3s_top
BUILD     := ../../build/ulx3s
JSON      := $(BUILD)/top.json
CONFIG    := $(BUILD)/top.config
BIT       := $(BUILD)/top.bit
LPF       := ulx3s_v316.lpf
YS        := $(BUILD)/top.ys
SYNTH_YS  := $(BUILD)/synth.ys
YOSYS_DATDIR := $(shell yosys-config --datdir)

PLL_V     := hdmi_pll.v
COMMON_V  := ../common/color_bars.v ../common/sine_gen.v
BOARD_V   := ulx3s_top.v
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
	nextpnr-ecp5 --85k --package CABGA381 --freq 25 \
		--json $(JSON) --lpf $(LPF) --textcfg $(CONFIG)

$(BIT): $(CONFIG)
	ecppack --compress $(CONFIG) $(BIT)

bitstream: $(BIT)

# Program FPGA SRAM (active until power-off; use after each build to test)
prog: $(BIT)
	fujprog $(BIT)

# Program SPI flash (persists across power cycles)
prog-flash: $(BIT)
	fujprog -j flash $(BIT)

clean:
	rm -f $(SYNTH_YS) $(JSON) $(CONFIG) $(BIT)
