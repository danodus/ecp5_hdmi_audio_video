// SPDX-License-Identifier: MIT
// PLL: 25 MHz in -> ~74 MHz pixel, ~370 MHz serial (5x) — VIC 4 / 34
// ecppll -n hdmi_pll -i 100 -o 370 --clkout1 370 --clkout2 74

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
(* FREQUENCY_PIN_CLKOP="370" *)
(* FREQUENCY_PIN_CLKOS="370" *)
(* FREQUENCY_PIN_CLKOS2="74" *)
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
        .CLKI_DIV(10),
        .CLKOP_ENABLE("ENABLED"),
        .CLKOP_DIV(2),
        .CLKOP_CPHASE(1),
        .CLKOP_FPHASE(0),
        .CLKOS_ENABLE("ENABLED"),
        .CLKOS_DIV(2),
        .CLKOS_CPHASE(1),
        .CLKOS_FPHASE(0),
        .CLKOS2_ENABLE("ENABLED"),
        .CLKOS2_DIV(10),
        .CLKOS2_CPHASE(1),
        .CLKOS2_FPHASE(0),
        .FEEDBK_PATH("CLKOP"),
        .CLKFB_DIV(37)
    ) pll_i (
        .RST(1'b0),
        .STDBY(1'b0),
        .CLKI(clk_in),
        .CLKOP(clk_op_unused),
        .CLKOS(clk_serial),
        .CLKOS2(clk_pixel),
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
