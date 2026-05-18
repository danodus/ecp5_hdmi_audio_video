// SPDX-License-Identifier: MIT
// Ported from hdl-util/hdmi packet_picker.sv (Verilog-2001)

module hdmi_packet_picker #(
    parameter [6:0] VIDEO_ID_CODE = 7'd1,
    parameter IT_CONTENT = 1'b1,
    parameter AUDIO_BIT_WIDTH = 16
) (
    input  wire        clk_pixel,
    input  wire        sample_strobe,
    input  wire        reset,
    input  wire        video_field_end,
    input  wire        packet_enable,
    input  wire [4:0]  packet_pixel_counter,
    input  wire [AUDIO_BIT_WIDTH-1:0] audio_sample_word_0,
    input  wire [AUDIO_BIT_WIDTH-1:0] audio_sample_word_1,
    output wire [23:0] header,
    output wire [55:0] sub_0,
    output wire [55:0] sub_1,
    output wire [55:0] sub_2,
    output wire [55:0] sub_3
);

    reg [7:0] packet_type;

    wire clk_audio_counter_wrap;

    wire [23:0] header_acr;
    wire [55:0] sub_acr_0, sub_acr_1, sub_acr_2, sub_acr_3;

    wire [23:0] header_asp;
    wire [55:0] sub_asp_0, sub_asp_1, sub_asp_2, sub_asp_3;

    wire [23:0] header_avi;
    wire [55:0] sub_avi_0, sub_avi_1, sub_avi_2, sub_avi_3;

    wire [23:0] header_spd;
    wire [55:0] sub_spd_0, sub_spd_1, sub_spd_2, sub_spd_3;

    wire [23:0] header_aif;
    wire [55:0] sub_aif_0, sub_aif_1, sub_aif_2, sub_aif_3;

    reg sample_buffer_current;
    reg [1:0] samples_remaining;

    reg [23:0] buf_0_0, buf_0_1, buf_1_0, buf_1_1, buf_2_0, buf_2_1, buf_3_0, buf_3_1;
    reg [23:0] buf_b0_0, buf_b0_1, buf_b1_0, buf_b1_1, buf_b2_0, buf_b2_1, buf_b3_0, buf_b3_1;

    reg [23:0] asp_00, asp_01, asp_10, asp_11, asp_20, asp_21, asp_30, asp_31;

    reg sample_buffer_used;
    reg sample_buffer_ready;

    reg [7:0] frame_counter;
    reg last_clk_audio_counter_wrap;

    reg audio_info_frame_sent;
    reg avi_info_frame_sent;
    reg spd_info_frame_sent;

    reg [3:0] audio_sample_word_present;

    hdmi_audio_clock_regeneration_packet acr (
        .clk_pixel(clk_pixel),
        .sample_strobe(sample_strobe),
        .clk_audio_counter_wrap(clk_audio_counter_wrap),
        .header(header_acr),
        .sub_0(sub_acr_0), .sub_1(sub_acr_1), .sub_2(sub_acr_2), .sub_3(sub_acr_3)
    );

    hdmi_audio_sample_packet #(
        .SAMPLING_FREQUENCY(4'b0010),
        .WORD_LENGTH(4'b1000)
    ) asp (
        .frame_counter(frame_counter),
        .header(header_asp),
        .sub_0(sub_asp_0), .sub_1(sub_asp_1), .sub_2(sub_asp_2), .sub_3(sub_asp_3),
        .audio_sample_word_00(asp_00), .audio_sample_word_01(asp_01),
        .audio_sample_word_10(asp_10), .audio_sample_word_11(asp_11),
        .audio_sample_word_20(asp_20), .audio_sample_word_21(asp_21),
        .audio_sample_word_30(asp_30), .audio_sample_word_31(asp_31),
        .audio_sample_word_present(audio_sample_word_present)
    );

    hdmi_auxiliary_video_information_info_frame #(
        .VIDEO_ID_CODE(VIDEO_ID_CODE),
        .IT_CONTENT(IT_CONTENT)
    ) avi (
        .header(header_avi),
        .sub_0(sub_avi_0), .sub_1(sub_avi_1), .sub_2(sub_avi_2), .sub_3(sub_avi_3)
    );

    hdmi_source_product_description_info_frame spd (
        .header(header_spd),
        .sub_0(sub_spd_0), .sub_1(sub_spd_1), .sub_2(sub_spd_2), .sub_3(sub_spd_3)
    );

    hdmi_audio_info_frame aif (
        .header(header_aif),
        .sub_0(sub_aif_0), .sub_1(sub_aif_1), .sub_2(sub_aif_2), .sub_3(sub_aif_3)
    );

    assign header = (packet_type == 8'd1) ? header_acr :
                    (packet_type == 8'd2) ? header_asp :
                    (packet_type == 8'h82) ? header_avi :
                    (packet_type == 8'h83) ? header_spd :
                    (packet_type == 8'h84) ? header_aif : 24'd0;

    assign sub_0 = (packet_type == 8'd1) ? sub_acr_0 :
                   (packet_type == 8'd2) ? sub_asp_0 :
                   (packet_type == 8'h82) ? sub_avi_0 :
                   (packet_type == 8'h83) ? sub_spd_0 :
                   (packet_type == 8'h84) ? sub_aif_0 : 56'd0;

    assign sub_1 = (packet_type == 8'd1) ? sub_acr_1 :
                   (packet_type == 8'd2) ? sub_asp_1 :
                   (packet_type == 8'h82) ? sub_avi_1 :
                   (packet_type == 8'h83) ? sub_spd_1 :
                   (packet_type == 8'h84) ? sub_aif_1 : 56'd0;

    assign sub_2 = (packet_type == 8'd1) ? sub_acr_2 :
                   (packet_type == 8'd2) ? sub_asp_2 :
                   (packet_type == 8'h82) ? sub_avi_2 :
                   (packet_type == 8'h83) ? sub_spd_2 :
                   (packet_type == 8'h84) ? sub_aif_2 : 56'd0;

    assign sub_3 = (packet_type == 8'd1) ? sub_acr_3 :
                   (packet_type == 8'd2) ? sub_asp_3 :
                   (packet_type == 8'h82) ? sub_avi_3 :
                   (packet_type == 8'h83) ? sub_spd_3 :
                   (packet_type == 8'h84) ? sub_aif_3 : 56'd0;

    always @(posedge clk_pixel) begin
        if (sample_buffer_used)
            sample_buffer_ready <= 1'b0;

        if (sample_strobe) begin
            if (sample_buffer_current) begin
                case (samples_remaining)
                    2'd0: begin buf_b0_0 <= {audio_sample_word_0, 8'd0};
                            buf_b0_1 <= {audio_sample_word_1, 8'd0}; end
                    2'd1: begin buf_b1_0 <= {audio_sample_word_0, 8'd0};
                            buf_b1_1 <= {audio_sample_word_1, 8'd0}; end
                    2'd2: begin buf_b2_0 <= {audio_sample_word_0, 8'd0};
                            buf_b2_1 <= {audio_sample_word_1, 8'd0}; end
                    2'd3: begin buf_b3_0 <= {audio_sample_word_0, 8'd0};
                            buf_b3_1 <= {audio_sample_word_1, 8'd0}; end
                endcase
            end else begin
                case (samples_remaining)
                    2'd0: begin buf_0_0 <= {audio_sample_word_0, 8'd0};
                            buf_0_1 <= {audio_sample_word_1, 8'd0}; end
                    2'd1: begin buf_1_0 <= {audio_sample_word_0, 8'd0};
                            buf_1_1 <= {audio_sample_word_1, 8'd0}; end
                    2'd2: begin buf_2_0 <= {audio_sample_word_0, 8'd0};
                            buf_2_1 <= {audio_sample_word_1, 8'd0}; end
                    2'd3: begin buf_3_0 <= {audio_sample_word_0, 8'd0};
                            buf_3_1 <= {audio_sample_word_1, 8'd0}; end
                endcase
            end

            if (samples_remaining == 2'd3) begin
                samples_remaining <= 2'd0;
                sample_buffer_ready <= 1'b1;
                sample_buffer_current <= ~sample_buffer_current;
            end else
                samples_remaining <= samples_remaining + 2'd1;
        end
    end

    always @(posedge clk_pixel) begin
        if (reset)
            frame_counter <= 8'd0;
        else if (packet_pixel_counter == 5'd31 && packet_type == 8'd2) begin
            if (frame_counter >= 8'd192)
                frame_counter <= frame_counter - 8'd192 + 8'd4;
            else
                frame_counter <= frame_counter + 8'd4;
        end
    end

    always @(posedge clk_pixel) begin
        if (sample_buffer_used)
            sample_buffer_used <= 1'b0;

        if (reset || video_field_end) begin
            audio_info_frame_sent <= 1'b0;
            avi_info_frame_sent <= 1'b0;
            spd_info_frame_sent <= 1'b0;
            packet_type <= 8'd0;
        end else if (packet_enable) begin
            if (last_clk_audio_counter_wrap ^ clk_audio_counter_wrap) begin
                packet_type <= 8'd1;
                last_clk_audio_counter_wrap <= clk_audio_counter_wrap;
            end else if (sample_buffer_ready) begin
                packet_type <= 8'd2;
                audio_sample_word_present <= 4'b1111;
                if (sample_buffer_current) begin
                    asp_00 <= buf_0_0;
                    asp_01 <= buf_0_1;
                    asp_10 <= buf_1_0;
                    asp_11 <= buf_1_1;
                    asp_20 <= buf_2_0;
                    asp_21 <= buf_2_1;
                    asp_30 <= buf_3_0;
                    asp_31 <= buf_3_1;
                end else begin
                    asp_00 <= buf_b0_0;
                    asp_01 <= buf_b0_1;
                    asp_10 <= buf_b1_0;
                    asp_11 <= buf_b1_1;
                    asp_20 <= buf_b2_0;
                    asp_21 <= buf_b2_1;
                    asp_30 <= buf_b3_0;
                    asp_31 <= buf_b3_1;
                end
                sample_buffer_used <= 1'b1;
            end else if (!audio_info_frame_sent) begin
                packet_type <= 8'h84;
                audio_info_frame_sent <= 1'b1;
            end else if (!avi_info_frame_sent) begin
                packet_type <= 8'h82;
                avi_info_frame_sent <= 1'b1;
            end else if (!spd_info_frame_sent) begin
                packet_type <= 8'h83;
                spd_info_frame_sent <= 1'b1;
            end else
                packet_type <= 8'd0;
        end
    end

endmodule
