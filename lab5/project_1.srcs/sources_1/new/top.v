`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/19/2026 10:23:04 AM
// Design Name: 
// Module Name: top
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


module top_system (
    input clk,              
    input btn_rst,          
    input [15:0] sw_hardware,
    output [15:0] led_hardware
);
    wire rst_debounced;
    wire [15:0] current_count;
    
    reg [26:0] clk_div = 0;
reg tick_1hz = 0;

always @(posedge clk or posedge rst_debounced) begin
    if (rst_debounced) begin
        clk_div <= 0;
        tick_1hz <= 0;
    end
    else begin
        if (clk_div == 100_000_000) begin  
            clk_div <= 0;
            tick_1hz <= 1'b1;
        end else begin
            clk_div <= clk_div + 1;
            tick_1hz <= 1'b0;
        end
    end
end

 
   
    debouncer rst_db (
        .clk(clk),
        .pbin(btn_rst),
        .pbout(rst_debounced)
    );
 
    // --- FSM Timer ---
    countdown_timer timer_inst (
        .clk(clk),
        .tick(tick_1hz),      
        .rst(rst_debounced),
        .sw_in(sw_hardware),
        .count_out(current_count)
    );
 
    assign led_hardware = current_count;
 
endmodule