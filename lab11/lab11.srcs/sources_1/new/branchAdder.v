`timescale 1ns / 1ps
module branchAdder(
    input [31:0] pc,
    input [31:0] imm,
    output [31:0] out
);
    assign out = pc + (imm << 1);
endmodule