`timescale 1ns / 1ps

// Immediate Generator
// Extracts and sign-extends the immediate value from a 32-bit RISC-V instruction.
// Supports I-type, S-type, B-type, U-type (LUI/AUIPC), J-type (JAL).

module immGen (
    input  wire [31:0] instruction,
    output reg  [31:0] imm_out
);

    wire [6:0] opcode = instruction[6:0];

    localparam LOAD    = 7'b0000011; // I-type: lw, lh, lb
    localparam I_ARITH = 7'b0010011; // I-type: addi, ori, xori, andi, slli, srli
    localparam JALR    = 7'b1100111; // I-type: jalr
    localparam STORE   = 7'b0100011; // S-type: sw, sh, sb
    localparam BRANCH  = 7'b1100011; // B-type: beq, bne, blt, bge
    localparam LUI     = 7'b0110111; // U-type: lui
    localparam AUIPC   = 7'b0010111; // U-type: auipc
    localparam JAL     = 7'b1101111; // J-type: jal

    always @(*) begin
        case (opcode)

      
            // I-type: Load, ADDI/ANDI/ORI/XORI/SLLI/SRLI, JALR
            // imm[11:0] = instr[31:20], sign-extended from bit 31
     
            LOAD, I_ARITH, JALR: begin
                imm_out = {{20{instruction[31]}}, instruction[31:20]};
            end

      
            // S-type: Store (sw, sh, sb)
            // imm[11:5] = instr[31:25], imm[4:0] = instr[11:7]
      
            STORE: begin
                imm_out = {{20{instruction[31]}},
                           instruction[31:25],
                           instruction[11:7]};
            end

          
            // B-type: Branch (beq, bne, blt, bge)
            // Bits are scattered in the encoding; reassemble:
            //   imm[12]   = instr[31]
            //   imm[11]   = instr[7]
            //   imm[10:5] = instr[30:25]
            //   imm[4:1]  = instr[11:8]
            //   imm[0]    = 0  (branches are always halfword-aligned)
            // FIX: previous version was missing the 1'b0 at bit[0],
            // causing every branch target to be 2 bytes short.
       
            BRANCH: begin
                imm_out = {{19{instruction[31]}},
                           instruction[31],
                           instruction[7],
                           instruction[30:25],
                           instruction[11:8],
                           1'b0};
            end

      
            // U-type: LUI, AUIPC
            // imm[31:12] = instr[31:12], lower 12 bits are 0
      
            LUI, AUIPC: begin
                imm_out = {instruction[31:12], 12'b0};
            end

        
            // J-type: JAL
            //   imm[20]    = instr[31]
            //   imm[10:1]  = instr[30:21]
            //   imm[11]    = instr[20]
            //   imm[19:12] = instr[19:12]
            //   imm[0]     = 0
       
            JAL: begin
                imm_out = {{11{instruction[31]}},
                           instruction[31],
                           instruction[19:12],
                           instruction[20],
                           instruction[30:21],
                           1'b0};
            end

            default: begin
                imm_out = 32'd0;
            end

        endcase
    end

endmodule