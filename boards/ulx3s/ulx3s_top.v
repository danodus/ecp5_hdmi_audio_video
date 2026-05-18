// SPDX-License-Identifier: MIT
// ULX3S v3.1.7 HDMI demo: color bars + 440 Hz tone

module ulx3s_top (
    input  wire clk_25mhz,
    output wire [3:0] gpdi_dp
);

    wire reset;
    reg [15:0] reset_cnt;

    wire clk_pixel;
    wire clk_serial;
    wire sample_strobe;
    wire [2:0] tmds;
    wire       tmds_clock;
    wire [3:0] tmds_p;
    wire [3:0] tmds_n;

    wire [9:0] cx, cy;
    wire [9:0] frame_width, frame_height, screen_width, screen_height;
    wire [23:0] rgb;

    wire signed [15:0] audio_left;
    wire signed [15:0] audio_right;

    always @(posedge clk_pixel) begin
        if (reset_cnt != 16'hffff)
            reset_cnt <= reset_cnt + 16'd1;
    end
    assign reset = (reset_cnt != 16'hffff);

    hdmi_pll u_pll (
        .clk_in(clk_25mhz),
        .clk_pixel(clk_pixel),
        .clk_serial(clk_serial),
        .clk_pixel_buf()
    );

    hdmi_audio_clk_gen #(
        .CLK_HZ(25_000_000)
    ) u_audio_clk (
        .clk_pixel(clk_pixel),
        .reset(reset),
        .sample_strobe(sample_strobe)
    );

    hdmi #(
        .VIDEO_ID_CODE(1),
        .IT_CONTENT(1'b1),
        .DVI_OUTPUT(1'b0),
        .AUDIO_RATE(48000),
        .AUDIO_BIT_WIDTH(16)
    ) u_hdmi (
        .clk_pixel_x5(clk_serial),
        .clk_pixel(clk_pixel),
        .sample_strobe(sample_strobe),
        .reset(reset),
        .rgb(rgb),
        .audio_sample_word_0(audio_left),
        .audio_sample_word_1(audio_right),
        .tmds(tmds),
        .tmds_clock(tmds_clock),
        .tmds_p(tmds_p),
        .tmds_n(tmds_n),
        .cx(cx),
        .cy(cy),
        .frame_width(frame_width),
        .frame_height(frame_height),
        .screen_width(screen_width),
        .screen_height(screen_height)
    );

    color_bars u_color_bars (
        .cx(cx),
        .cy(cy),
        .screen_width(screen_width),
        .screen_height(screen_height),
        .rgb(rgb)
    );

    sine_gen u_sine (
        .clk_pixel(clk_pixel),
        .sample_strobe(sample_strobe),
        .reset(reset),
        .sample_0(audio_left),
        .sample_1(audio_right)
    );

    assign gpdi_dp[2:0] = tmds;
    assign gpdi_dp[3]   = tmds_clock;

endmodule
