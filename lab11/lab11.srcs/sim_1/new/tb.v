`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/13/2026 12:17:55 PM
// Design Name: 
// Module Name: tb
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




module Task1_tb();
    // Clock and Reset
    reg clk;
    reg reset;

    // Control Signals
    reg PCSrc;
    reg [31:0] instruction;

    // Internal Wires (Outputs of modules)
    wire [31:0] pc_out;
    wire [31:0] pc_plus_4;
    wire [31:0] pc_branch;
    wire [31:0] next_pc;
    wire [31:0] imm_ext;


    
    ProgramCounter PC_Reg (
        .clk(clk), .reset(reset), .PC_in(next_pc), .PC_out(pc_out)
    );

    pcAdder Sequential_Adder (
        .a(pc_out), .b(32'd4), .out(pc_plus_4)
    );

    immGen Immediate_Generator (
        .inst(instruction), .imm(imm_ext)
    );

    branchAdder Branch_Target_Adder (
        .pc(pc_out), .imm(imm_ext), .out(pc_branch)
    );

    mux2 Next_PC_Mux (
        .a(pc_plus_4), .b(pc_branch), .s(PCSrc), .out(next_pc)
    );


    always #5 clk = ~clk;

    initial begin
   
        clk = 0; reset = 1; PCSrc = 0; instruction = 32'b0;
        #12 reset = 0;

        
        #20; 
        #10; 

        // 3. Test Immediate Gen (B-type: beq x1, x2, offset=8)
        // Instruction: 0000000 00010 00001 000 0010 0 1100011 (Hex: 00208463)
        instruction = 32'h00208463; 
        #5; 

        // 4. Test Branch Update (PCSrc = 1)
        PCSrc = 1; 
        #10; // At posedge, PC should jump to PC + (imm << 1)
        
        // 5. Return to Sequential
        PCSrc = 0;
        #10;

        $stop;
    end
endmodule
