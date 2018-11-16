# Nice Try Lab 4 Report
Louise Nielsen and Camille Xue

## CPU Architecture

## Hazard Mitigation

## Testing

We tested our pipeline CPU against three assembly tests: [`mips1.asm`](/asmtest/mips1.asm), [`mem.asm`](/asmtest/mem.asm), and [`array_loop.asm`](/asmtest/array_loop.asm). It passes the first two and fails the third due to data hazards. However, if we add `nop`s to the array loop program cleverly (as in [`array_loop_nops.asm`](/asmtest/array_loop_nops.asm)), it does work as expected. Details on functionality are available in the Hazard Mitigation section.

Getting to that point took a lot of gtkwave and time. 

## Workplan Reflection
