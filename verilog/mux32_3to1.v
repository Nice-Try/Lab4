// 3 to 1x32 mux
module mux3to1by32
(
output [31:0] out,
input         address,
input  [31:0] input0, input1, input2
);

  wire [31:0] mux [2:0];
  assign mux[0] = input0;
  assign mux[1] = input1;
  assign mux[2] = input2;

  assign out = mux[address];
endmodule
