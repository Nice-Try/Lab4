# Nice Try Lab 4 Report
Louise Nielsen and Camille Xue

## Architecture

Our architecture closely follows the general idea of the pipeline CPUs from the class slides. Our full diagram is below.

The red lines between phases represent our D flip flops that make this a pipeline CPU. For clarity, we don't show signals being propagated the entire way through - we show them going into the next D flip flop line, then refer to them (with the appropriate phase name, indicating how far they were propagated) when we use them again.

![Diagram](https://image.ibb.co/jRkQ0L/full-pipeline.png)

### Instruction fetch phase

Here we access instruction memory (really a subset of data memory) based on the current PC address and mux it with a `nop` instruction (all zeros). The rationale behind the control signal there is explained in the Hazard Mitigation section. Not pictured in the diagram is some decoding of `instruction` (after the mux with `nop`) in order to handle control flow and control flow hazards.

<img src="https://image.ibb.co/iomnEf/IF-phase.png" width="400"/>

The really interesting part of the IF phase is the PC unit. This PC unit looks a lot like our single cycle CPU's PC unit with two exceptions: several of the inputs from the single cycle CPU's LUT are from specific phases in our pipeline CPU, and the PC D flip flop itself has an enable. The inputs to the enable are explained more in the Hazard Mitigation section. The inputs from specific phases are part of the managing of control flow - for example, we don't know if we should branch or not for a `BEQ` or `BNE` instruction until that instruction has made it to the EX phase, so we use the `BEQ_EX` and `BNE_EX` flags to determine whether to take a branch or not.

<img src="https://lh3.googleusercontent.com/YewM2YJxL0fSWr5Q2XFWkbCBQlx16Jn9adxPrOrXbMLCRytKiGY2-rqNgyNCJU9qAdb5xDWlAEfhWTKiqPRsvgXFrQzCn6_1YWSBC9NZk_4R4r2IVk8dgNE1fFdOgsqAoSHe8hIDAtm4aOQUCBgmcjDcex9dEfSVqXWVy4uPbz44vZzOQwqXI0ThlWChU1DgEJj7zWW1V53gZUMoR82wxyikj61PwKu6gjp0n9OJDHQfkFLGEC8U7INiY3cpmgLQuYI0w7aAHZUWTOTFaUZRW6My48UCG3BjO-YY6ion0PX4YJE5aPk5ovtXLcmJmTIbkmfK3OIawUdMm7scphakXNUtGLPPu0U5ywjXwCGLojHJaxGCZAFDprpvQWDkYnYHZ3rG0gdgwdR1IpWeQyLBuMGLBbHyGZi7EDYD45dwfQKtC4WzibBI7Bpmw4FfOOfE4qbuQFj9PxHA-Rqfk1_gyyfCMQj_F0sChurGlu6T3SwAvjvTM-v24ODcW3RUPWDX8CX6XmSQkboqN_JwLTtTjiapRh9sNKCtFsEpZ7oekdz-5zQKHaqqvX6IzlAIq64SSF4e0g5Qs_zE8BJRRJdJ2iObT_bklMDCQOX3IJtD2mmgCbrq7Zb3yG23t7w8EU9va9DVK5oLAbk3HPcL7aLOuRYSiA=w953-h714-no" width="700"/>

### Register fetch phase

In this phase, we decode the instruction, create a lot of control signals with a LUT, read from the register file, and determine to what address we will be writing to the register file in three phases. Muxing between the possible register addresses here would be slightly more efficient than later because we are only passing along one 5-bit address instead of three 5-bit addresses and 2 bits of control signal through the rest of the pipeline.

Our LUT is a subset of our LUT last phase, except that we implemented a `nop` instruction. We used all 0s, which looks like an `opcode` and `funct` of all 0s. For a full MIPS CPU, that is the command for shift left logical. However, that instruction means to logically (fill with 0s) shift left what's in the zero register by 0 bits and write it to the zero register, none of which do anything.

<img src="https://image.ibb.co/iHAfZf/RF-phase.png" width="400"/>

### Execute phase

The EX phase looks a lot like part of our single cycle CPU, except with a lot of muxes. These muxes are for data forwarding, how we handled a lot of our data hazards. More information is available in the Hazard Mitigation section.

<img src="https://image.ibb.co/e753n0/EX-phase.png" width="400"/>

### Memory phase

In this phase, we write to and read to memory, as well as decide which of three possible inputs goes into the register file. Having the mux in this phase (instead of the next phase) is useful both for space efficiency - only one 32-bit to pass along, instead of three and a 2-bit control signal - and for hazard mitigation (we get to forward from `lw` instructions this way).

<img src="https://image.ibb.co/dhH50L/MEM-phase.png" width="400"/>

### Write back phase
In this phase, we write back to the register file. It's probably the least interesting phase because we made all the relevant decisions in earlier phases.

<img src="https://image.ibb.co/ctu7Ef/WB-phase.png" width="400"/>

## Hazard Mitigation

### Structural Hazards

We ensure that there are no structural hazards by making sure every instruction goes through each phase even if it's not doing anything in that phase. No two instructions will try to go through the same phase and use the same modules at the same time. In the case of the register file and data memory, no two instructions will be accessing the same ports at the same time.

### Control Hazards

To prevent control hazards, stall instructions are sent after `bne`, `beq`, `jr`, `lw` instructions.

### Data Hazards

To mitigate data hazards, we implemented data forwarding for several types of instructions. We can mitigate hazards for R-type instructions for both registers `rs` and `rt`, and for I-type instructions for register `rs`. Additionally, we stall one cycle after every `lw` instruction to mitigate data hazards from that (because you can never get what `lw` is pulling from memory before the memory phase). This doesn't address data hazards with `jr` (instead, pad with `nop`s if `jr` happens fewer than 4 cycles after `jal`) or `sw` (we do not support forwarding of register `rt` values for I-type instructions).

## Testing

We tested our pipeline CPU against three assembly tests: [`mips1.asm`](/asmtest/mips1.asm), [`mem.asm`](/asmtest/mem.asm), and [`array_loop.asm`](/asmtest/array_loop.asm). It passes the first two and fails the third due to data hazards. However, if we add `nop`s to the array loop program cleverly (as in [`array_loop_nops.asm`](/asmtest/array_loop_nops.asm)), it does work as expected. Details on functionality are available in the Hazard Mitigation section.

Getting to that point took a lot of gtkwave and time.

## Workplan Reflection
