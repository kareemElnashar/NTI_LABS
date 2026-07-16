# Lab 10 — Counter Using Functions

## Objective
Encapsulate the counter's combinational next-state behavior inside a Verilog `function` instead of writing it
directly inside the always block.

## Description
Behaves exactly like the Lab 9 counter (rst / load / enab), but the next-count logic is computed inside a
function called `get_next_count` instead of being written inline.

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
- `maincode.v` — counter design using a function (module `counter_with_function`).
- `testbench.v` — same stimulus as Lab 9 (module `counter_with_function_tb`).

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
