#! /bin/bash

rm func.text.hex
rm func.data.hex
# mars a mc CompactTextAtZero dump .text HexText array_loop.text.hex ../asmtest/array_loop/array_loop.asm
# mars a mc CompactTextAtZero dump .data HexText array_loop.data.hex ../asmtest/array_loop/array_loop.asm
mars a mc CompactTextAtZero dump .text HexText func.text.hex ../asmtest/func.asm
mars a mc CompactTextAtZero dump .text HexText func.text.hex ../asmtest/func.asm

iverilog -Wall -o pipecpu.vvp pipecpu.t.v
./pipecpu.vvp

gtkwave pipecpu.vcd pipelinepc.gtkw
