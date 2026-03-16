`timescale 1ns / 1ps
module FSMController (
    input         clk, rst,
    input  [15:0] sw,
    input         btnU,    // write LEDs
    input         btnD,    // write DataMem
    input         btnL,    // read DataMem
    input         btnR,    // read Switches
    output reg [31:0] address,
    output reg [31:0] writeData,
    output reg        writeEnable,
    output reg        readEnable
);

    // States
    localparam IDLE        = 3'd0;
    localparam WRITE_LED   = 3'd1;
    localparam WRITE_MEM   = 3'd2;
    localparam READ_MEM    = 3'd3;
    localparam READ_SW     = 3'd4;

    reg [2:0] state, next_state;

    // State register
    always @(posedge clk or posedge rst) begin
        if (rst) state <= IDLE;
        else     state <= next_state;
    end

    // Next state logic
    always @(*) begin
        next_state = IDLE;   // default back to idle every cycle
        case (state)
            IDLE: begin
                if      (btnU) next_state = WRITE_LED;
                else if (btnD) next_state = WRITE_MEM;
                else if (btnL) next_state = READ_MEM;
                else if (btnR) next_state = READ_SW;
                else           next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    // Output logic
    always @(*) begin
        // defaults
        address     = 32'b0;
        writeData   = 32'b0;
        writeEnable = 1'b0;
        readEnable  = 1'b0;

        case (state)
            WRITE_LED: begin
                address     = 32'h200;          // LED address range
                writeData   = {16'b0, sw};       // switches ? LED data
                writeEnable = 1'b1;
            end
            WRITE_MEM: begin
                address     = {24'b0, sw[7:0]}; // lower 8 switches = address
                writeData   = {16'b0, sw};       // all switches = data
                writeEnable = 1'b1;
            end
            READ_MEM: begin
                address    = {24'b0, sw[7:0]};  // lower 8 switches = address
                readEnable = 1'b1;
            end
            READ_SW: begin
                address    = 32'h300;            // Switch address range
                readEnable = 1'b1;
            end
            default: begin
                address     = 32'b0;
                writeData   = 32'b0;
                writeEnable = 1'b0;
                readEnable  = 1'b0;
            end
        endcase
    end

endmodule