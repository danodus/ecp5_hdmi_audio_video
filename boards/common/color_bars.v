// SPDX-License-Identifier: MIT
// EIA-189A simplified SMPTE 75% color bars (7 columns, bottom PLUGE strip)

module color_bars #(
    parameter COUNTER_WIDTH = 12,
    parameter SCREEN_WIDTH = 640
) (
    input  wire [COUNTER_WIDTH-1:0] cx,
    input  wire [COUNTER_WIDTH-1:0] cy,
    input  wire [COUNTER_WIDTH-1:0] screen_width,
    input  wire [COUNTER_WIDTH-1:0] screen_height,
    output reg  [23:0] rgb
);

    localparam [COUNTER_WIDTH-1:0] BAR_W = (SCREEN_WIDTH * 1) / 7;
    localparam [COUNTER_WIDTH-1:0] BAR_1 = (SCREEN_WIDTH * 2) / 7;
    localparam [COUNTER_WIDTH-1:0] BAR_2 = (SCREEN_WIDTH * 3) / 7;
    localparam [COUNTER_WIDTH-1:0] BAR_3 = (SCREEN_WIDTH * 4) / 7;
    localparam [COUNTER_WIDTH-1:0] BAR_4 = (SCREEN_WIDTH * 5) / 7;
    localparam [COUNTER_WIDTH-1:0] BAR_5 = (SCREEN_WIDTH * 6) / 7;

    wire active = (cx < screen_width) && (cy < screen_height);
    wire bottom_strip = cy >= ((screen_height * 3) >> 2);

    wire [2:0] bar_idx = (cx >= screen_width) ? 3'd6 :
                          (cx < BAR_W)  ? 3'd0 :
                          (cx < BAR_1)  ? 3'd1 :
                          (cx < BAR_2)  ? 3'd2 :
                          (cx < BAR_3)  ? 3'd3 :
                          (cx < BAR_4)  ? 3'd4 :
                          (cx < BAR_5)  ? 3'd5 : 3'd6;

    localparam [23:0] CLR_WHITE   = {8'd180, 8'd180, 8'd180};
    localparam [23:0] CLR_YELLOW  = {8'd180, 8'd180, 8'd16};
    localparam [23:0] CLR_CYAN    = {8'd16,  8'd180, 8'd180};
    localparam [23:0] CLR_GREEN   = {8'd16,  8'd180, 8'd16};
    localparam [23:0] CLR_MAGENTA = {8'd180, 8'd16,  8'd180};
    localparam [23:0] CLR_RED     = {8'd180, 8'd16,  8'd16};
    localparam [23:0] CLR_BLUE    = {8'd16,  8'd16,  8'd180};
    localparam [23:0] CLR_BLACK   = 24'd0;

    always @(*) begin
        if (!active) begin
            rgb = CLR_BLACK;
        end else if (bottom_strip) begin
            case (bar_idx)
                3'd1: rgb = CLR_WHITE;
                default: rgb = CLR_BLACK;
            endcase
        end else begin
            case (bar_idx)
                3'd0: rgb = CLR_WHITE;
                3'd1: rgb = CLR_YELLOW;
                3'd2: rgb = CLR_CYAN;
                3'd3: rgb = CLR_GREEN;
                3'd4: rgb = CLR_MAGENTA;
                3'd5: rgb = CLR_RED;
                default: rgb = CLR_BLUE;
            endcase
        end
    end

endmodule
