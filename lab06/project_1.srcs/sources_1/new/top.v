`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/26/2026 11:31:09 AM
// Design Name: 
// Module Name: top
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

module alu_top (
    input  wire [15:0] sw,    
    output wire [15:0] led   
);
    wire [31:0] alu_A;
    wire [31:0] alu_B;
    wire [3:0]  alu_ctrl;
    wire [31:0] alu_result;
    wire        alu_zero;

    assign alu_ctrl = sw[15:12]; 
    assign alu_A = {26'd0, sw[11:6]}; 
    assign alu_B = {26'd0, sw[5:0]};  
    alu_32bit ALU_Inst (
        .A(alu_A),
        .B(alu_B),
        .ALUControl(alu_ctrl),
        .ALUResult(alu_result),
        .Zero(alu_zero)
    );  
    assign led[15] = alu_zero;
    assign led[14:8] = 7'b0000000;
    assign led[7:0] = alu_result[7:0];

endmodule