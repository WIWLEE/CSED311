`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/19 21:58:12
// Design Name: 
// Module Name: ALU
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


module ALU(
    alu_op,      // input
    alu_in_1,    // input  
    alu_in_2,    // input
    alu_result,  // output
    alu_bcond    // output
    );
    input [3:0] alu_op;     // input(whole instruction x)
    input [31:0] alu_in_1;    // input  
    input [31:0] alu_in_2;    // input
    output reg [31:0] alu_result;  // output
    output reg alu_bcond;    // output
    
    always @(*) begin
        alu_result = 0;
        alu_bcond = 0;
        case(alu_op)
            4'b0000 : alu_result = alu_in_1 + alu_in_2;
            4'b0001 : alu_result = alu_in_1 - alu_in_2;
            4'b0010 : alu_result = alu_in_1 << alu_in_2;
            4'b0111 : alu_result = alu_in_1 ^ alu_in_2;
            4'b0110 : alu_result = alu_in_1 | alu_in_2;
            4'b0101 : alu_result = alu_in_1 & alu_in_2;
            4'b0011 : alu_result = alu_in_1 >> alu_in_2;
            
            4'b1000 : begin // BEQ
                if(alu_in_1 == alu_in_2) alu_bcond = 1;            
                else alu_bcond = 0;    
            end
            4'b1001 : begin
                if(alu_in_1 != alu_in_2) alu_bcond = 1;
                else alu_bcond = 0;
            end
            4'b1100 : begin
                if(alu_in_1 < alu_in_2) alu_bcond = 1;
                else alu_bcond = 0;
            end
            4'b1101 : begin
                if(alu_in_1 >= alu_in_2) alu_bcond = 1;
                else alu_bcond = 0;
            end
        endcase
    end
    
endmodule
