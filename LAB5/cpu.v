// Submit this file with other files you created.
// Do not touch port declarations of the module 'CPU'.

// Guidelines
// 1. It is highly recommened to `define opcodes and something useful.
// 2. You can modify modules (except InstMemory, DataMemory, and RegisterFile)
// (e.g., port declarations, remove modules, define new modules, ...)
// 3. You might need to describe combinational logics to drive them into the module (e.g., mux, and, or, ...)
// 4. `include files if required

module CPU(input reset,       // positive reset signal
           input clk,         // clock signal
           output is_halted); // Whehther to finish simulation
  /***** Wire declarations *****/
    wire [31:0] nextPC;
    wire [31:0] currentPC;
    wire [31:0] instruction;
    //wire [31:0] currentPCplus4;
    wire [31:0] beforeInst;

    wire [3:0] alu_op;

/////////////////for register /////////////
    wire [31:0] WriteRegister;
    wire [31:0]real_RegWriteData;
    wire [31:0]RegReadData1;
    wire [31:0]RegReadData2;
    wire [31:0] rf17;
/////////for Data mem/////////////////////////
    wire [31:0]DataReadData;
    wire [31:0]real_DataReadData;
     wire [31:0]real_real_DataReadData;
/// for immgen step & mux step
   wire [31:0]imm_gen_out;
   wire [31:0]real_RegReadData2;
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
   wire writeEnable;
   wire IsEcall;
   
////////for ALU ///////////////////
   wire alu_bcond; // branch condition
   
   wire [1:0] forwardingA;
   wire [1:0] forwardingB;
   wire [31:0]real_ALU_inA;
   wire [31:0]real_ALU_inB;
   wire [31:0] ALU_out;
//////////for SUM////////////////////////////////
   wire [31:0] SUM_out;
  
    wire IF_ID_write;
    wire PCWrite;
    wire [4:0] real_ID_EX_rs1;
    
    wire [31:0] real_ID_EX_rs1_before;
    wire [31:0] real_ID_EX_rs2_before;
   
   wire [4:0] afterhaltingMuxrs1;
   ///////////for hazard ////////////
   
   wire hazard_out;
   
   ////for ecall //////
    
   
   
  /***** Register declarations *****/
  // You need to modify the width of registers
  // In addition, 
  // 1. You might need other pipeline registers that are not described below
  // 2. You might not need registers described below
  /***** IF/ID pipeline registers *****/
  reg [31:0] IF_ID_inst;           // will be used in ID stage
  reg [31:0] IF_ID_currentPC;

  /***** ID/EX pipeline registers *****/
  // From the control unit
  reg [3:0] ID_EX_alu_op;         // will be used in EX stage
  reg ID_EX_alu_src;        // will be used in EX stage
  reg ID_EX_mem_write;      // will be used in MEM stage
  reg ID_EX_mem_read;       // will be used in MEM stage
  reg ID_EX_mem_to_reg;     // will be used in WB stage
  reg ID_EX_reg_write;      // will be used in WB stage
  // From others
  reg [31:0] ID_EX_rs1_data;
  reg [31:0] ID_EX_rs2_data;
  reg [4:0] ID_EX_rs1;
  reg [4:0] ID_EX_rs2;
  reg [31:0] ID_EX_imm;
  reg [3:0] ID_EX_ALU_ctrl_unit_input;
  reg [4:0] ID_EX_rd;
  reg [31:0] ID_EX_currentPC;
  reg ID_EX_isHalted;
  reg ID_EX_isEcall;
  reg ID_EX_isJal;
  reg ID_EX_isJalr;
  reg ID_EX_isBranch;
  reg [31:0]ID_EX_inst;
  
  reg [31:0] ID_EX_jump_rdin;
  /***** EX/MEM pipeline registers *****/
  // From the control unit
  reg EX_MEM_mem_write;     // will be used in MEM stage
  reg EX_MEM_mem_read;      // will be used in MEM stage
  reg EX_MEM_mem_read2;
  reg EX_MEM_is_branch;     // will be used in MEM stage
  reg EX_MEM_mem_to_reg;    // will be used in WB stage
  reg EX_MEM_reg_write;     // will be used in WB stage
  // From others
  reg [31:0] EX_MEM_alu_out;
  reg [31:0] EX_MEM_dmem_data;
  reg [4:0]EX_MEM_rd;
  reg EX_MEM_bcond;
  reg [31:0] EX_MEM_SUM_out;
  reg EX_MEM_isHalted;
  
  reg[31:0] EX_MEM_jump_rdin;
  reg EX_MEM_isJal;
  reg EX_MEM_isJalr;
  reg [31:0]EX_MEM_inst;
  /***** MEM/WB pipeline registers *****/
  // From the control unit
  reg MEM_WB_mem_to_reg;    // will be used in WB stage
  reg MEM_WB_reg_write;     // will be used in WB stage
  // From others
  reg [31:0] MEM_WB_mem_to_reg_src_1;
  reg [31:0] MEM_WB_mem_to_reg_src_2;
  reg [4:0] MEM_WB_rd;
  reg MEM_WB_isHalted;
  reg MEM_WB_alu_out;
  
  reg [31:0]MEM_WB_jump_rdin;
  reg MEM_WB_isJal;
  reg MEM_WB_isJalr;
  reg [31:0]MEM_WB_inst;
  ///for branch predict ///
  reg [31:0] branchPC;
  reg isTaken;
  
  //for cache //
  wire is_input_valid;
  wire is_output_valid;
  wire is_hit;
  wire is_ready;
  wire [2:0] cache_status;
 wire CacheStall;
