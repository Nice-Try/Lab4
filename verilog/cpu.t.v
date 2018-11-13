`include "cpu.v"

// CPU testbench

module cpu_test();

  reg clk;

  initial clk = 0;
  always #10 clk = !clk;

  CPU cpu(.clk(clk));

  initial begin

  $readmemh("mem.text.hex", cpu.datamem.memory, 0);

  $readmemh("mem.data.hex", cpu.datamem.memory, 2048);

  $dumpfile("cpu.vcd");
  $dumpvars();

  #5000 $finish();
  end
endmodule
