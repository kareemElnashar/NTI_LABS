# 2-Bit Up/Down Counter — Gate-Level Style

## Description
The counter's next-state logic is built entirely from Verilog primitive gates (`and`, `or`, `not`, `buf`) instead
of behavioral arithmetic. The resulting next-state bits (`d1`, `d0`) are latched into an internal register on
every rising clock edge, with asynchronous active-high reset.

## Ports
| Signal | Direction | Width | Description                          |
|--------|-----------|-------|----------------------------------------|
| clock  | input     | 1     | Clock                                  |
| reset  | input     | 1     | Asynchronous reset, active-high        |
| up     | input     | 1     | Count direction (1 = up, 0 = down)     |
| count  | output    | 2     | Current counter value                  |

## Files
- `maincode.v` — counter design (module `counter2`), built from primitive gate instances.
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
