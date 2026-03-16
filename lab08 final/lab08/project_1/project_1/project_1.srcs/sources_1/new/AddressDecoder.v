module AddressDecoder (
    input  [9:0] address,
    input        readEnable,
    input        writeEnable,
    output       DataMemWrite,
    output       DataMemRead,
    output       LEDWrite,
    output       SwitchRead
);
    wire isDataMem=(address[9:8]==2'b00);
    wire isLED=(address[9:8]==2'b10);
    wire isSwitch= (address[9:8]==2'b11);

    assign DataMemWrite = isDataMem && writeEnable;
    assign DataMemRead  = isDataMem && readEnable;
    assign LEDWrite     = isLED && writeEnable;
    assign SwitchRead   = isSwitch && readEnable;
endmodule