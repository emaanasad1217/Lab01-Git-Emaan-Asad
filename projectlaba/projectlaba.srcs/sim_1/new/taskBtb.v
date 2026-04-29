`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/27/2026 05:06:02 PM
// Design Name: 
// Module Name: taskBtb
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

module tb_Fibonacci();

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

        // 1. Initialize Inputs
        clk = 0;
        rst_raw = 1; 
        sw = 16'd10;  

        #100;

        rst_raw = 0;
        $display("\n==============================================");
        $display("   STARTING FIBONACCI SIMULATION");
        $display("==============================================\n");

        $monitor("Time: %0t ns | LEDs Display: %0d", $time, led);

       
        #15000; 

       
        $display("\n==============================================");
        $display("   COMPUTATION FINISHED. CHECKING DATA MEMORY:");
        $display("==============================================");
        
      
        $display("Mem[0] (Fib 0) : %0d", uut.u_datamem.mem[0]);
        $display("Mem[1] (Fib 1) : %0d", uut.u_datamem.mem[1]);
        $display("Mem[2] (Fib 2) : %0d", uut.u_datamem.mem[2]);
        $display("Mem[3] (Fib 3) : %0d", uut.u_datamem.mem[3]);
        $display("Mem[4] (Fib 4) : %0d", uut.u_datamem.mem[4]);
        $display("Mem[5] (Fib 5) : %0d", uut.u_datamem.mem[5]);
        $display("Mem[6] (Fib 6) : %0d", uut.u_datamem.mem[6]);
        $display("Mem[7] (Fib 7) : %0d", uut.u_datamem.mem[7]);
        $display("Mem[8] (Fib 8) : %0d", uut.u_datamem.mem[8]);
        $display("Mem[9] (Fib 9) : %0d", uut.u_datamem.mem[9]);

        $display("\n==============================================");
        $display("   SIMULATION COMPLETE");
        $display("==============================================\n");
        $finish;
    end

endmodule
