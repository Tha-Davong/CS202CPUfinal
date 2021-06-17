`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/17/2021 12:54:13 AM
// Design Name: 
// Module Name: CPU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CPU(
input clk,
input reset,
output [31:0] Instruction

    );
wire clock;

wire[31:0] branch_base_addr;
wire [31:0] Addr_result; 
wire Branch,nBranch,Jmp,Jal,Jr,Zero;
wire MemToReg, RegDst, RegWrite;

wire [31:0] link_addr;
wire [31:0] next_PC;
wire [31:0]PC;
wire [31:0] read_data_1;
wire[31:0] read_data_2; 
wire[31:0] Imme_extend;
wire[31:0] ALU_result; 
wire[31:0] read_data;

wire MemWrite, ALUSrc, I_format, Sftmd;
wire [1:0] ALUOp;

cpuclkclk cpuclk(.clk_in1(clk), .clk_out1(clock));

//wire [31:0] address, write_data; 

dmemory32 dmem(
//input
.clock(clock),
.Memwrite(MemWrite),
.address(ALU_result),
.write_data(read_data_2),
//output
.read_data(read_data));

Ifetc32 ifet(
//input
.Addr_result(Addr_result),
.Read_data_1(read_data_1),
.Branch(Branch),
.nBranch(nBranch),
.Jmp(Jmp),
.Jal(Jal),
.Jr(Jr),
.Zero(Zero),
.clock(clock),
.reset(reset),
//output
.Instruction(Instruction),
.branch_base_addr(branch_base_addr),
.link_addr(link_addr),
.pco(PC)

);



Idecode32 ide(
//input
.Instruction(Instruction),
.read_data(read_data),
.ALU_result(ALU_result),
.Jal(Jal),
.RegWrite(RegWrite),
.MemtoReg(MemToReg),
.RegDst(RegDst),
.clock(clock),
.reset(reset),
.opcplus4(link_addr),
//output
.read_data_1(read_data_1),
.read_data_2(read_data_2),
.imme_extend(Imme_extend));

control32 cont(
//input
.Opcode(Instruction[31:26]),
.Function_opcode(Instruction[5:0]),
//output
.Jr(Jr),
.RegDST(RegDst),
.ALUSrc(ALUSrc),
.MemtoReg(MemToReg),
.RegWrite(RegWrite),
.MemWrite(MemWrite),
.Branch(Branch),
.nBranch(nBranch),
.Jmp(Jmp),
.Jal(Jal),
.I_format(I_format),
.Sftmd(Sftmd),
.ALUOp(ALUOp));

Executs32 ALU(
//input
.Read_data_1(read_data_1),
.Read_data_2(read_data_2),
.Imme_extend(Imme_extend),
.Function_opcode(Instruction[5:0]),
.opcode(Instruction[31:26]),
.ALUOp(ALUOp),
.Shamt(Instruction[10:6]),
.Sftmd(Sftmd),
.ALUSrc(ALUSrc),
.I_format(I_format),
.Jr(Jr),
.PC_plus_4(branch_base_addr),
//output
.Zero(Zero),
.ALU_Result(ALU_result),
.Addr_Result(Addr_result)
);



endmodule