//  reg [1:0] CacheStallLoad;
  reg [31:0] beforeALUout;
  wire [31:0] Cachebeforeinst;
  reg [31:0] RegReadData1_Cache;
  reg [31:0] RegReadData2_Cache;
  
  // ---------- Update program counter ----------
  // PC must be updated on the rising edge (positive edge) of the clock.
  PC pc(
    .reset(reset),       // input (Use reset to initialize PC. Initial value must be 0)
    .clk(clk),         // input
    .next_pc(nextPC),     // input
    .signal(PCWrite && !CacheStall),
    .current_pc(currentPC)   // output
  );
  
  // ---------- Instruction Memory ----------
  InstMemory imem(
    .reset(reset),   // input
    .clk(clk),     // input
    .addr(currentPC),    // input
    .dout(beforeInst)     // output
  );

  // Update IF/ID pipeline registers here
  always @(posedge clk) begin
    if (reset) begin
        IF_ID_inst <= 0;
        IF_ID_currentPC <= 0;
    end
    else if(isTaken) begin
        IF_ID_inst <= 0;
    end
    else if(CacheStall) begin
    end
    else begin
            if(IF_ID_write == 0) begin
            end
            else begin
                IF_ID_inst <= beforeInst;
                IF_ID_currentPC <= currentPC;
            end
    end
  end

  // ---------- Register File ----------
  RegisterFile reg_file (
    .reset (reset),        // input
    .clk (clk),          // input
    .rs1 (afterhaltingMuxrs1),          // input
    .rs2 (IF_ID_inst[24:20]),          // input
    .rd (MEM_WB_rd),           // input
    .rd_din (real_real_DataReadData),       // input
    .write_enable (MEM_WB_reg_write),    // input
    .rs1_dout (RegReadData1),     // output
    .rs2_dout (RegReadData2)      // output
  );

 
  // ---------- Control Unit ----------
  ControlUnit ctrl_unit (
    .instruction(IF_ID_inst),  // input
    .rf17(rf17),
    .is_jal(isJal),        // output
    .is_jalr(isJalr),       // output
    .branch(isBranch),        // output
    .part_of_inst(IF_ID_inst[6:0]),  // input
    .mem_read(memRead),      // output
    .mem_to_reg(memToReg),    // output
    .mem_write(memWrite),     // output
    .alu_src(ALUSrc),       // output
    .write_enable(regWrite),  // output
    .pc_to_reg(PCToReg),     // output
    .is_ecall(IsEcall)       // output (ecall inst)
  );
  
  //assign control_signal = {isJal,isJalr,isBranch,memRead,memToReg,memWrite,ALUSrc,writeEnable,PCToReg,alu_op};
  assign is_halted = MEM_WB_isHalted;

  // ---------- Immediate Generator ----------
  ImmediateGenerator imm_gen(
    .part_of_inst(IF_ID_inst),  // input
    .imm_gen_out(imm_gen_out)    // output
  );

  // ---------- ALU Control Unit ----------
  ALUControlUnit alu_ctrl_unit (
    .part_of_inst(IF_ID_inst),  // input
    .alu_op(alu_op)         // output
  );
  
  // Update ID/EX pipeline registers here
  always @(posedge clk) begin
    if (reset) begin
        ID_EX_rs1_data <= 0;
        ID_EX_rs2_data <= 0;
        ID_EX_rs1 <= 0;
        ID_EX_rs2 <= 0;
        ID_EX_rd <= 0;
        ID_EX_imm <= 0;
        ID_EX_ALU_ctrl_unit_input <= 0;
