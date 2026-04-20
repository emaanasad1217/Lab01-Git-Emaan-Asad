`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/13/2026 12:03:59 PM
// Design Name: 
// Module Name: pcAdder
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


module pcAdder(
    input [31:0] a,
    input [31:0] b,
    output [31:0] out
);
    assign out = a + b;
endmodule
