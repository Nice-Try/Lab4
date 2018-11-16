#! /bin/bash

rm array_loop.text.hex
mars a mc CompactTextAtZero dump .text HexText array_loop.text.hex ../asmtest/array_loop/array_loop.asm
mars a mc CompactTextAtZero dump .data HexText array_loop.data.hex ../asmtest/array_loop/array_loop.asm
# mars a mc CompactTextAtZero dump .text HexText mem.text.hex ../asmtest/mem.asm

iverilog -Wall -o pipecpu.vvp pipecpu.t.v
./pipecpu.vvp

gtkwave pipecpu.vcd pipelinepc.gtkw
