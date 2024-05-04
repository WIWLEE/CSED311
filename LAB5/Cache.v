`include "CLOG2.v"
`define CACHE_STOP 4'b0000
`define CACHE_END 4'b0100
`define TAG_COMPARE 4'b0001
`define READ_MISS 4'b0101
`define WRITE_HIT_CACHE_CONFLICT 4'b0011
`define WRITE_MISS_ALLOCATE 4'b0010
`define WRITE_MISS_ALLOCATE_WRITE 4'b0110
`define READ_MISS_WRITE 4'b1000
`define READ_MISS_2 4'b1100

module Cache #(parameter LINE_SIZE = 16,
               parameter NUM_SETS = 16,
               parameter NUM_WAYS = 1) (
    input reset,
    input clk,

    input is_input_valid,
    input [31:0] addr,
    input mem_read,
    input mem_write,
    input [31:0] din,
    
    input [31:0] EX_MEM_inst,
    
    output reg is_ready,
    output reg is_output_valid,
    output reg [31:0] dout,
    output reg is_hit);
  // Wire declarations

  
  // 데이터들이 4Byte라고 가정 
  // LINE_SIZE가 16Byte 이므로, 블럭의 개수는 4개이다.
  wire [1:0]block_offset; 
  wire [3:0]set_idx; // set가 16개이므로 4bit addr - [CLOG2[16]-1:0]
  wire [23:0]tag;
  
  wire dmem_ready;
  wire dmem_output_valid;
  reg dmem_input_valid;
  reg dmem_read;
  reg dmem_write;
  
  reg mem_read2;
  
  // Reg declarations
  // You might need registers to keep the status.
 
  reg [23:0] Tag_Bank[0:NUM_SETS-1]; // 1 way이므로 tag는 set개만큼 있다.
  reg Valid[0:NUM_SETS-1];
  reg Dirty[0:NUM_SETS-1];
  //데이터들은 block 단위로 저장된다. block의 크기는 16바이트(LINE_SIZE)이므로, data_bank의 크기를 구할 수 있다.
  reg [0:LINE_SIZE*8-1] Data_Bank[0:NUM_SETS-1]; // 256 바이트짜리 데이터 뱅크 
  reg [0:LINE_SIZE*8-1] WriteBack_Data;
  
  reg [3:0] cache_status;
  reg [3:0] next_cache_status;
  
  reg [31:0]dmem_addr;
  reg [LINE_SIZE*8-1:0] dmem_din; 
  wire [LINE_SIZE*8-1:0] dmem_dout;
  

 //assign// 
 assign tag = addr[31:8];
 assign set_idx = addr[7:4];
 assign block_offset = addr[3:2];
 
