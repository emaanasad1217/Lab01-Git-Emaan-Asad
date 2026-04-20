`timescale 1ns / 1ps
module mux2(
    input [31:0] a, 
    input [31:0] b, 
    input s,        
    output [31:0] out
);
    assign out = s ? b : a;
endmodule