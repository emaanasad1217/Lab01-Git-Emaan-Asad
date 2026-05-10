`timescale 1ns / 1ps

module tb_AUIPC();

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
     
        force uut.rst_clean = rst_raw;

        // Initialize Inputs
        clk = 0;
        rst_raw = 1; 
        sw = 16'd0;  

        #100; 
        
        rst_raw = 0; // Release reset to start the CPU
        
        $display("   STARTING AUIPC VERIFICATION");
       
        $monitor("Time: %0t ns | LEDs Output: %h (Hex)", $time, led);
        #200; 
        $display("SIMULATION COMPLETE");
        $finish;
    end

endmodule
