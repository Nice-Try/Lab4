#! /bin/bash

rm array_loop_nops.text.hex
rm array_loop_nops.data.hex
mars a mc CompactTextAtZero dump .text HexText array_loop_nops.text.hex ../asmtest/array_loop/array_loop_nops.asm
mars a mc CompactTextAtZero dump .data HexText array_loop_nops.data.hex ../asmtest/array_loop/array_loop_nops.asm
# mars a mc CompactTextAtZero dump .text HexText func.text.hex ../asmtest/func.asm
# mars a mc CompactTextAtZero dump .text HexText func.text.hex ../asmtest/func.asm

iverilog -Wall -o pipecpu.vvp pipecpu.t.v
./pipecpu.vvp

gtkwave pipecpu.vcd pipelinepc.gtkw
