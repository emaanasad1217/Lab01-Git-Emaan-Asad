`timescale 1ns / 1ps
module countdown_timer (

    input clk,

    input tick,           // 1Hz enable pulse

    input rst,            // Reset signal

    input [15:0] sw_in,

    output reg [15:0] count_out

);

    localparam IDLE  = 1'b0;

    localparam COUNT = 1'b1;
 
    reg state, next_state;

    reg [15:0] counter_reg;
 


    always @(posedge clk or posedge rst) begin

        if (rst) begin

            state <= IDLE;

            counter_reg <= 16'd0;

        end else begin

            state <= next_state;

            if (state == IDLE && sw_in > 0) begin

                counter_reg <= sw_in; 

            end else if (state == COUNT && tick && counter_reg > 0) begin

                counter_reg <= counter_reg - 1'b1; 

            end

        end

    end
 


    always @(*) begin

        case (state)

            IDLE:    next_state = (sw_in > 0) ? COUNT : IDLE;

            COUNT:   next_state = (counter_reg == 0) ? IDLE : COUNT;

            default: next_state = IDLE;

        endcase

    end
 
    always @(*) count_out = counter_reg;
 
endmodule
 