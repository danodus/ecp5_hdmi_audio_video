// SPDX-License-Identifier: MIT
// Ported from hdl-util/hdmi hdmi.sv (Verilog-2001)

module hdmi #(
    parameter VIDEO_ID_CODE = 1,
    parameter IT_CONTENT = 1'b1,
    parameter DVI_OUTPUT = 1'b0,
    parameter AUDIO_RATE = 48000,
    parameter AUDIO_BIT_WIDTH = 16,
    parameter [63:0] VENDOR_NAME = 64'h556E6B6E6F776E00,
    parameter [127:0] PRODUCT_DESCRIPTION = 128'h554C58335300000000000000000000,
    parameter [7:0] SOURCE_DEVICE_INFORMATION = 8'h09,
    parameter START_X = 0,
    parameter START_Y = 0,
    parameter TMDS_CLOCK_DDR = 0,
    parameter TMDS_DIFFERENTIAL = 0,
    parameter FRAME_WIDTH = 800,
    parameter FRAME_HEIGHT = 525,
    parameter SCREEN_WIDTH = 640,
    parameter SCREEN_HEIGHT = 480,
    parameter HSYNC_PULSE_START = 16,
    parameter HSYNC_PULSE_SIZE = 96,
    parameter VSYNC_PULSE_START = 10,
    parameter VSYNC_PULSE_SIZE = 2,
    parameter INVERT_POLARITY = 1,
    parameter COUNTER_WIDTH = 12
) (
    input  wire        clk_pixel_x5,
    input  wire        clk_pixel,
    input  wire        sample_strobe,
    input  wire        reset,
    input  wire [23:0] rgb,
    input  wire [AUDIO_BIT_WIDTH-1:0] audio_sample_word_0,
    input  wire [AUDIO_BIT_WIDTH-1:0] audio_sample_word_1,
    output wire [2:0]  tmds,
    output wire        tmds_clock,
    output wire [3:0]  tmds_p,
    output wire [3:0]  tmds_n,
    output reg  [COUNTER_WIDTH-1:0] cx,
    output reg  [COUNTER_WIDTH-1:0] cy,
    output wire [COUNTER_WIDTH-1:0] frame_width,
    output wire [COUNTER_WIDTH-1:0] frame_height,
    output wire [COUNTER_WIDTH-1:0] screen_width,
    output wire [COUNTER_WIDTH-1:0] screen_height
);

    localparam [COUNTER_WIDTH-1:0] FRAME_W = FRAME_WIDTH;
    localparam [COUNTER_WIDTH-1:0] FRAME_H = FRAME_HEIGHT;
    localparam [COUNTER_WIDTH-1:0] SCREEN_W = SCREEN_WIDTH;
    localparam [COUNTER_WIDTH-1:0] SCREEN_H = SCREEN_HEIGHT;
    localparam [COUNTER_WIDTH-1:0] H_SYNC_START = HSYNC_PULSE_START;
    localparam [COUNTER_WIDTH-1:0] H_SYNC_SIZE = HSYNC_PULSE_SIZE;
    localparam [COUNTER_WIDTH-1:0] V_SYNC_START = VSYNC_PULSE_START;
    localparam [COUNTER_WIDTH-1:0] V_SYNC_SIZE = VSYNC_PULSE_SIZE;
    localparam [COUNTER_WIDTH-1:0] ONE = {{(COUNTER_WIDTH-1){1'b0}}, 1'b1};

    reg hsync;
    reg vsync;
    wire invert;

    assign frame_width = FRAME_W;
    assign frame_height = FRAME_H;
    assign screen_width = SCREEN_W;
    assign screen_height = SCREEN_H;
    assign invert = INVERT_POLARITY;

    always @(*) begin
        hsync = invert ^ (cx >= SCREEN_W + H_SYNC_START &&
                          cx < SCREEN_W + H_SYNC_START + H_SYNC_SIZE);
        if (cy == SCREEN_H + V_SYNC_START - ONE)
            vsync = invert ^ (cx >= SCREEN_W + H_SYNC_START);
        else if (cy == SCREEN_H + V_SYNC_START + V_SYNC_SIZE - ONE)
            vsync = invert ^ (cx < SCREEN_W + H_SYNC_START);
        else
            vsync = invert ^ (cy >= SCREEN_H + V_SYNC_START &&
                              cy < SCREEN_H + V_SYNC_START + V_SYNC_SIZE);
    end

    always @(posedge clk_pixel) begin
        if (reset) begin
            cx <= START_X[COUNTER_WIDTH-1:0];
            cy <= START_Y[COUNTER_WIDTH-1:0];
        end else begin
            if (cx == FRAME_W - ONE)
                cx <= {COUNTER_WIDTH{1'b0}};
            else
                cx <= cx + ONE;
            if (cx == FRAME_W - ONE) begin
                if (cy == FRAME_H - ONE)
                    cy <= {COUNTER_WIDTH{1'b0}};
                else
                    cy <= cy + ONE;
            end
        end
    end

    reg video_data_period;
    always @(posedge clk_pixel) begin
        if (reset)
            video_data_period <= 1'b0;
        else
            video_data_period <= (cx < SCREEN_W) && (cy < SCREEN_H);
    end

    reg [2:0] mode;
    reg [23:0] video_data;
    reg [5:0] control_data;
    reg [11:0] data_island_data;

    reg video_guard;
    reg video_preamble;
    reg [4:0] num_packets_alongside;
    wire data_island_period_instantaneous;
    wire packet_enable;
    reg data_island_guard;
    reg data_island_preamble;
    reg data_island_period;

    wire [23:0] pkt_header;
    wire [55:0] pkt_sub_0, pkt_sub_1, pkt_sub_2, pkt_sub_3;
    wire video_field_end;
    wire [4:0] packet_pixel_counter;
    wire [8:0] packet_data;

    wire [9:0] tmds_internal_0;
    wire [9:0] tmds_internal_1;
    wire [9:0] tmds_internal_2;

    integer max_num_packets_alongside;

    assign video_field_end = (cx == SCREEN_W - ONE) && (cy == SCREEN_H - ONE);

    always @(*) begin
        max_num_packets_alongside =
            (FRAME_W - SCREEN_W - 2 - 8 - 4 - 2 - 2 - 8 - 4) / 32;
        if (max_num_packets_alongside > 18)
            num_packets_alongside = 5'd18;
        else
            num_packets_alongside = max_num_packets_alongside[4:0];
    end

    generate
        if (!DVI_OUTPUT) begin : hdmi_aux
            always @(posedge clk_pixel) begin
                if (reset) begin
                    video_guard <= 1'b1;
                    video_preamble <= 1'b0;
                end else begin
                    video_guard <= (cx >= FRAME_W - 12'd2) && (cx < FRAME_W) &&
                        ((cy == FRAME_H - ONE) || (cy < SCREEN_H - ONE));
                    video_preamble <= (cx >= FRAME_W - 12'd10) && (cx < FRAME_W - 12'd2) &&
                        ((cy == FRAME_H - ONE) || (cy < SCREEN_H - ONE));
                end
            end

            assign data_island_period_instantaneous =
                (num_packets_alongside > 0) &&
                (cx >= SCREEN_W + 12'd14) &&
                (cx < SCREEN_W + 12'd14 + {5'd0, num_packets_alongside, 5'd0});

            wire [COUNTER_WIDTH-1:0] packet_slot = cx + SCREEN_W + 12'd18;
            assign packet_enable =
                data_island_period_instantaneous && (packet_slot[4:0] == 5'd0);

            always @(posedge clk_pixel) begin
                if (reset) begin
                    data_island_guard <= 1'b0;
                    data_island_preamble <= 1'b0;
                    data_island_period <= 1'b0;
                end else begin
                    data_island_guard <= (num_packets_alongside > 0) && (
                        ((cx >= SCREEN_W + 12'd12) && (cx < SCREEN_W + 12'd14)) ||
                        ((cx >= SCREEN_W + 12'd14 + {5'd0, num_packets_alongside, 5'd0}) &&
                         (cx < SCREEN_W + 12'd14 + {5'd0, num_packets_alongside, 5'd0} + 12'd2))
                    );
                    data_island_preamble <= (num_packets_alongside > 0) &&
                        (cx >= SCREEN_W + 12'd4) && (cx < SCREEN_W + 12'd12);
                    data_island_period <= data_island_period_instantaneous;
                end
            end

            hdmi_packet_picker #(
                .VIDEO_ID_CODE(VIDEO_ID_CODE),
                .IT_CONTENT(IT_CONTENT),
                .AUDIO_BIT_WIDTH(AUDIO_BIT_WIDTH)
            ) u_packet_picker (
                .clk_pixel(clk_pixel),
                .sample_strobe(sample_strobe),
                .reset(reset),
                .video_field_end(video_field_end),
                .packet_enable(packet_enable),
                .packet_pixel_counter(packet_pixel_counter),
                .audio_sample_word_0(audio_sample_word_0),
                .audio_sample_word_1(audio_sample_word_1),
                .header(pkt_header),
                .sub_0(pkt_sub_0), .sub_1(pkt_sub_1),
                .sub_2(pkt_sub_2), .sub_3(pkt_sub_3)
            );

            hdmi_packet_assembler u_packet_assembler (
                .clk_pixel(clk_pixel),
                .reset(reset),
                .data_island_period(data_island_period),
                .header(pkt_header),
                .sub_0(pkt_sub_0), .sub_1(pkt_sub_1),
                .sub_2(pkt_sub_2), .sub_3(pkt_sub_3),
                .packet_data(packet_data),
                .counter(packet_pixel_counter)
            );

            always @(posedge clk_pixel) begin
                if (reset) begin
                    mode <= 3'd2;
                    video_data <= 24'd0;
                    control_data <= 6'd0;
                    data_island_data <= 12'd0;
                end else begin
                    mode <= data_island_guard ? 3'd4 :
                            data_island_period ? 3'd3 :
                            video_guard ? 3'd2 :
                            video_data_period ? 3'd1 : 3'd0;
                    video_data <= rgb;
                    control_data <= {
                        1'b0, data_island_preamble,
                        1'b0, video_preamble || data_island_preamble,
                        vsync, hsync
                    };
                    data_island_data[11:4] <= packet_data[8:1];
                    data_island_data[3] <= (cx != {COUNTER_WIDTH{1'b0}});
                    data_island_data[2] <= packet_data[0];
                    data_island_data[1:0] <= {vsync, hsync};
                end
            end
        end else begin : dvi_only
            always @(posedge clk_pixel) begin
                if (reset) begin
                    mode <= 3'd0;
                    video_data <= 24'd0;
                    control_data <= 6'd0;
                end else begin
                    mode <= video_data_period ? 3'd1 : 3'd0;
                    video_data <= rgb;
                    control_data <= {4'b0000, vsync, hsync};
                end
            end
            assign packet_enable = 1'b0;
            assign data_island_period = 1'b0;
        end
    endgenerate

    hdmi_tmds_channel #(.CN(0)) u_tmds_b (
        .clk_pixel(clk_pixel), .video_data(video_data[7:0]),
        .data_island_data(data_island_data[3:0]),
        .control_data(control_data[1:0]), .mode(mode), .tmds(tmds_internal_0)
    );
    hdmi_tmds_channel #(.CN(1)) u_tmds_g (
        .clk_pixel(clk_pixel), .video_data(video_data[15:8]),
        .data_island_data(data_island_data[7:4]),
        .control_data(control_data[3:2]), .mode(mode), .tmds(tmds_internal_1)
    );
    hdmi_tmds_channel #(.CN(2)) u_tmds_r (
        .clk_pixel(clk_pixel), .video_data(video_data[23:16]),
        .data_island_data(data_island_data[11:8]),
        .control_data(control_data[5:4]), .mode(mode), .tmds(tmds_internal_2)
    );

    hdmi_serializer_ecp5 #(
        .TMDS_CLOCK_DDR(TMDS_CLOCK_DDR),
        .TMDS_DIFFERENTIAL(TMDS_DIFFERENTIAL)
    ) u_serializer (
        .clk_pixel(clk_pixel),
        .clk_serial(clk_pixel_x5),
        .reset(reset),
        .tmds_internal_0(tmds_internal_0),
        .tmds_internal_1(tmds_internal_1),
        .tmds_internal_2(tmds_internal_2),
        .tmds_p(tmds_p),
        .tmds_n(tmds_n)
    );

    assign tmds = tmds_p[2:0];
    assign tmds_clock = tmds_p[3];

endmodule
