# Lab 4 — Data Driver (Tri-State Bus Driver)

## Objective
Practice using Verilog literal values (sized/unsized constants, `x`, `z`, the replication
operator) to build a parameterized-width tri-state bus driver — the kind of block you'd put
at the boundary of a shared data bus so multiple devices can take turns driving it.

## Description
`driver` is a single continuous assignment with a ternary operator:

```verilog
assign data_out = (data_en == 1'b1) ? data_in : {WIDTH{1'bz}};
```

- When `data_en = 1`, the driver is "on the bus": `data_out` follows `data_in` directly
  (a simple pass-through, zero propagation delay in simulation).
- When `data_en = 0`, the driver disconnects itself electrically by driving every bit of
  `data_out` to high-impedance (`z`), using the **replication operator**
  `{WIDTH{1'bz}}` to build a `WIDTH`-bit-wide all-`z` value regardless of the parameter value.

This is exactly the behavior needed for a shared bus with multiple drivers (e.g. a memory
data bus, or one lane of a multi-master interconnect): only one driver should be actively
asserting a value at a time, and every other driver on the same wire must be at `z` so their
outputs don't electrically fight.

## Ports
| Signal    | Direction | Width              | Description                     |
|-----------|-----------|--------------------|----------------------------------|
| data_in   | input     | WIDTH (default 8)  | Input data                       |
| data_en   | input     | 1                  | Output enable                    |
| data_out  | output    | WIDTH (default 8)  | Output data, or Z when disabled  |

## Verilog concepts demonstrated
- Sized literals (`1'b1`, `1'b0`) and the four-value logic system (`0`, `1`, `x`, `z`).
- The replication operator `{N{value}}` for building a bus-wide constant from a parameter.
- `parameter WIDTH` for a reusable, width-agnostic module.
- Continuous assignment (`assign`) driving a tri-state (`z`-capable) output.

## Testbench strategy
`testbench.v` drives `data_en`/`data_in` through three cases and checks `data_out` after each:
1. `data_en = 0` with `data_in` at all-`x` → expects `data_out` to be all-`z` (disabled state,
   independent of whatever garbage is on `data_in`).
2. `data_en = 1`, `data_in = 8'b01010101` → expects `data_out` to follow exactly.
3. `data_en = 1`, `data_in = 8'b10101010` → expects `data_out` to follow exactly.

Each case is checked by a `check` task that compares `data_out` against the expected value
using `!==` (case-equality, which correctly distinguishes `z`/`x` from `0`/`1` — a plain `!=`
would not catch a `z` vs `0` mismatch).

## Files
- `maincode.v` — driver design (module `driver`).
- `testbench.v` — self-checking testbench (module `driver_tb`).

## Running the simulation (Icarus Verilog)
```
iverilog -g2005 -o sim.out maincode.v testbench.v
vvp sim.out
```

## Expected output
```
At time 1 data_en=0 data_in=xxxxxxxx data_out=zzzzzzzz
At time 2 data_en=1 data_in=01010101 data_out=01010101
At time 3 data_en=1 data_in=10101010 data_out=10101010
TEST PASSED
```
