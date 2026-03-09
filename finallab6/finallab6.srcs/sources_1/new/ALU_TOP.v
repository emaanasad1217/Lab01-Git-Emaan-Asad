`timescale 1ns / 1ps
module ALU_TOP (
    input clk,              // 100 MHz from Basys3
    input rst_raw,          // raw reset button (U18) - will be debounced
    input [3:0] sw,         // 4 switches V17-W17 = ALUControl
    output [15:0] led       // 16 LEDs
);
    wire rst;
    debouncer #(
        .STABLE_MAX(500_000)   // ~5 ms debounce
    ) db_rst (
        .clk(clk),
        .pbin(rst_raw),
        .pbout(rst)
    );
    wire [31:0] A = 32'h10101010;
    wire [31:0] B = 32'h01010101;
    wire [3:0] ALUControl = sw;
    wire [31:0] ALUResult;
    wire Zero;
    ALU alu_inst (
        .A(A),
        .B(B),
        .ALUControl(ALUControl),
        .ALUResult(ALUResult),
        .Zero(Zero)
    );
    assign led[14:0] = ALUResult[14:0];
    assign led[15]   = Zero;
endmodule