//        ID_EX_currentPC <= 0;
        
         //signal
        ID_EX_alu_op <= 0;        
        ID_EX_alu_src <= 0;        
        ID_EX_mem_write <= 0;      
        ID_EX_mem_read <= 0;       
        ID_EX_mem_to_reg <= 0;     
        ID_EX_reg_write <= 0;  
        ID_EX_isHalted <= 0;    
        ID_EX_isEcall <= IsEcall;
        ID_EX_isJal <= 0;
        ID_EX_isJalr <= 0;
        ID_EX_isBranch <= 0;
    end
    else if(CacheStall) begin  
    end
    else if (hazard_out || isTaken) begin
//        ID_EX_rs1_data <= 0;
//        ID_EX_rs2_data <= 0;
//        ID_EX_rs1 <= 0;
//        ID_EX_rs2 <= 0;
        //ID_EX_rd <= 0;
        //ID_EX_imm <= 0;
        ID_EX_ALU_ctrl_unit_input <= 0;
//        ID_EX_currentPC <= 0;
        
         //signal
        ID_EX_alu_op <= 0;        
        ID_EX_alu_src <= 0;        
        ID_EX_mem_write <= 0;      
        ID_EX_mem_read <= 0;       
        ID_EX_mem_to_reg <= 0;     
        ID_EX_reg_write <= 0;  
        ID_EX_isHalted <= 0;    
        ID_EX_isEcall <= IsEcall;
        ID_EX_isJal <= 0;
        ID_EX_isJalr <= 0;
        ID_EX_isBranch <= 0;
    end
    else begin
        ID_EX_rs1_data <= RegReadData1;
        ID_EX_rs2_data <= RegReadData2;
        ID_EX_rs1 <= afterhaltingMuxrs1;
        ID_EX_rs2 <= IF_ID_inst[24:20];
        ID_EX_rd <= IF_ID_inst[11:7];
        ID_EX_imm <= imm_gen_out;
        ID_EX_ALU_ctrl_unit_input <= IF_ID_inst;
        ID_EX_currentPC <= IF_ID_currentPC;
        ID_EX_inst <= IF_ID_inst;   
        ID_EX_alu_op <= alu_op;        
        ID_EX_alu_src <= ALUSrc;        
        ID_EX_mem_write <= memWrite;      
        ID_EX_mem_read <= memRead;       
        ID_EX_mem_to_reg <= memToReg;     
        ID_EX_reg_write <= regWrite;      
        ID_EX_isHalted <= 0;
        ID_EX_isEcall <= IsEcall;
        ID_EX_isJal <= isJal;
        ID_EX_isJalr <= isJalr;
        ID_EX_isBranch <= isBranch;
        ID_EX_jump_rdin <= currentPC;

    end
  end
 

  always @(*) begin
    if (ID_EX_isJal || ID_EX_isJalr || (ID_EX_isBranch && alu_bcond)) begin
        isTaken = 1;    
    end
    else begin
        isTaken = 0;
    end
  end
  // ---------- ALU ----------
  ALU alu (
    .alu_op(ID_EX_alu_op),      // input
    .alu_in_1(real_ALU_inA),    // input  
    .alu_in_2(real_ALU_inB),    // input
    .alu_result(ALU_out),  // output
    .alu_bcond(alu_bcond)     // output
  );
  
