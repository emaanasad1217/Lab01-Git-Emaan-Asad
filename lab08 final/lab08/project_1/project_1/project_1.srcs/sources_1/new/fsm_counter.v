module fsm_counter(
   input clk,
   input rst,
   input [15:0] switch_in,
   output reg [15:0] led_out
);

   parameter WAIT = 1'b0, COUNT = 1'b1;

   reg state;
   reg [15:0] counter;

   // -----------------------------
   // Slow clock divider (~1 second)
   // 100 MHz clock ? 1 Hz tick
   // -----------------------------
   reg [26:0] slow_clk;
   wire tick;

   assign tick = (slow_clk == 27'd100_000_000);

   always @(posedge clk or posedge rst) begin
       if (rst)
           slow_clk <= 0;
       else if (tick)
           slow_clk <= 0;
       else
           slow_clk <= slow_clk + 1;
   end

   // -----------------------------
   // FSM
   // -----------------------------
   always @(posedge clk or posedge rst) begin

       if (rst) begin
           state   <= WAIT;
           counter <= 0;
           led_out <= 0;
       end

       else begin
           case(state)

           // -------------------------
           //WAIT STATE
           // -------------------------
           WAIT: begin
               led_out <= 0;

               if (switch_in != 0) begin
                   counter <= switch_in;   // capture switch value
                   led_out <= switch_in;   // display immediately
                   state   <= COUNT;
               end
           end

           // -------------------------
           // COUNT STATE
           // -------------------------
           COUNT: begin
               led_out <= counter;

               if (tick) begin           // decrement only once per second
                   if (counter > 0)
                       counter <= counter - 1;
                   else
                       state <= WAIT;
               end
           end

           endcase
       end
   end

endmodule