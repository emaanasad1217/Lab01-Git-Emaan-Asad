`timescale 1ns / 1ps
module immGen(
    input [31:0] inst,
    output reg [31:0] imm
);
    always @(*) begin
        case(inst[6:0])
            7'h13: imm = {{20{inst[31]}}, inst[31:20]};                 
            7'h23: imm = {{20{inst[31]}}, inst[31:25], inst[11:7]};    
            7'h63: imm = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0}; 
            default: imm = 32'b0;
        endcase
    end
endmodule