// `include "pc_dff.v"
// `include "adder.v"
// `include "mux32.v"

// PC unit
module pipePCUnit
(
output [31:0] PC,                 // current output of PC
              PC_plus_four,       // current output of PC + 4
input         clk,                // System clock
input  [31:0] da_RF,              // Reg output a from RF phase (for JR ctrl)
input  [25:0] address,            // Jump address from instruction
input  [31:0] imm_EX,             // Immediate from EX phase
input         stall_MUX,          // Whether the NOP mux is stalled
              ALUZero,            // Zero output of ALU (from EX phase)
              BEQ_IF,             // whether it is BEQ from the IF phase
              BNE_IF,             // whether it is BNE from the IF phase
              BEQ_EX,             // whether it is BEQ from the EX phase
              BNE_EX,             // whether it is BNE from the EX phase
              J_IF,               // whether it is J from the IF phase
              JAL_IF,             // whether it is JAL from the IF phase
              JR_IF,              // whether it is JR from the IF phase
              JR_RF,              // whether it is JR from the RF phase
              LW_IF               // whether it is LW from the IF phase
);
  // Branch control wires
  wire [31:0] branchAddr,
              pc_plus_four_plus_branch,
              muxBranchOut;
  wire        BEQctrl,
              BNEctrl,
              nALUZero,
              branchctrl;

  // Jump control wires
  wire [31:0] jumpAddr,
              muxJROut,
              muxJumpOut;
  wire        jumpctrl;

  // PC
  pc_dff #(32) pc(.trigger(clk),
              .d(muxJumpOut),
              .q(PC));

  // PC + 4
  full32BitAdder add4(.sum(PC_plus_four),
              .carryout(),
              .overflow(),
              .a(PC),
              .b(32'b100),
              .subtract(1'b0));

  // Branch address
  assign branchAddr = imm_EX << 10;

  // Branch control
  and and0(BEQctrl, BEQ_EX, ALUZero);       // If BEQ and ALUZero
  not inv(nALUZero, ALUZero);
  and and1(BNEctrl, BNE_EX, nALUZero);      // Or if BNE and not ALUZero
  or orgate(branchctrl, BEQctrl, BNEctrl);  // Then take branch address in mux

  // PC + 4 + branch address
  full32BitAdder addBranch(.sum(pc_plus_four_plus_branch),
              .carryout(),
              .overflow(),
              .a(PC_plus_four),
              .b(branchAddr),
              .subtract(1'b0));


  // Mux PC + 4 with branch address
  mux2to1by32 mux_branch(.out(muxBranchOut),
              .address(branchctrl),
              .input0(PC_plus_four),
              .input1(pc_plus_four_plus_branch));

  // Jump address
  assign jumpAddr = {PC_plus_four[31:28], address, 2'b0};

  // Mux jump address with jump register address
  mux2to1by32 mux_jr(.out(muxJROut),
              .address(JR_RF),
              .input0(jumpAddr),
              .input1(da_RF));

  // Jump control
  assign jumpctrl = (JR_RF | J_IF | JAL_IF);

  // Mux PC+4/branch with jump address
  mux2to1by32 mux_jump(.out(muxJumpOut),
              .address(jumpctrl),
              .input0(muxBranchOut),
              .input1(muxJROut));

endmodule
