# FSM — 3-State Moore/Mealy Finite State Machine

## Objective
Design a 3-state finite state machine (`fsm_2`) with two inputs that produces **both** a
Mealy-type output and a Moore-type output side by side, in the same design — a direct,
hands-on illustration of the difference between the two output styles rather than treating
them as two separate machines (contrast with the `rising edge detector` lab, which instead
compares Moore vs. Mealy by building two *entirely separate* modules for the same task).

## How it works
```verilog
always @(posedge clk or negedge reset)
    if (!reset) present_state <= S0;
    else        present_state <= next_state;

always @(*) begin
    next_state = present_state;
    y0 = 0;
    y1 = (present_state != S2);

    case (present_state)
        S0: begin
            y0 = a & b;
            next_state = !a ? S0 : (b ? S2 : S1);
        end
        S1: next_state = a ? S0 : S1;
        S2: next_state = S0;
        default: next_state = S0;
    endcase
end
```

- **`y1` is the Moore output**: it's assigned *before* the `case` statement, purely as a
  function of `present_state` (`1` in every state except `S2`) — no input (`a`/`b`) appears
  in its expression at all. A Moore output only ever changes when the state itself changes,
  i.e. on a clock edge.
- **`y0` is the Mealy output**: it's only assigned inside the `S0` branch of the `case`, as
  `a & b` — a function of *both* the current state **and** the current inputs. Because it
  depends directly on `a`/`b`, it can change **within** a state, immediately as `a` or `b`
  change, without waiting for the next clock edge — the defining trait of a Mealy output.
- Reset here is **asynchronous and active-low** (`negedge reset` in the sensitivity list,
  and `if (!reset)`): the state machine snaps back to `S0` the instant `reset` drops to `0`,
  regardless of the clock. This is the opposite polarity from most other reset signals in
  this lab set (which are active-high), so it's worth double-checking stimulus code
  carefully when reusing this module elsewhere.

### Next-state logic
| Current state | Condition        | Next state |
|----------------|-------------------|------------|
| S0             | `!a`              | S0         |
| S0             | `a & b`           | S2         |
| S0             | `a & !b`          | S1         |
| S1             | `a`               | S0         |
| S1             | `!a`              | S1         |
| S2             | (always)          | S0         |

## Ports
| Signal  | Direction | Width | Description                       |
|---------|-----------|-------|-------------------------------------|
| a       | input     | 1     | Input A                             |
| b       | input     | 1     | Input B                             |
| clk     | input     | 1     | Clock                               |
| reset   | input     | 1     | Asynchronous reset, active-low      |
| y0      | output    | 1     | Mealy output (asserted only in S0, when `a & b`) |
| y1      | output    | 1     | Moore output (1 in every state except S2) |

## Verilog concepts demonstrated
- Combining a Mealy output and a Moore output in the same FSM, so the contrast between "state
  + input dependent" vs. "state-only" outputs is visible directly in one `case` statement.
- Asynchronous, **active-low** reset (`negedge reset`), as opposed to the active-high resets
  used elsewhere in this lab set.
- Default assignments (`next_state = present_state; y0 = 0; y1 = ...;`) placed *before* the
  `case`, so every state/branch has a well-defined fallback value and no unintended latches
  are inferred.

## Testbench strategy
`testbench.v` drives `a`/`b` through a sequence of eight combinations (after an initial reset
pulse) and uses `$monitor` to print every signal on every change, so the resulting log can be
read directly as a timing trace — useful for manually verifying, cycle by cycle, that `y0`
reacts immediately within a state while `y1` only changes when `present_state` itself changes.

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
