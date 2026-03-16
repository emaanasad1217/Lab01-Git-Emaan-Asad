`timescale 1ns / 1ps

module LEDModule (
    input         clk,
    input         rst,
    input         LEDWrite,
    input  [15:0] writeData,
    output [15:0] leds
);
    reg [15:0] led_reg;

    always @(posedge clk or posedge rst) begin
        if (rst)
            led_reg <= 16'b0;
        else if (LEDWrite)
            led_reg <= writeData;
    end

    assign leds = led_reg;

endmodule