\# MIPS Multi-Cycle Processor Architecture



\## 1. Overview



This project implements a MIPS-style multi-cycle processor using a finite-state-machine based control unit.



The processor divides instruction execution across multiple clock cycles, allowing major hardware resources such as the ALU, register file, and memory to be reused.



The repository contains the original academic implementation as a baseline/reference and an enhanced Verilog implementation.



\## 2. Datapath



The enhanced datapath contains:



\- 32-bit Program Counter (PC)

\- Instruction Register

\- 32 × 32-bit register file

\- A and B temporary operand registers

\- ALU

\- ALUOut register

\- Memory Data Register (MDR)

\- Shared instruction/data memory

\- Sign-extension logic

\- Branch-target generation

\- Jump-target generation

\- Signed overflow detection



Register `$0` is maintained at zero.



\## 3. Multi-Cycle Execution



Instructions are divided into several stages:



1\. Instruction Fetch

2\. Instruction Decode / Register Read

3\. Execute or Address Calculation

4\. Memory Access or ALU completion

5\. Register Writeback



Different instruction types use different numbers of cycles.



\### R-Type



```text

Fetch → Decode → Execute → Writeback

