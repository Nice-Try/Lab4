// 3 to 1x5 mux
module mux3to1by5
(
output [4:0] out,
input  [1:0]      address,
input  [4:0] input0, input1, input2
);

  wire [4:0] mux [2:0];
  assign mux[0] = input0;
  assign mux[1] = input1;
  assign mux[2] = input2;

  assign out = mux[address];
endmodule
