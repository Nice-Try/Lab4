# Nice Try Lab 4 Report
Louise Nielsen and Camille Xue

## CPU Architecture
![Diagram](https://image.ibb.co/jRkQ0L/full-pipeline.png)
<img src="https://image.ibb.co/iomnEf/IF-phase.png" width="400"/>
<img src="https://image.ibb.co/iHAfZf/RF-phase.png" width="400"/>
<img src="https://image.ibb.co/e753n0/EX-phase.png" width="400"/>
<img src="https://image.ibb.co/dhH50L/MEM-phase.png" width="400"/>
<!-- <img src="https://image.ibb.co/ctu7Ef/WB-phase.png" width="400"/> -->

## Hazard Mitigation
![timing](https://image.ibb.co/kL78n0/timing-diagram.png)

## Testing

We tested our pipeline CPU against three assembly tests: [`mips1.asm`](/asmtest/mips1.asm), [`mem.asm`](/asmtest/mem.asm), and [`array_loop.asm`](/asmtest/array_loop.asm). It passes the first two and fails the third due to data hazards. However, if we add `nop`s to the array loop program cleverly (as in [`array_loop_nops.asm`](/asmtest/array_loop_nops.asm)), it does work as expected. Details on functionality are available in the Hazard Mitigation section.

Getting to that point took a lot of gtkwave and time. 

## Workplan Reflection


## Diagram Image Links
[Full Pipeline Diagram](https://ibb.co/dydOn0)

[IF Phase](https://ibb.co/kC3CfL)

[RF Phase](https://ibb.co/fy1b70)

[EX Phase](https://ibb.co/eObb70)

[MEM Phase](https://ibb.co/mjmyLL)

[WB Phase](https://ibb.co/mt1XfL)
