\# Verification



\## 1. Verification Approach



The original recovered Verilog testbench only generated a clock, applied reset, allowed the processor to execute, and then terminated.



The enhanced repository replaces that approach with a self-checking Verilog testbench.



The testbench directly examines processor state and reports each functional test as `PASS` or `FAIL`.



\## 2. Automated Tests



| Test | Expected Result | Status |

|---|---|---|

| ADDI | R8 = 10 | PASS |

| ADDI chaining | R9 = 15 | PASS |

| ADD | R10 = 25 | PASS |

| LW | R8 = 42 | PASS |

| SW | Memory word 17 = 42 | PASS |

| BEQ | Branch target executes | PASS |

| JAL | R31 = 4 | PASS |

| JAL | Jump target executes | PASS |

| Signed overflow | Overflow asserted | PASS |



\## 3. Verification Output



The integrated enhanced implementation produced:



&#x20;   PASS: ADDI R8 = 0000000a

&#x20;   PASS: ADDI R9 = 0000000f

&#x20;   PASS: ADD R10 = 00000019

&#x20;   PASS: LW R8 = 0000002a

&#x20;   PASS: SW MEM\[17] = 0000002A

&#x20;   PASS: BEQ target = 00000007

&#x20;   PASS: JAL link R31 = 00000004

&#x20;   PASS: JAL target R8 = 0000002a

&#x20;   PASS: signed overflow detected



&#x20;   ========================================

&#x20;   ALL ENHANCED MIPS TESTS PASSED

&#x20;   ========================================



\## 4. Reproducing the Verification



From the repository root:



&#x20;   C:\\iverilog\\bin\\iverilog.exe -g2012 -o verilog\\simulation\\enhanced\_mips.vvp `

&#x20;       verilog\\src\\mips.v `

&#x20;       verilog\\src\\datapath.v `

&#x20;       verilog\\src\\control.v `

&#x20;       verilog\\src\\alucontrol.v `

&#x20;       verilog\\testbench\\tb\_mips.v



Then run:



&#x20;   C:\\iverilog\\bin\\vvp.exe verilog\\simulation\\enhanced\_mips.vvp



A successful run ends with:



&#x20;   ALL ENHANCED MIPS TESTS PASSED



\## 5. Verification Scope



The automated testbench verifies functional behavior of the enhanced Verilog implementation.



The original Logisim implementation and academic report are retained separately as part of the project's development history and reference material.



The verification currently covers arithmetic, memory access, branching, jumping, immediate arithmetic, link-register behavior, and signed overflow detection.

