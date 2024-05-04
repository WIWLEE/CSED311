// Submit this file with other files you created.
// Do not touch port declarations of the module 'CPU'.

// Guidelines
// 1. It is highly recommened to `define opcodes and something useful.
// 2. You can modify the module.
// (e.g., port declarations, remove modules, define new modules, ...)
// 3. You might need to describe combinational logics to drive them into the module (e.g., mux, and, or, ...)
// 4. `include files if required

module CPU(input reset,       // positive reset signal
           input clk,         // clock signal
           output is_halted); // Whehther to finish simulation
  /***** Wire declarations *****/
     wire [31:0] nextPC;
     wire [31:0] currentPC;
     wire [31:0] real_currentPC;
     wire [31:0] currentPCplus4; 
     wire [4:0] alu_op_part;
     wire [3:0] alu_op;
     
     ////////////////for ALU /////////////
     wire [31:0] realA;
     wire [31:0] realB;
     wire [31:0] ALU_out;
     wire alu_bcond;
     
     wire [3:0] ALUCtrlOn;
    /////////////////for register /////////////
     wire [31:0] MemData;
   /////////////////for register /////////////
    wire [31:0] WriteRegister;
    wire [31:0]real_RegWriteData;
    wire [31:0]RegReadData1;
    wire [31:0]RegReadData2;
/////signal////////////////////////;
    
    wire isJal;
    wire isJalr;
    wire isBranch;
    
    wire RegWrite;
    wire MemRead;
    wire MemWrite;
    wire MemtoReg;

    wire is_ecall;
    wire is_halted;
    
    wire ALUSrcA;
    wire [1:0] ALUSrcB;
    wire IorD;
    wire IRWrite;
    wire PCSource;
    wire PCWrite;
    wire PCWriteNotCond;
    
    wire IsEcall;    
/////////////////////////////////
/// for immgen step & mux step
   wire [31:0]imm_gen_out;
    

  /***** Register declarations *****/
  reg [31:0] IR; // instruction register
  reg [31:0] MDR; // memory data register
  reg [31:0] A; // Read 1 data register
  reg [31:0] B; // Read 2 data register
  reg [31:0] ALUOut; // ALU output register
  // Do not modify and use registers declared above.
    
  reg [31:0] rf17;

  // ---------- Update program counter ----------
  // PC must be updated on the rising edge (positive edge) of the clock.
  PC pc(
    .reset(reset),       // input (Use reset to initialize PC. Initial value must be 0)
    .clk(clk),         // input
    .next_pc(nextPC),     // input
    .current_pc(currentPC),   // output
    .signal((!alu_bcond && PCWriteNotCond) || PCWrite)
  );

  // ---------- Register File ----------
  RegisterFile reg_file(
    .reset(reset),        // input
    .clk(clk),          // input
    .rs1(IR[19:15]),         // input
    .rs2(IR[24:20]),          // input
    .rd(IR[11:7]),           // input
    .rd_din(real_RegWriteData),       // input
    .write_enable(RegWrite),    // input
    .rs1_dout(RegReadData1),     // output
    .rs2_dout(RegReadData2)     // output
  );

  // ---------- Memory ----------
  Memory memory(
    .reset(reset),        // input
    .clk(clk),          // input
    .addr(real_currentPC),         // input
    .din(RegReadData2),          // input
    .mem_read(MemRead),     // input
    .mem_write(MemWrite),    // input
    .dout(MemData)          // output
  );

  // ---------- Control Unit ----------
  ControlUnit ctrl_unit(
    .instruction(IR[31:0]),  // input
    .reset(reset),
    .clk(clk),
    .RegWrite(RegWrite),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .MemtoReg(MemtoReg),
    .is_ecall(is_ecall),
    .is_halted(is_halted),
    .ALUSrcA(ALUSrcA),
    .IorD(IorD),
    .IRWrite(IRWrite),
    .PCSource(PCSource),
    .PCWrite(PCWrite),
    .PCWriteNotCond(PCWriteNotCond),
    .ALUSrcB(ALUSrcB),
    .ALUCtrlOn(ALUCtrlOn[3:0]),
    .alu_bcond(alu_bcond),
    .rf17(rf17)
  );

  // ---------- Immediate Generator ----------
  ImmediateGenerator imm_gen(
    .part_of_inst(IR[31:0]),  // input
    .imm_gen_out(imm_gen_out)    // output
  );

  // ---------- ALU Control Unit ----------
  ALUControlUnit alu_ctrl_unit(
    .part_of_inst(IR[31:0]),  // input
    .ALUCtrlOn(ALUCtrlOn[3:0]),
    .alu_op(alu_op)         // output
  );

  // ---------- ALU ----------
  ALU alu(
    .alu_op(alu_op),      // input
    .alu_in_1(realA),    // input  
    .alu_in_2(realB),    // input
    .alu_result(ALU_out),  // output
    .alu_bcond(alu_bcond)     // output
  );
  
   //mux ishalted(
   //  .mux1(1),
   //  .mux2(0),
   //  .muxoutput(is_halted),
     //.selector(is_ecall&&(RegReadData1==10))
  // );
  // ---------- mux -----------
  mux afterA(
      .mux1(currentPC), 
      .mux2(A), 
      .muxoutput(realA), 
      .selector(ALUSrcA)
  );
  
  mux4 afterB(
      .mux1(B),
      .mux2(4),
      .mux3(imm_gen_out),
      .muxoutput(realB),
      .selector(ALUSrcB)
  );
  
  mux beforePC(
      .mux1(ALU_out), 
      .mux2(ALUOut), 
      .muxoutput(nextPC), 
      .selector(PCSource)
  );
  
  mux afterPC(
      .mux1(currentPC), 
      .mux2(ALUOut), 
      .muxoutput(real_currentPC), 
      .selector(IorD)
  );
  
  mux beforeRegWrite(
      .mux1(ALUOut), 
      .mux2(MDR), 
      .muxoutput(real_RegWriteData), 
      .selector(MemtoReg)
  );
  

 //assign rf17 = (IR[11:7]==17 && RegWrite == 1)? real_RegWriteData : temp;
 
 //reg[31:0] temp = real_regWriteData;
 
    // ---------- register update -----------
always @(posedge clk) begin
    A <= RegReadData1;
    B <= RegReadData2;
    ALUOut <= ALU_out;
    if(RegWrite == 1 && IR[11:7] == 17) begin
        rf17 <= real_RegWriteData;
    end
      
    if(IorD == 1) begin
        MDR <= MemData;  
    end
    else if(IRWrite == 1) begin
        IR <= MemData;
    end
end


endmodule