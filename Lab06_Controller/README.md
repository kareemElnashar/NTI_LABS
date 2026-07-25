# Lab 6 — Controller (Simple CPU Controller)

## Objective
Practice using the Verilog `case` statement to build the control unit of a small,
phase-based CPU: a block that looks at *what instruction* is executing and *which phase of
execution* it's in, and drives every datapath control signal accordingly.

## Description
`control` is a synchronous state machine driven purely by an external `phase` counter
(phases 0–7 are supplied from outside this module, not generated here — this lab focuses on
the *decode/control* logic, not the phase sequencer itself).

The structure is: a combinational `always @(*)` computes `alu_op` (1 whenever the current
opcode is ADD/AND/XOR/LDA, i.e. whenever the instruction actually needs the ALU), and a
second, clocked `always @(posedge clk)` block does the real control-signal generation. Inside
that block, every output is first assigned `0` unconditionally (both in the `rst` branch and
at the top of the normal branch), and then a `case (phase)` selectively raises the specific
outputs needed for that phase:

- **Phase 0–3** — instruction fetch: `sel` puts the PC on the address bus, `rd` starts a
  memory read, and by phase 2–3 `ld_ir` latches the fetched byte into the instruction register.
- **Phase 4** — `inc_pc` advances the program counter; if `opcode == HLT`, `halt` is also raised.
- **Phase 5** — `rd <= alu_op`: only opcodes that actually need an ALU operand start a second
  memory read here (HLT/SKZ/STO/JMP don't).
- **Phase 6** — `rd <= alu_op` continues; additionally `SKZ` conditionally raises `inc_pc`
  (only if `zero == 1`), `JMP` raises `ld_pc`, and `STO` raises `data_e`.
- **Phase 7** — `rd`/`ld_ac` follow `alu_op` (committing the ALU result to the accumulator for
  ADD/AND/XOR/LDA); `JMP` raises `ld_pc` again, and `STO` raises both `wr` and `data_e` to
  actually perform the memory write.

Two design details worth calling out:
- **`alu_op`** is a purely combinational helper flag (a second, small `always @(*)` block)
  that answers "does this opcode actually need the ALU / a data fetch?" — it's reused across
  three different phases (5, 6, 7) instead of repeating the same four-way `||` each time.
- **Every output is reset to `0` at the top of the `else` branch, every cycle**, before the
  `case` statement selectively turns specific ones on. This is what stops the design from
  synthesizing unwanted latches: every register is unconditionally assigned on every clock
  edge, so there's no code path where an output "remembers" its old value by accident.
- Reset here is **synchronous** (`posedge clk` only, no `posedge rst` in the sensitivity
  list) — different from most of the sequential labs in this set, which use asynchronous
  reset. Compare with Lab 7/Lab 9, which are also synchronous, versus the FSM labs, which
  are asynchronous.

## Ports
| Signal | Direction | Width | Description                       |
|--------|-----------|-------|-------------------------------------|
| clk    | input     | 1     | System clock                        |
| rst    | input     | 1     | Synchronous, active-high reset      |
| zero   | input     | 1     | 1 when the accumulator is zero      |
| phase  | input     | 3     | Current execution phase (0-7)       |
| opcode | input     | 3     | CPU operation code (same encoding as Lab 5's ALU) |
| sel    | output    | 1     | Select PC (vs. other address source) onto the address bus |
| rd     | output    | 1     | Memory / ALU-operand read strobe    |
| ld_ir  | output    | 1     | Load the instruction register        |
| halt   | output    | 1     | Stop execution (opcode = HLT)        |
| inc_pc | output    | 1     | Increment the program counter        |
| ld_ac  | output    | 1     | Load the accumulator with the ALU result |
| ld_pc  | output    | 1     | Load PC (opcode = JMP)               |
| wr     | output    | 1     | Memory write strobe (opcode = STO)   |
| data_e | output    | 1     | Enable the data (as opposed to instruction) address path |

## Verilog concepts demonstrated
- `case` statement selecting between many output combinations based on a control variable.
- Concatenation-style bulk reset of many `reg` outputs in one line.
- A small combinational helper signal (`alu_op`) computed separately from, and reused inside,
  the main sequential `case`.
- Synchronous (as opposed to asynchronous) reset.

## Testbench strategy
`testbench.v` doesn't just replay a handful of canned instructions — it exhaustively sweeps
**all 8 opcodes × all 8 phases** (64 combinations total), independently recomputing the
expected value of every one of the 9 outputs for each combination (`compute_expected` task,
which mirrors the DUT's own `case` logic), and fails loudly (`$display("TEST FAILED")` +
`$finish`) at the first mismatch. This kind of exhaustive sweep is a strong way to test a
control unit, since a bug in even one `phase`/`opcode` corner would otherwise be easy to miss
with hand-picked test vectors.

## Files
- `maincode.v` — controller design (module `control`).
- `testbench.v` — self-checking testbench (module `controller_tb`) that sweeps all 8 opcodes × all 8 phases and checks against an independently computed spec.

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
