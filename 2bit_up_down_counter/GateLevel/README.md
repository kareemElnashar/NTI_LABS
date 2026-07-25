# 2-Bit Up/Down Counter — Gate-Level Style

> Part of the [2-Bit Up/Down Counter — Three Design Styles](../README.md) exercise.
> See the parent README for the shared functional spec, next-state equation derivation,
> and testbench strategy.

## Description
This variant takes the structural version's next-state equations one step further: instead
of writing `d0 = ~count[0]` and `d1 = count[1] ^ (up ^ ~count[0])` as high-level Verilog
expressions, they're expanded into their sum-of-products Boolean form and built entirely out
of Verilog's built-in **primitive gates** (`not`, `and`, `or`, `buf`) — no `+`, `-`, `?:`,
or `always`-block arithmetic is used for the next-state logic at all.

```verilog
not n0 (not_q0, q_reg[0]);
not n1 (not_q1, q_reg[1]);
not n2 (not_up, up);

buf b0 (d0, not_q0);                          // d0 = ~q0

and a1 (w1, up, not_q1, q_reg[0]);            // up  & ~q1 &  q0
and a2 (w2, up, q_reg[1], not_q0);            // up  &  q1 & ~q0
and a3 (w3, not_up, not_q1, not_q0);          // ~up & ~q1 & ~q0
and a4 (w4, not_up, q_reg[1], q_reg[0]);      // ~up &  q1 &  q0

or  o0 (d1, w1, w2, w3, w4);                  // d1 = sum of the four product terms
```

The only clocked element left is a single `always @(posedge clock or posedge reset)` block
that latches `{d1, d0}` into an internal register `q_reg` — the flip-flop itself is still
described behaviorally here (Verilog's built-in primitives don't include a D flip-flop
primitive), but **all of the combinational next-state logic** is now expressed gate-by-gate.

### Reading the equation off the gates
`d1`'s sum-of-products expands to exactly the XOR relation used in the structural version:
```
d1 = (up & ~q1 & q0) | (up & q1 & ~q0) | (~up & ~q1 & ~q0) | (~up & q1 & q0)
   = q1 XOR (up XOR ~q0)
```
Both forms are logically identical — this file is simply the "unrolled" version of the
structural design's continuous assignment, one logic gate at a time.

## Ports
| Signal | Direction | Width | Description                          |
|--------|-----------|-------|----------------------------------------|
| clock  | input     | 1     | Clock                                  |
| reset  | input     | 1     | Asynchronous reset, active-high        |
| up     | input     | 1     | Count direction (1 = up, 0 = down)     |
| count  | output    | 2     | Current counter value (= internal `q_reg`) |

## Internal signals
| Signal | Meaning                                             |
|--------|------------------------------------------------------|
| not_q0, not_q1, not_up | Inverted versions of `q_reg[0]`, `q_reg[1]`, `up` |
| w1..w4 | The four AND product terms feeding the final OR for `d1` |
| d0, d1 | Computed next-state bits, latched into `q_reg` on the next clock edge |
| q_reg  | Internal 2-bit register that actually holds the counter state (driven out through `count`) |

## Verilog concepts demonstrated
- Verilog **built-in primitive gates**: `not`, `and` (with more than 2 inputs), `or`, `buf`.
- Manual sum-of-products (Boolean logic) implementation, the same output a logic synthesis
  tool would produce internally from the higher-level behavioral/structural descriptions.
- Mixing gate-level combinational logic with a behavioral sequential (`always`) block — this
  is a common and perfectly normal mix in real gate-level netlists, since Verilog has no
  built-in flip-flop primitive.

## Files
- `maincode.v` — counter design (module `counter2`), built from primitive gate instances.
- `testbench.v` — self-checking testbench (module `counter_tb`), identical to the other two variants.

## Running the simulation (Icarus Verilog)
```
iverilog -g2005 -o sim.out maincode.v testbench.v
vvp sim.out
```

## Expected result
All up/down/reset checks pass with no `>>> ERROR` lines, ending with:
```
--- Simulation Successfully Finished ---
```
