# 2-Bit Up/Down Counter — Behavioral Style

## Description
The counter is described directly with a clocked `always` block: on every rising edge of `clock`, `count`
increments (`up = 1`) or decrements (`up = 0`) by one. Reset is asynchronous and active-high.

## Ports
| Signal | Direction | Width | Description                          |
|--------|-----------|-------|----------------------------------------|
| clock  | input     | 1     | Clock                                  |
| reset  | input     | 1     | Asynchronous reset, active-high        |
| up     | input     | 1     | Count direction (1 = up, 0 = down)     |
| count  | output    | 2     | Current counter value                  |

## Files
- `maincode.v` — counter design (module `counter2`).
- `testbench.v` — self-checking testbench (module `counter_tb`).

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
