`timescale 1ns / 1ps


module ProcessorFPGA #(
    parameter CLK_DIVIDER = 13_000_000   
)(
    input  wire        clk,
    input  wire        rst_raw,  
    input  wire [15:0] sw,
    output wire [15:0] led
);

    wire rst_clean;

    debouncer u_debounce (
        .clk   (clk),
        .pbin  (rst_raw),
        .pbout (rst_clean)
    );


    wire clk_en;

    clock_divider #(
        .MAX_COUNT (CLK_DIVIDER)
    ) u_clk_div (
        .clk      (clk),
        .rst      (rst_clean),
        .slow_clk (clk_en)
    );


    wire [31:0] mem_address;
    wire [31:0] mem_write_data;
    wire        mem_write_en;
    wire        mem_read_en;
    wire [31:0] mem_read_data;

    TopLevelProcessor u_processor (
        .clk            (clk),
        .clk_en         (clk_en),
        .rst            (rst_clean),
        .mem_address    (mem_address),
        .mem_write_data (mem_write_data),
        .mem_write_en   (mem_write_en),
        .mem_read_en    (mem_read_en),
        .mem_read_data  (mem_read_data)
    );


    wire DataMemWrite;
    wire DataMemRead;
    wire LEDWrite;
    wire SwitchReadEnable;

    AddressDecoder u_addr_dec (
        .readEnable       (mem_read_en),
        .writeEnable      (mem_write_en),
        .address          (mem_address),
        .DataMemWrite     (DataMemWrite),
        .DataMemRead      (DataMemRead),
        .LEDWrite         (LEDWrite),
        .SwitchReadEnable (SwitchReadEnable)
    );


    wire [31:0] dmem_read_data;

    DataMemory u_datamem (
        .clk        (clk),
        .MemWrite   (DataMemWrite & clk_en),   // <-- gated
        .MemRead    (DataMemRead),
        .address    (mem_address),
        .write_data (mem_write_data),
        .read_data  (dmem_read_data)
    );


    wire [31:0] led_read_data;

    leds u_leds (
        .clk         (clk),
        .rst         (rst_clean),
        .writeData   (mem_write_data),
        .writeEnable (LEDWrite & clk_en),   
        .readEnable  (1'b0),
        .memAddress  (mem_address[31:2]),
        .readData    (led_read_data),
        .leds        (led)
    );

    wire [31:0] sw_read_data;

    switches u_switches (
        .clk         (clk),
        .rst         (rst_clean),
        .btns        (16'd0),
        .writeData   (32'd0),
        .writeEnable (1'b0),
        .readEnable  (SwitchReadEnable),
        .memAddress  (mem_address[31:2]),
        .switches    (sw),
        .readData    (sw_read_data)
    );

    assign mem_read_data = SwitchReadEnable ? sw_read_data : dmem_read_data;

endmodule