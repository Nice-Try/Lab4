`include "pc_dff.v"
// `include "adder.v"

`include "mux32.v"

// PC unit
module pcUnit
(
output [31:0] PC,           // current output of PC, goes to instruction memory
              PC_plus_four, // current output of PC, for case of JAL
input         clk,          // System clock
input [15:0]  branchAddr,   // Branch address from instr decoder
input [25:0]  jumpAddr,     // Jump address from instr decoder
input [31:0]  regDa,        // Output of regfile Da for jump register
input         ALUzero,      // Output of ALU zero flag when ALU is SUB (or XOR)
input         ctrlBEQ,      // HIGH when BEQ instr
              ctrlBNE,      // HIGH when BNE instr
              ctrlJ,        // HIGH when J type instr
              ctrlJR        // HIGH when JR instr
);
  wire [31:0] pc_out;
  wire [31:0] pc_plus_four;

  wire [31:0] branchAddr32;
  wire        branchCtrl;
  wire [31:0] pc_plus_four_plus_branch;
  wire [31:0] mux_branch_out;

  wire [31:0] jumpAddr32;
  wire [31:0] mux_jr_out;
  wire [31:0] mux_jump_out;

  wire and0out;
  wire nALUzero;
  wire and1out;

  // PC
  pc_dff #(32) pc(.trigger(clk),
                  .d(mux_jump_out),
                  .q(pc_out));

  // PC + 4
  full32BitAdder add4(.sum(pc_plus_four),
                  .carryout(),
                  .overflow(),
                  .a(pc_out),
                  .b(32'b100),
                  .subtract(1'b0));

  // Branch address
  assign branchAddr32 = {{14{branchAddr[15]}}, branchAddr, 2'b0};

  // Branch control
  and and0(and0out, ctrlBEQ, ALUzero);       // If BEQ and ALUZero
  not inv(nALUzero, ALUzero);
  and and1(and1out, ctrlBNE, nALUzero);      // Or if BNE and not ALUZero
  or orgate(branchCtrl, and0out, and1out);   // Then take branch address in mux

  // PC + 4 + Branch address
  full32BitAdder addBranch(.sum(pc_plus_four_plus_branch),
                  .carryout(),
                  .overflow(),
                  .a(pc_plus_four),
                  .b(branchAddr32),
                  .subtract(1'b0));

  // Mux PC + 4 with branch address
  mux2to1by32 mux_branch(.out(mux_branch_out),
                  .address(branchCtrl),
                  .input0(pc_plus_four),
                  .input1(pc_plus_four_plus_branch));

  // Jump address
  assign jumpAddr32 = {pc_plus_four[31:28], jumpAddr, 2'b0};

  // Mux jump address with jump register address
  mux2to1by32 mux_jr(.out(mux_jr_out),
                  .address(ctrlJR),
                  .input0(jumpAddr32),
                  .input1(regDa));

  // Mux PC+4/branch with jump address
  mux2to1by32 mux_jump(.out(mux_jump_out),
                  .address(ctrlJ),
                  .input0(mux_branch_out),
                  .input1(mux_jr_out));

  assign PC = pc_out;
  assign PC_plus_four = pc_plus_four;
endmodule
