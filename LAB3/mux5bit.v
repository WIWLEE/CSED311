`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/23 01:04:30
// Design Name: 
// Module Name: mux5bit
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


module mux5bit(
 mux1, mux2, muxoutput, selector
    );
    input [4:0] mux1;
    input [4:0] mux2;
    output [4:0] muxoutput;
    input selector;
    
    assign muxoutput = (selector == 0)?mux1 : mux2;

endmodule
