`timescale 1ns / 1ps
// AddressDecoder.v  -- FIXED
//
// The program uses these memory-mapped addresses:
//   0x000-0x1FF  Data Memory   (stack, local vars)
//   0x400        Switches      (main: read countdown start value)
//   0x800        LEDs          (write current count)
//   0xC00        Switches      (countdown: read stop signal)
//
// The original decoder checked address[9:8], which maps only a 1 KB
// window (0x000-0x3FF).  The program's peripherals sit at 0x800 and
// 0xC00, so address[9:8] is always 2'b00 for those addresses -- every
// access was silently routed to DataMemory and the LEDs/switches were
// never touched.
//
// FIX: use address[11:10] to decode the full address range:
//   bits[11:10] = 00  -> DataMemory  (0x000-0x3FF)
//   bits[11:10] = 01  -> Switches    (0x400-0x7FF)  read-only
//   bits[11:10] = 10  -> LEDs        (0x800-0xBFF)  write-only
//   bits[11:10] = 11  -> Switches    (0xC00-0xFFF)  read-only (stop signal)

module AddressDecoder (
    input  wire        readEnable,
    input  wire        writeEnable,
    input  wire [31:0] address,
    output wire        DataMemWrite,
    output wire        DataMemRead,
    output wire        LEDWrite,
    output wire        SwitchReadEnable
);
    wire [1:0] devSel = address[11:10];

    // Data Memory: bits[11:10] = 00
    assign DataMemWrite     = writeEnable & (devSel == 2'b00);
    assign DataMemRead      = readEnable  & (devSel == 2'b00);

    // LEDs: bits[11:10] = 10  (address 0x800)
    assign LEDWrite         = writeEnable & (devSel == 2'b10);

    // Switches: bits[11:10] = 01 (0x400) OR 11 (0xC00)
    // Replace the old assign with this exact line:
assign SwitchReadEnable = readEnable  & (devSel == 2'b01);

endmodule