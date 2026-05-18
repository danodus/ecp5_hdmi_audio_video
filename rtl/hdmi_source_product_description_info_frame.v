// SPDX-License-Identifier: MIT
// Ported from hdl-util/hdmi (Verilog-2001)

module hdmi_source_product_description_info_frame #(
    parameter [63:0] VENDOR_NAME = 64'h556E6B6E6F776E00,
    parameter [127:0] PRODUCT_DESCRIPTION = 128'h554C58335300000000000000000000,
    parameter [7:0] SOURCE_DEVICE_INFORMATION = 8'h09
) (
    output wire [23:0] header,
    output wire [55:0] sub_0,
    output wire [55:0] sub_1,
    output wire [55:0] sub_2,
    output wire [55:0] sub_3
);

    localparam [4:0] LENGTH = 5'd25;
    localparam [7:0] VERSION = 8'd1;
    localparam [6:0] TYPE = 7'd3;

    wire [7:0] pb0;
    wire [7:0] pb1;
    wire [7:0] pb2;
    wire [7:0] pb3;
    wire [7:0] pb4;
    wire [7:0] pb5;
    wire [7:0] pb6;
    wire [7:0] pb7;
    wire [7:0] pb8;
    wire [7:0] pb9;
    wire [7:0] pb10;
    wire [7:0] pb11;
    wire [7:0] pb12;
    wire [7:0] pb13;
    wire [7:0] pb14;
    wire [7:0] pb15;
    wire [7:0] pb16;
    wire [7:0] pb17;
    wire [7:0] pb18;
    wire [7:0] pb19;
    wire [7:0] pb20;
    wire [7:0] pb21;
    wire [7:0] pb22;
    wire [7:0] pb23;
    wire [7:0] pb24;
    wire [7:0] pb25;
    wire [7:0] pb26 = 8'd0;
    wire [7:0] pb27 = 8'd0;

    assign header = {{3'b0, LENGTH}, VERSION, {1'b1, TYPE}};

    assign pb1  = (VENDOR_NAME[63:56] == 8'h30) ? 8'h00 : VENDOR_NAME[63:56];
    assign pb2  = (VENDOR_NAME[55:48] == 8'h30) ? 8'h00 : VENDOR_NAME[55:48];
    assign pb3  = (VENDOR_NAME[47:40] == 8'h30) ? 8'h00 : VENDOR_NAME[47:40];
    assign pb4  = (VENDOR_NAME[39:32] == 8'h30) ? 8'h00 : VENDOR_NAME[39:32];
    assign pb5  = (VENDOR_NAME[31:24] == 8'h30) ? 8'h00 : VENDOR_NAME[31:24];
    assign pb6  = (VENDOR_NAME[23:16] == 8'h30) ? 8'h00 : VENDOR_NAME[23:16];
    assign pb7  = (VENDOR_NAME[15:8]  == 8'h30) ? 8'h00 : VENDOR_NAME[15:8];
    assign pb8  = (VENDOR_NAME[7:0]   == 8'h30) ? 8'h00 : VENDOR_NAME[7:0];

    assign pb9  = (PRODUCT_DESCRIPTION[127:120] == 8'h30) ? 8'h00 : PRODUCT_DESCRIPTION[127:120];
    assign pb10 = (PRODUCT_DESCRIPTION[119:112] == 8'h30) ? 8'h00 : PRODUCT_DESCRIPTION[119:112];
    assign pb11 = (PRODUCT_DESCRIPTION[111:104] == 8'h30) ? 8'h00 : PRODUCT_DESCRIPTION[111:104];
    assign pb12 = (PRODUCT_DESCRIPTION[103:96]  == 8'h30) ? 8'h00 : PRODUCT_DESCRIPTION[103:96];
    assign pb13 = (PRODUCT_DESCRIPTION[95:88]   == 8'h30) ? 8'h00 : PRODUCT_DESCRIPTION[95:88];
    assign pb14 = (PRODUCT_DESCRIPTION[87:80]   == 8'h30) ? 8'h00 : PRODUCT_DESCRIPTION[87:80];
    assign pb15 = (PRODUCT_DESCRIPTION[79:72]   == 8'h30) ? 8'h00 : PRODUCT_DESCRIPTION[79:72];
    assign pb16 = (PRODUCT_DESCRIPTION[71:64]   == 8'h30) ? 8'h00 : PRODUCT_DESCRIPTION[71:64];
    assign pb17 = (PRODUCT_DESCRIPTION[63:56]   == 8'h30) ? 8'h00 : PRODUCT_DESCRIPTION[63:56];
    assign pb18 = (PRODUCT_DESCRIPTION[55:48]   == 8'h30) ? 8'h00 : PRODUCT_DESCRIPTION[55:48];
    assign pb19 = (PRODUCT_DESCRIPTION[47:40]   == 8'h30) ? 8'h00 : PRODUCT_DESCRIPTION[47:40];
    assign pb20 = (PRODUCT_DESCRIPTION[39:32]   == 8'h30) ? 8'h00 : PRODUCT_DESCRIPTION[39:32];
    assign pb21 = (PRODUCT_DESCRIPTION[31:24]   == 8'h30) ? 8'h00 : PRODUCT_DESCRIPTION[31:24];
    assign pb22 = (PRODUCT_DESCRIPTION[23:16]   == 8'h30) ? 8'h00 : PRODUCT_DESCRIPTION[23:16];
    assign pb23 = (PRODUCT_DESCRIPTION[15:8]    == 8'h30) ? 8'h00 : PRODUCT_DESCRIPTION[15:8];
    assign pb24 = (PRODUCT_DESCRIPTION[7:0]     == 8'h30) ? 8'h00 : PRODUCT_DESCRIPTION[7:0];

    assign pb25 = SOURCE_DEVICE_INFORMATION;

    assign pb0 = 8'd1 + ~(header[23:16] + header[15:8] + header[7:0] +
                          pb25 + pb24 + pb23 + pb22 + pb21 + pb20 + pb19 + pb18 +
                          pb17 + pb16 + pb15 + pb14 + pb13 + pb12 + pb11 + pb10 +
                          pb9 + pb8 + pb7 + pb6 + pb5 + pb4 + pb3 + pb2 + pb1);

    assign sub_0 = {pb6, pb5, pb4, pb3, pb2, pb1, pb0};
    assign sub_1 = {pb13, pb12, pb11, pb10, pb9, pb8, pb7};
    assign sub_2 = {pb20, pb19, pb18, pb17, pb16, pb15, pb14};
    assign sub_3 = {pb27, pb26, pb25, pb24, pb23, pb22, pb21};

endmodule