always @(*) begin
    if(EX_MEM_inst[6:0] == 7'b0000011) begin
        mem_read2 = 1;
    end
    else begin
        mem_read2 = 0;
    end
end
 

  integer i;
  
  //1. 초기값을 메모리 초기화해주듯이 초기화한다. 
  always @(posedge clk) begin
    if(reset) begin 
        cache_status <= 3'b000; // 000 means nothing;
        for(i = 0; i < NUM_SETS;i = i + 1) begin
            Tag_Bank[i] <= 0;
            Data_Bank[i] <= 128'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
            Valid[i] <= 0;
            Dirty[i] <= 0;
        end
    end
    else begin
        cache_status <= next_cache_status;
    end
  end
  
  
  always @(*) begin
        case(cache_status)
            `CACHE_STOP : begin // 캐시가 중지된 상태 
                if(is_input_valid) begin
                    next_cache_status = `TAG_COMPARE;           
                    //is_cache_stopped = 0;
                    is_ready = 0;
                end
                else begin
                    next_cache_status = `CACHE_STOP;              
                    //is_cache_stopped = 1;
                    is_ready = 1;
                end
            end
            `CACHE_END : begin
                 //is_cache_stopped = 1;
                is_ready = 1;
                dmem_input_valid = 0;
                next_cache_status = `CACHE_STOP;
            end
            `TAG_COMPARE : begin // 캐시가 Hit인지 Miss인지를 확인하는 상태
                if(Valid[set_idx] && tag == Tag_Bank[set_idx]) begin
                    is_output_valid = 1;
                    is_hit = 1;
                    dmem_read = 0;
                    dmem_write = 0;
                end
                else begin 
                    is_output_valid = 0;
                    is_hit = 0;
                end
                
                if(mem_read2) begin 
                    if(is_hit == 1) begin // READ-HIT
                        case(block_offset)
                            2'b00: dout = Data_Bank[set_idx][0:31];
                            2'b01: dout = Data_Bank[set_idx][32:63];
                            2'b10: dout = Data_Bank[set_idx][64:95];
                            2'b11: dout = Data_Bank[set_idx][96:127];
                        endcase
                        //is_output_valid = 1;
                        dmem_read = 0;
                        dmem_write = 0;
                        
                        next_cache_status = `CACHE_END;
                    end
                    else begin // READ-MISS면 DMEM에서 올바른 데이터를 가져온다 
                        //next_cache_status = `READ_MISS; 
                        if(Dirty[set_idx])
                            next_cache_status = `READ_MISS_WRITE;
                        else
                            next_cache_status = `READ_MISS;
                    end
                end
                else if(mem_write) begin 
                    if(is_hit == 1) begin // WRITE_HIT
                        if(Dirty[set_idx] == 0) begin
                            Dirty[set_idx] = 1;
                            
                            WriteBack_Data = Data_Bank[set_idx];
        
                            case(block_offset)
                                2'b00: WriteBack_Data[0:31] = din;
                                2'b01: WriteBack_Data[32:63] = din;
                                2'b10: WriteBack_Data[64:95] = din;
                                2'b11: WriteBack_Data[96:127] = din;
                            endcase
                            
                            Data_Bank[set_idx] = WriteBack_Data;                  
                     
                            next_cache_status = `CACHE_END;
                        end
                        else begin
                            next_cache_status = `WRITE_HIT_CACHE_CONFLICT;
                        end
                    end
                    else begin // WRITE_MISS
                        if(Dirty[set_idx]) 
                            next_cache_status = `WRITE_MISS_ALLOCATE_WRITE;
                        else
                            next_cache_status  = `WRITE_MISS_ALLOCATE;
                    end
                end
            end
            `READ_MISS_WRITE : begin
                if(dmem_ready) begin 
                    dmem_addr = {Tag_Bank[set_idx],set_idx,4'b0000};
                    dmem_read = 0;
                    dmem_write = 1;
                    dmem_input_valid = 1;
                    dmem_din = Data_Bank[set_idx];
                    
                                
                    next_cache_status = `READ_MISS_2;
                end
            end
            `READ_MISS_2 : begin
                if(dmem_ready) begin
                        dmem_addr = {addr[31:4],4'b0000}; 
                        dmem_read = 1;
                        dmem_write =0;
                        
                        dmem_input_valid = 1;
                    end
                    
                    if(dmem_output_valid) begin
                        dmem_input_valid = 0;
                        
                        Dirty[set_idx] = 1;
                        Valid[set_idx] = 1;
                        
                        Tag_Bank[set_idx] = tag;
                        Data_Bank[set_idx] = dmem_dout;
                        
                        
                        next_cache_status = `TAG_COMPARE;
                    end
            end
            `READ_MISS : begin
                if(dmem_ready) begin
                    dmem_addr = {addr[31:4],4'b0000}; 
                    dmem_read = 1;
                    dmem_write =0;
                    
                    dmem_input_valid = 1;
                end
                
                if(dmem_output_valid) begin
                    dmem_input_valid = 0;
                    
                    Dirty[set_idx] = 0;
                    Valid[set_idx] = 1;
                    
                    Tag_Bank[set_idx] = tag;
                    Data_Bank[set_idx] = dmem_dout;
                    
                    
                    next_cache_status = `TAG_COMPARE;
                end
               
            end
            `WRITE_HIT_CACHE_CONFLICT : begin // 캐시 메모리가 새로운 Data Block으로 교체된다. 원래 있던 건 Main Memory에 업데이트 된다.  Write-Back Policy
                if(dmem_ready) begin
                    // Main memory 업데이트
                    dmem_addr = {Tag_Bank[set_idx],set_idx,4'b0000};
                    dmem_read = 0;
                    dmem_write = 1;
                    dmem_din = Data_Bank[set_idx]; // 원래 블럭을 넣음
                    dmem_input_valid = 1;
                    
                    Dirty[set_idx] = 0;

                    next_cache_status = `TAG_COMPARE;
                end
            end
            `WRITE_MISS_ALLOCATE_WRITE : begin // write miss인데 내가 들어가야 할 자리에 값이 있다.
                if(dmem_ready) begin 
                    dmem_addr = {Tag_Bank[set_idx],set_idx,4'b0000};
                    dmem_read = 0;
                    dmem_write = 1;
                    dmem_input_valid = 1;
                    dmem_din = Data_Bank[set_idx];
                    
                                
                    next_cache_status = `WRITE_MISS_ALLOCATE;
                end
            end
            `WRITE_MISS_ALLOCATE : begin // 
                dmem_addr = {addr[31:4],4'b0000};
                if(dmem_ready) begin
                    dmem_read = 1;
                    dmem_write =0;
                    dmem_input_valid = 1;
                    
                end
                if(dmem_output_valid) begin              
                    Dirty[set_idx] = 0;
                    Valid[set_idx] = 1;
                    dmem_input_valid = 0;
                    Data_Bank[set_idx] = dmem_dout;
                     
                    Tag_Bank[set_idx] = tag;
                                
                    next_cache_status = `TAG_COMPARE;
                end
            end
            endcase
  end
  
 // assign is_ready = dmem_ready;
  
  // Instantiate data memory
  DataMemory #(.BLOCK_SIZE(LINE_SIZE)) data_mem(
    .reset(reset),
    .clk(clk),
    .is_input_valid(dmem_input_valid),
    .addr(dmem_addr),        // NOTE: address must be shifted by CLOG2(LINE_SIZE)
    .mem_read(dmem_read),
    .mem_write(dmem_write),
    .din(dmem_din),
    // is output from the data memory valid?
    .is_output_valid(dmem_output_valid),
    .dout(dmem_dout),
    // is data memory ready to accept request?
    .mem_ready(dmem_ready)
  );
endmodule