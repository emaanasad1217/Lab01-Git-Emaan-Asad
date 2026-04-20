`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/13/2026 11:59:38 AM
// Design Name: 
// Module Name: programCounter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ProgramCounter(
    input clk,
    input reset,
    input [31:0] PC_in,
    output reg [31:0] PC_out
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            PC_out <= 32'b0;
        else
            PC_out <= PC_in;
    end
endmodule