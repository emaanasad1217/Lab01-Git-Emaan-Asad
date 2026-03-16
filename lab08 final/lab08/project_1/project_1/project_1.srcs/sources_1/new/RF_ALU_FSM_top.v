`timescale 1ns / 1ps
module RF_ALU_FSM_top (
    input  wire        clk,      
    input  wire        rst,      
    input  wire [15:0] sw,
    input  wire        btn_write, 
    output wire [15:0] led
);
    localparam CNT_MAX = 28'd50_000_000; 
    reg [27:0] cnt;
    reg        slow_clk;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt      <= 0;
            slow_clk <= 0;
        end else if (cnt == CNT_MAX - 1) begin
            cnt      <= 0;
            slow_clk <= ~slow_clk;
        end else begin
            cnt <= cnt + 1;
        end
    end
    wire btn_debounced;
    wire btn_pulse;
    debounce db_inst (
        .clk    (clk),
        .rst    (rst),
        .btn_in (btn_write),
        .btn_out(btn_debounced)
    );
    edge_detect ed_inst (
        .clk      (clk),
        .rst      (rst),
        .signal_in(btn_debounced),
        .pulse_out(btn_pulse)
    );
    localparam [3:0]
        S_IDLE = 4'd0,
        S_W_X1 = 4'd1,
        S_W_X2 = 4'd2,
        S_W_X3 = 4'd3,
        S_READ = 4'd4,
        S_WRES = 4'd5,
        S_DONE = 4'd6;
    reg [3:0] fsm_state;
    reg [2:0] op_cnt; 
    localparam [31:0]
        CONST_A = 32'h10101010,
        CONST_B = 32'h01010101,
        CONST_S = 32'h00000005;  
    reg        fsm_WE;
    reg  [4:0] fsm_rs1, fsm_rs2, fsm_rd;
    reg  [31:0] fsm_WD;
    reg  [3:0] fsm_ALUCtrl;
    function [3:0] op_to_ctrl;
        input [2:0] o;
        case (o)
            3'd0: op_to_ctrl = 4'b0000;  // ADD
            3'd1: op_to_ctrl = 4'b0001;  // SUB
            3'd2: op_to_ctrl = 4'b0010;  // AND
            3'd3: op_to_ctrl = 4'b0011;  // OR
            3'd4: op_to_ctrl = 4'b0100;  // XOR
            3'd5: op_to_ctrl = 4'b0101;  // SLL
            3'd6: op_to_ctrl = 4'b0110;  // SRL
            default: op_to_ctrl = 4'b0000;
        endcase
    endfunction
    always @(posedge slow_clk or posedge rst) begin
        if (rst) begin
            fsm_state <= S_IDLE;
            op_cnt    <= 3'd0;
        end else if (sw[15]) begin
            case (fsm_state)
                S_IDLE: fsm_state <= S_W_X1;
                S_W_X1: fsm_state <= S_W_X2;
                S_W_X2: fsm_state <= S_W_X3;
                S_W_X3: begin
                    op_cnt    <= 3'd0;
                    fsm_state <= S_READ;
                end
                S_READ: fsm_state <= S_WRES;
                S_WRES: begin
                    if (op_cnt == 3'd6) begin
                        fsm_state <= S_DONE;
                    end else begin
                        op_cnt    <= op_cnt + 3'd1;
                        fsm_state <= S_READ;
                    end
                end
                S_DONE:  fsm_state <= S_IDLE;  // loop
                default: fsm_state <= S_IDLE;
            endcase
        end
    end
    always @(*) begin
        // Safe defaults
        fsm_WE      = 1'b0;
        fsm_rs1     = 5'd1;
        fsm_rs2     = 5'd2;
        fsm_rd      = 5'd0;
        fsm_WD      = 32'b0;
        fsm_ALUCtrl = op_to_ctrl(op_cnt);

        case (fsm_state)
            S_W_X1: begin
                fsm_WE  = 1'b1;
                fsm_rd  = 5'd1;
                fsm_WD  = CONST_A;
            end
            S_W_X2: begin
                fsm_WE  = 1'b1;
                fsm_rd  = 5'd2;
                fsm_WD  = CONST_B;
            end
            S_W_X3: begin
                fsm_WE  = 1'b1;
                fsm_rd  = 5'd3;
                fsm_WD  = CONST_S;
            end
            S_READ: begin
                fsm_rs1 = 5'd1;
                // Ops 5 (SLL) and 6 (SRL) use x3 as shift amount
                fsm_rs2 = (op_cnt >= 3'd5) ? 5'd3 : 5'd2;
                fsm_ALUCtrl = op_to_ctrl(op_cnt);
            end
            S_WRES: begin
                fsm_WE  = 1'b1;
                fsm_rs1 = 5'd1;
                fsm_rs2 = (op_cnt >= 3'd5) ? 5'd3 : 5'd2;
                fsm_rd  = 5'd4 + {2'b00, op_cnt};  // x4..x10
                fsm_WD  = alu_result;
                fsm_ALUCtrl = op_to_ctrl(op_cnt);
            end
            default: ;
        endcase
    end
    wire        WE_final;
    wire [4:0]  rs1_final, rs2_final, rd_final;
    wire [31:0] WD_final;
    wire [3:0]  ALUCtrl_final;
    assign WE_final      = sw[15] ? fsm_WE      : (sw[4] & btn_pulse);
    assign rs1_final     = sw[15] ? fsm_rs1     : 5'd1;
    assign rs2_final     = sw[15] ? fsm_rs2     : 5'd2;
    assign rd_final      = sw[15] ? fsm_rd      : sw[9:5];
    assign WD_final      = sw[15] ? fsm_WD      : {28'b0, sw[3:0]};
    assign ALUCtrl_final = sw[15] ? fsm_ALUCtrl : sw[3:0];
    wire [31:0] rd1, rd2;
    RegisterFile rf_inst (
        .clk        (slow_clk),
        .rst        (rst),
        .WriteEnable(WE_final),
        .rs1        (rs1_final),
        .rs2        (rs2_final),
        .rd         (rd_final),
        .WriteData  (WD_final),
        .ReadData1  (rd1),
        .ReadData2  (rd2)
    );
    wire [31:0] alu_result;
    wire        zero_flag;
    ALU alu_inst (
        .A         (rd1),
        .B         (rd2),
        .ALUControl(ALUCtrl_final),
        .ALUResult (alu_result),
        .Zero      (zero_flag)
    );
    assign led[3:0]  = fsm_state;         
    assign led[4]    = zero_flag;         
    assign led[15:5] = alu_result[10:0];   
endmodule
module debounce #(parameter DB_CNT = 20) (
    input  wire clk,
    input  wire rst,
    input  wire btn_in,
    output reg  btn_out
);
    reg [DB_CNT-1:0] shift;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            shift   <= 0;
            btn_out <= 0;
        end else begin
            shift   <= {shift[DB_CNT-2:0], btn_in};
            btn_out <= &shift;
        end
    end
endmodule
module edge_detect (
    input  wire clk,
    input  wire rst,
    input  wire signal_in,
    output wire pulse_out
);
    reg prev;
    always @(posedge clk or posedge rst)
        if (rst) prev <= 0;
        else     prev <= signal_in;
    assign pulse_out = signal_in & ~prev;
endmodule