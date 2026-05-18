// SPDX-License-Identifier: MIT
// ACR packet — sample_strobe @ 48 kHz on clk_pixel

module hdmi_audio_clock_regeneration_packet #(
    parameter AUDIO_HZ = 48000
) (
    input  wire        clk_pixel,
    input  wire        sample_strobe,
    output reg         clk_audio_counter_wrap,
    output wire [23:0] header,
    output wire [55:0] sub_0,
    output wire [55:0] sub_1,
    output wire [55:0] sub_2,
    output wire [55:0] sub_3
);

    localparam [19:0] N = 20'd6144;
    localparam [5:0] CLK_AUDIO_COUNTER_END = 6'd47;

    reg [5:0] clk_audio_counter;
    reg       internal_wrap;
    reg [1:0] wrap_sync;

    reg [19:0] cycle_time_stamp;
    reg [14:0] cycle_time_stamp_counter;

    assign header = {8'd0, 8'd0, 8'd1};

    assign sub_0 = {N[7:0], N[15:8], {4'd0, N[19:16]},
                    cycle_time_stamp[7:0], cycle_time_stamp[15:8],
                    {4'd0, cycle_time_stamp[19:16]}, 8'd0};
    assign sub_1 = sub_0;
    assign sub_2 = sub_0;
    assign sub_3 = sub_0;

    always @(posedge clk_pixel) begin
        if (sample_strobe) begin
            if (clk_audio_counter == CLK_AUDIO_COUNTER_END) begin
                clk_audio_counter <= 6'd0;
                internal_wrap <= ~internal_wrap;
            end else
                clk_audio_counter <= clk_audio_counter + 6'd1;
        end
    end

    always @(posedge clk_pixel)
        wrap_sync <= {internal_wrap, wrap_sync[1]};

    always @(posedge clk_pixel) begin
        if (wrap_sync[1] ^ wrap_sync[0]) begin
            cycle_time_stamp_counter <= 15'd0;
            cycle_time_stamp <= {5'd0, cycle_time_stamp_counter + 15'd1};
            clk_audio_counter_wrap <= ~clk_audio_counter_wrap;
        end else
            cycle_time_stamp_counter <= cycle_time_stamp_counter + 15'd1;
    end

endmodule
