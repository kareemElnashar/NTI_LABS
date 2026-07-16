# Lab 7 — Generic Register

## Objective
Use nonblocking assignments to build a generic register that can serve as an accumulator or instruction register.

## Description
`data_out` takes the value of `data_in` when `load = 1` on the rising edge of `clk`.
Reset is synchronous and active-high, and clears `data_out`.

## Ports
| Signal    | Direction | Width              | Description            |
|-----------|-----------|--------------------|--------------------------|
| clk       | input     | 1                  | Clock, rising edge       |
| rst       | input     | 1                  | Synchronous, active-high reset |
| load      | input     | 1                  | Load enable               |
| data_in   | input     | WIDTH (default 8)  | Input data                |
| data_out  | output    | WIDTH (default 8)  | Stored data                |

## Files
- `maincode.v` — register design (module `register`).
- `testbench.v` — self-checking testbench (module `register_tb`).

## Running the simulation (Icarus Verilog)
```
iverilog -g2005 -o sim.out maincode.v testbench.v
vvp sim.out
```

## Expected output
```
At time 20 rst=0 load=1 data_in=01010101 data_out=01010101
At time 30 rst=0 load=1 data_in=10101010 data_out=10101010
At time 40 rst=0 load=1 data_in=11111111 data_out=11111111
At time 50 rst=1 load=1 data_in=11111111 data_out=00000000
TEST PASSED
```
