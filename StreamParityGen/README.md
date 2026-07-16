# Stream Parity Generator

## Objective
Design a circuit that continuously computes the parity of the last 8 bits of a serial stream, using a Verilog `function`.

## Description
On every rising edge, `serial_in` is shifted into an 8-bit shift register (`shift_reg`). The output `parity_out`
equals the XOR of the current 8 bits (running parity).

## Ports
| Signal      | Direction | Width | Description                     |
|-------------|-----------|-------|-----------------------------------|
| clk         | input     | 1     | Clock                              |
| reset       | input     | 1     | Clears the shift register          |
| serial_in   | input     | 1     | Incoming bit                       |
| parity_out  | output    | 1     | Parity (XOR) of the last 8 bits    |

## Files
- `maincode.v` — design (module `stream_parity_gen`).
- `testbench.v` — self-checking testbench (module `stream_parity_gen_tb`) that runs 100 randomized cases against an independent reference.

## Running the simulation (Icarus Verilog)
```
iverilog -g2005 -o sim.out maincode.v testbench.v
vvp sim.out
```

## Expected output
```
[INFO] Starting Randomized Self-Checking Test...
[SUCCESS] TEST PASSED! 100 Random cases matched perfectly.
```
