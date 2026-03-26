// ============================================================
// Testbench: tb_control_units
// Description: Verifies Main Control Unit and ALU Control Unit
//              for all supported RISC-V RV32I instructions.
// ============================================================

`timescale 1ns / 1ps

module tb_control_units;

    // --------------------------------------------------------
    // DUT: Main Control Unit
    // --------------------------------------------------------
    reg  [6:0] opcode;
    wire       RegWrite, MemRead, MemWrite, ALUSrc, MemtoReg, Branch;
    wire [1:0] ALUOp;

    main_control uut_main (
        .opcode   (opcode),
        .RegWrite (RegWrite),
        .ALUOp    (ALUOp),
        .MemRead  (MemRead),
        .MemWrite (MemWrite),
        .ALUSrc   (ALUSrc),
        .MemtoReg (MemtoReg),
        .Branch   (Branch)
    );

    // --------------------------------------------------------
    // DUT: ALU Control Unit
    // ALUOp connected directly from main_control output
    // --------------------------------------------------------
    reg  [2:0] funct3;
    reg  [6:0] funct7;
    wire [3:0] ALUControl;

    alu_control uut_alu (
        .ALUOp      (ALUOp),
        .funct3     (funct3),
        .funct7     (funct7),
        .ALUControl (ALUControl)
    );

    // --------------------------------------------------------
    // Main test sequence
    // --------------------------------------------------------
    initial begin

        // Initialize inputs
        opcode = 7'b0;
        funct3 = 3'b0;
        funct7 = 7'b0;
        #10;

        // --------------------------------------------------
        // R-type: add
        // opcode=0110011, funct3=000, funct7=0000000
        // --------------------------------------------------
        opcode = 7'b0110011;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        #10;

        // --------------------------------------------------
        // R-type: sub
        // opcode=0110011, funct3=000, funct7=0100000
        // --------------------------------------------------
        opcode = 7'b0110011;
        funct3 = 3'b000;
        funct7 = 7'b0100000;
        #10;

        // --------------------------------------------------
        // R-type: and
        // opcode=0110011, funct3=111, funct7=0000000
        // --------------------------------------------------
        opcode = 7'b0110011;
        funct3 = 3'b111;
        funct7 = 7'b0000000;
        #10;

        // --------------------------------------------------
        // R-type: or
        // opcode=0110011, funct3=110, funct7=0000000
        // --------------------------------------------------
        opcode = 7'b0110011;
        funct3 = 3'b110;
        funct7 = 7'b0000000;
        #10;

        // --------------------------------------------------
        // Load (lb/lw): opcode=0000011
        // --------------------------------------------------
        opcode = 7'b0000011;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        #10;

        // --------------------------------------------------
        // Store (sb/sw): opcode=0100011
        // --------------------------------------------------
        opcode = 7'b0100011;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        #10;

        // --------------------------------------------------
        // Branch (beq): opcode=1100011
        // --------------------------------------------------
        opcode = 7'b1100011;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        #10;

        // --------------------------------------------------
        // Unknown opcode - default safe case (all outputs 0)
        // --------------------------------------------------
        opcode = 7'b1111111;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        #10;

        $display("Simulation complete.");
        $finish;
    end

endmodule