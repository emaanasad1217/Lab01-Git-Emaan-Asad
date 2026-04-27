`timescale 1ns / 1ps

// ALU Control Unit
//
// ALUControl encoding:
//   4'b0000  AND
//   4'b0001  OR
//   4'b0010  ADD
//   4'b0100  XOR
//   4'b0110  SUB
//   4'b1000  SLL
//   4'b1001  SRL
//
// ALUOp:
//   2'b00  -> ADD  (load / store / JAL / JALR / LUI / AUIPC)
//   2'b01  -> SUB  (branch: BEQ/BNE use Zero flag after subtraction)
//   2'b10  -> R-type: decode funct3 + funct7[5]
//   2'b11  -> I-type arithmetic: decode funct3   ** FIXED: was only ADDI **

module ALUControl (
    input  wire [1:0] ALUOp,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,
    output reg  [3:0] ALUControl
);

    always @(*) begin
        case (ALUOp)

            // Load / Store / JAL / JALR / LUI / AUIPC  -> ADD
            2'b00: ALUControl = 4'b0010;

            // Branch -> SUB (zero flag used for BEQ; BNE inverts zero in datapath)
            2'b01: ALUControl = 4'b0110;

            // R-type: funct3 + funct7[5] select operation
            2'b10: begin
                case (funct3)
                    3'b000: begin
                        if (funct7[5] == 1'b1)
                            ALUControl = 4'b0110; // SUB
                        else
                            ALUControl = 4'b0010; // ADD
                    end
                    3'b001: ALUControl = 4'b1000; // SLL
                    3'b100: ALUControl = 4'b0100; // XOR
                    3'b101: ALUControl = 4'b1001; // SRL
                    3'b110: ALUControl = 4'b0001; // OR
                    3'b111: ALUControl = 4'b0000; // AND
                    default: ALUControl = 4'b0010;
                endcase
            end

            // I-type arithmetic: decode funct3
            // FIX: previous version only handled ADDI (funct3=000); all others
            // fell to the default ADD, silently corrupting ANDI/ORI/XORI/SLLI/SRLI.
            2'b11: begin
                case (funct3)
                    3'b000: ALUControl = 4'b0010; // ADDI  -> ADD
                    3'b001: ALUControl = 4'b1000; // SLLI  -> SLL
                    3'b100: ALUControl = 4'b0100; // XORI  -> XOR
                    3'b101: ALUControl = 4'b1001; // SRLI  -> SRL (funct7=0)
                                                  // SRAI would need funct7[5] check
                    3'b110: ALUControl = 4'b0001; // ORI   -> OR
                    3'b111: ALUControl = 4'b0000; // ANDI  -> AND
                    default: ALUControl = 4'b0010;
                endcase
            end

            default: ALUControl = 4'b0010;

        endcase
    end

endmodule