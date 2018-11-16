#! /bin/bash

rm fib_func.text.hex
mars a mc CompactTextAtZero dump .text HexText fib_func.text.hex ../asmtest/fib_func/fib_func.asm

iverilog -Wall -o pipecpu.vvp pipecpu.t.v
./pipecpu.vvp

gtkwave pipecpu.vcd pipecpu.gtkw
