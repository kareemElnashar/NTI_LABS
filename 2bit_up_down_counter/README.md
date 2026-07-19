# 2-Bit Up/Down Counter — Three Design Styles

## Objective
Implement the same 2-bit up/down counter (`counter2`) three different ways — behavioral, structural, and
gate-level — and verify all three against the same testbench.

## Common Interface
| Signal | Direction | Width | Description                          |
|--------|-----------|-------|----------------------------------------|
| clock  | input     | 1     | Clock                                  |
| reset  | input     | 1     | Asynchronous reset, active-high        |
| up     | input     | 1     | Count direction (1 = up, 0 = down)     |
| count  | output    | 2     | Current counter value                  |

All three variants are drop-in compatible: `count <= count + 1` when `up = 1`, `count <= count - 1` when `up = 0`,
and `count` clears to `00` asynchronously when `reset = 1`.

## Variants
| Folder        | Style       | Notes                                                                 |
|---------------|-------------|------------------------------------------------------------------------|
| `Behavioral/` | Behavioral  | Plain `always` block using `+`/`-` arithmetic.                        |
| `Structural/` | Structural  | Built from two instantiated `dff` flip-flop modules driven by next-state equations. |
| `GateLevel/`  | Gate-level  | Built entirely from primitive gates (`and`, `or`, `not`, `buf`).      |

Each folder contains:
- `maincode.v` — the design for that style (module `counter2`, plus a `dff` submodule in the structural version).
- `testbench.v` — the same self-checking testbench (module `counter_tb`) that exercises asynchronous reset, up-counting, down-counting, and a mid-cycle reset.
- `README.md` — details for that specific variant.

## Running any variant (Icarus Verilog)
```
cd <Variant>
iverilog -g2005 -o sim.out maincode.v testbench.v
vvp sim.out
```

All three variants pass the same testbench with no mismatches.
