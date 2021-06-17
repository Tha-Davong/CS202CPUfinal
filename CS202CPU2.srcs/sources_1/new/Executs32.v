`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/17/2021 12:31:34 AM
// Design Name: 
// Module Name: Executs32
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


module Executs32(
input[31:0] Read_data_1,
input[31:0] Read_data_2,
input[31:0] Imme_extend,
input[5:0] Function_opcode,
input[5:0] opcode,
input[1:0] ALUOp,
input[4:0] Shamt,
input Sftmd,
input ALUSrc,
input I_format,
input Jr,
input[31:0] PC_plus_4,

output Zero,
output reg [31:0] ALU_Result,
output [31:0] Addr_Result

);

wire signed [31:0] Ainput, Binput;//take into account sltu
wire [31:0] abs_A, abs_B;
wire[5:0] Exe_code;
wire[2:0] ALU_ctl;
wire[2:0] Sftm;
reg[31:0] Shift_Result;

wire[32:0] Branch_Addr;
//choosing operand
assign Ainput = Read_data_1;
assign Binput = (ALUSrc == 0) ? Read_data_2 : Imme_extend[31:0];
assign abs_A = ((Ainput >>> 31) + Ainput) ^ (Ainput >>> 31);
assign abs_B = ((Binput >>> 31) + Binput) ^ (Binput >>> 31);
//internal control 
assign Exe_code = (I_format == 0) ? Function_opcode : {3'b000, opcode[2:0]};
assign ALU_ctl[0] = (Exe_code[0] | Exe_code[3]) & ALUOp[1]; 
assign ALU_ctl[1] = ( (!Exe_code[2]) | (!ALUOp[1]) );
assign ALU_ctl[2] = ( Exe_code[1] & ALUOp[1] ) | ALUOp[0];
//identify the type of shift instruction
assign Sftm = Function_opcode[2:0];

//part1: Arithmetic and logical operation
reg[31:0] ALU_output_mux;

always @(ALU_ctl or Ainput or Binput)
begin
case(ALU_ctl)
    3'b000: ALU_output_mux = Ainput & Binput;
    3'b001: ALU_output_mux = Ainput | Binput;
    3'b010: ALU_output_mux = Ainput + Binput;
    3'b011: ALU_output_mux = Ainput + Binput;//addu addiu
    3'b100: ALU_output_mux = Ainput ^ Binput;
    3'b101: ALU_output_mux = ~(Ainput | Binput);
    3'b110: ALU_output_mux = Ainput + (~Binput +1);//beq bne sub slti
    3'b111: ALU_output_mux = Ainput - Binput; //subu, sltiu slt sltu
    default: ALU_output_mux = 32'h0000_0000;
endcase
end
//part2: Shift operation 
always @* 
begin 
    if(Sftmd)
        case(Sftm[2:0])
            3'b000:Shift_Result = Binput << Shamt; //Sll rd,rt,shamt 00000
            3'b010:Shift_Result = Binput >> Shamt; //Srl rd,rt,shamt 00010
            3'b100:Shift_Result = Binput << Ainput; //Sllv rd,rt,rs 000100
            3'b110:Shift_Result = Binput >> Ainput; //Srlv rd,rt,rs 000110
            3'b011:Shift_Result =  Binput >>> Shamt;     //Sra rd,rt,shamt 00011
            3'b111:Shift_Result = Binput >>> Ainput; //Srav rd,rt,rs 00111
            default:Shift_Result = Binput;
        endcase
    else
        Shift_Result = Binput;
end
//choosing result 
always @* begin
    //slt or slti
    if(((ALU_ctl==3'b111) && (Exe_code[0]==0))||((ALU_ctl == 3'b110) && (I_format==1)))
        ALU_Result = (Ainput-Binput<0) ? 1:0;
        //sltu or sltiu
    else if (((ALU_ctl==3'b111) && (Exe_code[3]==1)) ||((ALU_ctl == 3'b111) && I_format == 1 ))
        ALU_Result = (abs_A - abs_B<0) ? 1:0;
    else if((ALU_ctl==3'b101) && (I_format==1))
        ALU_Result[31:0]={Binput[15:0],{16{1'b0}}};
    else if(Sftmd==1)
        ALU_Result = Shift_Result;
    else
        ALU_Result = ALU_output_mux[31:0];
end

assign Branch_Addr = PC_plus_4[31:2] + Imme_extend[31:0];
assign Addr_Result = Branch_Addr[31:0];
assign Zero = (ALU_output_mux[31:0]== 32'h0000_0000) ? 1'b1 : 1'b0;


endmodule
