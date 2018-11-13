// 2 to 1x5 mux
module mux2to1by5
(
output [4:0] out,
input         address,
input  [4:0] input0, input1
);

  wire [4:0] mux [1:0];
  assign mux[0] = input0;
  assign mux[1] = input1;

  assign out = mux[address];
endmodule
