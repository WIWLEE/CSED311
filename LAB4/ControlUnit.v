`timescale 1ns / 1ps
`include "opcodes.v"



//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/19 21:56:28
// Design Name: 
// Module Name: ControlUnit
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


module ControlUnit(
    instruction,
    rf17,
    is_jal,
    is_jalr,
    branch,
    part_of_inst,
    mem_read,
    mem_to_reg,
    mem_write,
    alu_src,
    write_enable,
    pc_to_reg,
    is_ecall
    );
    
    input [31:0] instruction;  // input
    input [31:0] rf17;
    output reg is_jal;        // output
    output reg is_jalr;       // output
    output reg branch;        // output
    input [6:0] part_of_inst;
    output reg mem_read;      // output 메모리 읽기 가능 
    output reg mem_to_reg;    // output register 읽기 가능 
    output reg mem_write;     // output 메모리 쓰기 가능 
    output reg alu_src;       // output 
    output reg write_enable;
    output reg pc_to_reg;     // output
    output reg is_ecall;      // output (ecall inst)
    
        always @(*) begin
         is_jal = 0;
         is_jalr = 0;
         branch = 0;
         write_enable = 0;
         mem_read = 0;
         mem_to_reg = 0;
         mem_write = 0;
         alu_src = 0;
         pc_to_reg = 0;
         is_ecall = 0;
        
        case(instruction[6:0])
            `ARITHMETIC: begin
            write_enable  = 1; 
            end
            `ARITHMETIC_IMM: begin
            write_enable = 1;
            alu_src = 1;
            
            end
            `LOAD: begin
            alu_src = 1; 
            write_enable = 1;
            mem_read = 1;
            mem_to_reg = 1; 
            
            end
            `JALR: begin
            is_jalr = 1;     
            alu_src = 1;
            write_enable= 1;        
            pc_to_reg = 1;
            
            end
            `STORE: begin
            alu_src = 1;
            mem_write = 1;
            
            end
            `BRANCH: begin
                branch = 1; //blcoking 
            end
            `JAL: begin
            is_jal = 1;          
            alu_src = 1;
            write_enable = 1;  
            pc_to_reg = 1;
            
            end
            `ECALL: begin
            is_ecall = 1;

            end
        endcase
    end
endmodule
