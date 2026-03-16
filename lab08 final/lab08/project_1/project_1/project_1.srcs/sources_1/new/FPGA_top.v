

`timescale 1ns / 1ps
module FPGATop (
    input         clk,
    input         rst,
    input  [15:0] sw,
    input         btnU,
    input         btnD,
    input         btnL,
    input         btnR,
    output [15:0] led
);

   
    wire btnU_db, btnD_db, btnL_db, btnR_db;
    wire btnU_p,  btnD_p,  btnL_p,  btnR_p;

    debounce db0 (.clk(clk), .rst(rst), .btn_in(btnU), .btn_out(btnU_db));
    debounce db1 (.clk(clk), .rst(rst), .btn_in(btnD), .btn_out(btnD_db));
    debounce db2 (.clk(clk), .rst(rst), .btn_in(btnL), .btn_out(btnL_db));
    debounce db3 (.clk(clk), .rst(rst), .btn_in(btnR), .btn_out(btnR_db));

    edge_detect ed0 (.clk(clk), .rst(rst), .signal_in(btnU_db), .pulse_out(btnU_p));
    edge_detect ed1 (.clk(clk), .rst(rst), .signal_in(btnD_db), .pulse_out(btnD_p));
    edge_detect ed2 (.clk(clk), .rst(rst), .signal_in(btnL_db), .pulse_out(btnL_p));
    edge_detect ed3 (.clk(clk), .rst(rst), .signal_in(btnR_db), .pulse_out(btnR_p));

    
    wire [31:0] address;
    wire        readEnable, writeEnable;
    wire [31:0] writeData;

    FSMController fsm (
        .clk        (clk),
        .rst        (rst),
        .sw         (sw),
        .btnU       (btnU_p),
        .btnD       (btnD_p),
        .btnL       (btnL_p),
        .btnR       (btnR_p),
        .address    (address),
        .writeData  (writeData),
        .writeEnable(writeEnable),
        .readEnable (readEnable)
    );

    
    wire [31:0] readData_wire;
    wire [15:0] led_from_module;

    addressDecoderTop mem_sys (
        .clk        (clk),
        .rst        (rst),
        .address    (address),
        .readEnable (readEnable),
        .writeEnable(writeEnable),
        .writeData  (writeData),
        .switches   (sw),
        .readData   (readData_wire),
        .leds       (led_from_module)
    );

    
    reg [15:0] read_result;
    reg        show_read;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            read_result <= 16'b0;
            show_read   <= 1'b0;
        end else if (readEnable) begin
            read_result <= readData_wire[15:0];
            show_read   <= 1'b1;
        end else if (writeEnable) begin
            show_read   <= 1'b0;
        end
    end

    assign led = show_read ? read_result : led_from_module;

endmodule
`timescale 1ns / 1ps
module FPGATop (
    input         clk,
    input         rst,
    input  [15:0] sw,
    input         btnU,
    input         btnD,
    input         btnL,
    input         btnR,
    output [15:0] led
);

    
    wire btnU_db, btnD_db, btnL_db, btnR_db;
    wire btnU_p,  btnD_p,  btnL_p,  btnR_p;

    debounce db0 (.clk(clk), .rst(rst), .btn_in(btnU), .btn_out(btnU_db));
    debounce db1 (.clk(clk), .rst(rst), .btn_in(btnD), .btn_out(btnD_db));
    debounce db2 (.clk(clk), .rst(rst), .btn_in(btnL), .btn_out(btnL_db));
    debounce db3 (.clk(clk), .rst(rst), .btn_in(btnR), .btn_out(btnR_db));

    edge_detect ed0 (.clk(clk), .rst(rst), .signal_in(btnU_db), .pulse_out(btnU_p));
    edge_detect ed1 (.clk(clk), .rst(rst), .signal_in(btnD_db), .pulse_out(btnD_p));
    edge_detect ed2 (.clk(clk), .rst(rst), .signal_in(btnL_db), .pulse_out(btnL_p));
    edge_detect ed3 (.clk(clk), .rst(rst), .signal_in(btnR_db), .pulse_out(btnR_p));

   
    wire [31:0] address;
    wire        readEnable, writeEnable;
    wire [31:0] writeData;

    FSMController fsm (
        .clk        (clk),
        .rst        (rst),
        .sw         (sw),
        .btnU       (btnU_p),
        .btnD       (btnD_p),
        .btnL       (btnL_p),
        .btnR       (btnR_p),
        .address    (address),
        .writeData  (writeData),
        .writeEnable(writeEnable),
        .readEnable (readEnable)
    );

   
    wire [31:0] readData_wire;
    wire [15:0] led_from_module;

    addressDecoderTop mem_sys (
        .clk        (clk),
        .rst        (rst),
        .address    (address),
        .readEnable (readEnable),
        .writeEnable(writeEnable),
        .writeData  (writeData),
        .switches   (sw),
        .readData   (readData_wire),
        .leds       (led_from_module)
    );

    // ----------------------------------------------------------------
    // Latch read result so it stays visible on LEDs
    // ----------------------------------------------------------------
    reg [15:0] read_result;
    reg        show_read;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            read_result <= 16'b0;
            show_read   <= 1'b0;
        end else if (readEnable) begin
            read_result <= readData_wire[15:0];
            show_read   <= 1'b1;
        end else if (writeEnable) begin
            show_read   <= 1'b0;
        end
    end

    assign led = show_read ? read_result : led_from_module;

endmodule