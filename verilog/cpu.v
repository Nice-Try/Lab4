`include "alu.v"
`include "pc_unit.v"
`include "regfile.v"
`include "instruction_decoder.v"
`include "datamemory.v"
`include "mux5.v"
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
output reg  ctrlJ,
            ctrlJR,
            ctrlJAL,
            ctrlBEQ,
            ctrlBNE,
            RegDst,
            RegWr,
            ALUsrc,
            MemWr,
            MemToReg,
output reg [2:0] ALUctrl
);
  localparam     Rd = 0,
                 Rt = 1,
             ALUadd = 3'b000,
             ALUxor = 3'b010,
             ALUsub = 3'b001,
             ALUslt = 3'b011,
                 Db = 0,
                Imm = 1,
             ALUout = 0,
              Dout  = 1;

  always @(*) begin
    case(opcode)
      `LW: begin
        ctrlJ = 0;   ctrlJR = 0;  ctrlJAL = 0;
        ctrlBEQ = 0; ctrlBNE = 0;
        RegDst = Rt;  RegWr = 1;
        ALUctrl = ALUadd; ALUsrc = Imm;
        MemWr = 0;   MemToReg = Dout;
      end
      `SW: begin
        ctrlJ = 0;   ctrlJR = 0;  ctrlJAL = 0;
        ctrlBEQ = 0; ctrlBNE = 0;
        RegDst = Rd;  RegWr = 0;
        ALUctrl = ALUadd; ALUsrc = Imm;
        MemWr = 1;   MemToReg = ALUout;
      end
      `J: begin
        ctrlJ = 1;   ctrlJR = 0;  ctrlJAL = 0;
        ctrlBEQ = 0; ctrlBNE = 0;
        RegDst = Rd;  RegWr = 0;
        ALUctrl = ALUxor; ALUsrc = Db;
        MemWr = 0;   MemToReg = ALUout;
      end
      `JAL: begin
        ctrlJ = 1;   ctrlJR = 0;  ctrlJAL = 1;
        ctrlBEQ = 0; ctrlBNE = 0;
        RegDst = Rd;  RegWr = 1;
        ALUctrl = ALUxor; ALUsrc = Db;
        MemWr = 0;   MemToReg = ALUout;
      end
      `BEQ: begin
        ctrlJ = 0;   ctrlJR = 0;  ctrlJAL = 0;
        ctrlBEQ = 1; ctrlBNE = 0;
        RegDst = Rd;  RegWr = 0;
        ALUctrl = ALUxor; ALUsrc = Db;
        MemWr = 0;   MemToReg = ALUout;
      end
      `BNE: begin
        ctrlJ = 0;   ctrlJR = 0;  ctrlJAL = 0;
        ctrlBEQ = 0; ctrlBNE = 1;
        RegDst = Rd;  RegWr = 0;
        ALUctrl = ALUxor; ALUsrc = Db;
        MemWr = 0;   MemToReg = ALUout;
      end
      `XORI: begin
        ctrlJ = 0;   ctrlJR = 0;  ctrlJAL = 0;
        ctrlBEQ = 0; ctrlBNE = 0;
        RegDst = Rt;  RegWr = 1;
        ALUctrl = ALUxor; ALUsrc = Imm;
        MemWr = 0;   MemToReg = ALUout;
      end
      `ADDI: begin
        ctrlJ = 0;   ctrlJR = 0;  ctrlJAL = 0;
        ctrlBEQ = 0; ctrlBNE = 0;
        RegDst = Rt;  RegWr = 1;
        ALUctrl = ALUadd; ALUsrc = Imm;
        MemWr = 0;   MemToReg = ALUout;
      end
      `ARITH: begin
        case(funct)
          `JR: begin
            ctrlJ = 1;   ctrlJR = 1;  ctrlJAL = 0;
            ctrlBEQ = 0; ctrlBNE = 0;
            RegDst = Rd;  RegWr = 0;
            ALUctrl = ALUxor; ALUsrc = Db;
            MemWr = 0;   MemToReg = ALUout;
          end
          `ADD: begin
            ctrlJ = 0;   ctrlJR = 0;  ctrlJAL = 0;
            ctrlBEQ = 0; ctrlBNE = 0;
            RegDst = Rd;  RegWr = 1;
            ALUctrl = ALUadd; ALUsrc = Db;
            MemWr = 0;   MemToReg = ALUout;
          end
          `SUB: begin
            ctrlJ = 0;   ctrlJR = 0;  ctrlJAL = 0;
            ctrlBEQ = 0; ctrlBNE = 0;
            RegDst = Rd;  RegWr = 1;
            ALUctrl = ALUsub; ALUsrc = Db;
            MemWr = 0;   MemToReg = ALUout;
          end
          `SLT: begin
            ctrlJ = 0;   ctrlJR = 0;  ctrlJAL = 0;
            ctrlBEQ = 0; ctrlBNE = 0;
            RegDst = Rd;  RegWr = 1;
            ALUctrl = ALUslt; ALUsrc = Db;
            MemWr = 0;   MemToReg = ALUout;
          end
        endcase
      end
    endcase
  end
endmodule

module CPU
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
  wire [31:0] instruction;

  // LUT outputs
  wire  ctrlJ,
        ctrlJR,
        ctrlJAL,
        ctrlBEQ,
        ctrlBNE,
        RegDst,
        RegWr,
        ALUsrc,
        MemWr,
        MemToReg;
  wire [2:0] ALUctrl;

  // PC outputs
  wire [31:0] PC;
  wire [31:0] PC_plus_four;

  // Reg file inputs and outputs
  reg [4:0] reg31 = 5'd31;
  wire [4:0] rdMuxOut;
  wire [31:0] regDataIn;
  wire [31:0] da,
              db;

  // ALU src mux
  wire [31:0] ALUsrcMuxOut;

  // ALU outputs
  wire [31:0] ALUout;
  wire        ALUzero;

  // Reg Dest outputs
  wire [4:0] regDstMuxOut;

  instruction_decoder instrdecoder(.instruction(instruction),
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
                    .ctrlJ(ctrlJ),
                    .ctrlJR(ctrlJR),
                    .ctrlJAL(ctrlJAL),
                    .ctrlBEQ(ctrlBEQ),
                    .ctrlBNE(ctrlBNE),
                    .RegDst(RegDst),
                    .RegWr(RegWr),
                    .ALUctrl(ALUctrl),
                    .ALUsrc(ALUsrc),
                    .MemWr(MemWr),
                    .MemToReg(MemToReg));

  pcUnit pcmodule(.PC(PC),
                  .PC_plus_four(PC_plus_four),
                  .clk(clk),
                  .branchAddr(immediate),
                  .jumpAddr(address),
                  .regDa(da),
                  .ALUzero(ALUzero),
                  .ctrlBEQ(ctrlBEQ),
                  .ctrlBNE(ctrlBNE),
                  .ctrlJ(ctrlJ),
                  .ctrlJR(ctrlJR)
                  );

  // Reg file inputs
  // Aw input
  mux2to1by5 rdMux(.out(rdMuxOut),
                  .address(ctrlJAL),
                  .input0(rd),
                  .input1(reg31));

  mux2to1by5 regDstMux(.out(regDstMuxOut),
                  .address(RegDst),
                  .input0(rdMuxOut),
                  .input1(rt));

  regfile regFile(.ReadData1(da),
                  .ReadData2(db),
                  .WriteData(regDataIn),
                  .ReadRegister1(rs),
                  .ReadRegister2(rt),
                  .WriteRegister(regDstMuxOut),
                  .RegWrite(RegWr),
                  .Clk(clk));

  // ALU input
  // Immediate sign extend
  wire [31:0] imm;
  assign imm = {{16{immediate[15]}}, immediate};

  mux2to1by32 ALUsrcMux(.out(ALUsrcMuxOut),
                  .address(ALUsrc),
                  .input0(db),
                  .input1(imm));

  ALU alu(.result(ALUout),
                  .carryout(),
                  .zero(ALUzero),
                  .overflow(),
                  .operandA(da),
                  .operandB(ALUsrcMuxOut),
                  .command(ALUctrl));

  // data memory to register
  wire [31:0]  dataOut;
  wire [31:0] dataMemMuxOut;

  datamemory datamem(.clk(clk),
                    .instrOut(instruction),
                    .dataOut(dataOut),
                    .instrAddr(PC),
                    .address(ALUout),
                    .writeEnable(MemWr),
                    .dataIn(db));

  mux2to1by32 dataMemMux(.out(dataMemMuxOut),
                        .address(MemToReg),
                        .input0(ALUout),
                        .input1(dataOut));

  mux2to1by32 regDwMux(.out(regDataIn),
                      .address(ctrlJAL),
                      .input0(dataMemMuxOut),
                      .input1(PC_plus_four));
endmodule
