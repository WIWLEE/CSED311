`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/21 23:21:42
// Design Name: 
// Module Name: forwardingUnit
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


module forwardingUnit(
    input [4:0] rs1EX,
    input [4:0] rs2EX,
    input [4:0] rdMEM,
    input regWriteMEM,
    input [4:0] rdWB,
    input regWriteWB,
    output reg [1:0]forwardingA,
    output reg [1:0]forwardingB
    );
    
    always @(*) begin
        if(rs1EX != 0 && rs1EX == rdMEM && regWriteMEM)
            forwardingA = 2'b01;
        else if(rs1EX != 0 && rs1EX == rdWB && regWriteWB)
            forwardingA = 2'b10;
        else
            forwardingA = 2'b00;
        if(rs2EX != 0 && rs2EX == rdMEM && regWriteMEM)
            forwardingB = 2'b01;
        else if(rs2EX != 0 && rs2EX == rdWB && regWriteWB)
            forwardingB = 2'b10;
        else
            forwardingB = 2'b00;
    end
    
endmodule
