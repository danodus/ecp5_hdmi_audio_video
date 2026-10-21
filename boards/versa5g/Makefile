# versa5g HDMI color bars + 440 Hz tone demo (ECP5-85F, PCB v3.1.7 / v316 LPF)
# Prerequisite: source ~/oss-cad-suite/environment
# Run from: boards/versa5g

TOP       := versa5g_top
VIC       ?= 1
SUPPORTED_VICS := 0 1 4 34

ifneq ($(filter $(VIC),$(SUPPORTED_VICS)),$(VIC))
  $(error Unsupported VIC=$(VIC). Supported: $(SUPPORTED_VICS))
endif

BUILD     := ../../build/versa5g/vic$(VIC)
JSON      := $(BUILD)/top.json
CONFIG    := $(BUILD)/top.config
BIT       := $(BUILD)/top.bit
LPF       := versa5g.lpf

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
BOARD_V   := versa5g_top.v
BOARD_SRC := $(PLL_V) $(BOARD_V) $(COMMON_V)
RTL_V     := $(wildcard ../../rtl/*.v)

OBJS := $(BOARD_SRC) $(RTL_V)

OBJS_REALPATH := $(realpath $(OBJS))
 
.PHONY: all bitstream prog prog-flash clean

all: bitstream

$(JSON): $(OBJS_REALPATH)
	mkdir -p $(BUILD)
	cd $(BUILD) && yosys -p "synth_ecp5 -top versa5g_top -json top.json" $(OBJS_REALPATH) 

ifeq ($(VIC),1)
  NEXTPNR_EXTRA :=
else
  NEXTPNR_EXTRA := --randomize-seed --timing-allow-fail
endif

$(CONFIG): $(JSON) $(LPF)
	nextpnr-ecp5 --um5g-45k --package CABGA381 --speed 8 $(NEXTPNR_EXTRA) \
		--json $(JSON) --lpf $(LPF) --textcfg $(CONFIG)

$(BIT): $(CONFIG)
	ecppack --compress $(CONFIG) $(BIT)

bitstream: $(BIT)

prog: $(BIT)
	openFPGALoader $(BIT).bit

prog-flash: $(BIT)
	openFPGALoader -f $(BIT).bit

clean:
	rm -rf ../../build/versa5g
