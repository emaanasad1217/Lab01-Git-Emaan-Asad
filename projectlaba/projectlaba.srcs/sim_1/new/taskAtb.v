`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/27/2026 04:26:02 PM
// Design Name: 
// Module Name: taskAtb
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


module tb_Countdown();

    // -------------------------------------------------------
    // Testbench Signals
    // -------------------------------------------------------
    reg clk;
    reg rst_raw;
    reg [15:0] sw;
    wire [15:0] led;

    // -------------------------------------------------------
    // Instantiate the Top-Level Processor System
    // -------------------------------------------------------
    // CRITICAL: We override CLK_DIVIDER to 2.
    // This makes clk_en pulse every 2 clock cycles instead of
    // 25,000,000, speeding up simulation by 12.5 million times!
    ProcessorFPGA #(
        .CLK_DIVIDER(2) 
    ) uut (
        .clk(clk),
        .rst_raw(rst_raw),
        .sw(sw),
        .led(led)
    );

    // -------------------------------------------------------
    // Clock Generation (100 MHz -> 10ns period)
    // -------------------------------------------------------
    always #5 clk = ~clk;

    // -------------------------------------------------------
    // Test Sequence
    // -------------------------------------------------------
    initial begin
        // 1. Initialize Inputs
        force uut.rst_clean = rst_raw;
        clk = 0;
        rst_raw = 1; // Assert physical reset button
        sw = 16'd5;  // Set switches to 5 (binary 0000000000000101)

        // Wait a bit to let the system stabilize in reset
        #100;

        // 2. Release Reset and start execution
        rst_raw = 0;
        $display("\n==============================================");
        $display("   STARTING LED COUNTDOWN SIMULATION");
        $display("   Starting value on Switches: %0d", sw);
        $display("==============================================\n");

        // 3. Monitor the LEDs
        // $monitor will automatically print a line to the console 
        // every single time the 'led' wire changes its value.
        $monitor("Time: %0t ns | LEDs: %b (Decimal: %0d)", $time, led, led);

        // 4. Wait for the countdown to happen
        // Since your assembly code has a delay loop built-in, we need 
        // to let the simulation run for a decent chunk of simulated time 
        // so it can chew through those delay instructions.
        #2000; 

        // 5. Test the "Stop/Cancel" condition
        $display("\n--- Testing Cancel/Stop Condition ---");
        $display("Flipping switches to trigger the 0xC00 cancel logic...");
        sw = 16'hFFFF; // Simulate flipping all switches up
        
        // Wait to see the LEDs react to the cancel signal
        #50000;

        $display("\n==============================================");
        $display("   SIMULATION COMPLETE");
        $display("==============================================\n");
        $finish;
    end

endmodule
