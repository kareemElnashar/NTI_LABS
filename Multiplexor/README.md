# Multiplexor — 2:1 Mux

## Objective
Design a simple parameterized-width 2-to-1 multiplexer.

## Description
`mux_out` equals `in1` when `sel = 1`, and equals `in0` when `sel = 0`.

## Ports
| Signal   | Direction | Width              | Description       |
|----------|-----------|--------------------|---------------------|
| in0      | input     | WIDTH (default 5)  | First input         |
| in1      | input     | WIDTH (default 5)  | Second input        |
| sel      | input     | 1                  | Input select        |
| mux_out  | output    | WIDTH (default 5)  | Output              |

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
