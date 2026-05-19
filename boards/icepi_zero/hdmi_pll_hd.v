// SPDX-License-Identifier: MIT
// PLL: 50 MHz in -> ~74 MHz pixel, ~370 MHz serial (5x) — VIC 4 / 34

module hdmi_pll (
    input  wire clk_in,
    output wire clk_pixel,
    output wire clk_serial,
    output wire clk_pixel_buf
);

    wire clkfb;
    wire clk_op_unused;

    (* ICP_CURRENT="12" *) (* LPF_RESISTOR="8" *)
    (* MFG_ENABLE_FILTEROPAMP="1" *) (* MFG_GMCREF_SEL="2" *)
    EHXPLLL #(
        .PLLRST_ENA("DISABLED"),
        .INTFB_WAKE("DISABLED"),
        .STDBY_ENABLE("DISABLED"),
        .DPHASE_SOURCE("DISABLED"),
        .CLKOP_FPHASE(0),
        .CLKOP_CPHASE(1),
        .OUTDIVIDER_MUXA("DIVA"),
        .CLKOP_ENABLE("ENABLED"),
        .CLKOP_DIV(2),
        .CLKOS_ENABLE("ENABLED"),
        .CLKOS_DIV(2),
        .CLKOS_CPHASE(1),
        .CLKOS_FPHASE(0),
        .CLKOS2_ENABLE("ENABLED"),
        .CLKOS2_DIV(10),
        .CLKOS2_CPHASE(9),
        .CLKOS2_FPHASE(0),
        .CLKFB_DIV(74),
        .CLKI_DIV(10),
        .FEEDBK_PATH("INT_OP")
    ) pll_i (
        .CLKI(clk_in),
        .CLKFB(clkfb),
        .CLKINTFB(clkfb),
        .CLKOP(clk_op_unused),
        .CLKOS(clk_serial),
        .CLKOS2(clk_pixel_buf),
        .RST(1'b0),
        .STDBY(1'b0),
        .PHASESEL0(1'b0),
        .PHASESEL1(1'b0),
        .PHASEDIR(1'b0),
        .PHASESTEP(1'b0),
        .PLLWAKESYNC(1'b0),
        .ENCLKOP(1'b0),
        .LOCK()
    );

    assign clk_pixel = clk_pixel_buf;

endmodule
