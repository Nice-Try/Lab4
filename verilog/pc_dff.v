// D flip-flop with parameterized bit width (default: 1-bit)
// Parameters in Verilog: http://www.asic-world.com/verilog/para_modules1.html
module pc_dff #( parameter W = 1 )
(
    input trigger,
    input      [W-1:0] d,
    output reg [W-1:0] q
);
  initial begin
    q <= 0;
  end
  always @(posedge trigger) begin
        q <= d;
  end
endmodule
