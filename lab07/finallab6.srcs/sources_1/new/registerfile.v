`timescale 1ns / 1ps
 
module RegisterFile(
    input clk,
    input rst,
    input writeEnable,
 
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,
 
    input [31:0] writeData,
 
    output [31:0] readData1,
    output [31:0] readData2
);
 
reg [31:0] regs [31:0];
integer i;
 

assign readData1 = (rs1 == 5'd0) ? 32'b0 : regs[rs1];
assign readData2 = (rs2 == 5'd0) ? 32'b0 : regs[rs2];
 

always @(posedge clk) begin
 
    if(rst) begin
        for(i=0;i<32;i=i+1)
            regs[i] <= 32'b0;
    end
    else begin
        if(writeEnable && rd != 0)
            regs[rd] <= writeData;
    end
 
end
 
endmodule
