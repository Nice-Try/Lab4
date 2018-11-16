`include "alu.v"
// `include "pc_unit.v"
`include "pipe_pc_unit.v"
`include "pc_dff.v"
`include "adder.v"
`include "regfile.v"
`include "instruction_decoder.v"
`include "datamemory.v"
`include "mux32.v"
`include "mux5.v"
`include "mux5_3to1.v"
`include "mux32_3to1.v"
// `include "mux32.v"

`define LW    6'h23
`define SW    6'h2b
`define J     6'h2
`define JAL   6'h3
`define BEQ   6'h4
`define BNE   6'h5
`define XORI  6'he
`define ADDI  6'h8

`define ARITH 6'h0
`define JR    6'h8
`define ADD   6'h20
`define SUB   6'h22
`define SLT   6'h2a

module CPUcontrolLUT (
input       clk,
input [5:0] opcode,
            funct,
output reg  RegWr,
            ALUsrc,
            MemWr,
output reg [1:0] MemToReg,
                 RegDst,
output reg [2:0] ALUctrl
);
  localparam     Rd = 2'b0,    // for RegDst Mux
                 Rt = 2'b1,
             ALUadd = 3'b000,
             ALUxor = 3'b010,
             ALUsub = 3'b001,
             ALUslt = 3'b011,
                 Db = 0,    // for ALUsrc Mux
                Imm = 1,
             ALUout = 2'b1,    // for MemToReg Mux
              Dout = 2'b0;

  always @(*) begin
    case(opcode)
      `LW: begin
        RegDst = Rt; RegWr = 1;
        ALUctrl = ALUadd; ALUsrc = Imm;
        MemWr = 0; MemToReg = Dout;
      end
      `SW: begin
        RegDst = Rd;  RegWr = 0;
        ALUctrl = ALUadd; ALUsrc = Imm;
        MemWr = 1;   MemToReg = ALUout;
      end
      `J: begin
        RegDst = Rd;  RegWr = 0;
        ALUctrl = ALUxor; ALUsrc = Db;
        MemWr = 0;   MemToReg = ALUout;
      end
      `JAL: begin
        RegDst = Rd;  RegWr = 1;
        ALUctrl = ALUxor; ALUsrc = Db;
        MemWr = 0;   MemToReg = ALUout;
      end
      `BEQ: begin
        RegDst = Rd;  RegWr = 0;
        ALUctrl = ALUxor; ALUsrc = Db;
        MemWr = 0;   MemToReg = ALUout;
      end
      `BNE: begin
        RegDst = Rd;  RegWr = 0;
        ALUctrl = ALUxor; ALUsrc = Db;
        MemWr = 0;   MemToReg = ALUout;
      end
      `XORI: begin
        RegDst = Rt;  RegWr = 1;
        ALUctrl = ALUxor; ALUsrc = Imm;
        MemWr = 0;   MemToReg = ALUout;
      end
      `ADDI: begin
        RegDst = Rt;  RegWr = 1;
        ALUctrl = ALUadd; ALUsrc = Imm;
        MemWr = 0;   MemToReg = ALUout;
      end
      `ARITH: begin
        case(funct)
          `JR: begin
            RegDst = Rd;  RegWr = 0;
            ALUctrl = ALUxor; ALUsrc = Db;
            MemWr = 0;   MemToReg = ALUout;
          end
          `ADD: begin
            RegDst = Rd;  RegWr = 1;
            ALUctrl = ALUadd; ALUsrc = Db;
            MemWr = 0;   MemToReg = ALUout;
          end
          `SUB: begin
            RegDst = Rd;  RegWr = 1;
            ALUctrl = ALUsub; ALUsrc = Db;
            MemWr = 0;   MemToReg = ALUout;
          end
          `SLT: begin
            RegDst = Rd;  RegWr = 1;
            ALUctrl = ALUslt; ALUsrc = Db;
            MemWr = 0;   MemToReg = ALUout;
          end
        endcase
      end
    endcase
  end
endmodule

