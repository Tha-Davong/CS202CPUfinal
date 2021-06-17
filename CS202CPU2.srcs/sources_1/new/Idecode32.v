`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/17/2021 12:30:55 AM
// Design Name: 
// Module Name: Idecode32
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


module Idecode32(
input[31:0] Instruction,
input [31:0] read_data, //data from memory
input [31:0] ALU_result,
input Jal,
input RegWrite, //write to register or not
input MemtoReg,
input RegDst, //rd vs rt
input clock,
input reset,
input[31:0] opcplus4,

output [31:0] read_data_1, //for rs
output [31:0] read_data_2, //for rt or rd 
output [31:0] imme_extend  //ok
);

reg[31:0] register[0:31];

wire [4:0] rs, rt, rd;
wire [15:0] intermediate;
reg [4:0] write_address;
reg [31:0] write_data;
assign rs = Instruction[25:21];
assign rt = Instruction[20:16];
assign rd = Instruction[15:11];


assign intermediate = Instruction[15:0];
assign imme_extend = {{16{intermediate[15]}}, intermediate};   

assign read_data_1 = register[rs];
assign read_data_2 = register[rt];



//determine which register to write
always@* begin
    if(RegWrite == 1) begin
        if(Jal == 1'b1) begin
            write_address = 5'b1111_1;
        end
        else if(RegDst == 1'b1) begin
            write_address = rd;//R type
        end
        else if(RegDst == 1'b0) begin
             write_address = rt;//I type 
        end
    end

end

//determine what data to write

always@* begin
    if(RegWrite == 1) begin
    if(Jal == 1'b1) begin
        write_data = opcplus4;
    end 
    else if(MemtoReg == 1'b1) begin
        write_data = read_data;
    end
    else if(MemtoReg == 1'b0) begin
        write_data = ALU_result;
    end
    end
end

//write data or reset 
integer i;
always@(posedge clock) begin
    if(reset == 1'b1) begin
        for(i = 0; i < 31; i = i+1) begin
            register[i] <= 0;
        end
    end    
    else if(RegWrite == 1'b1 && write_address != 1'b0) begin
        register[write_address] <= write_data;
    end
end
   



    
endmodule
