// SPDX-License-Identifier: MIT
// PLL: 25 MHz in -> 50 MHz pixel, 250 MHz serial (5x) — VIC 0 (1024x600)
// ecppll -n hdmi_pll -i 100 -o 250 --clkout1 50 --clkout2 250

module hdmi_pll
(
    input  wire clk_in,
    output wire clk_pixel,
    output wire clk_serial,
    output wire clk_pixel_buf,
    output locked
);

    wire clkfb;
    wire clk_op_unused;
    
(* FREQUENCY_PIN_CLKI="100" *)
(* FREQUENCY_PIN_CLKOP="250" *)
(* FREQUENCY_PIN_CLKOS="50" *)
(* FREQUENCY_PIN_CLKOS2="250" *)
(* ICP_CURRENT="12" *) (* LPF_RESISTOR="8" *) (* MFG_ENABLE_FILTEROPAMP="1" *) (* MFG_GMCREF_SEL="2" *)
EHXPLLL #(
        .PLLRST_ENA("DISABLED"),
        .INTFB_WAKE("DISABLED"),
        .STDBY_ENABLE("DISABLED"),
        .DPHASE_SOURCE("DISABLED"),
        .OUTDIVIDER_MUXA("DIVA"),
        .OUTDIVIDER_MUXB("DIVB"),
        .OUTDIVIDER_MUXC("DIVC"),
        .OUTDIVIDER_MUXD("DIVD"),
        .CLKI_DIV(2),
        .CLKOP_ENABLE("ENABLED"),
        .CLKOP_DIV(2),
        .CLKOP_CPHASE(0),
        .CLKOP_FPHASE(0),
        .CLKOS_ENABLE("ENABLED"),
        .CLKOS_DIV(10),
        .CLKOS_CPHASE(0),
        .CLKOS_FPHASE(0),
        .CLKOS2_ENABLE("ENABLED"),
        .CLKOS2_DIV(2),
        .CLKOS2_CPHASE(0),
        .CLKOS2_FPHASE(0),
        .FEEDBK_PATH("CLKOP"),
        .CLKFB_DIV(5)
    ) pll_i (
        .RST(1'b0),
        .STDBY(1'b0),
        .CLKI(clk_in),
        .CLKOP(clk_op_unused),
        .CLKOS(clk_pixel_buf),
        .CLKOS2(clk_serial),
        .CLKFB(clk_op_unused),
        .CLKINTFB(),
        .PHASESEL0(1'b0),
        .PHASESEL1(1'b0),
        .PHASEDIR(1'b1),
        .PHASESTEP(1'b1),
        .PHASELOADREG(1'b1),
        .PLLWAKESYNC(1'b0),
        .ENCLKOP(1'b0),
        .LOCK(locked)
        );

    assign clk_pixel = clk_pixel_buf;

endmodule
