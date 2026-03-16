module addressDecoderTop(
    input         clk, rst,
    input  [31:0] address,
    input         readEnable, writeEnable,
    input  [31:0] writeData,
    input  [15:0] switches,
    output [31:0] readData,
    output [15:0] leds
);
    wire DataMemWrite, DataMemRead, LEDWrite, SwitchRead;
    wire [31:0] memReadData;

    // Address Decoder
    AddressDecoder decoder (
        .address     (address[9:0]),
        .readEnable  (readEnable),
        .writeEnable (writeEnable),
        .DataMemWrite(DataMemWrite),
        .DataMemRead (DataMemRead),
        .LEDWrite    (LEDWrite),
        .SwitchRead  (SwitchRead)
    );

    // Data Memory
    DataMemory dmem (
        .clk        (clk),
        .MemWrite   (DataMemWrite),
        .MemRead    (DataMemRead),
        .address    (address[7:0]),  
        .write_data (writeData),
        .read_data  (memReadData)
    );

    // LED register (from Lab 5)
    LEDModule leds_inst (
        .clk      (clk),
        .rst      (rst),
        .LEDWrite (LEDWrite),
        .writeData(writeData[15:0]),
        .leds     (leds)
    );

    // Read data mux - pick which device's output goes back to CPU
    assign readData = DataMemRead ? memReadData       :
                      SwitchRead  ? {16'b0, switches} :
                                    32'b0;
endmodule
