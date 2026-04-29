`timescale 1ns / 1ps

// TopLevelProcessor - Single-cycle RISC-V RV32I datapath
//
// clk_en is a 1-cycle-wide pulse from clock_divider in ProcessorFPGA.
// The PC only advances when clk_en is high, so the processor executes
// at the slow-clock rate while all registers, memory, and combinational
// logic still run on the fast clock (correct and timing-safe).

module TopLevelProcessor (
    input  wire        clk,
    input  wire        clk_en,    // clock enable from clock_divider
    input  wire        rst,

    output wire [31:0] mem_address,
    output wire [31:0] mem_write_data,
    output wire        mem_write_en,
    output wire        mem_read_en,
    input  wire [31:0] mem_read_data
);

 
    // PC DATAPATH
    // ----------------------------------------------------------------
    wire [31:0] PC;
    wire [31:0] PC_Plus4;
    wire [31:0] BranchTarget;
    wire [31:0] JumpTarget;
    wire [31:0] PC_Next;
    wire        PCSrc;
    wire        JumpSrc;

    // ----------------------------------------------------------------
    // INSTRUCTION DECODE
    // ----------------------------------------------------------------
    wire [31:0] instruction;
    wire [6:0]  opcode   = instruction[6:0];
    wire [4:0]  rd_addr  = instruction[11:7];
    wire [2:0]  funct3   = instruction[14:12];
    wire [4:0]  rs1_addr = instruction[19:15];
    wire [4:0]  rs2_addr = instruction[24:20];
    wire [6:0]  funct7   = instruction[31:25];

    // ----------------------------------------------------------------
    // CONTROL SIGNALS
    // ----------------------------------------------------------------
    wire        RegWrite;
    wire        ALUSrc;
    wire        MemRead;
    wire        MemWrite;
    wire        MemtoReg;
    wire        Branch;
    wire        Jump;
    wire [1:0]  ALUOp;
    wire [3:0]  ALUControl;

    // ----------------------------------------------------------------
    // REGISTER FILE / ALU
    // ----------------------------------------------------------------
    wire [31:0] ReadData1;
    wire [31:0] ReadData2;
    wire [31:0] WriteData;
    wire [31:0] imm_out;
    wire [31:0] ALU_B;
    wire [31:0] ALUResult;
    wire        Zero;
    wire        Negative = ALUResult[31];

    // ----------------------------------------------------------------
    // BRANCH CONDITION  (BEQ / BNE / BLT / BGE)
    // ----------------------------------------------------------------
    reg BranchTaken;
    always @(*) begin
        case (funct3)
            3'b000: BranchTaken = Zero;      // BEQ
            3'b001: BranchTaken = ~Zero;     // BNE
            3'b100: BranchTaken = Negative;  // BLT
            3'b101: BranchTaken = ~Negative; // BGE
            default: BranchTaken = 1'b0;
        endcase
    end
    assign PCSrc = Branch & BranchTaken;

    // ----------------------------------------------------------------
    // JUMP TARGET  (JAL: PC+imm  |  JALR: (rs1+imm)&~1)
    // ----------------------------------------------------------------
    localparam JALR_OP  = 7'b1100111;
    localparam JAL_OP   = 7'b1101111;
    localparam AUIPC_OP = 7'b0010111;

    wire [31:0] jalr_target = {ALUResult[31:1], 1'b0};
    wire [31:0] jal_target  = PC + imm_out;

    assign JumpTarget = (opcode == JALR_OP) ? jalr_target : jal_target;
    assign JumpSrc    = Jump;

   
    // PC NEXT MUX  (Jump > Branch > PC+4)
   
    assign PC_Next = JumpSrc ? JumpTarget :
                     PCSrc   ? BranchTarget :
                               PC_Plus4;


    // WRITEBACK MUX
    //   JAL/JALR  -> PC+4          (link address)
    //   AUIPC     -> PC + imm_out
    //   Load      -> mem_read_data
    //   default   -> ALUResult
   
    assign WriteData = (opcode == JAL_OP || opcode == JALR_OP) ? PC_Plus4      :
                       (opcode == AUIPC_OP)                     ? PC + imm_out  :
                       MemtoReg                                  ? mem_read_data :
                                                                  ALUResult;

    // ----------------------------------------------------------------
    // MEMORY INTERFACE
    // ----------------------------------------------------------------
    assign mem_address    = ALUResult;
    assign mem_write_data = ReadData2;
   assign mem_write_en   = MemWrite & clk_en;
    assign mem_read_en    = MemRead;

    // ================================================================
    // INSTANTIATIONS
    // ================================================================

    // PC advances only when clk_en pulse is high
    ProgramCounter u_pc (
        .clk     (clk),
        .clk_en  (clk_en),
        .rst     (rst),
        .PC_Next (PC_Next),
        .PC      (PC)
    );

    pcAdder u_pcAdder (
        .PC       (PC),
        .PC_Plus4 (PC_Plus4)
    );

    InstructionMemory u_instmem (
        .instAddress (PC),
        .instruction (instruction)
    );

    immGen u_immGen (
        .instruction (instruction),
        .imm_out     (imm_out)
    );

    branchAdder u_branchAdder (
        .PC           (PC),
        .imm          (imm_out),
        .BranchTarget (BranchTarget)
    );

    MainControl u_main_ctrl (
        .opcode   (opcode),
        .RegWrite (RegWrite),
        .ALUSrc   (ALUSrc),
        .MemRead  (MemRead),
        .MemWrite (MemWrite),
        .MemtoReg (MemtoReg),
        .Branch   (Branch),
        .Jump     (Jump),
        .ALUOp    (ALUOp)
    );

    ALUControl u_alu_ctrl (
        .ALUOp      (ALUOp),
        .funct3     (funct3),
        .funct7     (funct7),
        .ALUControl (ALUControl)
    );

    RegisterFile u_regfile (
        .clk         (clk),
        .rst         (rst),
        .WriteEnable (RegWrite & clk_en),  // write only on the active cycle
        .rs1         (rs1_addr),
        .rs2         (rs2_addr),
        .rd          (rd_addr),
        .WriteData   (WriteData),
        .ReadData1   (ReadData1),
        .ReadData2   (ReadData2)
    );

    mux2 u_mux_alusrc (
        .sel  (ALUSrc),
        .in0  (ReadData2),
        .in1  (imm_out),
        .out  (ALU_B)
    );

    ALU u_alu (
        .A          (ReadData1),
        .B          (ALU_B),
        .ALUControl (ALUControl),
        .ALUResult  (ALUResult),
        .Zero       (Zero)
    );

endmodule