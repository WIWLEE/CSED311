`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/20 22:56:41
// Design Name: 
// Module Name: mux
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

// selector�� 0�̸� mux1��, 0�̸� mux0�� ����
module mux(
    mux1, mux2, muxoutput, selector
    );
    input [31:0] mux1;
    input [31:0] mux2;
    output [31:0] muxoutput;
    input selector;
    
    assign muxoutput = (selector == 0)?mux1 : mux2;
        
endmodule
