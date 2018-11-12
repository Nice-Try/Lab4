# Lab 4: Pipeline CPU

## Microproposal

We will build a pipeline CPU that handles data hazards by forwarding and control hazards by stalling. It will support the following instructions:

```
LW, SW, J, JR, JAL, BEQ, BNE, XORI, ADDI, ADD, SUB, SLT
```

Deliverables:
* Work plan
* CPU in verilog
* Tests written in assembly
* Scripts to run the tests
* Report, which includes:
  * Explanation of CPU architecture
  * Timing diagram showing hazard handling
  * Description of tests/choices/process
  * Work plan reflection

Extra resources or references: We plan to use Ben's (and the NINJAs) office hours frequently. We don't think we necessarily need anything from the companion readings.
