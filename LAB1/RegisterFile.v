module RegisterFile(input   reset,
                    input clk,
                    input [4:0] rs1,          // source register 1
                    input [4:0] rs2,          // source register 2
                    input [4:0] rd,           // destination register
                    input [31:0] rd_din,      // input data for rd
                    input write_enable,          // RegWrite signal
                    output [31:0] rs1_dout,   // output of rs 1
                    output [31:0] rs2_dout,  // output of rs 2
                    output [31:0] rf17 //rf17 to exit
                    ); 
  integer i;
  // Register file
  reg [31:0] rf[0:31];

  // TODO
  // Asynchronously read register file
    assign rs1_dout = rf[rs1];
    assign rs2_dout = rf[rs2];
    assign rf17 = rf[17];

  // Synchronously write data to the register file
    always @(posedge clk) begin
        rf[0] <= 1'b0;
        if(write_enable == 1) begin
            rf[rd] <= rd_din;
        end
    end

  // Initialize register file (do not touch)
  always @(posedge clk) begin
    // Reset register file
    if (reset) begin
      for (i = 0; i < 32; i = i + 1)
        rf[i] = 32'b0;
      rf[2] = 32'h2ffc; // stack pointer
    end
  end
endmodule