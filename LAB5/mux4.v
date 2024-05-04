`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/14 17:58:18
// Design Name: 
// Module Name: mux4
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


module mux4(
    mux1, mux2, mux3, muxoutput, selector
    );
    input [31:0] mux1;
    input [31:0] mux2;
    input [31:0] mux3;
    output reg[31:0] muxoutput;
    input [1:0] selector;
    
    always @(*) begin
        if(selector == 2)
            muxoutput = mux3;
        else if(selector == 1)
            muxoutput = mux2;
        else if(selector == 0)
            muxoutput = mux1;
    end

endmodule
