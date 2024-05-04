`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/22 00:00:28
// Design Name: 
// Module Name: HazardDetection
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


module HazardDetection(
    input [4:0] rs1_ID,
    input [4:0] rs2_ID,
    input [4:0] rd_EX,
    input ID_EX_memRead,
    input [31:0] inst,
    output reg PCWrite,
    output reg IF_ID_write,
    output reg hazard_out,
    output reg [31:0] beforeinst
    );
    
    always @(*) begin
        hazard_out = 0;
        PCWrite = 1;
        IF_ID_write = 1;
        if ((((rs1_ID == rd_EX) &&  rs1_ID!=0) || ((rs2_ID == rd_EX) && rs2_ID!=0)) && ID_EX_memRead) begin
            PCWrite = 0;
            IF_ID_write = 0;
            hazard_out = 1;
            beforeinst = inst;
        end
    end
    
endmodule
