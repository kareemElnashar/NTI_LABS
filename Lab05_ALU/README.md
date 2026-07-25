# Lab 5 — Arithmetic Logic Unit (ALU)

## Objective
Practice using Verilog operators (arithmetic, bitwise, relational) together with a `case`
statement inside a combinational `always` block to build a parameterized-width ALU — the
same building block that later becomes part of the CPU controller in Lab 6 and the pipeline
in `TopModule`.

## Description
`alu` is purely combinational (`always @(*)`), so `alu_out` updates immediately whenever any
input changes — there's no clock involved in this module at all.

```verilog
always @(*) begin
    case (opcode)
        3'b000: alu_out = in_a;
        3'b001: alu_out = in_a;
        3'b010: alu_out = in_a + in_b;
        3'b011: alu_out = in_a & in_b;
        3'b100: alu_out = in_a ^ in_b;
        3'b101: alu_out = in_b;
        3'b110: alu_out = in_a;
        3'b111: alu_out = in_a;
        default: alu_out = 0;
    endcase
end
```

`a_is_zero` is a separate, independent continuous assignment:
```verilog
assign a_is_zero = (in_a == 0) ? 1'b1 : 1'b0;
```
It's a flag, not an ALU result — it's meant to answer "is operand A currently zero?" for use
by other logic (e.g. Lab 6's `zero` input, used for conditional branches).

### Opcode table
Note that this opcode encoding isn't an arbitrary ALU truth table — it's reused directly as
the CPU instruction opcode in Lab 6's controller, so several codes intentionally just pass
an operand through unchanged (they're op**codes** for a simple CPU, not all "ALU operations"
in the traditional sense):

| Opcode | Instruction | Operation      | Notes |
|--------|-------------|----------------|-------|
| 000    | HLT         | PASS A         | Halt — ALU result unused |
| 001    | SKZ         | PASS A         | Skip-if-zero — ALU result unused |
| 010    | ADD         | in_a + in_b    | Real ALU operation |
| 011    | AND         | in_a & in_b    | Real ALU operation |
| 100    | XOR         | in_a ^ in_b    | Real ALU operation |
| 101    | LDA         | PASS B         | Load accumulator from B |
| 110    | STO         | PASS A         | Store — ALU result unused |
| 111    | JMP         | PASS A         | Jump — ALU result unused |

## Ports
| Signal     | Direction | Width              | Description         |
|------------|-----------|--------------------|-----------------------|
| in_a       | input     | WIDTH (default 8)  | Operand A            |
| in_b       | input     | WIDTH (default 8)  | Operand B            |
| opcode     | input     | 3                  | Operation select code |
| alu_out    | output    | WIDTH (default 8)  | Result                |
| a_is_zero  | output    | 1                  | 1 when in_a = 0       |

## Verilog concepts demonstrated
- Combinational `always @(*)` with a `case` statement (full case coverage, plus `default`
  to avoid an unintended latch).
- Arithmetic (`+`), bitwise (`&`, `^`) operators.
- A separate, independent `assign` for a status flag alongside a procedural block for the
  main datapath — a very common ALU pattern (flags + result computed differently).

## Testbench strategy
`testbench.v` sweeps all 8 opcodes against one fixed pair of operands
(`in_a = 8'b01000010`, `in_b = 8'b10000110`) and checks both `alu_out` and `a_is_zero` after
each, then re-checks `a_is_zero` specifically with `in_a = 0` to confirm the zero-flag logic.

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
