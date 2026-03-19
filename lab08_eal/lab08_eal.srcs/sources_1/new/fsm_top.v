
`timescale 1ns / 1ps
module fsm_top #(
    parameter CLK_DIV_MAX   = 25_000_000,
    parameter DEBOUNCE_STAB = 500_000
)(
    input  wire        clk,
    input  wire        btn_reset_raw,
    input  wire [15:0] sw_raw,
    output wire [15:0] led_out         
);
    wire        slow_clk;
    wire        btn_reset;
    wire [31:0] sw_synced_bus;
    wire [15:0] sw_synced;
    wire [31:0] led_module_readData_nc;

    
    clock_divider #(
        .MAX_COUNT(CLK_DIV_MAX)
    ) u_clkdiv (
        .clk      (clk),
        .rst      (1'b0),
        .slow_clk (slow_clk)
    );

   
    debouncer #(
        .STABLE_MAX(DEBOUNCE_STAB)
    ) u_debouncer (
        .clk   (clk),
        .pbin  (btn_reset_raw),
        .pbout (btn_reset)
    );

    
    leds u_leds (
        .clk         (clk),
        .rst         (btn_reset),
        .btns        (16'd0),
        .writeData   (32'd0),
        .writeEnable (1'b0),
        .readEnable  (1'b1),
        .memAddress  (30'd0),
        .switches    (sw_raw),
        .readData    (sw_synced_bus)
    );

    assign sw_synced = sw_synced_bus[15:0];

    
    reg  [15:0] counter_reg;            

    switches u_switches (
        .clk         (clk),
        .rst         (btn_reset),
        .writeData   ({16'd0, counter_reg}),  
        .writeEnable (1'b1),                  
        .readEnable  (1'b0),
        .memAddress  (30'd0),
        .readData    (led_module_readData_nc),
        .leds        (led_out)                
    );

    // ----------------------------------------------------------------
    // FSM
    // ----------------------------------------------------------------
    localparam WAIT  = 1'b0;
    localparam COUNT = 1'b1;

    reg        state;
    reg [15:0] sw_prev;

    always @(posedge clk) begin
        if (btn_reset) begin
            state       <= WAIT;
            counter_reg <= 16'd0;
            sw_prev     <= 16'd0;
        end else begin
            sw_prev <= sw_synced;

            case (state)
                WAIT: begin
                    counter_reg <= 16'd0;
                    if (sw_synced != 16'd0 && sw_prev == 16'd0) begin
                        counter_reg <= sw_synced;
                        state       <= COUNT;
                    end
                end

                COUNT: begin
                    if (slow_clk) begin
                        if (counter_reg == 16'd1) begin
                            counter_reg <= 16'd0;
                            state       <= WAIT;
                        end else begin
                            counter_reg <= counter_reg - 16'd1;
                        end
                    end
                end

                default: begin
                    state       <= WAIT;
                    counter_reg <= 16'd0;
                end
            endcase
        end
    end

endmodule
