# 2-Bit Up/Down Counter — Three Design Styles

## Objective
Implement the exact same 2-bit up/down counter (`counter2`) three different ways —
**behavioral**, **structural**, and **gate-level** — and prove all three are functionally
identical by running them against one shared testbench. This is the classic exercise for
understanding that Verilog is a *hardware description* language: the same digital behavior
can be described at very different levels of abstraction, and all of them should still
synthesize to (roughly) the same physical logic.

## Functional Specification
| Signal | Direction | Width | Description                          |
|--------|-----------|-------|----------------------------------------|
| clock  | input     | 1     | Clock, counter updates on the rising edge |
| reset  | input     | 1     | Asynchronous reset, active-high        |
| up     | input     | 1     | Count direction (1 = up, 0 = down)     |
| count  | output    | 2     | Current counter value (wraps mod 4)    |

Behavior, identical for all three variants:
- `reset = 1` forces `count` to `2'b00` **immediately**, independent of `clock` (asynchronous reset).
- Otherwise, on every rising edge of `clock`:
  - `up = 1` → `count <= count + 1` (wraps `11 → 00`)
  - `up = 0` → `count <= count - 1` (wraps `00 → 11`)

## The Three Abstraction Levels

| Folder        | Style       | What it actually is                                                                 |
|---------------|-------------|---------------------------------------------------------------------------------------|
| `Behavioral/` | Behavioral  | One `always` block that just writes `count <= count + 1` / `count <= count - 1`. You describe *what* should happen and let the simulator/synthesizer figure out *how*. |
| `Structural/` | Structural  | Two hand-instantiated `dff` (D flip-flop) submodules, wired together with `assign` statements that compute each flip-flop's next-state input (`d0`, `d1`) from Boolean equations. You describe the circuit as a graph of smaller components. |
| `GateLevel/`  | Gate-level  | The next-state equations from the structural version, expanded further into individual Verilog primitive gates (`and`, `or`, `not`, `buf`), each wired to the next with named `wire`s. This is the closest Verilog gets to drawing an actual schematic. |

### Why the up/down logic looks different in each style
For a 2-bit up/down counter, the next-state equations for the two flip-flop inputs
(derived from a state table / Karnaugh map, where `q1 q0` is the current count) are:

```
d0 = ~q0
d1 = q1 XOR (up XOR ~q0)      i.e. q1 XOR up XOR ~q0
```

- **Behavioral** hides this derivation completely behind `count + 1` / `count - 1`.
- **Structural** exposes it as the two `assign` equations above, feeding two `dff` instances.
- **Gate-level** expands `d1` even further using its sum-of-products form
  (`up & ~q1 & q0` OR `up & q1 & ~q0` OR `~up & ~q1 & ~q0` OR `~up & q1 & q0`),
  built entirely out of `and`/`or`/`not` primitives — no `+`, `-`, `?:`, or `always`
  arithmetic at all for the next-state logic.

All three converge on the same truth table, which is exactly what the shared testbench
checks for.

## Files (per folder)
- `maincode.v` — the design for that style (module `counter2`, plus a `dff` submodule in `Structural/`).
- `testbench.v` — the same self-checking testbench (module `counter_tb`) in every folder.
- `README.md` — details specific to that variant.

## Testbench Strategy (shared by all three)
`testbench.v` is self-checking: it computes the *expected* next count in the testbench
itself (function `get_expected_count`) and compares it against the DUT's actual `count`
after every clock edge, printing `>>> ERROR` if they disagree. It exercises, in order:
1. Asynchronous reset asserted mid-simulation (checks reset doesn't wait for a clock edge).
2. Five up-counts in a row (checks wraparound `11 → 00`).
3. Five down-counts in a row (checks wraparound `00 → 11`).
4. An asynchronous reset asserted **in the middle** of a counting sequence (checks reset
   interrupts counting instantly, not just at the next clock edge).
5. A final couple of up-counts after the mid-cycle reset to confirm normal operation resumes.

## Running any variant (Icarus Verilog)
```
cd <Variant>
iverilog -g2005 -o sim.out maincode.v testbench.v
vvp sim.out
```

All three variants pass the same testbench with zero mismatches, ending in:
```
--- Simulation Successfully Finished ---
```

## Instructor talking points
- Behavioral vs. structural vs. gate-level is exactly the abstraction hierarchy a real ASIC/FPGA
  flow goes through: RTL → gate-level netlist (after synthesis) → physical layout.
- The `dff` submodule in `Structural/` is a reusable building block — a small demonstration of
  hierarchical design (module instantiation) rather than one flat module.
- The gate-level version is intentionally the most verbose and the least "designer-friendly" —
  that's the point: it shows what a synthesis tool produces automatically from the other two.
