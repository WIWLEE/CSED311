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
    
    reg_write,
    
    mem_read,
    mem_to_reg,
    mem_write,
    alu_src,
    pc_to_reg,
    is_ecall,
    is_halted
    );
    
    input [31:0] instruction;  // input
    input [31:0] rf17;
    output reg is_jal;        // output
    output reg is_jalr;       // output
    output reg branch;        // output
    
    output reg reg_write; // 레지스터 쓰기 가능  
    
    output reg mem_read;      // output 메모리 읽기 가능 
    output reg mem_to_reg;    // output register 읽기 가능 
    output reg mem_write;     // output 메모리 쓰기 가능 
    output reg alu_src;       // output 
    output reg pc_to_reg;     // output
    output reg is_ecall;      // output (ecall inst)
   
    output reg is_halted;

   
    always @(*) begin
         is_jal = 0;
         is_jalr = 0;
         branch = 0;
         reg_write = 0;
         mem_read = 0;
         mem_to_reg = 0;
         mem_write = 0;
         alu_src = 0;
         pc_to_reg = 0;
         is_ecall = 0;
         is_halted = 0;
        
        case(instruction[6:0])
            `ARITHMETIC: begin
            // RegWrite, ALUOP set 
            // GPR[rd] <- GPR[rs1] + GPR[rs2] 
            reg_write = 1; // ALU 값을 GPR[rd]에 써야 하므로 enable 
            //alu_op_part = instruction[30] + instruction[14:12];
            
            end
            `ARITHMETIC_IMM: begin
            reg_write = 1;
           // alu_op_part = instruction[30] + instruction[14:12];
            alu_src = 1;
            //immediate value일 경우 추가
            
            end
            `LOAD: begin
            alu_src = 1; //offset 연산할 때 immediate value를 사용 
            reg_write = 1; // 연산 하면서 쓴다 
            mem_read = 1;
            mem_to_reg = 1; 
            
            end
            `JALR: begin
            is_jalr = 1;
            
            alu_src = 1;
            reg_write = 1;
            
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
            // immediate value가 다른 곳에 저장되어 있어서 isjal을 쓴다 
            is_jal = 1;
            
            alu_src = 1;
            reg_write = 1;
            
            pc_to_reg = 1;
            
            end
            `ECALL: begin
            is_ecall = 1;
            if(rf17 == 10)
                is_halted = 1;
            end
        endcase
    end
endmodule
