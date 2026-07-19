# Sequence Detector — "110101" (Overlapping, Moore FSM)

## Objective
Design a Moore-type FSM that detects the bit sequence `110101` in a serial input stream, allowing overlapping
matches (i.e. the last bits of one match can be reused as the start of the next).

## Description
A 7-state Moore machine (`S0`...`S6`) shifts through states as `serial_in` bits arrive on each clock edge.
`sequence_detected` is asserted (Moore output, depends only on state) for one clock cycle whenever the FSM
reaches `S6`, i.e. right after the full pattern `110101` has been shifted in. Because several states loop back
on receiving a `1` instead of resetting to `S0`, overlapping occurrences of the pattern are correctly detected.
Reset is asynchronous and active-high.

## State transition table
| State | serial_in=0 → | serial_in=1 → |
|-------|----------------|----------------|
| S0    | S0             | S1             |
| S1    | S0             | S2             |
| S2    | S3             | S2             |
| S3    | S0             | S4             |
| S4    | S5             | S2             |
| S5    | S0             | S6             |
| S6    | S0             | S2             |

`sequence_detected = 1` only in `S6`.

## Ports
| Signal             | Direction | Width | Description                            |
|---------------------|-----------|-------|------------------------------------------|
| clk                 | input     | 1     | Clock                                    |
| reset               | input     | 1     | Asynchronous reset, active-high          |
| serial_in           | input     | 1     | Incoming serial bit                      |
| sequence_detected   | output    | 1     | 1 for one cycle when "110101" is detected |

## Files
- `maincode.v` — FSM design (module `seq_detector_overlapping`).
- `testbench.v` — testbench that drives two back-to-back (overlapping) occurrences of `110101` and monitors the output (module `seq_detector_overlapping_tb`).

## Running the simulation (Icarus Verilog)
```
iverilog -g2005 -o sim.out maincode.v testbench.v
vvp sim.out
```

## Expected output
```
Time=0 reset=1 serial_in=0 sequence_detected=0
Time=20000 reset=0 serial_in=0 sequence_detected=0
Time=30000 reset=0 serial_in=1 sequence_detected=0
Time=50000 reset=0 serial_in=0 sequence_detected=0
Time=60000 reset=0 serial_in=1 sequence_detected=0
Time=70000 reset=0 serial_in=0 sequence_detected=0
Time=80000 reset=0 serial_in=1 sequence_detected=0
Time=85000 reset=0 serial_in=1 sequence_detected=1
Time=95000 reset=0 serial_in=1 sequence_detected=0
Time=100000 reset=0 serial_in=0 sequence_detected=0
Time=110000 reset=0 serial_in=1 sequence_detected=0
Time=120000 reset=0 serial_in=0 sequence_detected=0
Time=130000 reset=0 serial_in=1 sequence_detected=0
Time=135000 reset=0 serial_in=1 sequence_detected=1
Time=140000 reset=0 serial_in=0 sequence_detected=1
Time=145000 reset=0 serial_in=0 sequence_detected=0
```
