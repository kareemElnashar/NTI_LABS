# Lab 9 — Generic Counter

## Objective
Use blocking and nonblocking assignments to build a generic counter that can serve as a program counter or phase counter.

## Description
If `rst = 1`, the output clears to zero. If `load = 1`, it loads `cnt_in`. If `enab = 1` (and load is low), it
increments by one. The combinational and sequential behavior are described in separate procedures.

## Ports
| Signal    | Direction | Width              | Description             |
|-----------|-----------|--------------------|---------------------------|
| clk       | input     | 1                  | Clock                     |
| rst       | input     | 1                  | Reset, active-high        |
| load      | input     | 1                  | Load a new value          |
| enab      | input     | 1                  | Count enable              |
| cnt_in    | input     | WIDTH (default 5)  | Value to load             |
| cnt_out   | output    | WIDTH (default 5)  | Current counter value     |

## Files
- `maincode.v` — counter design (module `counter`).
- `testbench.v` — self-checking testbench (module `counter_tb`).

## Running the simulation (Icarus Verilog)
```
iverilog -g2005 -o sim.out maincode.v testbench.v
vvp sim.out
```

## Expected output
```
At time 20 rst=0 load=1 enab=1 cnt_in=10101 cnt_out=10101
At time 30 rst=0 load=1 enab=1 cnt_in=01010 cnt_out=01010
At time 40 rst=0 load=1 enab=1 cnt_in=11111 cnt_out=11111
At time 50 rst=1 load=1 enab=1 cnt_in=11111 cnt_out=00000
At time 60 rst=0 load=1 enab=1 cnt_in=11111 cnt_out=11111
At time 70 rst=0 load=0 enab=1 cnt_in=11111 cnt_out=00000
TEST PASSED
```
