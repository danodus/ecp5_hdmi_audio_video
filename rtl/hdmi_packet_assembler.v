// SPDX-License-Identifier: MIT
// Ported from hdl-util/hdmi packet_assembler.sv (Verilog-2001)

module hdmi_packet_assembler (
    input  wire        clk_pixel,
    input  wire        reset,
    input  wire        data_island_period,
    input  wire [23:0] header,
    input  wire [55:0] sub_0,
    input  wire [55:0] sub_1,
    input  wire [55:0] sub_2,
    input  wire [55:0] sub_3,
    output wire [8:0]  packet_data,
    output reg  [4:0]  counter
);

    reg [7:0] parity_0;
    reg [7:0] parity_1;
    reg [7:0] parity_2;
    reg [7:0] parity_3;
    reg [7:0] parity_4;

    wire [5:0] counter_t2;
    wire [5:0] counter_t2_p1;
    wire [63:0] bch_0;
    wire [63:0] bch_1;
    wire [63:0] bch_2;
    wire [63:0] bch_3;
    wire [31:0] bch4;

    wire [7:0] parity_next_0;
    wire [7:0] parity_next_1;
    wire [7:0] parity_next_2;
    wire [7:0] parity_next_3;
    wire [7:0] parity_next_4;
    wire [7:0] parity_next_next_0;
    wire [7:0] parity_next_next_1;
    wire [7:0] parity_next_next_2;
    wire [7:0] parity_next_next_3;

    assign counter_t2 = {counter, 1'b0};
    assign counter_t2_p1 = {counter, 1'b1};

    assign bch_0 = {parity_0, sub_0};
    assign bch_1 = {parity_1, sub_1};
    assign bch_2 = {parity_2, sub_2};
    assign bch_3 = {parity_3, sub_3};
    assign bch4 = {parity_4, header};

    assign packet_data = {
        bch_3[counter_t2_p1], bch_2[counter_t2_p1], bch_1[counter_t2_p1], bch_0[counter_t2_p1],
        bch_3[counter_t2], bch_2[counter_t2], bch_1[counter_t2], bch_0[counter_t2],
        bch4[counter]
    };

    function [7:0] next_ecc;
        input [7:0] ecc;
        input       next_bch_bit;
        begin
            next_ecc = (ecc >> 1) ^ ((ecc[0] ^ next_bch_bit) ? 8'b10000011 : 8'd0);
        end
    endfunction

    assign parity_next_0 = next_ecc(parity_0, sub_0[counter_t2]);
    assign parity_next_1 = next_ecc(parity_1, sub_1[counter_t2]);
    assign parity_next_2 = next_ecc(parity_2, sub_2[counter_t2]);
    assign parity_next_3 = next_ecc(parity_3, sub_3[counter_t2]);
    assign parity_next_4 = next_ecc(parity_4, header[counter]);

    assign parity_next_next_0 = next_ecc(parity_next_0, sub_0[counter_t2_p1]);
    assign parity_next_next_1 = next_ecc(parity_next_1, sub_1[counter_t2_p1]);
    assign parity_next_next_2 = next_ecc(parity_next_2, sub_2[counter_t2_p1]);
    assign parity_next_next_3 = next_ecc(parity_next_3, sub_3[counter_t2_p1]);

    always @(posedge clk_pixel) begin
        if (reset)
            counter <= 5'd0;
        else if (data_island_period)
            counter <= counter + 5'd1;
    end

    always @(posedge clk_pixel) begin
        if (reset) begin
            parity_0 <= 8'd0;
            parity_1 <= 8'd0;
            parity_2 <= 8'd0;
            parity_3 <= 8'd0;
            parity_4 <= 8'd0;
        end else if (data_island_period) begin
            if (counter < 5'd28) begin
                parity_0 <= parity_next_next_0;
                parity_1 <= parity_next_next_1;
                parity_2 <= parity_next_next_2;
                parity_3 <= parity_next_next_3;
                if (counter < 5'd24)
                    parity_4 <= parity_next_4;
            end else if (counter == 5'd31) begin
                parity_0 <= 8'd0;
                parity_1 <= 8'd0;
                parity_2 <= 8'd0;
                parity_3 <= 8'd0;
                parity_4 <= 8'd0;
            end
        end else begin
            parity_0 <= 8'd0;
            parity_1 <= 8'd0;
            parity_2 <= 8'd0;
            parity_3 <= 8'd0;
            parity_4 <= 8'd0;
        end
    end

endmodule
