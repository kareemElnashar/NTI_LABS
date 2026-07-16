# Lab 4 — Data Driver (Tri-State Bus Driver)

## Objective
Use Verilog literal values to build a parameterized-width tri-state bus driver.

## Description
`data_out` equals `data_in` when `data_en = 1`, and goes high-impedance (`z`) when `data_en = 0`.

## Ports
| Signal    | Direction | Width              | Description                     |
|-----------|-----------|--------------------|----------------------------------|
| data_in   | input     | WIDTH (default 8)  | Input data                       |
| data_en   | input     | 1                  | Output enable                    |
| data_out  | output    | WIDTH (default 8)  | Output data, or Z when disabled  |

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
