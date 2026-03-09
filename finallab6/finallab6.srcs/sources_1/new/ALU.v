`timescale 1ns / 1ps
module ALU (
    input [31:0] A,           // 32-bit operand A
    input [31:0] B,           // 32-bit operand B
    input [3:0] ALUControl,   // 4-bit control signal
    output reg [31:0] ALUResult, // 32-bit result
    output Zero               // Zero flag for BEQ
);
    localparam AND_OP = 4'b0000;
    localparam OR_OP  = 4'b0001;
    localparam ADD_OP = 4'b0010;
    localparam SUB_OP = 4'b0110;
    localparam XOR_OP = 4'b0100;
    localparam SLL_OP = 4'b1000;
    localparam SRL_OP = 4'b1001;
    wire [31:0] B_for_adder;
    wire [32:0] carry;           // carry[0] = cin for LSB, carry[32] ignored
    wire [31:0] add_result;

    reg [31:0] B_temp;
    always @(*) begin
        if (ALUControl == SUB_OP)
            B_temp = ~B;      // invert for 2's complement subtraction
        else
            B_temp = B;
    end
    assign B_for_adder = B_temp;
    reg cin_lsb;
    always @(*) begin
        if (ALUControl == SUB_OP)
            cin_lsb = 1'b1;
        else
            cin_lsb = 1'b0;
    end
    assign carry[0] = cin_lsb;
    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : ripple_adder
            FullAdder fa (
                .a(A[i]),
                .b(B_for_adder[i]),
                .cin(carry[i]),
                .sum(add_result[i]),
                .cout(carry[i+1])
            );
        end
    endgenerate

    wire [31:0] and_result = A & B;
    wire [31:0] or_result  = A | B;
    wire [31:0] xor_result = A ^ B;
    wire [31:0] sll_result = A << B[4:0];   // Shift Left Logical
    wire [31:0] srl_result = A >> B[4:0];   // Shift Right Logical (zero fill)

    always @(*) begin
        if (ALUControl == AND_OP)
            ALUResult = and_result;
        else if (ALUControl == OR_OP)
            ALUResult = or_result;
        else if (ALUControl == XOR_OP)
            ALUResult = xor_result;
        else if (ALUControl == ADD_OP || ALUControl == SUB_OP)
            ALUResult = add_result;
        else if (ALUControl == SLL_OP)
            ALUResult = sll_result;
        else if (ALUControl == SRL_OP)
            ALUResult = srl_result;
        else
            ALUResult = 32'b0;   // default (safe)
    end
    assign Zero = (ALUResult == 32'b0);
endmodule