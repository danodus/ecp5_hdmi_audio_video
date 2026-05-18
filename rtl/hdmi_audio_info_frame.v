// SPDX-License-Identifier: MIT
// Audio InfoFrame — sample rate/size refer to IEC60958 stream (CEA-861)

module hdmi_audio_info_frame (
    output wire [23:0] header,
    output wire [55:0] sub_0,
    output wire [55:0] sub_1,
    output wire [55:0] sub_2,
    output wire [55:0] sub_3
);

    localparam [4:0] LENGTH = 5'd10;
    localparam [7:0] VERSION = 8'd1;
    localparam [6:0] TYPE = 7'd4;

    wire [7:0] pb0;
    wire [7:0] pb1;
    wire [7:0] pb2;
    wire [7:0] pb3;
    wire [7:0] pb4;
    wire [7:0] pb5;

    assign header = {{3'b0, LENGTH}, VERSION, {1'b1, TYPE}};

    assign pb1 = {4'b0000, 1'b0, 3'd1};
    assign pb2 = {3'b000, 3'b000, 2'b00};
    assign pb3 = 8'd0;
    assign pb4 = 8'h00;
    assign pb5 = {1'b0, 4'd0, 1'b0, 2'd0};
    assign pb0 = 8'd1 + ~(header[23:16] + header[15:8] + header[7:0] +
                          pb5 + pb4 + pb3 + pb2 + pb1);

    assign sub_0 = {8'd0, pb5, pb4, pb3, pb2, pb1, pb0};
    assign sub_1 = {8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0};
    assign sub_2 = {8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0};
    assign sub_3 = {8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0};

endmodule
