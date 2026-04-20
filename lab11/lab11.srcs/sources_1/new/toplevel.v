`timescale 1ns / 1ps

module TopLevelProcessor(
    input  wire        clk,
    input  wire        reset,
    output wire [15:0] probe_out 
);


    wire [31:0] pc_current, pc_next, pc_plus4, branch_target;
    wire [31:0] instruction;
    wire [31:0] imm_ext;
    wire [31:0] read_data1, read_data2, write_data;
    wire [31:0] alu_in2, alu_result;
    wire [31:0] mem_read_data;
    wire [3:0]  alu_control_signal;
    wire zero;
    
  
    wire reg_write, mem_read, mem_write, alu_src, mem_to_reg, branch_en;
    wire [1:0] alu_op;


    ProgramCounter pc_inst (
        .clk(clk),
        .reset(reset),
        .PC_in(pc_next),
        .PC_out(pc_current)
    ); 

    pcAdder pc_add4 (
        .a(pc_current),
        .b(32'd4),
        .out(pc_plus4)
    ); 

    instructionMemory imem (
        .instAddress(pc_current),
        .instruction(instruction)
    ); // [cite: 16]

    // --- Decode Stage ---
    main_control ctrl (
        .opcode(instruction[6:0]),
        .RegWrite(reg_write),
        .ALUOp(alu_op),
        .MemRead(mem_read),
        .MemWrite(mem_write),
        .ALUSrc(alu_src),
        .MemtoReg(mem_to_reg),
        .Branch(branch_en)
    ); 

    RegisterFile rf (
        .clk(clk),
        .rst(reset),
        .WriteEnable(reg_write),
        .rs1(instruction[19:15]),
        .rs2(instruction[24:20]),
        .rd(instruction[11:7]),
        .WriteData(write_data),
        .ReadData1(read_data1),
        .ReadData2(read_data2)
    );

    immGen ig (
        .inst(instruction),
        .imm(imm_ext)
    ); 

    
    alu_control alu_ctrl_unit (
        .ALUOp(alu_op),
        .funct3(instruction[14:12]),
        .funct7(instruction[31:25]),
        .ALUControl(alu_control_signal)
    ); 


    assign alu_in2 = alu_src ? imm_ext : read_data2;

    
    ALU main_alu (
        .A(read_data1),
        .B(alu_in2),
        .ALUControl(alu_control_signal),
        .ALUResult(alu_result),
        .Zero(zero)
    );

    branchAdder b_add (
        .pc(pc_current),
        .imm(imm_ext),
        .out(branch_target)
    ); 

 
    DataMemory dmem (
        .clk(clk),
        .MemWrite(mem_write),
        .MemRead(mem_read),
        .address(alu_result),
        .write_data(read_data2),
        .read_data(mem_read_data)
    ); 

    assign write_data = mem_to_reg ? mem_read_data : alu_result;

    mux2 pc_mux (
        .a(pc_plus4),
        .b(branch_target),
        .s(branch_en & zero),
        .out(pc_next)
    ); 
    assign probe_out = alu_result[15:0]; 
endmodule
