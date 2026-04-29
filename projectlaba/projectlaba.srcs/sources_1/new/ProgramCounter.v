`timescale 1ns / 1ps


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