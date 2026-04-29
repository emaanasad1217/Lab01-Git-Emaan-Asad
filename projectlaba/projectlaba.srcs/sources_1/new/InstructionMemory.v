`timescale 1ns / 1ps

module InstructionMemory #(
    parameter OPERAND_LENGTH = 31
)(
    input  [OPERAND_LENGTH:0] instAddress, 
    output reg [31:0]         instruction  
);
    
    reg [31:0] memory [0:63];
    initial begin
       
        $readmemh("fibonnaci.mem", memory);
    end
  
    always @(*) begin
        instruction = memory[instAddress >> 2];
    end
endmodule





