`include "pipecpu.v"

module pipecpu_test();
  reg clk;

  initial clk = 0;
  always #10 clk = !clk;

  pipeCPU pipecpu(.clk(clk));

  initial begin

  $readmemh("array_loop_nops.text.hex", pipecpu.datamem.memory, 0);

  $readmemh("array_loop_nops.data.hex", pipecpu.datamem.memory, 2048);

  $dumpfile("pipecpu.vcd");
  $dumpvars();
  $dumpvars(pipecpu.datamem.memory[2048]);

  #50000 $finish();
  end
endmodule
