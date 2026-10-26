// SPDX-License-Identifier: MIT
// Hold synchronous reset until PLL lock has been stable for 65535 clocks.
// Reassert reset if lock drops, then stretch again after it returns.

module pll_reset (
    input  wire clk,
    input  wire locked,
    output wire reset
);

    reg [1:0]  locked_sync;
    reg [15:0] reset_cnt;

    always @(posedge clk) begin
        locked_sync <= {locked_sync[0], locked};
        if (!locked_sync[1])
            reset_cnt <= 16'd0;
        else if (reset_cnt != 16'hffff)
            reset_cnt <= reset_cnt + 16'd1;
    end

    assign reset = !locked_sync[1] || (reset_cnt != 16'hffff);

endmodule
