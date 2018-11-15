# Project-specific settings

## Assembly settings

# Assembly program (minus .asm extension)
#PROGRAM := array_loop
PROGRAM := mips1

# Memory image(s) to create from the assembly program
TEXTMEMDUMP := $(PROGRAM).text.hex
DATAMEMDUMP := $(PROGRAM).data.hex


## Verilog settings

# Top-level module/filename (minus .v/.t.v extension)
TOPLEVEL := pipecpu

# All circuits included by the toplevel $(TOPLEVEL).t.v
CIRCUITS := $(TOPLEVEL).v counter.v
