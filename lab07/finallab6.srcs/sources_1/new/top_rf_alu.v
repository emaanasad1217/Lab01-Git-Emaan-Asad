
`timescale 1ns / 1ps

module top_rf_alu #(
    parameter DEBOUNCE_STAB = 500_000
)(
    input  wire        clk,
    input  wire        rst_raw,
    input  wire [3:0]  sw,
    output wire [15:0] led
);

    
    wire rst;
    debouncer #(.STABLE_MAX(DEBOUNCE_STAB)) u_deb (
        .clk  (clk),
        .pbin (rst_raw),
        .pbout(rst)
    );

    
    reg [3:0] sw_s1, sw_s2;
    always @(posedge clk) begin
        sw_s1 <= sw;
        sw_s2 <= sw_s1;
    end

    
    reg        rf_we;
    reg  [4:0] rf_rd;
    reg [31:0] rf_wdata;
    wire [31:0] rf_rdata1, rf_rdata2;

    RegisterFile u_rf (
        .clk        (clk),
        .rst        (rst),
        .writeEnable(rf_we),
        .rs1        (5'd1),
        .rs2        (5'd2),
        .rd         (rf_rd),
        .writeData  (rf_wdata),
        .readData1  (rf_rdata1),
        .readData2  (rf_rdata2)
    );

    
    wire [31:0] alu_result;
    wire        alu_zero;

    ALU u_alu (
        .A         (rf_rdata1),
        .B         (rf_rdata2),
        .ALUControl(sw_s2),
        .ALUResult (alu_result),
        .Zero      (alu_zero)
    );

    
    assign led = {alu_zero, alu_result[14:0]};

    
    localparam [1:0]
        INIT1 = 2'd1,
        INIT2 = 2'd2,
        IDLE  = 2'd0;

    reg [1:0] state;

    always @(posedge clk) begin
        if (rst) begin
            state    <= INIT1;
            rf_we    <= 1'b0;
            rf_rd    <= 5'd0;
            rf_wdata <= 32'd0;
        end else begin
            rf_we <= 1'b0;

            case (state)

                INIT1: begin
                    rf_we    <= 1'b1;
                    rf_rd    <= 5'd1;
                    rf_wdata <= 32'h10101010;
                    state    <= INIT2;
                end

                INIT2: begin
                    rf_we    <= 1'b1;
                    rf_rd    <= 5'd2;
                    rf_wdata <= 32'h01010101;
                    state    <= IDLE;
                end

                IDLE: begin
                    
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule