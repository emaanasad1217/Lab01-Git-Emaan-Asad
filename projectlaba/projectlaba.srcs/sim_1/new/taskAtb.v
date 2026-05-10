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

    reg clk;
    reg rst_raw;
    reg [15:0] sw;
    wire [15:0] led;

    ProcessorFPGA #(
        .CLK_DIVIDER(2) 
    ) uut (
        .clk(clk),
        .rst_raw(rst_raw),
        .sw(sw),
        .led(led)
    );

    always #5 clk = ~clk;


    initial begin
        // 1. Initialize Inputs
        force uut.rst_clean = rst_raw;
        clk = 0;
        rst_raw = 1; // Assert physical reset button
        sw = 16'd5;  

     
        #100;
        // 2. Release Reset and start execution
        rst_raw = 0;
        $display("   STARTING LED COUNTDOWN SIMULATION");
        $display("   Starting value on Switches: %0d", sw);

        $monitor("Time: %0t ns | LEDs: %b (Decimal: %0d)", $time, led, led);

        #2000; 

        $display("\n--- Testing Cancel/Stop Condition ---");
        $display("Flipping switches to trigger the 0xC00 cancel logic...");
        sw = 16'hFFFF; 
        #50000;
        $display("   SIMULATION COMPLETE");
        $finish;
    end

endmodule
