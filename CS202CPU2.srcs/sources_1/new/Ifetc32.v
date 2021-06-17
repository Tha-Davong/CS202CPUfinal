`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/17/2021 12:30:14 AM
// Design Name: 
// Module Name: Ifetc32
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



module Ifetc32(
input[31:0] Addr_result,
input[31:0] Read_data_1,
input Branch,
input nBranch,
input Jmp,//here
input Jal,//here
input Jr,
input Zero,
input clock,
input reset,

output[31:0] Instruction,
output[31:0] branch_base_addr,
output reg [31:0] link_addr,
output[31:0] pco
 );
reg[31:0] Next_PC;
reg[31:0] PC;
wire[31:0] PC_plus_4;

prgrom instmem(
        .clka(clock),         
        .addra(PC[15:2]),     
        .douta(Instruction)         
    );

assign PC_plus_4[31:2] = PC[31:2] + 1'b1;
assign PC_plus_4[1:0] =2'b00;
assign pco = PC;
assign branch_base_addr = PC_plus_4;
always @* begin
    if(((Branch == 1) && (Zero == 1 )) || ((nBranch == 1) && (Zero == 0))) 
        Next_PC = Addr_result << 2;
    else if(Jr == 1)
        Next_PC = Read_data_1 << 2; 
    else 
        Next_PC= PC_plus_4; 
end

always @(negedge clock) begin
    if(reset == 1)
        PC <= 32'h0000_0000;
    else begin
        if((Jmp == 1) || (Jal == 1)) begin
            link_addr = Next_PC >> 2;
            PC <= {4'b0000,Instruction[25:0],2'b00};
        end
        else PC <= Next_PC;
    end
end

endmodule

