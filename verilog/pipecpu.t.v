`include "pipecpu.v"

module pipecpu_test();
  reg clk;

  initial clk = 0;
  always #10 clk = !clk;

  pipeCPU pipecpu(.clk(clk));

  initial begin

  $readmemh("mips1.text.hex", pipecpu.datamem.memory, 0);

  $readmemh("mips1.text.hex", pipecpu.datamem.memory, 2048);

  $dumpfile("pipecpu.vcd");
  $dumpvars();

  #5000 $finish();
  end
endmodule
