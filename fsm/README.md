# FSM — 3-State Moore/Mealy Finite State Machine

## Objective
Design a 3-state finite state machine (`fsm_2`) with two inputs, an asynchronous active-low reset, one Mealy-type
output and one Moore-type output.

## Description
The FSM has 3 states: `S0 (00)`, `S1 (01)`, `S2 (10)`.

- `y1` is a Moore output: it is 1 in every state except `S2`.
- `y0` is a Mealy output: it is only asserted (`a & b`) while the FSM is in state `S0`.

### Next-state logic
| Current state | Condition        | Next state |
|----------------|-------------------|------------|
| S0             | `!a`              | S0         |
| S0             | `a & b`           | S2         |
| S0             | `a & !b`          | S1         |
| S1             | `a`               | S0         |
| S1             | `!a`              | S1         |
| S2             | (always)          | S0         |

Reset is asynchronous and active-low: `present_state` is forced to `S0` whenever `reset = 0`, independent of the clock.

## Ports
| Signal  | Direction | Width | Description                       |
|---------|-----------|-------|-------------------------------------|
| a       | input     | 1     | Input A                             |
| b       | input     | 1     | Input B                             |
| clk     | input     | 1     | Clock                               |
| reset   | input     | 1     | Asynchronous reset, active-low      |
| y0      | output    | 1     | Mealy output (asserted only in S0)  |
| y1      | output    | 1     | Moore output (1 in every state except S2) |

## Files
- `maincode.v` — FSM design (module `fsm_2`).
- `testbench.v` — testbench that drives `a`/`b` through several input sequences and monitors the outputs (module `fsm_2_tb`).

## Running the simulation (Icarus Verilog)
```
iverilog -g2005 -o sim.out maincode.v testbench.v
vvp sim.out
```

## Expected output
```
Time=0 Reset=0 a=0 b=0 y0=0 y1=1
Time=10000 Reset=1 a=0 b=0 y0=0 y1=1
Time=20000 Reset=1 a=1 b=0 y0=0 y1=1
Time=30000 Reset=1 a=1 b=1 y0=0 y1=1
Time=35000 Reset=1 a=1 b=1 y0=1 y1=1
Time=40000 Reset=1 a=0 b=0 y0=0 y1=1
Time=50000 Reset=1 a=1 b=0 y0=0 y1=1
Time=60000 Reset=1 a=0 b=0 y0=0 y1=1
Time=70000 Reset=1 a=1 b=1 y0=0 y1=1
Time=75000 Reset=1 a=1 b=1 y0=1 y1=1
Time=80000 Reset=1 a=0 b=1 y0=0 y1=1
```
