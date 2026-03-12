`timescale 1ns / 1ps

module RF_ALU_FSM_tb;


    reg clk;
    initial clk = 0;
    always #5 clk = ~clk;


    reg         rst;
    reg         writeEnable;
    reg  [4:0]  rs1, rs2, rd;
    reg  [31:0] writeData;
    wire [31:0] readData1, readData2;

    RegisterFile u_rf (
        .clk        (clk),
        .rst        (rst),
        .writeEnable(writeEnable),
        .rs1        (rs1),
        .rs2        (rs2),
        .rd         (rd),
        .writeData  (writeData),
        .readData1  (readData1),
        .readData2  (readData2)
    );


    reg  [31:0] alu_A, alu_B;
    reg  [3:0]  alu_ctrl;
    wire [31:0] alu_result;
    wire        alu_zero;

    ALU u_alu (
        .A         (alu_A),
        .B         (alu_B),
        .ALUControl(alu_ctrl),
        .ALUResult (alu_result),
        .Zero      (alu_zero)
    );

    
    localparam [2:0]
        IDLE            = 3'd0,
        WRITE_REGS      = 3'd1,
        READ_REGISTERS  = 3'd2,
        ALU_OPERATION   = 3'd3,
        WRITE_REGISTERS = 3'd4;

    reg [2:0] state;


    localparam [3:0]
        ADD_OP = 4'b0010,
        SUB_OP = 4'b0110,
        AND_OP = 4'b0000,
        OR_OP  = 4'b0001,
        XOR_OP = 4'b0100,
        SLL_OP = 4'b1000,
        SRL_OP = 4'b1001;

    reg [3:0] op_table  [0:6];
    reg [4:0] dst_table [0:6];
    integer   op_idx;

    initial begin
        op_table[0] = ADD_OP; dst_table[0] = 5'd4;
        op_table[1] = SUB_OP; dst_table[1] = 5'd5;
        op_table[2] = AND_OP; dst_table[2] = 5'd6;
        op_table[3] = OR_OP;  dst_table[3] = 5'd7;
        op_table[4] = XOR_OP; dst_table[4] = 5'd8;
        op_table[5] = SLL_OP; dst_table[5] = 5'd9;
        op_table[6] = SRL_OP; dst_table[6] = 5'd10;
    end

    
    initial begin
        $dumpfile("RF_ALU_FSM_tb.vcd");
        $dumpvars(0, RF_ALU_FSM_tb);
    end

   
    initial begin
        rst = 1; writeEnable = 0;
        rs1 = 0; rs2 = 0; rd = 0; writeData = 0;
        alu_A = 0; alu_B = 0; alu_ctrl = ADD_OP;
        state = IDLE; op_idx = 0;

       
        @(posedge clk); #1;
        @(posedge clk); #1;
        rst = 0;
        $display("[%0t] STATE: IDLE", $time);
        @(posedge clk); #1;

       
        state = WRITE_REGS;
        $display("[%0t] STATE: WRITE_REGS", $time);

        writeEnable = 1; rd = 5'd1; writeData = 32'h10101010;
        @(posedge clk); #1; writeEnable = 0;

        writeEnable = 1; rd = 5'd2; writeData = 32'h01010101;
        @(posedge clk); #1; writeEnable = 0;

        writeEnable = 1; rd = 5'd3; writeData = 32'h00000005;
        @(posedge clk); #1; writeEnable = 0;

        
        for (op_idx = 0; op_idx < 7; op_idx = op_idx + 1) begin

            
            state = READ_REGISTERS;
            rs1 = 5'd1; rs2 = 5'd2;
            @(posedge clk); #1;
            alu_A    = readData1;
            alu_B    = readData2;
            alu_ctrl = op_table[op_idx];
            $display("[%0t] STATE: READ_REGISTERS  A=0x%h  B=0x%h",
                     $time, alu_A, alu_B);

           
            state = ALU_OPERATION;
            @(posedge clk); #1;
            $display("[%0t] STATE: ALU_OPERATION   result=0x%h  Zero=%b",
                     $time, alu_result, alu_zero);

           
            state = WRITE_REGISTERS;
            writeEnable = 1;
            rd          = dst_table[op_idx];
            writeData   = alu_result;
            @(posedge clk); #1;
            writeEnable = 0;
            $display("[%0t] STATE: WRITE_REGISTERS result=0x%h ? x%0d",
                     $time, alu_result, dst_table[op_idx]);

            
            if (op_table[op_idx] == SUB_OP) begin
                if (alu_zero) begin
                    writeEnable = 1; rd = 5'd11; writeData = 32'h1;
                    @(posedge clk); #1;
                    writeEnable = 0;
                    $display("[%0t] BEQ: Zero=1 (A==B) flag written to x11", $time);
                end else begin
                    $display("[%0t] BEQ: Zero=0 (A!=B) x11 unchanged", $time);
                end
            end
        end

        
        state = IDLE;
        $display("[%0t] STATE: IDLE - done", $time);
        $finish;
    end

endmodule