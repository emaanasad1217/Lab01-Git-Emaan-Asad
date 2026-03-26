`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/26/2026 11:04:54 AM
// Design Name: 
// Module Name: alu_control
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
// Module: alu_control
// Description: ALU Control Unit for RISC-V (RV32I subset)
//              Generates 4-bit ALUControl signal based on
//              ALUOp (from main control), funct3, and funct7.
//
// ALUOp encoding (from main control):
//   00 ? Force ADD       (lw / sw address calc)
//   01 ? Force SUB       (beq comparison)
//   10 ? Use funct fields (R-type / I-type ALU)
//
// ALUControl encoding (output):
//   0000 ? AND
//   0001 ? OR
//   0010 ? ADD
//   0110 ? SUB
//   0111 ? SLT  (set less than)
//   1111 ? NOR  (optional / default for unknowns)
//
// funct7 bit used: bit 5 (funct7[5])
//   0 ? ADD variant
//   1 ? SUB variant  (for R-type sub only)
// ============================================================

module alu_control (
    input  wire [1:0] ALUOp,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,
    output reg  [3:0] ALUControl
);

    // funct3 encodings
    localparam F3_ADD_SUB = 3'b000;  // add / sub / addi
    localparam F3_SLL     = 3'b001;  // sll  (not implemented here)
    localparam F3_SLT     = 3'b010;  // slt / slti
    localparam F3_SLTU    = 3'b011;  // sltu (not implemented here)
    localparam F3_XOR     = 3'b100;  // xor  (not implemented here)
    localparam F3_SRL_SRA = 3'b101;  // srl/sra
    localparam F3_OR      = 3'b110;  // or / ori
    localparam F3_AND     = 3'b111;  // and / andi

    // funct7 discriminator (bit 5)
    // funct7[5] = 0 ? standard (ADD)
    // funct7[5] = 1 ? alternate (SUB for R-type, SRA for shifts)

    always @(*) begin
        ALUControl = 4'b0010;  // Default: ADD (safe fallback)

        case (ALUOp)
            // ------------------------------------------------
            // ALUOp = 00: Load / Store ? always ADD
            // ------------------------------------------------
            2'b00: begin
                ALUControl = 4'b0010;  // ADD
            end

            // ------------------------------------------------
            // ALUOp = 01: Branch (beq) ? always SUB
            // ------------------------------------------------
            2'b01: begin
                ALUControl = 4'b0110;  // SUB
            end

            // ------------------------------------------------
            // ALUOp = 10: R-type or I-type ALU
            //   Decode using funct3 (and funct7[5] for R-type)
            // ------------------------------------------------
            2'b10: begin
                case (funct3)
                    F3_ADD_SUB: begin
                        // R-type: funct7[5]=1 ? SUB, else ADD
                        // I-type (addi): funct7 is part of imm ? treat as 0
                        if (funct7[5] == 1'b1)
                            ALUControl = 4'b0110;  // SUB (R-type only)
                        else
                            ALUControl = 4'b0010;  // ADD / ADDI
                    end

                    F3_AND: begin
                        ALUControl = 4'b0000;  // AND / ANDI
                    end

                    F3_OR: begin
                        ALUControl = 4'b0001;  // OR / ORI
                    end

                    F3_SLT: begin
                        ALUControl = 4'b0111;  // SLT / SLTI
                    end

                    default: begin
                        // Unimplemented funct3 - safe default ADD
                        ALUControl = 4'b0010;
                    end
                endcase
            end

            // ------------------------------------------------
            // Default / undefined ALUOp ? ADD
            // ------------------------------------------------
            default: begin
                ALUControl = 4'b0010;  // ADD
            end
        endcase
    end

endmodule
