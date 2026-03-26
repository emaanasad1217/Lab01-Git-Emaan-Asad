`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/26/2026 11:03:58 AM
// Design Name: 
// Module Name: main_control
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


// ============================================================
// Module: main_control
// Description: Main Control Unit for RISC-V (RV32I subset)
//              Decodes 7-bit opcode to generate control signals.
//
// Supported Instructions:
//   R-type  : opcode = 0110011
//   I-type  : opcode = 0010011 (ALU immediate)
//   lw      : opcode = 0000011
//   sw      : opcode = 0100011
//   beq     : opcode = 1100011
//
// Outputs:
//   RegWrite  - Enable write to register file
//   ALUOp     - ALU operation selector (2-bit)
//              00 = add (for lw/sw)
//              01 = subtract (for beq)
//              10 = R-type / I-type (use funct fields)
//   MemRead   - Enable memory read
//   MemWrite  - Enable memory write
//   ALUSrc    - 0 = register B, 1 = immediate
//   MemtoReg  - 0 = ALU result, 1 = memory data
//   Branch    - Branch enable
// ============================================================

module main_control (
    input  wire [6:0] opcode,
    output reg        RegWrite,
    output reg [1:0]  ALUOp,
    output reg        MemRead,
    output reg        MemWrite,
    output reg        ALUSrc,
    output reg        MemtoReg,
    output reg        Branch
);

    // Opcode definitions
    localparam R_TYPE  = 7'b0110011;  // R-type (add, sub, and, or, slt)
    localparam I_ALU   = 7'b0010011;  // I-type ALU (addi, andi, ori, slti)
    localparam LOAD    = 7'b0000011;  // Load (lw)
    localparam STORE   = 7'b0100011;  // Store (sw)
    localparam BRANCH  = 7'b1100011;  // Branch (beq)

    always @(*) begin
        // Default (safe) values - avoid latches
        RegWrite = 1'b0;
        ALUOp    = 2'b00;
        MemRead  = 1'b0;
        MemWrite = 1'b0;
        ALUSrc   = 1'b0;
        MemtoReg = 1'b0;
        Branch   = 1'b0;

        case (opcode)
            R_TYPE: begin
                // Register-register operations
                RegWrite = 1'b1;
                ALUOp    = 2'b10;
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                ALUSrc   = 1'b0;  // Use register operand
                MemtoReg = 1'b0;  // Write ALU result
                Branch   = 1'b0;
            end

            I_ALU: begin
                // Immediate ALU operations (addi, andi, ori, slti)
                RegWrite = 1'b1;
                ALUOp    = 2'b10;
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                ALUSrc   = 1'b1;  // Use immediate operand
                MemtoReg = 1'b0;  // Write ALU result
                Branch   = 1'b0;
            end

            LOAD: begin
                // Load word: lw rd, imm(rs1)
                RegWrite = 1'b1;
                ALUOp    = 2'b00;  // Add for address calculation
                MemRead  = 1'b1;
                MemWrite = 1'b0;
                ALUSrc   = 1'b1;  // Use immediate offset
                MemtoReg = 1'b1;  // Write memory data to register
                Branch   = 1'b0;
            end

            STORE: begin
                // Store word: sw rs2, imm(rs1)
                RegWrite = 1'b0;
                ALUOp    = 2'b00;  // Add for address calculation
                MemRead  = 1'b0;
                MemWrite = 1'b1;
                ALUSrc   = 1'b1;  // Use immediate offset
                MemtoReg = 1'bx;  // Don't care (no register write)
                Branch   = 1'b0;
            end

            BRANCH: begin
                // Branch equal: beq rs1, rs2, offset
                RegWrite = 1'b0;
                ALUOp    = 2'b01;  // Subtract for comparison
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                ALUSrc   = 1'b0;  // Use register operand
                MemtoReg = 1'bx;  // Don't care (no register write)
                Branch   = 1'b1;
            end

            default: begin
                // Unknown opcode - all outputs remain at safe defaults
                RegWrite = 1'b0;
                ALUOp    = 2'b00;
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                ALUSrc   = 1'b0;
                MemtoReg = 1'b0;
                Branch   = 1'b0;
            end
        endcase
    end

endmodule
