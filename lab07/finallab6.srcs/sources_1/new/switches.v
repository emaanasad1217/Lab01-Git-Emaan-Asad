`timescale 1ns / 1ps
// switches.v
// Drives physical LEDs: when writeEnable is high, latches
// writeData[15:0] onto the leds output pins.
// readData mirrors the current LED state for FSM readback.
module switches (
    input              clk,
    input              rst,
    input  [31:0]      writeData,
    input              writeEnable,
    input              readEnable,
    input  [29:0]      memAddress,
    output reg [31:0]  readData,
    output reg [15:0]  leds        // ? physical LED pins
);
    always @(posedge clk) begin
        if (rst) begin
            leds     <= 16'd0;
            readData <= 32'd0;
        end else if (writeEnable) begin
            leds            <= writeData[15:0];
            readData[15:0]  <= writeData[15:0];
            readData[31:16] <= 16'd0;
        end
    end
endmodule