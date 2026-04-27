//`timescale 1ns / 1ps
//// ============================================================
//// branchAdder.v
//// Lab 11 - Task 1
////
//// Computes the branch target address: PC + (imm << 1)
////
//// Why << 1?
////   RISC-V branch immediates from immGen already have bit[0]=0
////   (branches are halfword aligned). The shift by 1 converts
////   the halfword-count offset into a byte address offset.
////   This gives the correct target byte address.
////
//// Pure combinational - no clock.
//// ============================================================
//module branchAdder (
//    input  wire [31:0] PC,          // current PC
//    input  wire [31:0] imm,         // sign-extended immediate from immGen
//    output wire [31:0] BranchTarget // PC + (imm << 1)
//);

//    assign BranchTarget = PC + (imm << 1);

//endmodule






`timescale 1ns / 1ps

// computes the branch target address: PC + (imm << 1)

module branchAdder (
    input  wire [31:0] PC,  
    input  wire [31:0] imm, 
    output wire [31:0] BranchTarget 
);
    assign BranchTarget = PC + imm; // Removed the redundant << 1
endmodule

