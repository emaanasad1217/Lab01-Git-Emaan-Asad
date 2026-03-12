`timescale 1ns / 1ps
module ALU_1bit (
    input a,                // 1-bit from A
    input b,                // 1-bit from B (already inverted if SUB)
    input cin,              // Carry in
    input [3:0] alucontrol, // Same control as top module
    output reg result,      // 1-bit result
    output reg cout         // Carry out (only used in ADD/SUB)
);
    wire and_res = a & b;
    wire or_res  = a | b;
    wire xor_res = a ^ b;
    wire fa_sum;
    wire fa_cout;
    FullAdder fa (
        .a(a),
        .b(b),
        .cin(cin),
        .sum(fa_sum),
        .cout(fa_cout)
    );
    always @(*) begin
        cout = fa_cout;  
        if (alucontrol == 4'b0000)      // AND
            result = and_res;
        else if (alucontrol == 4'b0001) // OR
            result = or_res;
        else if (alucontrol == 4'b0100) // XOR
            result = xor_res;
        else if (alucontrol == 4'b0010 || alucontrol == 4'b0110) // ADD or SUB
            result = fa_sum;
        else
            result = 1'b0; // default (never used in normal operation)
    end
endmodule