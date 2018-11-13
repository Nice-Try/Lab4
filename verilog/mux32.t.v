`include "mux.v"

module test2to1mux();

wire [31:0] out;
reg address;
reg [31:0] input0, input1;

reg dutpassed = 1;

mux2to1by32 dut(out, address, input0, input1);

initial begin
  $display("Testing 2 to 1 by 32 mux.");

  input0 = 11111011000010001110001001001000;
  input1 = 10010100110001101000000110000111;

  address=0; #20
  if (out !== input0) begin
    $display("Test address 0 failed");
    $display("Expected: %b", input0);
    $display("Actual:   %b", out);
    dutpassed = 0;
  end
  // Test address 1
  address=1; #20
  if (out !== input1) begin
    $display("Test address 1 failed");
    $display("Expected: %b", input1);
    $display("Actual:   %b", out);
    dutpassed = 0;
  end


  input0 = 1011001000100101010111111110010;

  input1 = 10110011111101100111110100111111;
  // Test address 0
  address=0; #20
  if (out !== input0) begin
    $display("Test address 0 failed");
    $display("Expected: %b", input0);
    $display("Actual:   %b", out);
    dutpassed = 0;
  end
  // Test address 1
  address=1; #20
  if (out !== input1) begin
    $display("Test address 1 failed");
    $display("Expected: %b", input1);
    $display("Actual:   %b", out);
    dutpassed = 0;
  end
  if (dutpassed) begin
    $display("Tests passed");
  end else begin
    $display("Tests complete");
  end

end
endmodule
