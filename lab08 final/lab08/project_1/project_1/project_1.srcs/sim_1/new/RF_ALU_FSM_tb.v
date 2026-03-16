`timescale 1ns / 1ps
module RF_ALU_FSM_tb;
    reg clk, rst;
    initial clk = 0;
    always #5 clk = ~clk;   
    reg         WE;
    reg  [4:0]  rs1, rs2, rd;
    reg  [31:0] WD;
    wire [31:0] RD1, RD2;
    reg  [3:0]  ALUCtrl;
    wire [31:0] ALUResult;
    wire        Zero;
    RegisterFile RF (
        .clk        (clk),
        .rst        (rst),
        .WriteEnable(WE),
        .rs1        (rs1),
        .rs2        (rs2),
        .rd         (rd),
        .WriteData  (WD),
        .ReadData1  (RD1),
        .ReadData2  (RD2)
    );
    ALU alu (
        .A         (RD1),
        .B         (RD2),
        .ALUControl(ALUCtrl),   
        .ALUResult (ALUResult), 
        .Zero      (Zero)
    );
    localparam [3:0]
        IDLE         = 4'd0,
        WRITE_REG1   = 4'd1,   // x1 = CONST_X1
        WRITE_REG2   = 4'd2,   // x2 = CONST_X2
        WRITE_REG3   = 4'd3,   // x3 = CONST_X3 (shift amount)
        READ_ALU     = 4'd4,   // present operands, wait 1 cycle
        WRITE_RESULT = 4'd5,   // store ALUResult -> x(4+op_idx)
        BEQ_CHECK    = 4'd6,   // x1-x1, write Zero flag to x11
        RAW_WRITE    = 4'd7,   // write x12 = 0xFACEFACE
        RAW_READ     = 4'd8,   // read x12 next cycle
        DONE         = 4'd9;
    localparam [3:0]
        OP_ADD = 4'b0000,
        OP_SUB = 4'b0001,
        OP_AND = 4'b0010,
        OP_OR  = 4'b0011,
        OP_XOR = 4'b0100,
        OP_SLL = 4'b0101,
        OP_SRL = 4'b0110,
        OP_BEQ = 4'b0111;   
    localparam [31:0]
        CONST_X1 = 32'h10101010,
        CONST_X2 = 32'h01010101,
        CONST_X3 = 32'h00000005;  
    reg [3:0] state;
    reg [2:0] op_idx;   
    always @(*) begin
        if (state == BEQ_CHECK)
            ALUCtrl = OP_BEQ;       
        else begin
            case (op_idx)
                3'd0: ALUCtrl = OP_ADD;
                3'd1: ALUCtrl = OP_SUB;
                3'd2: ALUCtrl = OP_AND;
                3'd3: ALUCtrl = OP_OR;
                3'd4: ALUCtrl = OP_XOR;
                3'd5: ALUCtrl = OP_SLL;
                3'd6: ALUCtrl = OP_SRL;
                default: ALUCtrl = OP_ADD;
            endcase
        end
    end
    wire use_shift = (op_idx >= 3'd5);
    function [4:0] dest_reg;
        input [2:0] idx;
        dest_reg = 5'd4 + {2'b00, idx};
    endfunction
    always @(posedge clk) begin
        if (rst) begin
            state  <= IDLE;
            op_idx <= 3'd0;
        end else begin
            case (state)
                IDLE:        state <= WRITE_REG1;
                WRITE_REG1:  state <= WRITE_REG2;
                WRITE_REG2:  state <= WRITE_REG3;
                WRITE_REG3: begin
                    op_idx <= 3'd0;    
                    state  <= READ_ALU;
                end
                READ_ALU:    state <= WRITE_RESULT;

                WRITE_RESULT: begin
                    if (op_idx == 3'd6) begin
                        state <= BEQ_CHECK;    
                    end else begin
                        op_idx <= op_idx + 3'd1;
                        state  <= READ_ALU;
                    end
                end
                BEQ_CHECK:   state <= RAW_WRITE;
                RAW_WRITE:   state <= RAW_READ;
                RAW_READ:    state <= DONE;
                DONE:        state <= DONE;    
                default:     state <= IDLE;
            endcase
        end
    end
    always @(*) begin
        WE  = 1'b0;
        rs1 = 5'd0;
        rs2 = 5'd0;
        rd  = 5'd0;
        WD  = 32'b0;
        case (state)
            IDLE: ;     
            WRITE_REG1: begin
                WE = 1'b1;
                rd = 5'd1;
                WD = CONST_X1;
            end
            WRITE_REG2: begin
                WE = 1'b1;
                rd = 5'd2;
                WD = CONST_X2;
            end
            WRITE_REG3: begin
                WE = 1'b1;
                rd = 5'd3;
                WD = CONST_X3;
            end
            READ_ALU: begin
                rs1 = 5'd1;
                rs2 = use_shift ? 5'd3 : 5'd2;
            end
            WRITE_RESULT: begin
                WE  = 1'b1;
                rs1 = 5'd1;
                rs2 = use_shift ? 5'd3 : 5'd2;
                rd  = dest_reg(op_idx);
                WD  = ALUResult;
            end
            BEQ_CHECK: begin
                WE  = 1'b1;
                rs1 = 5'd1;
                rs2 = 5'd1;         
                rd  = 5'd11;
                WD  = Zero ? 32'h0000_0001 : 32'h0000_0000;
            end
            RAW_WRITE: begin
                WE = 1'b1;
                rd = 5'd12;
                WD = 32'hFACE_FACE;
            end

            RAW_READ: begin
                rs1 = 5'd12;    
            end

            DONE: ;
        endcase
    end
    task check;
        input [239:0] label;
        input [31:0]  got, exp;
        begin
            if (got === exp)
                $display("PASS %-35s got=0x%08h", label, got);
            else
                $display("FAIL %-35s got=0x%08h  exp=0x%08h", label, got, exp);
        end
    endtask
    always @(posedge clk) begin
        if (state == WRITE_RESULT) begin
            case (op_idx)
                3'd0: check("ADD  x4 = x1 + x2",
                            ALUResult, CONST_X1 + CONST_X2);
                3'd1: check("SUB  x5 = x1 - x2",
                            ALUResult, CONST_X1 - CONST_X2);
                3'd2: check("AND  x6 = x1 & x2",
                            ALUResult, CONST_X1 & CONST_X2);
                3'd3: check("OR   x7 = x1 | x2",
                            ALUResult, CONST_X1 | CONST_X2);
                3'd4: check("XOR  x8 = x1 ^ x2",
                            ALUResult, CONST_X1 ^ CONST_X2);
                3'd5: check("SLL  x9  = x1 << x3[4:0]",
                            ALUResult, CONST_X1 << CONST_X3[4:0]);
                3'd6: check("SRL  x10 = x1 >> x3[4:0]",
                            ALUResult, CONST_X1 >> CONST_X3[4:0]);
            endcase
        end
        if (state == BEQ_CHECK)
            check("BEQ  Zero flag (x1-x1==0) -> x11",
                  WD, 32'h0000_0001);
        if (state == RAW_READ)
            check("RAW  x12 read-after-write",
                  RD1, 32'hFACE_FACE);
        if (state == DONE) begin
            $display("\n--- All checks complete. Simulation done. ---");
            #10 $finish;
        end
    end
    initial begin
        $dumpfile("RF_ALU_FSM_tb.vcd");
        $dumpvars(0, RF_ALU_FSM_tb);
        rst = 1;
        @(posedge clk); #1;
        @(posedge clk); #1;
        rst = 0;
        #3000;
        $display("TIMEOUT - simulation did not reach DONE state");
        $finish;
    end
    reg [87:0] state_name;
    always @(*) begin
        case (state)
            IDLE        : state_name = "IDLE       ";
            WRITE_REG1  : state_name = "WRITE_REG1 ";
            WRITE_REG2  : state_name = "WRITE_REG2 ";
            WRITE_REG3  : state_name = "WRITE_REG3 ";
            READ_ALU    : state_name = "READ_ALU   ";
            WRITE_RESULT: state_name = "WRITE_RESLT";
            BEQ_CHECK   : state_name = "BEQ_CHECK  ";
            RAW_WRITE   : state_name = "RAW_WRITE  ";
            RAW_READ    : state_name = "RAW_READ   ";
            DONE        : state_name = "DONE       ";
            default     : state_name = "UNKNOWN    ";
        endcase
    end
endmodule