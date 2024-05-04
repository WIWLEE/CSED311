`timescale 1ns / 1ps
`define IF 4'b0000 // 0
`define ID 4'b0001 // 1
`define MEMADDRCOMPUTE 4'b0010 // 2
`define EXER 4'b0101 // 5
`define EXEI 4'b0110 // 6
`define BRANCHCOMPUTE 4'b1001 // 9
`define BRANCHSELECT 4'b1010 // 10
`define MEMREAD 4'b0011 // 3
`define MEMWRITE 4'b1000 // 8
`define WBALU 4'b0111 // 7
`define WB 4'b0100 // 4
`define WBJAL 4'b1011 // 11
`define WBJALR 4'b1100 // 12
`define ECALLCOMPUTE 4'b1101 // 13

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
    reset,
    clk,
    
    RegWrite,
    MemRead,
    MemWrite,
    MemtoReg,

    is_ecall,
    is_halted,
    
    ALUSrcA,
    IorD,
    IRWrite,
    PCSource,
    PCWrite,
    PCWriteNotCond,
    ALUSrcB,
    
    ALUCtrlOn,
    alu_bcond,
    rf17
    );
    
    input [31:0] instruction;  // input
    input [31:0] rf17;
    input reset; 
    input clk;
    
    output reg RegWrite; // 레지스터 쓰기 가능  
    output reg MemRead;      // output 메모리 읽기 가능 
    output reg MemWrite;    // output register 읽기 가능 
    output reg MemtoReg;     // output 메모리 쓰기 가능 
    
    output reg is_ecall;       
    output reg is_halted;
    
    output reg ALUSrcA;
    output reg IorD; 
    output reg IRWrite;
    output reg PCSource;
    output reg PCWrite;
    output reg PCWriteNotCond;
    output reg [1:0] ALUSrcB;
    
    output reg [3:0] ALUCtrlOn;
    
    input alu_bcond;
  
   reg [6:0] opcode;
   reg [3:0] microPC;
   reg [3:0] AddrCtl;
    
    reg [3:0] DispatchROM2[0:7];
    reg [3:0] DIspatchROM3[0:2];
    reg [3:0] DispatchROM4;
    reg [3:0] DispatchROM5;
    //Address Select logic 
    always @(posedge clk) begin
        opcode = instruction[6:0];
        
        if(reset) begin
            microPC = `IF;
            DispatchROM2[0] = `MEMADDRCOMPUTE;
            DispatchROM2[1] = `EXER;
            DispatchROM2[2] = `EXEI;
            DispatchROM2[3] = `BRANCHCOMPUTE;
            DispatchROM2[4] = `WBJAL;
            DispatchROM2[5] = `WBJALR;
            DispatchROM2[6] = `ECALLCOMPUTE;
            
            DIspatchROM3[0] = `MEMREAD;
            DIspatchROM3[1] = `MEMWRITE;
            
            DispatchROM4 = `BRANCHSELECT;
            DispatchROM5 = `WBALU;
        end
        else begin
         //1. OPCODE로 dispatchrom1, 2를 긁어온다.
         
         //AddrCtl로 select
            case(AddrCtl)
                0: begin
                    microPC = `IF;
                end
                1 : begin
                    microPC = microPC + 1;
                end
                2 : begin
                    case(opcode)
                        `LOAD: begin
                            microPC = DispatchROM2[0];
                        end
                        `STORE : begin
                            microPC = DispatchROM2[0];
                        end
                        `ARITHMETIC : begin
                            microPC = DispatchROM2[1];
                        end
                        `ARITHMETIC_IMM : begin
                            microPC = DispatchROM2[2];
                        end 
                        `BRANCH : begin
                            microPC = DispatchROM2[3];
                        end
                        `JAL : begin
                            microPC = DispatchROM2[4];
                        end 
                        `JALR : begin
                            microPC = DispatchROM2[5];
                        end
                        `ECALL : begin
                            microPC = DispatchROM2[6];
                        end
                    endcase
                end
                3 : begin
                    if(opcode == `LOAD)
                        microPC = DIspatchROM3[0];
                    if(opcode == `STORE)
                        microPC = DIspatchROM3[1];
                end
                4 : begin
                   microPC = DispatchROM4;
                end
                5 : begin
                    microPC = DispatchROM5;
                end
            endcase
        end
    end
    
    always @(*) begin
         RegWrite = 0;
         MemRead = 0;
         MemWrite = 0;
         MemtoReg = 0;
         
         is_ecall = 0;
         is_halted = 0;
         
         ALUSrcA = 0;
         //IorD = 0;
         IRWrite = 0;
         PCSource = 0;
         PCWrite = 0;
         PCWriteNotCond = 0;
         ALUSrcB = 0;       
        
        ALUCtrlOn = 0;
        
        //opcode = instruction[6:0];

        case(microPC)
            `IF : begin
                
                IorD = 0;
                MemRead = 1;
      
                IRWrite = 1;
                
                AddrCtl = 1;
            end
            `ID : begin
              
                ALUSrcA = 0; // PC를 더해줘서 ALUOut에 저장해 놓는다 
                ALUSrcB = 1; // 4이다. 
                ALUCtrlOn = 3'b001; // ALUCtrlOn이 1이면 PC+4 연산을 하는 것이다.    
                
                AddrCtl = 2;
            end
            `ECALLCOMPUTE : begin
                is_ecall = 1;
                
                //is_halted = 1;
                if(rf17 == 10) begin
                    is_halted = 1;
                end
                ALUSrcA = 0; 
                ALUSrcB = 1;  
                ALUCtrlOn = 3'b001;
                PCSource = 0;
                PCWrite = 1; // PC = PC + 4
                
                AddrCtl = 0; // go to IF stage
            end
            `MEMADDRCOMPUTE: begin
                 ALUSrcA =1;
                 ALUSrcB = 2;
                 ALUCtrlOn = 1; // 주소 구하기 
                 
                 AddrCtl = 3;
            end
            `EXER : begin
                ALUSrcA = 1;
                ALUSrcB = 0;
                ALUCtrlOn = 2;
                
                AddrCtl = 5;
            end
            `EXEI : begin
                ALUSrcA = 1;
                ALUSrcB = 2;
                ALUCtrlOn = 2;
                
                AddrCtl = 5;
            end
            `BRANCHCOMPUTE: begin
                        
                        //branch 명령어일 경우 다음 PC는 BEQ rs1, rs2, imm13 
                        ALUSrcA = 1; // rs1 
                        ALUSrcB = 0; // rs2 
                        ALUCtrlOn = 2; // branch는 복잡한 연산 
                        
                        //bcond가 나왔다. bcond가 0이면 PC = PC+4로 업데이트 해야 한다.
                        PCSource = 1; // PC+4가 들어가 있는 위치 : ALUout
                        PCWriteNotCond = 1; // bcond가 1이고 이것도 1이어야 PC가 브랜치 되는 것이허용된다.
                        
                        if(alu_bcond)
                            AddrCtl = 4;
                        else
                            AddrCtl = 0;
             end
            `BRANCHSELECT : begin
                
                ALUSrcA = 0; // 이건 bcond가 1일 경우이다.
                ALUSrcB = 2;
                ALUCtrlOn = 1;
                
                PCSource = 0;
                PCWrite = 1;
                
                AddrCtl = 0;
            end
            `MEMREAD: begin
                        
                MemRead = 1;
                IorD = 1; // ALUOut가 Data address를 alu_bcond 
                
                AddrCtl = 1;
             end       
            `MEMWRITE: begin
                
                MemWrite = 1;
                IorD = 1;       
                
                ALUSrcA = 0;
                ALUSrcB = 1;
                ALUCtrlOn = 1;
                PCSource = 0;
                PCWrite = 1;    
                
                AddrCtl = 0;
            end
            `WBALU : begin
                RegWrite = 1;
                        
                ALUSrcA = 0;
                ALUSrcB = 1;
                ALUCtrlOn = 1;
                PCSource = 0;
                PCWrite = 1;   
                
                AddrCtl = 0; 
            end
            `WB : begin
                RegWrite = 1;  
                MemtoReg = 1;
                
                ALUSrcA = 0;
                ALUSrcB = 1;
                ALUCtrlOn = 1;
                PCSource = 0;
                PCWrite = 1;   
                
                AddrCtl = 0;
            end
            `WBJAL: begin
                RegWrite = 1;
                ALUSrcA = 0;
                ALUSrcB = 2;
                ALUCtrlOn = 1;
                PCSource = 0;
                PCWrite = 1;
                
                AddrCtl = 0;
            end
            `WBJALR : begin
                RegWrite = 1;
                ALUSrcA = 1;
                ALUSrcB = 2;
                ALUCtrlOn = 1;
                PCSource = 0;
                PCWrite = 1;
                
                AddrCtl = 0; // go to IF
            end
           endcase                   
end
    
endmodule
