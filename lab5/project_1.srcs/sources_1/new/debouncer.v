`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/19/2026 10:28:02 AM
// Design Name: 
// Module Name: debouncer
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

module debouncer(
    input clk,
    input pbin,
    output reg pbout = 0 
);
    
    reg [22:0] count = 0; 
    reg sync_0 = 0, sync_1 = 0;
 
    always @(posedge clk) begin
        sync_0 <= pbin;
        sync_1 <= sync_0;
 
        if (sync_1 == pbout) begin
            count <= 0; 
        end else begin
            if (count < 5_000_000) begin
                count <= count + 1'b1;
            end else begin
                pbout <= sync_1; 
                count <= 0;
            end
        end
    end
endmodule
