#! /bin/bash

rm mips1.text.hex
mars a mc CompactTextAtZero dump .text HexText mips1.text.hex ../asmtest/mips1.asm

iverilog -Wall -o pipecpu.vvp pipecpu.t.v
./pipecpu.vvp

gtkwave pipecpu.vcd pipecpu.gtkw
