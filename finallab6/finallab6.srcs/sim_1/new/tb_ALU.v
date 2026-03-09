`timescale 1ns / 1ps
module tb_ALU;
    // Inputs
    reg [31:0] A;
    reg [31:0] B;
    reg [3:0] ALUControl;
    // Outputs
    wire [31:0] ALUResult;
    wire Zero;
    // Instantiate the ALU (same names as manual)
    ALU dut (
        .A(A),
        .B(B),
        .ALUControl(ALUControl),
        .ALUResult(ALUResult),
        .Zero(Zero)
    );
    initial begin
        A = 32'h00000005;   // 5
        B = 32'h00000003;   // 3
        ALUControl = 4'b0010; // ADD
        #50;

        A = 32'h0000000A;   // 10
        B = 32'h00000004;   // 4
        ALUControl = 4'b0110; // SUB
        #50;

        A = 32'h00000005;   // 5
        B = 32'h00000008;   // 8  
        ALUControl = 4'b0110; // SUB
        #50;
        A = 32'h0000000F;   // 000...1111
        B = 32'h00000005;   // 000...0101
        ALUControl = 4'b0000; // AND
        #50;

        A = 32'h0000000A;
        B = 32'h00000005;
        ALUControl = 4'b0001; // OR
        #50;

        A = 32'h0000000F;
        B = 32'h00000005;
        ALUControl = 4'b0100; // XOR
        #50;
        A = 32'h00000001;   // 1
        B = 32'h00000002;   // shift amount = 2
        ALUControl = 4'b1000; // SLL
        #50;

        A = 32'h00000001;
        B = 32'h0000001F;   // shift amount = 31
        ALUControl = 4'b1000; // SLL
        #50;

        A = 32'h000000F0;   // ...11110000
        B = 32'h00000003;   // shift amount = 3
        ALUControl = 4'b1001; // SRL
        #50;

        A = 32'h00000005;
        B = 32'h00000005;
        ALUControl = 4'b0110; // SUB ? 5-5 = 0
        #50;

        A = 32'h00000001;
        B = 32'h00000000;
        ALUControl = 4'b0010; // ADD ? 1+0 = 1
        #50;
        #100;
        $finish;
    end
endmodule