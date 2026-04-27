`timescale 1ns / 1ps



// computes PC + 4.
module pcAdder (
    input  wire [31:0] PC,          //current PC value
    output wire [31:0] PC_Plus4     //PC + 4
);

    assign PC_Plus4 = PC + 32'd4;

endmodule