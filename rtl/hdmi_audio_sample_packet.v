// SPDX-License-Identifier: MIT
// Ported from hdl-util/hdmi (Verilog-2001)

module hdmi_audio_sample_packet #(
    parameter [3:0] SAMPLING_FREQUENCY = 4'b0010,
    parameter [3:0] WORD_LENGTH = 4'b0010
) (
    input  wire [7:0]  frame_counter,
    output wire [23:0] header,
    output wire [55:0] sub_0,
    output wire [55:0] sub_1,
    output wire [55:0] sub_2,
    output wire [55:0] sub_3,
    input  wire [23:0] audio_sample_word_00,
    input  wire [23:0] audio_sample_word_01,
    input  wire [23:0] audio_sample_word_10,
    input  wire [23:0] audio_sample_word_11,
    input  wire [23:0] audio_sample_word_20,
    input  wire [23:0] audio_sample_word_21,
    input  wire [23:0] audio_sample_word_30,
    input  wire [23:0] audio_sample_word_31,
    input  wire [3:0]  audio_sample_word_present
);

    localparam CHANNEL_STATUS_LENGTH = 192;
    localparam [3:0] CHANNEL_LEFT = 4'd1;
    localparam [3:0] CHANNEL_RIGHT = 4'd2;

    wire [191:0] channel_status_left;
    wire [191:0] channel_status_right;

    wire [7:0] fc0, fc1, fc2, fc3;
    wire [7:0] afc0, afc1, afc2, afc3;
    wire p00, p01, p10, p11, p20, p21, p30, p31;

    assign fc0 = frame_counter;
    assign fc1 = frame_counter + 8'd1;
    assign fc2 = frame_counter + 8'd2;
    assign fc3 = frame_counter + 8'd3;

    assign afc0 = (fc0 >= 8'd192) ? fc0 - 8'd192 : fc0;
    assign afc1 = (fc1 >= 8'd192) ? fc1 - 8'd192 : fc1;
    assign afc2 = (fc2 >= 8'd192) ? fc2 - 8'd192 : fc2;
    assign afc3 = (fc3 >= 8'd192) ? fc3 - 8'd192 : fc3;

    // IEC 60958 channel status block (LSB first), matches hdl-util audio_sample_packet.sv
    assign channel_status_left = {
        152'd0,
        4'b0000,                    // ORIGINAL_SAMPLING_FREQUENCY
        WORD_LENGTH,                // {word_length[2:0], limit}
        2'b00,                      // CLOCK_ACCURACY
        SAMPLING_FREQUENCY,
        CHANNEL_LEFT,
        4'd0,                       // SOURCE_NUMBER
        8'd0,                       // CATEGORY_CODE
        2'b00,                      // MODE
        3'b000,                     // PRE_EMPHASIS
        1'b1,                       // COPYRIGHT_NOT_ASSERTED
        1'b0,                       // SAMPLE_WORD_TYPE (LPCM)
        1'b0                        // GRADE (consumer)
    };

    assign channel_status_right = {
        152'd0,
        4'b0000,
        WORD_LENGTH,
        2'b00,
        SAMPLING_FREQUENCY,
        CHANNEL_RIGHT,
        4'd0,
        8'd0,
        2'b00,
        3'b000,
        1'b1,
        1'b0,
        1'b0
    };

    assign header[19:12] = {4'b0000, {3'b000, 1'b0}};
    assign header[7:0] = 8'd2;

    assign header[23] = (afc0 == 8'd0) && audio_sample_word_present[0];
    assign header[22] = (afc1 == 8'd0) && audio_sample_word_present[1];
    assign header[21] = (afc2 == 8'd0) && audio_sample_word_present[2];
    assign header[20] = (afc3 == 8'd0) && audio_sample_word_present[3];
    assign header[11] = audio_sample_word_present[0];
    assign header[10] = audio_sample_word_present[1];
    assign header[9]  = audio_sample_word_present[2];
    assign header[8]  = audio_sample_word_present[3];

    assign p00 = ^{channel_status_left[afc0], 1'b0, 1'b0, audio_sample_word_00[23:16]};
    assign p01 = ^{channel_status_right[afc0], 1'b0, 1'b0, audio_sample_word_01[23:16]};
    assign p10 = ^{channel_status_left[afc1], 1'b0, 1'b0, audio_sample_word_10[23:16]};
    assign p11 = ^{channel_status_right[afc1], 1'b0, 1'b0, audio_sample_word_11[23:16]};
    assign p20 = ^{channel_status_left[afc2], 1'b0, 1'b0, audio_sample_word_20[23:16]};
    assign p21 = ^{channel_status_right[afc2], 1'b0, 1'b0, audio_sample_word_21[23:16]};
    assign p30 = ^{channel_status_left[afc3], 1'b0, 1'b0, audio_sample_word_30[23:16]};
    assign p31 = ^{channel_status_right[afc3], 1'b0, 1'b0, audio_sample_word_31[23:16]};

    assign sub_0 = audio_sample_word_present[0] ?
        {p01, channel_status_right[afc0], 1'b0, 1'b0,
         p00, channel_status_left[afc0], 1'b0, 1'b0,
         audio_sample_word_01, audio_sample_word_00} : 56'd0;

    assign sub_1 = audio_sample_word_present[1] ?
        {p11, channel_status_right[afc1], 1'b0, 1'b0,
         p10, channel_status_left[afc1], 1'b0, 1'b0,
         audio_sample_word_11, audio_sample_word_10} : 56'd0;

    assign sub_2 = audio_sample_word_present[2] ?
        {p21, channel_status_right[afc2], 1'b0, 1'b0,
         p20, channel_status_left[afc2], 1'b0, 1'b0,
         audio_sample_word_21, audio_sample_word_20} : 56'd0;

    assign sub_3 = audio_sample_word_present[3] ?
        {p31, channel_status_right[afc3], 1'b0, 1'b0,
         p30, channel_status_left[afc3], 1'b0, 1'b0,
         audio_sample_word_31, audio_sample_word_30} : 56'd0;

endmodule
