`timescale 1ns / 1ps

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

 
    assign DataMemWrite     = writeEnable & (devSel == 2'b00);
    assign DataMemRead      = readEnable  & (devSel == 2'b00);

    
    assign LEDWrite         = writeEnable & (devSel == 2'b10);

    
assign SwitchReadEnable = readEnable  & (devSel == 2'b01);

endmodule