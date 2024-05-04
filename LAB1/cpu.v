// Submit this file with other files you created.
// Do not touch port declarations of the module 'CPU'.

// Guidelines
// 1. It is highly recommened to `define opcodes and something useful.
// 2. You can modify the module.
// (e.g., port declarations, remove modules, define new modules, ...)
// 3. You might need to describe combinational logics to drive them into the module (e.g., mux, and, or, ...)
// 4. `include files if required

`include "PC.v"
`include "Memory.v"
`include "RegisterFile.v"
`include "ControlUnit.v"
`include "ImmediateGenerator.v"
`include "ALUControlUnit.v"
`include "ALU.v"

 
 module CPU(input reset,       // positive reset signal
           input clk,         // clock signal
           output is_halted); // Whehther to finish simulation
  /***** Wire declarations *****/
   
   wire [31:0] nextPC;
   wire [31:0] currentPC;
   wire [31:0] instruction;
   
   wire [31:0] currentPCplus4;
   
  // wire [4:0] alu_op_part;
   wire [3:0] alu_op;

/////////////////for register /////////////
 wire [31:0] WriteRegister;
    wire [31:0]real_RegWriteData;
    wire [31:0]RegReadData1;
    wire [31:0]RegReadData2;
    wire [31:0] rf17;
/////////for Data mem/////////////////////////
    wire [31:0]real_DataOutput;
    wire [31:0]DataReadData;


/////////////////////////////////
/// for immgen step & mux step
   wire [31:0]imm_gen_out;
   wire [31:0]real_RegReadData2;
   //////////////////////////////
////////for control unit ///////// 
   
   wire isJal;
   wire isJalr;
   wire isBranch;
   
   wire regWrite;
   
   wire memRead;
   wire memToReg;
   wire memWrite;
   wire ALUSrc;
   wire PCToReg;
   wire IsEcall;
  /////////////////////////////////
////////for ALU ///////////////////
   wire alu_bcond; // branch condition
     wire [31:0] ALU_out;

//////////for SUM////////////////////////////////
    wire [31:0] SumOut;
    wire [31:0] SumMux1Out;
    wire [31:0] SumMux2Out;
   

  /***** Register declarations *****/
    
    
  // ---------- Update program counter ----------
  // PC must be updated on the rising edge (positive edge) of the clock.
  PC pc(
    .reset(reset),       // input (Use reset to initialize PC. Initial value must be 0)
    .clk(clk),         // input
    .next_pc(nextPC),     // input
    .current_pc(currentPC)   // output
  );
  
  // ---------- Instruction Memory ----------
  InstMemory imem(
    .reset(reset),   // input
    .clk(clk),     // input
    .addr(currentPC),    // input
    .dout(instruction)    // output
  );

  // ---------- Register File ----------
  RegisterFile reg_file (
    .reset (reset),        // input
    .clk (clk),          // input
    .rs1 (instruction[19:15]),          // input
    .rs2 (instruction[24:20]),          // input
    .rd (instruction[11:7]),           // input
    .rd_din (real_DataOutput),       // input
    .write_enable (regWrite),    // input
    .rs1_dout (RegReadData1),     // output
    .rs2_dout (RegReadData2),      // output
    .rf17(rf17)

  );



  // ---------- Control Unit ----------
  ControlUnit ctrl_unit (
    .instruction(instruction),  // input
    .rf17(rf17),
    
    .is_jal(isJal),        // output
    .is_jalr(isJalr),       // output
    .branch(isBranch),        // output
    
    .reg_write(regWrite),
   // .alu_op_part(alu_op_part),
    
    .mem_read(memRead),      // output
    .mem_to_reg(memToReg),    // output
    .mem_write(memWrite),     // output
    .alu_src(ALUSrc),       // output
    .pc_to_reg(PCToReg),     // output
    .is_ecall(IsEcall),      // output (ecall inst)
    .is_halted(is_halted)
  );

  // ---------- Immediate Generator ----------
  ImmediateGenerator imm_gen(
    .part_of_inst(instruction),  // input
    .imm_gen_out(imm_gen_out)    // output
  );

 
  // ---------- ALU Control Unit ----------
  ALUControlUnit alu_ctrl_unit (
    .part_of_inst(instruction),  // input
    .alu_op(alu_op)         // output
  );

  // ---------- ALU ----------
  ALU alu (
    .alu_op(alu_op),      // input
    .alu_in_1(RegReadData1),    // input  
    .alu_in_2(real_RegReadData2),    // input
    .alu_result(ALU_out),  // output
    .alu_bcond(alu_bcond)     // output
  );

  // ---------- Data Memory ----------
  DataMemory dmem(
    .reset (reset),      // input
    .clk (clk),        // input
    .addr (ALU_out),       // input
    .din (RegReadData2),        // input
    .mem_read (memRead),   // input
    .mem_write (memWrite),  // input
    .dout (DataReadData)        // output
  );
  
  
  //----------------mux-----------------------ALU
   //immediate value인지 rs2 value인지를 선택 
  mux ImmOrRs2(
    .mux1(RegReadData2),
    .mux2(imm_gen_out),
    .selector(ALUSrc),
    .muxoutput(real_RegReadData2)
 );

 // Datamemory 나오고 나서 있는 mux  
   mux afterData(
      .mux1(ALU_out), 
      .mux2(DataReadData), 
      .muxoutput(real_DataOutput), 
      .selector(memToReg)
  );
  
  // Register 들어가기 전에 있는 mux 
   mux beforeReg(
      .mux1(real_DataOutput), 
      .mux2(currentPCplus4), 
      .muxoutput(real_RegWriteData), 
      .selector(PCToReg)
  );
  
  // jump에서 첫번쨰로 만나는 mux
  
  mux SumMux1(
       .mux1(currentPCplus4), 
      .mux2(SumOut), 
      .muxoutput(SumMux1Out), 
      .selector((isBranch && alu_bcond) || isJal)
  );

  // jump에서 두번째로 만나는 mux 
  mux SumMux2(
       .mux1(SumMux1Out), 
      .mux2(ALU_out), 
      .muxoutput(nextPC), 
       .selector(isJalr)
  );
  
  // -- add ------
  add PCPLUS4(
    .add1(currentPC),
    .add2(4),
    .addoutput(currentPCplus4)
  );
  
  add SUM(
    .add1(currentPC),
    .add2(imm_gen_out),
    .addoutput(SumOut)
  );

endmodule
