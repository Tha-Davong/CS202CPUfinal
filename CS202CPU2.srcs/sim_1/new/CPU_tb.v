`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/17/2021 01:08:08 AM
// Design Name: 
// Module Name: CPU_tb
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


module CPU_tb(
    );
reg clk = 0;
reg reset = 1;

wire[31:0] Instruction;
wire[5:0] opcode;//check wave form for 0 if R-format
wire[5:0] function_opcode;//check wave form for R type function
wire[4:0] rd;
wire[15:0] immediate;
wire[4:0] Shfmt;

assign rd = Instruction[15:11];
//get rs and rt from decoder using vivado scope option
assign Shfmt = Instruction [10:6];//for shift instruction
assign immediate = Instruction[15:0];//for I type instruction
assign opcode = Instruction[31:26];
assign function_opcode = Instruction[5:0];
CPU cpu(.clk(clk), .reset(reset), .Instruction(Instruction));

always #10 clk = ~clk;
initial begin
#1000 reset = 0;
end


endmodule
