

`timescale 1ns / 1ps

module fsm_top #(
    parameter DEBOUNCE_STAB = 500_000,
    parameter CLK_DIV_MAX   = 25_000_000
)(
    input  wire        clk,
    input  wire        rst_raw,
    input  wire [3:0]  sw,
    output wire [15:0] led
);

   
    wire rst;
    debouncer #(.STABLE_MAX(DEBOUNCE_STAB)) u_debouncer (
        .clk  (clk),
        .pbin (rst_raw),
        .pbout(rst)
    );

   
    wire slow_clk;
    clock_divider #(.MAX_COUNT(CLK_DIV_MAX)) u_clkdiv (
        .clk     (clk),
        .rst     (rst),
        .slow_clk(slow_clk)
    );

  
    wire [31:0] sw_synced_bus;
    leds u_leds (
        .clk        (clk),
        .rst        (rst),
        .btns       (16'd0),
        .writeData  (32'd0),
        .writeEnable(1'b0),
        .readEnable (1'b0),
        .memAddress (30'd0),
        .switches   ({12'd0, sw}), 
        .readData   (sw_synced_bus)
    );
    wire [3:0] sw_synced = sw_synced_bus[3:0];

   
    localparam [31:0] A = 32'h10101010;
    localparam [31:0] B = 32'h01010101;

    reg  [3:0]  alu_control_reg;
    wire [31:0] alu_result;
    wire        alu_zero;

    ALU u_alu (
        .A         (A),
        .B         (B),
        .ALUControl(alu_control_reg),
        .ALUResult (alu_result),
        .Zero      (alu_zero)
    );

    
    reg        sw_write_en;
    reg [31:0] sw_write_data;

    switches u_switches (
        .clk        (clk),
        .rst        (rst),
        .writeData  (sw_write_data),
        .writeEnable(sw_write_en),
        .readEnable (1'b0),
        .memAddress (30'd0),
        .readData   (),
        .leds       (led)           
    );

    
    localparam [1:0] IDLE    = 2'd0,
                     COMPUTE = 2'd1,
                     DISPLAY = 2'd2;

    reg [1:0] state;

    always @(posedge clk) begin
        if (rst) begin
            state           <= IDLE;
            alu_control_reg <= 4'd0;
            sw_write_en     <= 1'b0;
            sw_write_data   <= 32'd0;
        end else begin
            sw_write_en <= 1'b0;    

            case (state)

                IDLE: begin
                    sw_write_data <= 32'd0;
                    sw_write_en   <= 1'b1;      
                    if (sw_synced != 4'd0) begin
                        alu_control_reg <= sw_synced;
                        state           <= COMPUTE;
                    end
                end

                COMPUTE: begin
                    if (sw_synced != 4'd0)
                        alu_control_reg <= sw_synced;
                    if (slow_clk)
                        state <= DISPLAY;
                end

                DISPLAY: begin
                    sw_write_data <= {15'd0, alu_zero, alu_result[14:0]};
                    sw_write_en   <= 1'b1;
                    if (sw_synced == 4'd0)
                        state <= IDLE;
                    else if (sw_synced != alu_control_reg) begin
                        alu_control_reg <= sw_synced;
                        state           <= COMPUTE;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
