`include "pipecpu.v"

module pipecpu_test();
  reg clk;

  initial clk = 0;
  always #10 clk = !clk;

  pipeCPU pipecpu(.clk(clk));

  initial begin

  $readmemh("func.text.hex", pipecpu.datamem.memory, 0);

  $readmemh("func.data.hex", pipecpu.datamem.memory, 2048);

  $dumpfile("pipecpu.vcd");
  $dumpvars();
  $dumpvars(pipecpu.datamem.memory[2048]);

  #50000 $finish();
  end
endmodule
