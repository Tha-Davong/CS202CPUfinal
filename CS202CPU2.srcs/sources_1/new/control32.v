`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/17/2021 12:28:08 AM
// Design Name: 
// Module Name: control32
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


module control32(
input[5:0] Opcode,
input[5:0] Function_opcode,
output Jr,//done
output RegDST,//to decoder------
output ALUSrc,
output MemtoReg,//to decoder-------done
output RegWrite,//done
output MemWrite,//done
output Branch,//done
output nBranch,//done
output Jmp,//done
output Jal,//done
output I_format, //done
output Sftmd,//done 
output [1:0] ALUOp
);

wire R_format;
assign R_format = (Opcode[5:0] == 6'b000000) ? 1'b1 : 1'b0;//ok

assign I_format = (Opcode[5:3] == 3'b001) ? 1'b1 : 1'b0;//ok

assign Branch = (Opcode[5:0] == 6'b000100) ? 1'b1 : 1'b0;//ok
assign nBranch = (Opcode[5:0] == 6'b000101) ? 1'b1 : 1'b0;//ok

assign Jmp = (Opcode[5:0] == 6'b000010) ? 1'b1 : 1'b0;//ok
assign Jal = (Opcode[5:0] == 6'b000011) ? 1'b1 : 1'b0;//ok
assign Jr = (Opcode == 6'b0000_00 && Function_opcode == 6'b0010_00) ? 1'b1 : 1'b0;//ok

assign Sftmd = (R_format && Function_opcode[5:3] == 3'b000) ? 1'b1 : 1'b0;//ok

assign MemWrite = (Opcode[5:0] == 6'b101011) ? 1'b1 : 1'b0;// for sw
assign MemtoReg = (Opcode[5:0] == 6'b100011) ? 1'b1 : 1'b0;//for lw
assign RegWrite = (I_format || MemtoReg || Jal || R_format ) && ~Jr;
assign RegDST = R_format && (~I_format && ~MemtoReg);

assign ALUSrc = (I_format || MemWrite || MemtoReg);//I type, lw or sw
assign ALUOp = {(I_format || R_format), (Branch || nBranch)};

endmodule
