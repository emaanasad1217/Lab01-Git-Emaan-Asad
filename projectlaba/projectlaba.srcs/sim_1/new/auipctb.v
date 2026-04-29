`timescale 1ns / 1ps

module tb_AUIPC();

    // -------------------------------------------------------
    // Testbench Signals
    // -------------------------------------------------------
    reg clk;
    reg rst_raw;
    reg [15:0] sw;
    wire [15:0] led;

    // -------------------------------------------------------
    // Instantiate the Processor
    // (Override CLK_DIVIDER to 2 for instant simulation)
    // -------------------------------------------------------
    ProcessorFPGA #(
        .CLK_DIVIDER(2) 
    ) uut (
        .clk(clk),
        .rst_raw(rst_raw),
        .sw(sw),
        .led(led)
    );

    // -------------------------------------------------------
    // Clock Generation (100 MHz)
    // -------------------------------------------------------
    always #5 clk = ~clk;

    // -------------------------------------------------------
    // Test Sequence
    // -------------------------------------------------------
    initial begin
        // Instantly bypass the hardware debouncer
        force uut.rst_clean = rst_raw;

        // Initialize Inputs
        clk = 0;
        rst_raw = 1; 
        sw = 16'd0;  

        #100; // Wait for system stabilization
        
        rst_raw = 0; // Release reset to start the CPU
        
        $display("\n==============================================");
        $display("   STARTING AUIPC VERIFICATION");
        $display("==============================================\n");

        // Monitor the LEDs in the console
        // We expect this to output 5008 (Hex)
        $monitor("Time: %0t ns | LEDs Output: %h (Hex)", $time, led);

        // Allow enough time for the 5 instructions to execute
        #200; 

        $display("\n==============================================");
        $display("   SIMULATION COMPLETE");
        $display("==============================================\n");
        $finish;
    end

endmodule