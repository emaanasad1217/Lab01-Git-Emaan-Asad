`timescale 1ns / 1ps

// Main Control Unit
//
// Supported instructions:
//   R-type  : ADD SUB SLL SRL AND OR XOR        (opcode 0110011)
//   I-arith : ADDI ANDI ORI XORI SLLI SRLI      (opcode 0010011)
//   Load    : LW LH LB                           (opcode 0000011)
//   Store   : SW SH SB                           (opcode 0100011)
//   Branch  : BEQ BNE BLT BGE                    (opcode 1100011)
//   JAL     : Jump-and-link                      (opcode 1101111)  ** ADDED **
//   JALR    : Jump-and-link register             (opcode 1100111)  ** ADDED **
//   LUI     : Load upper immediate               (opcode 0110111)  ** ADDED **
//   AUIPC   : Add upper immediate to PC          (opcode 0010111)  ** ADDED **
//
// ALUOp encoding:
//   2'b00  Load / Store       -> ALU does ADD
//   2'b01  Branch             -> ALU does SUB (for BEQ/BNE zero check)
//   2'b10  R-type             -> ALUControl decodes funct3/funct7
//   2'b11  I-type arithmetic  -> ALUControl decodes funct3

module MainControl (
    input  wire [6:0] opcode,
    output reg        RegWrite,
    output reg        ALUSrc,
    output reg        MemRead,
    output reg        MemWrite,
    output reg        MemtoReg,  // 0 = ALU result, 1 = memory data, 2 = PC+4 (JAL/JALR)
    output reg        Branch,
    output reg        Jump,       // NEW: 1 for JAL/JALR
    output reg [1:0]  ALUOp
);

    localparam R_TYPE  = 7'b0110011;
    localparam I_ARITH = 7'b0010011;
    localparam LOAD    = 7'b0000011;
    localparam STORE   = 7'b0100011;
    localparam BRANCH  = 7'b1100011;
    localparam JAL     = 7'b1101111;
    localparam JALR    = 7'b1100111;
    localparam LUI     = 7'b0110111;
    localparam AUIPC   = 7'b0010111;

    always @(*) begin
        // safe defaults
        RegWrite = 1'b0;
        ALUSrc   = 1'b0;
        MemRead  = 1'b0;
        MemWrite = 1'b0;
        MemtoReg = 1'b0;
        Branch   = 1'b0;
        Jump     = 1'b0;
        ALUOp    = 2'b00;

        case (opcode)

            R_TYPE: begin
                RegWrite = 1'b1;
                ALUSrc   = 1'b0;
                MemtoReg = 1'b0;
                ALUOp    = 2'b10;
            end

            I_ARITH: begin
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                MemtoReg = 1'b0;
                ALUOp    = 2'b11;
            end

            LOAD: begin
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                MemRead  = 1'b1;
                MemtoReg = 1'b1;
                ALUOp    = 2'b00;
            end

            STORE: begin
                ALUSrc   = 1'b1;
                MemWrite = 1'b1;
                ALUOp    = 2'b00;
            end

            BRANCH: begin
                Branch   = 1'b1;
                ALUOp    = 2'b01;
            end

            // JAL: rd = PC+4, PC = PC + J-imm
            // ALUSrc=1 so ALU gets imm (not used for result, but avoids X)
            JAL: begin
                RegWrite = 1'b1;
                Jump     = 1'b1;
                ALUSrc   = 1'b1;
                MemtoReg = 1'b0; // writeback mux selects PC+4 (handled in datapath)
                ALUOp    = 2'b00;
            end

            // JALR: rd = PC+4, PC = (rs1 + imm) & ~1
            JALR: begin
                RegWrite = 1'b1;
                Jump     = 1'b1;
                ALUSrc   = 1'b1;
                MemtoReg = 1'b0;
                ALUOp    = 2'b00;
            end

            // LUI: rd = imm << 12  (ALU receives 0 + imm with ALUSrc=1, ADD)
            LUI: begin
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                MemtoReg = 1'b0;
                ALUOp    = 2'b00;
            end

            // AUIPC: rd = PC + (imm << 12) - handled in datapath
            AUIPC: begin
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
                MemtoReg = 1'b0;
                ALUOp    = 2'b00;
            end

            default: begin
                // all signals already 0
            end

        endcase
    end

endmodule