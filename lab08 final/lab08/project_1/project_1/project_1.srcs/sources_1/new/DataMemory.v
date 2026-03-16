module DataMemory (
    input         clk,
    input         MemWrite,
    input         MemRead,
    input  [7:0]  address,      // only lower 8 bits needed (512 locations)
    input  [31:0] write_data,
    output [31:0] read_data
);
    reg [31:0] mem [0:511];
    integer i;
    

    always @(posedge clk)
        if (MemWrite)
            for(i=0;i<4;i=i+1) begin
                mem[address+i] <= write_data[i*8 +:8];
        end
    
    assign read_data = MemRead ? {mem[address+3], mem[address+2],  mem[address+1], mem[address+0]} : 32'b0;
endmodule
