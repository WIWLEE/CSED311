`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/19 21:54:29
// Design Name: 
// Module Name: PC
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


module PC(
    reset,       
    clk,         
    next_pc,     
    current_pc,
    signal
  /* 
    isjumpinst,
    jumptarget,
    isbranchinst, 
    branchtarget
    */
    );
    input reset;       
    input clk;         
    input [31:0] next_pc;     
    output reg [31:0] current_pc;
    input signal;
    
    /*
    input isjumpinst;
    input [31:0] jumptarget;
    input isbranchinst; 
    input [31:0] branchtarget;
    */
    
    always @(posedge clk) begin
        if(reset)
            current_pc <= 0;
        if(signal == 1)
            current_pc <= next_pc;
    end
    
endmodule