`include "opcodes.v"

module ImmediateGenerator(
    part_of_inst,  // input
    imm_gen_out   // output
);
input [31:0] part_of_inst;
output reg [31:0] imm_gen_out;


    always @(*) begin
                imm_gen_out = 0;
        case(part_of_inst[6:0])
        `ARITHMETIC_IMM : begin
            //sign_extend를 할 때, [31]을 하나하나 넣어줄 필요 없이 signed만 붙여도 된다
            imm_gen_out = $signed(part_of_inst[31:20]);
        end
        `LOAD : begin
            imm_gen_out = $signed(part_of_inst[31:20]);
        end
        `JALR : begin
            imm_gen_out = $signed(part_of_inst[31:20]);
        end
        `STORE : begin
        
            imm_gen_out[11:5] = part_of_inst[31:25];
            imm_gen_out[4:1] = part_of_inst[11:8];
            imm_gen_out[0] = part_of_inst[7];
            if(part_of_inst[31] == 1) 
                imm_gen_out[31:12] = 20'b11111111111111111111;
            else
                imm_gen_out[31:12] = 20'b00000000000000000000;           
 
        end
        `BRANCH : begin
            imm_gen_out[11] = part_of_inst[7];
            imm_gen_out[10:5] = part_of_inst[30:25];
            imm_gen_out[4:1] = part_of_inst[11:8];
             if(part_of_inst[31] == 1) 
                imm_gen_out[31:12] = 20'b11111111111111111111;
            else
                imm_gen_out[31:12] = 20'b00000000000000000000;         
        end
        `JAL : begin
            imm_gen_out[19:12] = part_of_inst[19:12];
            imm_gen_out[11] = part_of_inst[20];
            imm_gen_out[10:1] = part_of_inst[30:21];
            imm_gen_out[0] = 1'b0;
             if(part_of_inst[31] == 1) 
                imm_gen_out[31:20] = 12'b111111111111;
            else
                imm_gen_out[31:20] = 12'b000000000000;         
        end
        endcase
    end
endmodule