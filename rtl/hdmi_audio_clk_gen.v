// SPDX-License-Identifier: MIT
// 48 kHz one-cycle sample_strobe on clk_pixel (Bresenham divider)

module hdmi_audio_clk_gen #(
    parameter CLK_HZ = 25000000,
    parameter AUDIO_HZ = 48000
) (
    input  wire clk_pixel,
    input  wire reset,
    output wire sample_strobe
);

    reg [31:0] acc;
    reg        strobe_reg;

    assign sample_strobe = strobe_reg;

    // Remainder stays in acc so the long-term rate is AUDIO_HZ/CLK_HZ.
    always @(posedge clk_pixel) begin
        if (reset) begin
            acc <= 32'd0;
            strobe_reg <= 1'b0;
        end else if ((acc + AUDIO_HZ) >= CLK_HZ) begin
            acc <= acc + AUDIO_HZ - CLK_HZ;
            strobe_reg <= 1'b1;
        end else begin
            acc <= acc + AUDIO_HZ;
            strobe_reg <= 1'b0;
        end
    end

endmodule
