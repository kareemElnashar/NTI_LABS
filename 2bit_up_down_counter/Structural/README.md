# 2-Bit Up/Down Counter — Structural Style

## Description
The counter is built by instantiating two `dff` (D flip-flop) submodules, one per count bit. The next-state
value for each bit is computed with continuous assignments (`d0`, `d1`) and fed into the flip-flops, whose
outputs directly become `count[0]` and `count[1]`. Reset is asynchronous and active-high, applied to each `dff`.

## Submodule: `dff`
| Signal | Direction | Width | Description                     |
|--------|-----------|-------|------------------------------------|
| clk    | input     | 1     | Clock                              |
| rst    | input     | 1     | Asynchronous reset, active-high    |
| d      | input     | 1     | Data input                         |
| q      | output    | 1     | Registered output                  |

## Top module: `counter2`
| Signal | Direction | Width | Description                          |
|--------|-----------|-------|----------------------------------------|
| clock  | input     | 1     | Clock                                  |
| reset  | input     | 1     | Asynchronous reset, active-high        |
| up     | input     | 1     | Count direction (1 = up, 0 = down)     |
| count  | output    | 2     | Current counter value                  |

## Files
- `maincode.v` — counter design (modules `dff` and `counter2`).
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
