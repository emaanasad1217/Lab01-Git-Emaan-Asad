`timescale 1ns / 1ps

// Program Counter
// Clocked on the fast system clock throughout.
// Only advances when clk_en (the slow_clk pulse from clock_divider) is high,
// so the processor executes one instruction per slow-clock period.
//
// Using a clock enable instead of driving the flip-flop from slow_clk directly
// keeps everything on one clock domain and avoids gated-clock timing issues.

module ProgramCounter (
    input  wire        clk,
    input  wire        clk_en,   // 1-cycle pulse from clock_divider
    input  wire        rst,
    input  wire [31:0] PC_Next,
    output reg  [31:0] PC
);

    always @(posedge clk) begin
        if (rst)
            PC <= 32'h00000000;
        else if (clk_en)
            PC <= PC_Next;
    end

endmodule