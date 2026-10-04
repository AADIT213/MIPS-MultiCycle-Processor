\# MIPS Instruction Set



\## Supported Instructions



The enhanced processor supports the following instruction groups.



\### R-Type Instructions



| Instruction | Function |

|---|---|

| ADD | `100000` |

| SUB | `100010` |

| AND | `100100` |

| OR | `100101` |

| SLT | `101010` |



R-type instructions use:



&#x20;   opcode = 000000



\### Memory Instructions



| Instruction | Opcode |

|---|---|

| LW | `100011` |

| SW | `101011` |



\### Branch Instruction



| Instruction | Opcode |

|---|---|

| BEQ | `000100` |



\### Jump Instructions



| Instruction | Opcode |

|---|---|

| J | `000010` |

| JAL | `000011` |



\### Immediate Arithmetic



| Instruction | Opcode |

|---|---|

| ADDI | `001000` |



\## Instruction Formats



\### R-Type



&#x20;   31        26 25    21 20    16 15    11 10     6 5      0

&#x20;   +-----------+--------+--------+--------+--------+--------+

&#x20;   |  opcode   |   rs   |   rt   |   rd   | shamt  | funct  |

&#x20;   +-----------+--------+--------+--------+--------+--------+



\### I-Type



&#x20;   31        26 25    21 20    16 15                       0

&#x20;   +-----------+--------+--------+---------------------------+

&#x20;   |  opcode   |   rs   |   rt   |        immediate          |

&#x20;   +-----------+--------+--------+---------------------------+



Used by `LW`, `SW`, `BEQ`, and `ADDI`.



\### J-Type



&#x20;   31        26 25                                      0

&#x20;   +-----------+-----------------------------------------+

&#x20;   |  opcode   |              target                      |

&#x20;   +-----------+-----------------------------------------+



Used by `J` and `JAL`.



\## Enhanced Instructions



\### ADDI



&#x20;   ADDI rt, rs, immediate



Adds a sign-extended immediate value to `rs` and stores the result in `rt`.



\### JAL



&#x20;   JAL target



Transfers control to the target address and saves the link value in register `$31`.



\### Signed Overflow Detection



The enhanced datapath detects signed addition overflow.



Overflow occurs when two operands have the same sign but the resulting value has the opposite sign.



The condition is exposed through the `Overflow` signal.

