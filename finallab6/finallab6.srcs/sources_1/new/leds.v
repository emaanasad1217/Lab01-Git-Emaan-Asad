
`timescale 1ns / 1ps
// leds.v
// Reads and syncs raw switch pins (switches input ? readData).
// The switches input is the raw sw pins from the FPGA top level.
module leds (
    input              clk,
    input              rst,
    input  [15:0]      btns,
    input  [31:0]      writeData,
    input              writeEnable,
    input              readEnable,
    input  [29:0]      memAddress,
    input  [15:0]      switches,    // raw switch pins from FPGA
    output reg [31:0]  readData     // synced switch values
);
    reg [15:0] sync_stage1;

    always @(posedge clk) begin
        if (rst) begin
            sync_stage1 <= 16'd0;
            readData    <= 32'd0;
        end else begin
            sync_stage1     <= switches;
            readData[15:0]  <= sync_stage1;
            readData[31:16] <= 16'd0;
        end
    end
endmodule