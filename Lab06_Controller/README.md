# Lab 6 — Controller (VeriRISC CPU Controller)

## Objective
Use the Verilog case statement to build a controller that generates all control signals for a simple CPU.

## Description
The controller takes a 3-bit `opcode`, a 3-bit `phase` (8 phases), and `zero`, and drives 9 control outputs
(`sel, rd, ld_ir, halt, inc_pc, ld_ac, ld_pc, wr, data_e`) according to a spec table indexed by phase and opcode.
Reset is synchronous and active-high.

## Ports
| Signal | Direction | Width | Description                       |
|--------|-----------|-------|-------------------------------------|
| clk    | input     | 1     | System clock                        |
| rst    | input     | 1     | Synchronous, active-high reset      |
| zero   | input     | 1     | 1 when the accumulator is zero      |
| phase  | input     | 3     | Current execution phase (0-7)       |
| opcode | input     | 3     | CPU operation code                  |
| sel, rd, ld_ir, halt, inc_pc, ld_ac, ld_pc, wr, data_e | output | 1 each | Control signals |

## Files
- `maincode.v` — controller design (module `control`).
- `testbench.v` — self-checking testbench (module `controller_tb`) that sweeps all 8 opcodes × all 8 phases and checks against the spec table.

## Running the simulation (Icarus Verilog)
```
iverilog -g2005 -o sim.out maincode.v testbench.v
vvp sim.out
```

## Expected output
```
Testing opcode HLT phase 0 1 2 3 4 5 6 7
Testing opcode SKZ phase 0 1 2 3 4 5 6 7
Testing opcode ADD phase 0 1 2 3 4 5 6 7
Testing opcode AND phase 0 1 2 3 4 5 6 7
Testing opcode XOR phase 0 1 2 3 4 5 6 7
Testing opcode LDA phase 0 1 2 3 4 5 6 7
Testing opcode STO phase 0 1 2 3 4 5 6 7
Testing opcode JMP phase 0 1 2 3 4 5 6 7
TEST PASSED
```
