`timescale 1ns / 1ps

// ProcessorFPGA - Basys3 top-level wrapper  -- FIXED
//
// Changes from original:
//   1. AddressDecoder address map now matches the program (bits[11:10]).
//   2. LED writeEnable is gated with clk_en so the LED register only
//      latches on the one cycle the processor actually commits a write.
//      Without this gate, the write fires on EVERY fast-clock edge while
//      the processor is "thinking", potentially latching a stale ALU result.
//   3. DataMemory write is similarly gated with clk_en for the same reason.
//      (DataMemory already does a synchronous write, but the enable must
//       only be asserted for one slow-clock period to avoid repeated writes.)

module ProcessorFPGA #(
    parameter CLK_DIVIDER = 25_000_000   // 4 instructions/second at 100 MHz
)(
    input  wire        clk,
    input  wire        rst_raw,   // BTNC
    input  wire [15:0] sw,
    output wire [15:0] led
);

    // ----------------------------------------------------------------
    // Debounced reset
    // ----------------------------------------------------------------
    wire rst_clean;

    debouncer u_debounce (
        .clk   (clk),
        .pbin  (rst_raw),
        .pbout (rst_clean)
    );

    // ----------------------------------------------------------------
    // Clock divider - 1-cycle enable pulse at slow rate
    // ----------------------------------------------------------------
    wire clk_en;

    clock_divider #(
        .MAX_COUNT (CLK_DIVIDER)
    ) u_clk_div (
        .clk      (clk),
        .rst      (rst_clean),
        .slow_clk (clk_en)
    );

    // ----------------------------------------------------------------
    // CPU core memory interface
    // ----------------------------------------------------------------
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

    // ----------------------------------------------------------------
    // Address decoder  (now uses bits[11:10])
    // ----------------------------------------------------------------
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

    // ----------------------------------------------------------------
    // Data memory
    // FIX: gate MemWrite with clk_en so writes only happen once per
    //      slow-clock period, not on every 100 MHz edge.
    // ----------------------------------------------------------------
    wire [31:0] dmem_read_data;

    DataMemory u_datamem (
        .clk        (clk),
        .MemWrite   (DataMemWrite & clk_en),   // <-- gated
        .MemRead    (DataMemRead),
        .address    (mem_address),
        .write_data (mem_write_data),
        .read_data  (dmem_read_data)
    );

    // ----------------------------------------------------------------
    // LED peripheral
    // FIX: gate writeEnable with clk_en so the LED register latches
    //      only on the committed instruction cycle.
    // ----------------------------------------------------------------
    wire [31:0] led_read_data;

    leds u_leds (
        .clk         (clk),
        .rst         (rst_clean),
        .writeData   (mem_write_data),
        .writeEnable (LEDWrite & clk_en),   // <-- gated
        .readEnable  (1'b0),
        .memAddress  (mem_address[31:2]),
        .readData    (led_read_data),
        .leds        (led)
    );

    // ----------------------------------------------------------------
    // Switch peripheral  (always combinationally readable)
    // ----------------------------------------------------------------
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

    // ----------------------------------------------------------------
    // Read data mux: switches win over data memory when enabled
    // ----------------------------------------------------------------
    assign mem_read_data = SwitchReadEnable ? sw_read_data : dmem_read_data;

endmodule