always@(*) begin
    beforeALUout = MEM_WB_alu_out;
end

  // Update EX/MEM pipeline registers here
  always @(posedge clk) begin
    if (reset) begin
        EX_MEM_alu_out <= 0;
        EX_MEM_dmem_data <= 0;
        EX_MEM_rd <= 0;
        EX_MEM_mem_write <= 0;     // will be used in MEM stage
        EX_MEM_mem_read <= 0 ;      // will be used in MEM stage
        EX_MEM_mem_read2 <= 0;
        EX_MEM_is_branch <= 0;     // will be used in MEM stage
        EX_MEM_mem_to_reg <= 0;    // will be used in WB stage
        EX_MEM_reg_write <= 0;     // will be used in WB stage 
        EX_MEM_isHalted <= 0;
    end
    else if(CacheStall) begin
    end
    else begin
        //signal 
//        if(ALU_out != 0) begin
//              EX_MEM_alu_out <= ALU_out;
//        end
//        else begin
//              EX_MEM_alu_out <= beforeALUout;
//        end
        EX_MEM_alu_out <= ALU_out;
        EX_MEM_dmem_data <= real_ID_EX_rs2_before;
        EX_MEM_rd <= ID_EX_rd;
        EX_MEM_inst <= ID_EX_inst;
        EX_MEM_mem_write <= ID_EX_mem_write;     // will be used in MEM stage
        EX_MEM_mem_read <= ID_EX_mem_read;      // will be used in MEM stage
        EX_MEM_is_branch <= isBranch;     // will be used in MEM stage
        EX_MEM_mem_to_reg <= ID_EX_mem_to_reg;    // will be used in WB stage
        EX_MEM_reg_write <= ID_EX_reg_write;     // will be used in WB stage 
        EX_MEM_jump_rdin <= ID_EX_jump_rdin;
        EX_MEM_isJal <= ID_EX_isJal;
        EX_MEM_isJalr <= ID_EX_isJalr;
        //EX_MEM_isHalted <= ID_EX_isHalted;
        
        if(ID_EX_isEcall == 1 && real_ALU_inA == 10) begin
            EX_MEM_isHalted <= 1;        
        end
        else begin
            EX_MEM_isHalted <= 0;
        end
    end
  end

