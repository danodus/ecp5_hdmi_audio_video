// SPDX-License-Identifier: MIT
// 440 Hz sine at 48 kHz, stereo (~-18 dBFS)

module sine_gen (
    input  wire        clk_pixel,
    input  wire        sample_strobe,
    input  wire        reset,
    output reg  signed [15:0] sample_0,
    output reg  signed [15:0] sample_1
);

    // 440 Hz @ 48 kHz: 2^32 * 440 / 48000
    localparam [31:0] PHASE_INC = 32'd39370534;

    reg [31:0] phase;
    wire [7:0] lut_index;
    reg signed [15:0] sample_full;

    assign lut_index = phase[31:24];

    always @(posedge clk_pixel) begin
        if (reset) begin
            phase <= 32'd0;
            sample_0 <= 16'sd0;
            sample_1 <= 16'sd0;
        end else if (sample_strobe) begin
            phase <= phase + PHASE_INC;
            case (lut_index[7:6])
                2'd0: sample_full <= $signed({1'b0, lut_index[5:0], 9'b0});
                2'd1: sample_full <= $signed({1'b0, 6'd63 - lut_index[5:0], 9'b0});
                2'd2: sample_full <= -$signed({1'b0, lut_index[5:0], 9'b0});
                default: sample_full <= -$signed({1'b0, 6'd63 - lut_index[5:0], 9'b0});
            endcase
            sample_0 <= sample_full >>> 4;
            sample_1 <= sample_full >>> 4;
        end
    end

endmodule
