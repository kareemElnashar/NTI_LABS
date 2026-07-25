# Sequence Detector — "110101" (Overlapping, Moore FSM)

## Objective
Design a Moore-type finite state machine that detects the bit sequence `110101` arriving one
bit per clock on a serial line, correctly handling **overlapping** matches — i.e. the tail end
of one detected occurrence can also serve as the beginning of the next one, rather than
forcing the FSM back to `S0` after every match.

## How it works
The design uses the standard two-block FSM pattern: a sequential block that latches
`next_state` into `current_state` on every rising edge (with asynchronous active-high reset
back to `S0`), and a combinational block that computes `next_state` from `current_state` and
`serial_in` via a `case` statement. A third, separate combinational block drives the Moore
output `sequence_detected` — asserted for exactly one clock cycle whenever `current_state`
equals `S6`, which is only reachable right after the six bits `1,1,0,1,0,1` have been shifted
in, one per state transition: `S0 →(1)→ S1 →(1)→ S2 →(0)→ S3 →(1)→ S4 →(0)→ S5 →(1)→ S6`.

### Why overlapping works
The key design decision is what `S6` does on receiving another `1`: instead of falling back
to `S0` (which would force the FSM to restart the search from scratch), it goes to **`S2`** —
the same state reached after consuming exactly `"11"` from `S0`. This is legal because the
bit that just triggered the `S6 → S2` transition, together with the final `1` of the just-
completed match, forms exactly the two-bit prefix `"11"` that a fresh search would need to
have already seen. In other words, the FSM never "forgets" progress it has already made
toward the next match — that's precisely what makes overlapping detection possible.

### State transition table
| State | serial_in=0 → | serial_in=1 → |
|-------|----------------|----------------|
| S0    | S0             | S1             |
| S1    | S0             | S2             |
| S2    | S3             | S2             |
| S3    | S0             | S4             |
| S4    | S5             | S2             |
| S5    | S0             | S6             |
| S6    | S0             | S2             |

`sequence_detected = 1` only in `S6`; it is `0` in every other state.

## Ports
| Signal             | Direction | Width | Description                            |
|---------------------|-----------|-------|--------------------------------------------|
| clk                 | input     | 1     | Clock                                    |
| reset               | input     | 1     | Asynchronous reset, active-high          |
| serial_in           | input     | 1     | Incoming serial bit                      |
| sequence_detected   | output    | 1     | 1 for one cycle when "110101" is detected |

## Verilog concepts demonstrated
- Two-`always`-block Moore FSM: sequential state register + combinational next-state logic
  + combinational output logic (three separate `always` blocks, each with one job).
- `localparam` used to give symbolic names (`S0`..`S6`) to the state encoding, instead of
  scattering raw binary literals through the `case` statement.
- Overlap-aware FSM design — a common technique for serial pattern/protocol detectors.

## Testbench strategy
`testbench.v` uses `$monitor` to print every signal on every change, and drives 13 bits total:
`1,1,0,1,0,1,1,0,1,0,1,0,0`. Bits 1–6 form the first occurrence of `110101`; bits 6–11 (note
bit 6 is shared/reused) form a **second, overlapping** occurrence — this is deliberately
constructed so the expected log shows `sequence_detected` pulsing high **twice**, proving the
overlap logic actually works rather than just checking a single isolated match.

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
