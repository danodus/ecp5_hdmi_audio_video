// SPDX-License-Identifier: MIT
// Ported from hdl-util/hdmi (Verilog-2001)

module hdmi_auxiliary_video_information_info_frame #(
    parameter [6:0] VIDEO_ID_CODE = 7'd1,
    parameter IT_CONTENT = 1'b1
) (
    output wire [23:0] header,
    output wire [55:0] sub_0,
    output wire [55:0] sub_1,
    output wire [55:0] sub_2,
    output wire [55:0] sub_3
);

    localparam [4:0] LENGTH = 5'd13;
    localparam [7:0] VERSION = 8'd2;
    localparam [6:0] TYPE = 7'd2;

    wire [7:0] pb0;
    wire [7:0] pb1;
    wire [7:0] pb2;
    wire [7:0] pb3;
    wire [7:0] pb4;
    wire [7:0] pb5;
    wire [7:0] pb6  = 8'd0;
    wire [7:0] pb7  = 8'd0;
    wire [7:0] pb8  = 8'd0;
    wire [7:0] pb9  = 8'd0;
    wire [7:0] pb10 = 8'd0;
    wire [7:0] pb11 = 8'd0;
    wire [7:0] pb12 = 8'd0;
    wire [7:0] pb13 = 8'd0;
    wire [7:0] pb14 = 8'd0;
    wire [7:0] pb15 = 8'd0;
    wire [7:0] pb16 = 8'd0;
    wire [7:0] pb17 = 8'd0;
    wire [7:0] pb18 = 8'd0;
    wire [7:0] pb19 = 8'd0;
    wire [7:0] pb20 = 8'd0;
    wire [7:0] pb21 = 8'd0;
    wire [7:0] pb22 = 8'd0;
    wire [7:0] pb23 = 8'd0;
    wire [7:0] pb24 = 8'd0;
    wire [7:0] pb25 = 8'd0;
    wire [7:0] pb26 = 8'd0;
    wire [7:0] pb27 = 8'd0;

    assign header = {{3'b0, LENGTH}, VERSION, {1'b1, TYPE}};

    assign pb1 = {1'b0, 2'b00, 1'b0, 2'b00, 2'b00};
    assign pb2 = {2'b00, 2'b00, 4'b1000};
    assign pb3 = {IT_CONTENT, 3'b000, 2'b00, 2'b00};
    assign pb4 = {1'b0, VIDEO_ID_CODE};
    assign pb5 = {2'b00, 2'b00, 4'b0000};
    assign pb0 = 8'd1 + ~(header[23:16] + header[15:8] + header[7:0] +
                          pb13 + pb12 + pb11 + pb10 + pb9 + pb8 + pb7 + pb6 +
                          pb5 + pb4 + pb3 + pb2 + pb1);

    assign sub_0 = {pb6, pb5, pb4, pb3, pb2, pb1, pb0};
    assign sub_1 = {pb13, pb12, pb11, pb10, pb9, pb8, pb7};
    assign sub_2 = {pb20, pb19, pb18, pb17, pb16, pb15, pb14};
    assign sub_3 = {pb27, pb26, pb25, pb24, pb23, pb22, pb21};

endmodule
