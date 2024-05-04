`timescale 1ns / 1ps
`include "opcodes.v"

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/19 22:00:58
// Design Name: 
// Module Name: ALUControlUnit
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


module ALUControlUnit(
    part_of_inst,  // input
    alu_op       // output
    );
    input [31:0]part_of_inst;  // input
    output reg [3:0] alu_op;       // output
    
    //part_of_inst에서 opcode를 보고 우선 연산의 종류 나눠줌, ControlUnit 참고

    always @(*) begin
            case(part_of_inst[6:0]) 
                `ARITHMETIC: begin
                    if(part_of_inst[30] == 1)
                        alu_op = 4'b0001;
                    else begin
                        case(part_of_inst[14:12]) 
                            `FUNCT3_ADD : begin
                                alu_op = 4'b0000;
                            end
                            `FUNCT3_SLL : begin
                                alu_op = 4'b0010; /// 임의로 정함
                            end
                            `FUNCT3_XOR : begin
                                alu_op = 4'b0111;
                            end 
                            `FUNCT3_OR : begin
                                alu_op = 4'b0110;
                            end 
                            `FUNCT3_AND : begin
                                alu_op = 4'b0101;
                            end 
                            `FUNCT3_SRL : begin
                                alu_op = 4'b0011; /// 임의로 정함
                            end
                        endcase
                    end
                 end
                `ARITHMETIC_IMM: begin
                    case(part_of_inst[14:12])
                            `FUNCT3_ADD : begin
                                alu_op = 4'b0000;
                            end
                            `FUNCT3_SLL : begin
                                alu_op = 4'b0010; /// 임의로 정함
                            end
                            `FUNCT3_XOR : begin
                                alu_op = 4'b0111;
                            end 
                            `FUNCT3_OR : begin
                                alu_op = 4'b0110;
                            end 
                            `FUNCT3_AND : begin
                                alu_op = 4'b0101;
                            end 
                            `FUNCT3_SRL : begin
                                alu_op = 4'b0011; /// 임의로 정함
                            end                   
                    endcase
                end
                `LOAD: begin
                    alu_op = 4'b0000;
                end
                `JALR: begin
                    alu_op = 4'b0000;
                end
                `STORE: begin
                    alu_op = 4'b0000;
                end
                `BRANCH: begin
                //////////////ALU에서 branch condition을 관측해 주어야 한다. //////////////
                    case(part_of_inst[14:12])
                            `FUNCT3_BEQ : begin
                                alu_op = 4'b1000;
                            end
                            `FUNCT3_BNE : begin
                                alu_op = 4'b1001; 
                            end
                            `FUNCT3_BLT : begin
                                alu_op = 4'b1100;
                            end 
                            `FUNCT3_BGE : begin
                                alu_op = 4'b1101; 
                            end                   
                    endcase
                end
    //JAL은 연산 안 한다
            endcase
        end
endmodule
