module full32BitSLT
(
  output [31:0]less,
  output carryout,
  output overflow,
  input signed [31:0] sum,
  input overflowin
  );
  genvar i;
  generate
    for (i=1; i<32; i=i+1)
    begin:genblock
      assign less[i] = 0;
    end
  endgenerate
  wire overflow, carryout;
  xor xorgate(less[0], overflowin, sum[31]); //output is just sign of sum[31]
  assign carryout = 0;
  assign overflow = 0;

endmodule
