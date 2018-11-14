`include "alu.v"
`include "pc_unit.v"
`include "regfile.v"
`include "instruction_decoder.v"
`include "datamemory.v"
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
output reg  RegDst,
            RegWr,
            ALUsrc,
            MemWr,
            MemToReg,
output reg [2:0] ALUctrl
);
  localparam     Rd = 0,    // for RegDst Mux
                 Rt = 1,
             ALUadd = 3'b000,
             ALUxor = 3'b010,
             ALUsub = 3'b001,
             ALUslt = 3'b011,
                 Db = 0,    // for ALUsrc Mux
                Imm = 1,
             ALUout = 0,    // for MemToReg Mux
              Dout  = 1;

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
      // `J: begin
      //   RegDst = Rd;  RegWr = 0;
      //   ALUctrl = ALUxor; ALUsrc = Db;
      //   MemWr = 0;   MemToReg = ALUout;
      // end
      // `JAL: begin
      //   RegDst = Rd;  RegWr = 1;
      //   ALUctrl = ALUxor; ALUsrc = Db;
      //   MemWr = 0;   MemToReg = ALUout;
      // end
      // `BEQ: begin
      //   RegDst = Rd;  RegWr = 0;
      //   ALUctrl = ALUxor; ALUsrc = Db;
      //   MemWr = 0;   MemToReg = ALUout;
      // end
      // `BNE: begin
      //   RegDst = Rd;  RegWr = 0;
      //   ALUctrl = ALUxor; ALUsrc = Db;
      //   MemWr = 0;   MemToReg = ALUout;
      // end
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

  // Instruction decoder outputs
  wire[5:0] opcode,
            funct;
  wire[4:0] rs,
            rt,
            rd;
  wire [15:0] immediate;
  wire [25:0] address;

  //Instruction decoder input
  wire [31:0] instruction_IF;

  // LUT outputs
  wire       RegDst_RF; // ctrl signal for RegDst mux
  wire       RegWr_EX,
             ALUsrc_EX,
             MemWr_EX,
             MemToReg_EX;
  wire [2:0] ALUctrl_EX;
  wire [4:0] regDest_EX; //actual reg address
  wire [31:0] imm_EX;

  reg         RegWr_MEM,
              MemWr_MEM,
              MemToReg_MEM;
  reg [31:0]  db_MEM;
  wire [31:0] RegVal_MEM,
              ALUout_MEM;
  reg [4:0]   regDest_MEM;

  reg         RegWr_WB;
  reg [4:0]   regDest_WB;
  wire [31:0]  RegVal_WB;


  // PC outputs
  wire [31:0] PC;
  wire [31:0] PC_plus_four;

  // Reg file inputs and outputs
  reg [4:0] reg31 = 5'd31;
  wire [4:0] rdMuxOut;
  wire [31:0] regDataIn;
  wire [31:0] da_EX,
              db_EX;

  // ALU src mux
  wire [31:0] ALUsrcMuxOut;

  // ALU outputs
  wire        ALUzero;

  // Reg Dest outputs
  wire [4:0] regDstMuxOut;

  always @(posedge clk) begin
    // RF -> EX DFFs

    // EX -> MEM DFFs
    RegWr_MEM <= RegWr_EX;
    MemWr_MEM <= MemWr_EX;
    MemToReg_MEM <= MemToReg_EX;
    db_MEM <= db_EX;
    regDest_MEM <= regDest_EX;

    // MEM -> WB DFFs
    regDest_WB <= regDest_MEM;
    RegWr_WB <= RegWr_MEM;

  end

  instruction_decoder instrdecoder(.instruction(instruction_IF),
                      .opcode(opcode),
                      .rs(rs),
                      .rt(rt),
                      .rd(rd),
                      .funct(funct),
                      .immediate(immediate),
                      .address(address));

  CPUcontrolLUT LUT(.clk(clk),
                    .opcode(opcode),
                    .funct(funct),
                    .RegDst(RegDst_RF),
                    .RegWr(RegWr_EX),
                    .ALUctrl(ALUctrl_EX),
                    .ALUsrc(ALUsrc_EX),
                    .MemWr(MemWr_EX),
                    .MemToReg(MemToReg_EX));

  pcUnit pcmodule(.PC(PC),
                  .PC_plus_four(PC_plus_four),
                  .clk(clk),
                  .branchAddr(immediate),
                  .jumpAddr(address),
                  .regDa(da_EX),
                  .ALUzero(ALUzero),
                  .ctrlBEQ(ctrlBEQ),
                  .ctrlBNE(ctrlBNE),
                  .ctrlJ(ctrlJ),
                  .ctrlJR(ctrlJR)
                  );

  // Reg file inputs
  // Aw input
  mux3to1by5 rdMux(.out(regDest_EX), // actual register address
                  .address(RegDst_RF), // ctrl signal
                  .input0(rd),
                  .input1(rt),
                  .input2(reg31));

  regfile regFile(.ReadData1(da_EX),
                  .ReadData2(db_EX),
                  .WriteData(RegVal_WB),
                  .ReadRegister1(rs),
                  .ReadRegister2(rt),
                  .WriteRegister(regDest_WB),
                  .RegWrite(RegWr_WB),
                  .Clk(clk));

  // ALU input
  // Immediate sign extend
  assign imm_EX = {{16{immediate[15]}}, immediate};

  mux2to1by32 ALUsrcMux(.out(ALUsrcMuxOut),
                  .address(ALUsrc_EX),
                  .input0(db_EX),
                  .input1(imm_EX));

  ALU alu(.result(ALUout_MEM),
                  .carryout(),
                  .zero(ALUzero),
                  .overflow(),
                  .operandA(da_EX),
                  .operandB(ALUsrcMuxOut),
                  .command(ALUctrl_EX));

  // data memory to register
  wire [31:0] dataOut_MEM;
  wire [31:0] dataMemMuxOut;

  datamemory datamem(.clk(clk),
                    .instrOut(instruction_IF),
                    .dataOut(dataOut_MEM),
                    .instrAddr(PC),
                    .address(ALUout_MEM),
                    .writeEnable(MemWr_MEM),
                    .dataIn(db_MEM));


  mux3to1by32 regDwMux(.out(RegVal_WB),
                      .address(MemtoReg_MEM),
                      .input0(dataOut_MEM),
                      .input1(ALUout_MEM),
                      .input2(PC_plus_four));
endmodule
