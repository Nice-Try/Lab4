//------------------------------------------------------------------------
// Data Memory
//   Positive edge triggered
//   dataOut always has the value mem[address]
//   If writeEnable is true, writes dataIn to mem[address]
//------------------------------------------------------------------------

module datamemory
#(
    parameter addresswidth  = 32,
    parameter indexwidth    = 12,
    parameter depth         = 2**indexwidth,
    parameter width         = 32
)
(
    input 		                  clk,
    output  [width-1:0]      instrOut,
    output  [width-1:0]      dataOut,
    input [addresswidth-1:0]    instrAddr,
    input [addresswidth-1:0]    address,
    input                       writeEnable,
    input [width-1:0]           dataIn
);

  // translate from MIPS byte address (32bits) to
  // verilog word array index
  wire [indexwidth-1:0] index, instrindex;
  assign index = address[indexwidth+1:2];
  assign instrindex = instrAddr[indexwidth+1:2];

    reg [width-1:0] memory [depth-1:0];
    assign dataOut = memory[index];
    assign instrOut = memory[instrindex];

    always @(posedge clk) begin
        if(writeEnable)
            memory[index] <= dataIn;
    end

endmodule
