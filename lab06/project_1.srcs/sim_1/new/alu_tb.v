`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/26/2026 10:24:58 AM
// Design Name: 
// Module Name: alu_tb
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

module alu_1bit_tb;
    reg A;
    reg B;
    reg [3:0] ALUControl;

    wire ALUResult;
    wire Zero;
    alu_1bit uut (
        .A(A),
        .B(B),
        .ALUControl(ALUControl),
        .ALUResult(ALUResult),
        .Zero(Zero)
    );

    initial begin
        A = 0;
        B = 0;
        ALUControl = 0;
        #10;

        // Test 1: AND
        ALUControl = 4'b0000; A = 1'b1; B = 1'b1; #10;
        ALUControl = 4'b0000; A = 1'b1; B = 1'b0; #10;
        // Test 2: OR
        ALUControl = 4'b0001; A = 1'b0; B = 1'b1; #10;
        ALUControl = 4'b0001; A = 1'b0; B = 1'b0; #10;
        // Test 3: ADD 
        ALUControl = 4'b0010; A = 1'b1; B = 1'b0; #10;
        ALUControl = 4'b0010; A = 1'b1; B = 1'b1; #10; 
        // Test 4: SUB 
        ALUControl = 4'b0110; A = 1'b1; B = 1'b1; #10; 
        ALUControl = 4'b0110; A = 1'b0; B = 1'b1; #10;
        // Test 5: XOR
        ALUControl = 4'b0100; A = 1'b1; B = 1'b0; #10;
        // Test 6: SLL 
        ALUControl = 4'b1000; A = 1'b1; B = 1'b1; #10;
        // Test 7: SRL 
        ALUControl = 4'b1001; A = 1'b1; B = 1'b0; #10;

        #10;
        $finish;
    end

endmodule