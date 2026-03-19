`timescale 1ns / 1ps
module MemorySystem_top (
    input  wire        clk,
    input  wire        rst_raw,
    input  wire [15:0] sw,
    output wire [15:0] led
);

    wire rst;
    debouncer #(
        .STABLE_MAX(500_000)
    ) u_debouncer (
        .clk  (clk),
        .pbin (rst_raw),
        .pbout(rst)
    );

    wire slow_clk;
    clock_divider #(
        .MAX_COUNT(100_000_000)
    ) u_clkdiv (
        .clk     (clk),
        .rst     (rst),
        .slow_clk(slow_clk)
    );

    wire [31:0] fsm_address;
    wire        fsm_readEnable;
    wire        fsm_writeEnable;
    wire [31:0] fsm_writeData;
    wire [31:0] mem_readData;
    wire [15:0] fsm_leds;

    MemorySystem_FSM u_fsm (
        .clk        (clk),
        .rst        (rst),
        .slow_clk   (slow_clk),
        .address    (fsm_address),
        .readEnable (fsm_readEnable),
        .writeEnable(fsm_writeEnable),
        .writeData  (fsm_writeData),
        .readData   (mem_readData),
        .fsm_leds   (fsm_leds)
    );

    wire [15:0] mem_leds;

    addressDecoderTop u_mem_sys (
        .clk        (clk),
        .rst        (rst),
        .address    (fsm_address),
        .readEnable (fsm_readEnable),
        .writeEnable(fsm_writeEnable),
        .writeData  (fsm_writeData),
        .switches   (sw),
        .readData   (mem_readData),
        .leds       (mem_leds)
    );

    assign led = sw[15] ? fsm_leds : sw[15:0];

endmodule