\# MIPS Multi-Cycle Processor



A MIPS-style multi-cycle processor implemented using a finite-state-machine based control unit, with both Logisim Evolution and Verilog implementations.



The project began as a Computer Architecture academic implementation and has been consolidated and extended into a structured processor-design repository.



\---



\## Overview



A multi-cycle processor executes instructions across multiple clock cycles rather than completing every instruction in a single cycle.



This architecture allows hardware resources such as the ALU, register file, and memory to be reused between instruction stages.



The project demonstrates:



\- MIPS datapath design

\- Finite-state-machine based control

\- Multi-cycle instruction execution

\- ALU control

\- Register-file operations

\- Shared instruction/data memory

\- Branch and jump handling

\- Immediate arithmetic

\- Signed overflow detection

\- Automated Verilog verification



\---



\## Architecture



The processor consists of two major sections:



\### Datapath



The datapath contains:



\- 32-bit Program Counter

\- Instruction Register

\- 32 × 32-bit register file

\- A and B operand registers

\- ALU

\- ALUOut register

\- Memory Data Register

\- Shared memory

\- Sign-extension logic

\- Branch and jump target generation

\- Overflow detection



\### Control Unit



The control unit is implemented as a finite state machine.



It generates the control signals required to move an instruction through its multi-cycle execution sequence.



Typical execution flow:



```text

Instruction Fetch

&#x20;       ↓

Instruction Decode

&#x20;       ↓

Execute / Address Calculation

&#x20;       ↓

Memory Access / ALU Completion

&#x20;       ↓

Writeback

