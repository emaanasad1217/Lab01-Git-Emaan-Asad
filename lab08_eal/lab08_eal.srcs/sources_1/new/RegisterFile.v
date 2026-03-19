`timescale 1ns / 1ps
module RegisterFile (
    input  wire        clk,
    input  wire        rst,
    input  wire        WriteEnable,
    input  wire [4:0]  rs1,
    input  wire [4:0]  rs2,
    input  wire [4:0]  rd,
    input  wire [31:0] WriteData,
    output wire [31:0] ReadData1,   // asynchronous read port 1
    output wire [31:0] ReadData2    // asynchronous read port 2
);
    reg [31:0] regs [0:31];

    
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1)
            regs[i] = i;          // regs[0]=0, regs[1]=1, regs[2]=2 ... regs[31]=31
    end

    // Synchronous write, asynchronous reset
    // On reset: restore intial values
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1)
                regs[i] <= i;     
        end
        else if (WriteEnable && (rd != 5'b00000)) begin
            regs[rd] <= WriteData;
        end
    end

    // Asynchronous read ports 
    // x0 is hardwired to 0 
    assign ReadData1 = (rs1 == 5'b00000) ? 32'b0 : regs[rs1];
    assign ReadData2 = (rs2 == 5'b00000) ? 32'b0 : regs[rs2];

endmodule