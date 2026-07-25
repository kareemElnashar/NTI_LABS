# Multiplexor — 2:1 Mux

## Objective
The simplest building block in the whole lab set: a parameterized-width 2-to-1 multiplexer,
used as a warm-up exercise for the ternary (conditional) operator and module parameters
before moving into sequential logic.

## Description
```verilog
assign mux_out = (sel == 1'b1) ? in1 : in0;
```
A single continuous assignment using the ternary operator: `mux_out` follows `in1` when
`sel = 1`, and `in0` when `sel = 0`. There is no clock and no internal state — `mux_out`
reacts immediately (combinationally) to any change on `in0`, `in1`, or `sel`.

## Ports
| Signal   | Direction | Width              | Description       |
|----------|-----------|--------------------|---------------------|
| in0      | input     | WIDTH (default 5)  | First input (selected when `sel=0`) |
| in1      | input     | WIDTH (default 5)  | Second input (selected when `sel=1`) |
| sel      | input     | 1                  | Input select        |
| mux_out  | output    | WIDTH (default 5)  | Output              |

## Verilog concepts demonstrated
- Continuous assignment (`assign`) with the ternary conditional operator (`cond ? a : b`).
- `parameter WIDTH` for a reusable, bus-width-agnostic module.

## Testbench strategy
`testbench.v` sets two different `(in0, in1)` pairs, and for each one toggles `sel` between
`0` and `1`, checking `mux_out` follows the correct input every time — four total checks.

## Files
- `maincode.v` — mux design (module `multiplexor`).
- `testbench.v` — self-checking testbench (module `multiplexor_tb`).

## Running the simulation (Icarus Verilog)
```
iverilog -g2005 -o sim.out maincode.v testbench.v
vvp sim.out
```

## Expected output
```
At time 1 sel=0 in0=00001 in1=11110 mux_out=00001
At time 2 sel=1 in0=00001 in1=11110 mux_out=11110
At time 3 sel=0 in0=10101 in1=01010 mux_out=10101
At time 4 sel=1 in0=10101 in1=01010 mux_out=01010
TEST PASSED
```
