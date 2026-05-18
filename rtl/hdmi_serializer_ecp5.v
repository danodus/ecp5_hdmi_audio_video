// SPDX-License-Identifier: MIT
// ECP5 TMDS serializer using ODDRX1F (2 bits per 125 MHz clock)
// Adapted from BrunoLevy/learn-fpga, hdl-util/hdmi, cheyao/icepi-zero vga2dvid

module hdmi_serializer_ecp5 #(
    parameter TMDS_CLOCK_DDR = 0,
    parameter TMDS_DIFFERENTIAL = 0
) (
    input  wire        clk_pixel,
    input  wire        clk_serial,
    input  wire        reset,
    input  wire [9:0]  tmds_internal_0,
    input  wire [9:0]  tmds_internal_1,
    input  wire [9:0]  tmds_internal_2,
    output wire [3:0]  tmds_p,
    output wire [3:0]  tmds_n
);

    wire      tmds_shift_load;

    reg [9:0] tmds_shift_0;
    reg [9:0] tmds_shift_1;
    reg [9:0] tmds_shift_2;
    reg [9:0] shift_clock;

    // Match emard hdmi_interface / xgsoc: load every 5th serial clock, DVI clock char 10'h3e0
    reg [3:0] ctr_mod5;
    reg       shift_ld;

    always @(posedge clk_serial) begin
        shift_ld <= (ctr_mod5 == 4'd4);
        ctr_mod5 <= (ctr_mod5 == 4'd4) ? 4'd0 : ctr_mod5 + 4'd1;
    end

    assign tmds_shift_load = shift_ld;

    always @(posedge clk_serial) begin
        if (reset) begin
            tmds_shift_0 <= 10'd0;
            tmds_shift_1 <= 10'd0;
            tmds_shift_2 <= 10'd0;
            shift_clock  <= 10'h3e0;
        end else begin
            tmds_shift_0 <= tmds_shift_load ? tmds_internal_0 : tmds_shift_0[9:2];
            tmds_shift_1 <= tmds_shift_load ? tmds_internal_1 : tmds_shift_1[9:2];
            tmds_shift_2 <= tmds_shift_load ? tmds_internal_2 : tmds_shift_2[9:2];
            shift_clock  <= tmds_shift_load ? 10'h3e0 : shift_clock[9:2];
        end
    end

    // ODDR reset held low (same as working xgsoc hdmi_interface)
    ODDRX1F ddr_b (
        .D0(tmds_shift_0[0]), .D1(tmds_shift_0[1]),
        .Q(tmds_p[0]), .SCLK(clk_serial), .RST(1'b0)
    );
    ODDRX1F ddr_g (
        .D0(tmds_shift_1[0]), .D1(tmds_shift_1[1]),
        .Q(tmds_p[1]), .SCLK(clk_serial), .RST(1'b0)
    );
    ODDRX1F ddr_r (
        .D0(tmds_shift_2[0]), .D1(tmds_shift_2[1]),
        .Q(tmds_p[2]), .SCLK(clk_serial), .RST(1'b0)
    );

    generate
        if (TMDS_CLOCK_DDR) begin : clock_ddr
            ODDRX1F ddr_clk (
                .D0(shift_clock[0]), .D1(shift_clock[1]),
                .Q(tmds_p[3]), .SCLK(clk_serial), .RST(1'b0)
            );
        end else begin : clock_sdr
            assign tmds_p[3] = clk_pixel;
        end
    endgenerate

    generate
        if (TMDS_DIFFERENTIAL) begin : diff_n
            ODDRX1F ddr_b_n (
                .D0(~tmds_shift_0[0]), .D1(~tmds_shift_0[1]),
                .Q(tmds_n[0]), .SCLK(clk_serial), .RST(1'b0)
            );
            ODDRX1F ddr_g_n (
                .D0(~tmds_shift_1[0]), .D1(~tmds_shift_1[1]),
                .Q(tmds_n[1]), .SCLK(clk_serial), .RST(1'b0)
            );
            ODDRX1F ddr_r_n (
                .D0(~tmds_shift_2[0]), .D1(~tmds_shift_2[1]),
                .Q(tmds_n[2]), .SCLK(clk_serial), .RST(1'b0)
            );
            if (TMDS_CLOCK_DDR) begin
                ODDRX1F ddr_clk_n (
                    .D0(~shift_clock[0]), .D1(~shift_clock[1]),
                    .Q(tmds_n[3]), .SCLK(clk_serial), .RST(1'b0)
                );
            end else begin
                assign tmds_n[3] = ~clk_pixel;
            end
        end else begin : no_diff_n
            assign tmds_n = 4'b0000;
        end
    endgenerate

endmodule
