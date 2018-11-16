# Nice Try Lab 4 Report
Louise Nielsen and Camille Xue

## Architecture

Our architecture closely follows the general idea of the pipeline CPUs from the class slides. Our full diagram is below.

![Diagram](https://raw.githubusercontent.com/Nice-Try/Lab4/master/images/full_pipeline.png)

### Instruction fetch phase

Here we access instruction memory (really a subset of data memory) based on the current PC address and mux it with a `nop` instruction (all zeros). The rationale behind the control signal there is explained in the Hazard Mitigation section. Not pictured in the diagram is some decoding of `instruction` (after the mux with `nop`) in order to handle control flow and control flow hazards.

<img src="https://image.ibb.co/iomnEf/IF-phase.png" width="400"/>

The really interesting part of the IF phase is the PC unit. This PC unit looks a lot like our single cycle CPU's PC unit with two exceptions: several of the inputs from the single cycle CPU's LUT are from specific phases in our pipeline CPU, and the PC D flip flop itself has an enable. The inputs to the enable are explained more in the Hazard Mitigation section. The inputs from specific phases are part of the managing of control flow - for example, we don't know if we should branch or not for a `BEQ` or `BNE` instruction until that instruction has made it to the EX phase, so we use the `BEQ_EX` and `BNE_EX` flags to determine whether to take a branch or not.

<img src="https://lh3.googleusercontent.com/YewM2YJxL0fSWr5Q2XFWkbCBQlx16Jn9adxPrOrXbMLCRytKiGY2-rqNgyNCJU9qAdb5xDWlAEfhWTKiqPRsvgXFrQzCn6_1YWSBC9NZk_4R4r2IVk8dgNE1fFdOgsqAoSHe8hIDAtm4aOQUCBgmcjDcex9dEfSVqXWVy4uPbz44vZzOQwqXI0ThlWChU1DgEJj7zWW1V53gZUMoR82wxyikj61PwKu6gjp0n9OJDHQfkFLGEC8U7INiY3cpmgLQuYI0w7aAHZUWTOTFaUZRW6My48UCG3BjO-YY6ion0PX4YJE5aPk5ovtXLcmJmTIbkmfK3OIawUdMm7scphakXNUtGLPPu0U5ywjXwCGLojHJaxGCZAFDprpvQWDkYnYHZ3rG0gdgwdR1IpWeQyLBuMGLBbHyGZi7EDYD45dwfQKtC4WzibBI7Bpmw4FfOOfE4qbuQFj9PxHA-Rqfk1_gyyfCMQj_F0sChurGlu6T3SwAvjvTM-v24ODcW3RUPWDX8CX6XmSQkboqN_JwLTtTjiapRh9sNKCtFsEpZ7oekdz-5zQKHaqqvX6IzlAIq64SSF4e0g5Qs_zE8BJRRJdJ2iObT_bklMDCQOX3IJtD2mmgCbrq7Zb3yG23t7w8EU9va9DVK5oLAbk3HPcL7aLOuRYSiA=w953-h714-no" width="700"/>

### Register fetch phase



<img src="https://raw.githubusercontent.com/Nice-Try/Lab4/master/images/RF_phase.png" width="400"/>

### Execute phase
<img src="https://raw.githubusercontent.com/Nice-Try/Lab4/master/images/EX_phase.png" width="400"/>

### Memory phase
<img src="https://raw.githubusercontent.com/Nice-Try/Lab4/master/images/MEM_phase.png" width="400"/>

### Write back phase
<img src="https://raw.githubusercontent.com/Nice-Try/Lab4/master/images/WB_phase.png" width="400"/>

## Hazard Mitigation

## Testing

We tested our pipeline CPU against three assembly tests: [`mips1.asm`](/asmtest/mips1.asm), [`mem.asm`](/asmtest/mem.asm), and [`array_loop.asm`](/asmtest/array_loop.asm). It passes the first two and fails the third due to data hazards. However, if we add `nop`s to the array loop program cleverly (as in [`array_loop_nops.asm`](/asmtest/array_loop_nops.asm)), it does work as expected. Details on functionality are available in the Hazard Mitigation section.

Getting to that point took a lot of gtkwave and time.

## Workplan Reflection