module pipeCPU
(
input clk
);
  // Initial values for control signals
  initial begin
    // RF phase
    BEQ_RF <= 0;
    BNE_RF <= 0;
    JR_RF <= 0;
    LW_RF <= 0;

    // EX phase
    BEQ_EX <= 0;
    BNE_EX <= 0;
  end

  // Instruction fetch NOP wires
  wire [31:0] instruction;
  reg  [31:0] NOP = 32'b0;
  wire        stall_mux;

  // Instruction decoder outputs
  wire[5:0] opcode,
            funct;
  wire[4:0] rs_RF,
            rt_RF,
            rd;
  wire [15:0] immediate;
  wire [25:0] address;

  // Instruction Fetch Phase
  wire [31:0] instruction_IF;
  wire [25:0] address_IF;
  wire        BEQ_IF,
              BNE_IF,
              J_IF,
              JAL_IF,
              JR_IF,
              LW_IF;

  // Register Fetch Phase
  wire       RegWr_RF,
             ALUsrc_RF,
             MemWr_RF;
  wire [1:0] RegDst_RF,
             MemToReg_RF;
  reg        BEQ_RF,
             BNE_RF,
             JR_RF,
             LW_RF;
  wire [2:0] ALUctrl_RF;
  wire [4:0] regDest_RF; //actual reg address from RegDst mux
  wire [31:0]da_RF,   // reg file output
             db_RF,   // reg file output
             imm_RF;  // Immediate sign extend
  reg  [31:0]instruction_RF;

  assign imm_RF = {{16{immediate[15]}}, immediate};

  // Execute Phase
  reg        RegWr_EX,
             ALUsrc_EX,
             MemWr_EX,
             BEQ_EX,
             BNE_EX;
  reg [1:0]  MemToReg_EX;
  reg [2:0]  ALUctrl_EX;
  wire [31:0]ALUout_EX;
  reg [4:0]  regDest_EX;
  reg [31:0] da_EX,
             db_EX,
             imm_EX;
  reg  [4:0] rs_EX,
             rt_EX;

  // Memory Phase
  reg         RegWr_MEM,
              MemWr_MEM;
  reg [1:0]   MemToReg_MEM;
  reg [31:0]  ALUout_MEM,
              db_MEM;
  wire [31:0] RegVal_MEM;
  reg [4:0]   regDest_MEM;
  wire [31:0] dataMemMuxOut,
              dataOut_MEM;

  // Write-back Phase
  reg         RegWr_WB;
  reg [4:0]   regDest_WB;
  reg [31:0]  RegVal_WB;

  // PC outputs
  wire [31:0] PC;
  wire [31:0] PC_plus_four;

  // Data forwarding wires
  wire ALUin0ctrl;
  wire ALUin1ctrl;
  wire [31:0] ALUin0;
  wire [31:0] ALUin1;

  // Reg file inputs
  reg [4:0] reg31 = 5'd31;
  wire [4:0] rdMuxOut;
  wire [31:0]regDataIn;

  // ALU src mux
  wire [31:0] ALUsrcMuxOut;

  // ALU outputs
  wire        ALUzero;

  // Reg Dest outputs
  wire [4:0] regDstMuxOut;

  always @(posedge clk) begin
    // IF -> RF DFFS
    instruction_RF <= instruction_IF;
    BEQ_RF <= BEQ_IF;
    BNE_RF <= BNE_IF;
    JR_RF <= JR_IF;
    LW_RF <= LW_IF;

    // RF -> EX DFFs
    RegWr_EX <= RegWr_RF;
    ALUsrc_EX <= ALUsrc_RF;
    MemWr_EX <= MemWr_RF;
    MemToReg_EX <= MemToReg_RF;
    ALUctrl_EX <= ALUctrl_RF;
    regDest_EX <= regDest_RF;
    da_EX <= da_RF;
    db_EX <= db_RF;
    BEQ_EX <= BEQ_RF;
    BNE_EX <= BNE_RF;
    rs_EX <= rs_RF;
    rt_EX <= rt_RF;


    // EX -> MEM DFFs
    RegWr_MEM <= RegWr_EX;
    MemWr_MEM <= MemWr_EX;
    MemToReg_MEM <= MemToReg_EX;
    db_MEM <= db_EX;
    regDest_MEM <= regDest_EX;
    ALUout_MEM <= ALUout_EX;
    imm_EX <= imm_RF;

    // MEM -> WB DFFs
    regDest_WB <= regDest_MEM;
    RegWr_WB <= RegWr_MEM;
    RegVal_WB <= RegVal_MEM;
  end

  // Necessary decoding in IF phase
  assign J_IF = ~| (instruction[31:26] ^ `J);
  assign JAL_IF = ~| (instruction[31:26] ^ `JAL);
  assign BEQ_IF = ~| (instruction[31:26] ^ `BEQ);
  assign BNE_IF = ~| (instruction[31:26] ^ `BNE);
  assign JR_IF = (~|(instruction[31:26] ^ 6'b0)) && (~|(instruction[5:0] ^ `JR));
  assign LW_IF = ~| (instruction[31:26] ^ `LW);
  assign address_IF = instruction[25:0];

  // Instruction/NOP mux logic
  // NOTE: This OR gate might also need BEQ_EX and BNE_EX, not sure
  assign stall_mux = (BEQ_RF | BNE_RF | JR_RF | LW_RF);
  mux2to1by32 mux_NOP(.out(instruction_IF),
              .address(stall_mux),
              .input0(instruction),
              .input1(NOP));


  instruction_decoder instrdecoder(.instruction(instruction_RF),
                      .opcode(opcode),
                      .rs(rs_RF),
                      .rt(rt_RF),
                      .rd(rd),
                      .funct(funct),
                      .immediate(immediate),
                      .address(address));

  CPUcontrolLUT LUT(.clk(clk),
                    .opcode(opcode),
                    .funct(funct),
                    .RegDst(RegDst_RF),
                    .RegWr(RegWr_RF),
                    .ALUctrl(ALUctrl_RF),
                    .ALUsrc(ALUsrc_RF),
                    .MemWr(MemWr_RF),
                    .MemToReg(MemToReg_RF));

  pipePCUnit pcmodule(.PC(PC),
                    .PC_plus_four(PC_plus_four),
                    .clk(clk),
                    .da_RF(da_RF),
                    .address(address_IF),
                    .imm_EX(imm_EX),
                    .stall_MUX(stall_mux),
                    .ALUZero(ALUzero),
                    .BEQ_IF(BEQ_IF),
                    .BNE_IF(BNE_IF),
                    .BEQ_EX(BEQ_EX),
                    .BNE_EX(BNE_EX),
                    .J_IF(J_IF),
                    .JAL_IF(JAL_IF),
                    .JR_IF(JR_IF),
                    .JR_RF(JR_RF),
                    .LW_IF(LW_IF));

  // Reg file inputs
  // Aw input
  mux3to1by5 rdMux(.out(regDest_RF), // actual register address
                  .address(RegDst_RF), // ctrl signal
                  .input0(rd),
                  .input1(rt_RF),
                  .input2(reg31));

  mux3to1by32 regdataMux(.out(RegVal_MEM),
                        .address(MemToReg_MEM),
                        .input0(dataOut_MEM),
                        .input1(ALUout_MEM),
                        .input2(PC_plus_four));

  regfile regFile(.ReadData1(da_RF),
                  .ReadData2(db_RF),
                  .WriteData(RegVal_WB),
                  .ReadRegister1(rs_RF),
                  .ReadRegister2(rt_RF),
                  .WriteRegister(regDest_WB),
                  .RegWrite(RegWr_WB),
                  .Clk(clk));

  // Data forwarding logic
  assign ALUin0ctrl = RegWr_MEM && (~| (regDest_MEM ^ rs_EX));
  assign ALUin1ctrl = (RegWr_MEM && (~|(regDest_MEM ^ rt_EX)) && (BEQ_EX | BNE_EX | Rtype_EX));

  // ALU input
  mux2to1by32 ALUsrcMux(.out(ALUsrcMuxOut),
                  .address(ALUsrc_EX),
                  .input0(db_EX),
                  .input1(imm_EX));

  ALU alu(.result(ALUout_EX),
                  .carryout(),
                  .zero(ALUzero),
                  .overflow(),
                  .operandA(da_EX),
                  .operandB(ALUsrcMuxOut),
                  .command(ALUctrl_EX));


  datamemory datamem(.clk(clk),
                    .instrOut(instruction),
                    .dataOut(dataOut_MEM),
                    .instrAddr(PC),
                    .address(ALUout_MEM),
                    .writeEnable(MemWr_MEM),
                    .dataIn(db_MEM));

endmodule
