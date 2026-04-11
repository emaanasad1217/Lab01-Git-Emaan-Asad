`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2026 12:02:04 PM
// Design Name: 
// Module Name: im_tb
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


`timescale 1ns / 1ps

module instructionMemory_tb();

    // Parameters
    parameter OPERAND_LENGTH = 31;

    // Inputs
    reg [OPERAND_LENGTH:0] instAddress;

    // Outputs
    wire [31:0] instruction;

    // Instantiate the Unit Under Test (UUT)
    instructionMemory #(
        .OPERAND_LENGTH(OPERAND_LENGTH)
    ) uut (
        .instAddress(instAddress),
        .instruction(instruction)
    );

    initial begin
        // Initialize Inputs
        instAddress = 0;

        // Wait for memory to initialize (if using $readmemh)
        #10;

        $display("Starting Instruction Memory Verification...");
        $display("-----------------------------------------");

        // Test Case 1: First Instruction (Expected: 0x00500E13)
        instAddress = 32'd0;
        #10;
        $display("Address: %0d | Instruction: %h", instAddress, instruction);

        // Test Case 2: Second Instruction (Expected: 0x1FF00113)
        instAddress = 32'd4;
        #10;
        $display("Address: %0d | Instruction: %h", instAddress, instruction);

        // Test Case 3: Third Instruction (Expected: 0x30000293)
        instAddress = 32'd8;
        #10;
        $display("Address: %0d | Instruction: %h", instAddress, instruction);

        // Test Case 4: Loop through several instructions to verify sequencing
        $display("Sequencing Check:");
        for (integer i = 3; i < 10; i = i + 1) begin
            instAddress = i * 4;
            #10;
            $display("Address: %0d | Instruction: %h", instAddress, instruction);
        end

        // Test Case 5: Final Instruction (ret at address 152)
        instAddress = 32'd152;
        #10;
        $display("Address: %0d | Instruction: %h", instAddress, instruction);

        $display("-----------------------------------------");
        $display("Verification Complete.");
        $finish;
    end
      
endmodule
