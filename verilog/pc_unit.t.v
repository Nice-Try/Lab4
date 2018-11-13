`include "pc_unit.v"
module testpcUnit();

wire [31:0] PC;
reg         clk;
reg [15:0]  branchAddr;
reg [25:0]  jumpAddr;
reg [31:0]  regDa;
reg         ALUzero;
reg         ctrlBEQ;
reg         ctrlBNE;
reg         ctrlJ;
reg         ctrlJR;

pcUnit dut(.PC(PC),
            .clk(clk),
            .branchAddr(branchAddr),
            .jumpAddr(jumpAddr),
            .regDa(regDa),
            .ALUzero(ALUzero),
            .ctrlBEQ(ctrlBEQ),
            .ctrlBNE(ctrlBNE),
            .ctrlJ(ctrlJ),
            .ctrlJR(ctrlJR));

reg dutpassed = 1;

initial clk=0;
always #10 clk=!clk;

initial begin

  $display("Testing PC Unit.");
  branchAddr = 16'd32;
  jumpAddr = 26'd20;
  regDa = 32'd16;

  $display("Testing Jump.");
  $display("Old PC: %b", PC);
  ctrlJ = 1;
  $display("New PC: $b", PC);


  end
endmodule
