`include "pipecpu.v"

module pipecpu_test();
  reg clk;

  initial clk = 0;
  always #10 clk = !clk;

  pipeCPU pipecpu(.clk(clk));

  initial begin

  $readmemh("fib_func.text.hex", pipecpu.datamem.memory, 0);

  $readmemh("fib_func.text.hex", pipecpu.datamem.memory, 2048);

  $dumpfile("pipecpu.vcd");
  $dumpvars();

  #50000 $finish();
  end
endmodule
