# Lab 5 — Arithmetic Logic Unit (ALU)

## Objective
Use Verilog operators to build a parameterized-width ALU that performs 8 operations selected by opcode.

## Description
`alu_out` is determined by the 3-bit `opcode`, and `a_is_zero` is a combinational flag that is 1 whenever `in_a == 0`.

## Opcode Table
| Opcode | Instruction | Operation      |
|--------|-------------|----------------|
| 000    | HLT         | PASS A         |
| 001    | SKZ         | PASS A         |
| 010    | ADD         | in_a + in_b    |
| 011    | AND         | in_a & in_b    |
| 100    | XOR         | in_a ^ in_b    |
| 101    | LDA         | PASS B         |
| 110    | STO         | PASS A         |
| 111    | JMP         | PASS A         |

## Ports
| Signal     | Direction | Width              | Description         |
|------------|-----------|--------------------|-----------------------|
| in_a       | input     | WIDTH (default 8)  | Operand A            |
| in_b       | input     | WIDTH (default 8)  | Operand B            |
| opcode     | input     | 3                  | Operation select code |
| alu_out    | output    | WIDTH (default 8)  | Result                |
| a_is_zero  | output    | 1                  | 1 when in_a = 0       |

## Files
- `maincode.v` — ALU design (module `alu`).
- `testbench.v` — self-checking testbench (module `alu_tb`).

## Running the simulation (Icarus Verilog)
```
iverilog -g2005 -o sim.out maincode.v testbench.v
vvp sim.out
```

## Expected output
```
At time 1 opcode=000 in_a=01000010 in_b=10000110 a_is_zero=0 alu_out=01000010
At time 2 opcode=001 in_a=01000010 in_b=10000110 a_is_zero=0 alu_out=01000010
At time 3 opcode=010 in_a=01000010 in_b=10000110 a_is_zero=0 alu_out=11001000
At time 4 opcode=011 in_a=01000010 in_b=10000110 a_is_zero=0 alu_out=00000010
At time 5 opcode=100 in_a=01000010 in_b=10000110 a_is_zero=0 alu_out=11000100
At time 6 opcode=101 in_a=01000010 in_b=10000110 a_is_zero=0 alu_out=10000110
At time 7 opcode=110 in_a=01000010 in_b=10000110 a_is_zero=0 alu_out=01000010
At time 8 opcode=111 in_a=01000010 in_b=10000110 a_is_zero=0 alu_out=01000010
At time 9 opcode=111 in_a=00000000 in_b=10000110 a_is_zero=1 alu_out=00000000
TEST PASSED
```
