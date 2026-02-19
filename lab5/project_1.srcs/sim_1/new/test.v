`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/19/2026 11:08:30 AM
// Design Name: 
// Module Name: test
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
 
module top_system_tb();
 
    // Inputs
    reg clk;
    reg btn_rst;
    reg [15:0] sw_hardware;
 
    // Outputs
    wire [15:0] led_hardware;
 

    top_system uut (
        .clk(clk),
        .btn_rst(btn_rst),
        .sw_hardware(sw_hardware),
        .led_hardware(led_hardware)
    );
 
 
    initial clk = 0;
    always #5 clk = ~clk;
 
   
    initial begin

        btn_rst = 0;
        sw_hardware = 16'h0000;

       
        #20 btn_rst = 1;
        #100 btn_rst = 0;
        #50;
 
        
       
        sw_hardware = 16'h0005;
        
        #100;
       
 
       
        sw_hardware = 16'h0000;
    
        #600;
 


        sw_hardware = 16'h000A; 
        #200;
        sw_hardware = 16'h0000;
        #500; 
   
        btn_rst = 1;
        #100;
        btn_rst = 0;
        #100;

 
        
        #5000;
        $finish;
        
    end

    
 
endmodule