always @(*) begin
    if(EX_MEM_inst[6:0] == 7'b0000011) begin
        EX_MEM_mem_read2 = 1;
    end
    else begin
        EX_MEM_mem_read2 = 0;
    end
end



assign CacheStall = is_input_valid && !(is_hit && is_ready);

  // Update MEM/WB pipeline registers here
  always @(posedge clk) begin
    if (reset) begin
         MEM_WB_mem_to_reg_src_1 <= 0;
         MEM_WB_mem_to_reg_src_2 <= 0;
         MEM_WB_rd <= 0;
        //signal 
         MEM_WB_mem_to_reg <= 0;    // will be used in WB stage
         MEM_WB_reg_write <= 0;     // will be used in WB stage
         MEM_WB_isHalted <= 0;
    end
    else if(CacheStall) begin
    end
    else begin
         MEM_WB_mem_to_reg_src_1 <= EX_MEM_alu_out;
         MEM_WB_mem_to_reg_src_2 <= DataReadData;
         MEM_WB_rd <= EX_MEM_rd;
         MEM_WB_jump_rdin <= EX_MEM_jump_rdin;
        //signal 
         MEM_WB_mem_to_reg <= EX_MEM_mem_to_reg;    // will be used in WB stage
         MEM_WB_reg_write <= EX_MEM_reg_write;     // will be used in WB stage
         MEM_WB_isHalted <= EX_MEM_isHalted;
         MEM_WB_isJal <= EX_MEM_isJal;
         MEM_WB_isJalr <= EX_MEM_isJalr;
         MEM_WB_inst <= EX_MEM_inst;
         MEM_WB_alu_out <= EX_MEM_alu_out;
    end
  end

  forwardingUnit forward(
        .rs1EX(ID_EX_rs1),
        .rs2EX(ID_EX_rs2),
        .rdMEM(EX_MEM_rd),
        .regWriteMEM(EX_MEM_reg_write),
        .rdWB(MEM_WB_rd),
        .regWriteWB(MEM_WB_reg_write),
        .forwardingA(forwardingA),
        .forwardingB(forwardingB)
    );    
    
    mux4 forwardAmux(
        .mux1(ID_EX_rs1_data),
        .mux2(EX_MEM_alu_out),
        .mux3(real_DataReadData),
        .selector(forwardingA),
        .muxoutput(real_ALU_inA)
    );
    
    mux4 forwardBmux(
        .mux1(ID_EX_rs2_data),
        .mux2(EX_MEM_alu_out),
        .mux3(real_DataReadData),
        .selector(forwardingB),
        .muxoutput(real_ID_EX_rs2_before)    
    );

    mux afterForwardB(
        .mux1(real_ID_EX_rs2_before),
        .mux2(ID_EX_imm),
        .selector(ID_EX_alu_src),
        .muxoutput(real_ALU_inB)    
    );
//----mux----//

 // Datamemory 나오고 나서 있는 mux  
//src1이 aLU RESULT, 2가 read data

    mux afterData(
      .mux1(MEM_WB_mem_to_reg_src_1), 
      .mux2(MEM_WB_mem_to_reg_src_2), 
      .muxoutput(real_DataReadData), 
      .selector(MEM_WB_mem_to_reg)
  );

  //pc전의 MUX
  mux before_ID_EX(
      .mux1(control_out), 
      .mux2(0), 
      .muxoutput(real_pipeline_signal), 
      .selector(hazard_out) 
   );
   
   always @(*) begin
    if(ID_EX_isJal || (ID_EX_isBranch && alu_bcond )) branchPC = ID_EX_currentPC + ID_EX_imm;
    else if(ID_EX_isJalr) begin
        branchPC = ID_EX_rs1_data + ID_EX_imm;
        branchPC = branchPC & 32'hFFFFFFFE;
    end
    else branchPC = 0;

   end
   
  mux realPC(
        .mux1(currentPC + 4),
        .mux2(branchPC),
        .muxoutput(nextPC),  
        .selector(isTaken)
  );
   
   mux5bit forHalted(
      .mux1(IF_ID_inst[19:15]), 
      .mux2(5'b10001), 
      .muxoutput(afterhaltingMuxrs1), 
      .selector(IsEcall) 
   );
   
   mux forJumpStore(
       .mux1(real_DataReadData),
       .mux2(EX_MEM_jump_rdin),
       .muxoutput(real_real_DataReadData),
       .selector(MEM_WB_isJal || MEM_WB_isJalr)
   );

   
 ///------adder--------
 /* add PCPLUS4(
    .add1(currentPC),
    .add2(4),
    .addoutput(nextPC)
  );*/

HazardDetection HDT(
    .rs1_ID(afterhaltingMuxrs1),
    .rs2_ID(IF_ID_inst[24:20]),
    .rd_EX(ID_EX_rd),
    .ID_EX_memRead(ID_EX_mem_read),
    .inst(IF_ID_inst),
    .PCWrite(PCWrite),
    .IF_ID_write(IF_ID_write),
    .hazard_out(hazard_out),
    .beforeinst(Cachebeforeinst)
);

assign is_input_valid =  (EX_MEM_mem_read2 || EX_MEM_mem_write);


Cache cache(
    .reset(reset),
    .clk(clk),
    .is_input_valid(is_input_valid), // input으로 쓰임 -> cache input이 valid하려면 ? 
    .addr(EX_MEM_alu_out),
    .mem_read(EX_MEM_mem_read2),
    .mem_write(EX_MEM_mem_write),
    .din(EX_MEM_dmem_data),
    .EX_MEM_inst(EX_MEM_inst),
    .is_ready(is_ready),
    .is_output_valid(is_output_valid),
    .dout(DataReadData),
    .is_hit(is_hit)
);

endmodule