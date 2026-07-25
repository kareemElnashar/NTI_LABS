# Rising Edge Detector — Moore vs. Mealy

## Objective
Detect a rising edge (a `0 → 1` transition) on an input signal `level` and pulse `tick` high
for exactly one clock cycle — implemented **twice**, once as a Moore FSM and once as a Mealy
FSM, as two independent modules instantiated side by side in the same testbench, so the
one-cycle timing difference between the two styles is directly visible in the simulation log.

## How it works

### `edge_detector_moore` — 3 states
```verilog
localparam [1:0] ZERO = 2'b00, EDG = 2'b01, ONE = 2'b10;

always @(posedge clk or posedge reset)
    current_state <= reset ? ZERO : next_state;

always @(*)
    case (current_state)
        ZERO: next_state = level ? EDG : ZERO;
        EDG:  next_state = level ? ONE : ZERO;
        ONE:  next_state = level ? ONE : ZERO;
    endcase

always @(*)
    tick = (current_state == EDG) ? 1'b1 : 1'b0;
```
This needs a dedicated third state, `EDG`, purely to "remember" that a rising edge just
happened. `tick` depends **only** on `current_state`, which is the definition of a Moore
output — so it can only become `1` on the cycle *after* the FSM has already moved into `EDG`,
i.e. one full clock cycle after `level` actually rose.

### `edge_detector_mealy` — 2 states
```verilog
localparam ZERO = 1'b0, ONE = 1'b1;

always @(posedge clk or posedge reset)
    current_state <= reset ? ZERO : next_state;

always @(*)
    case (current_state)
        ZERO: next_state = level ? ONE : ZERO;
        ONE:  next_state = level ? ONE : ZERO;
    endcase

always @(*)
    tick = (current_state == ZERO && level) ? 1'b1 : 1'b0;
```
Only 2 states are needed, because `tick` here depends on **both** `current_state` **and**
`level` directly (`current_state == ZERO && level`) — the definition of a Mealy output. There's
no need for an intermediate "just saw the edge" state: the moment `level` rises while still in
`ZERO`, `tick` goes high combinationally, in the *same* cycle as the transition.

## Moore vs. Mealy — the key timing difference
- **Mealy**: `tick` reacts combinationally to `level` while in state `ZERO`, so it asserts in
  the *same* cycle `level` rises — but this also means, in general, a Mealy output can react
  purely combinationally to a *glitch* on the input, without waiting for a clock edge.
- **Moore**: `tick` only depends on being in the intermediate `EDG` state, so it asserts one
  clock cycle *after* `level` rises. Moore outputs are always glitch-free with respect to the
  input (since they only change on a clock edge), at the cost of that one extra cycle of
  latency — this lab makes that one-cycle lag directly observable, since both FSMs run against
  the exact same `level` stimulus.

## Ports (both modules)
| Signal | Direction | Width | Description                     |
|--------|-----------|-------|----------------------------------|
| clk    | input     | 1     | Clock                            |
| reset  | input     | 1     | Asynchronous reset, active-high  |
| level  | input     | 1     | Input signal to monitor          |
| tick   | output    | 1     | 1-cycle pulse on rising edge     |

## Verilog concepts demonstrated
- Two independent FSMs (different state counts, different output-generation style) placed in
  one file and compared directly against identical stimulus.
- `localparam [1:0]` for explicit multi-bit state encoding vs. a plain single-bit `localparam`.
- Moore output (state-only) vs. Mealy output (state + input) — the central concept of the lab.

## Testbench strategy
`testbench.v` instantiates **both** `edge_detector_moore` and `edge_detector_mealy` against
the exact same `clk`/`reset`/`level` signals, and uses `$monitor` to print `tick_moore` and
`tick_mealy` together on every change. This makes the one-cycle Moore-vs-Mealy lag visible by
direct comparison in a single log, rather than requiring two separate simulation runs.

## Files
- `edge_detector.v` — both FSMs in a single file:
  - `edge_detector_moore` — 3 states (`ZERO`, `EDG`, `ONE`); `tick` depends only on the current
    state, so it fires one cycle *after* the edge is registered.
  - `edge_detector_mealy` — 2 states (`ZERO`, `ONE`); `tick` depends on the current state
    **and** the input, so it fires on the *same* cycle the edge occurs.
- `testbench.v` — instantiates both modules side by side against the same `clk`/`reset`/`level`
  stimulus so the timing difference between the two styles is visible directly in the log.

## Running the simulation (Icarus Verilog)
```
iverilog -g2005 -o sim.out edge_detector.v testbench.v
vvp sim.out
```

## Expected output (excerpt)
```
t=69000 reset=0 level=1 tick_moore=0 tick_mealy=1
t=75000 reset=0 level=1 tick_moore=1 tick_mealy=0
t=85000 reset=0 level=1 tick_moore=0 tick_mealy=0
t=99000 reset=0 level=0 tick_moore=0 tick_mealy=0
```
Note `tick_mealy` pulses the same cycle `level` rises, while `tick_moore` pulses one cycle later.
