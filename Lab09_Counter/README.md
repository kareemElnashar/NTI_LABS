# Lab 9 — Generic Counter

## Objective
Practice the difference between **blocking** (`=`) and **nonblocking** (`<=`) assignment by
splitting a counter's behavior into two separate procedures: a combinational "what should
happen next" block and a sequential "commit it on the clock edge" block. This generic
loadable counter later serves as the program counter / phase counter for the CPU built up in
Labs 5–6.

## Description
```verilog
always @(*) begin
    if (load)      next_cnt = cnt_in;
    else if (enab) next_cnt = cnt_out + 1;
    else           next_cnt = cnt_out;
end

always @(posedge clk or posedge rst) begin
    if (rst) cnt_out <= {WIDTH{1'b0}};
    else     cnt_out <= next_cnt;
end
```

- The **first block** is purely combinational (`always @(*)`), using **blocking** assignment
  (`=`), and computes `next_cnt` — what the counter's value *should become* — based on
  `load`/`enab`/`cnt_in`/current `cnt_out`. It has no memory of its own; it's pure logic.
- The **second block** is sequential (`always @(posedge clk or posedge rst)`), using
  **nonblocking** assignment (`<=`), and is the only place `cnt_out` (a real register) is
  ever written. It simply commits whatever `next_cnt` currently evaluates to, on every rising
  clock edge — or clears to 0 asynchronously on `rst`.
- Priority order, from highest to lowest: **reset** (asynchronous, wins immediately) →
  **load** (synchronous, wins over counting) → **enable/count** → **hold** (neither load nor
  enable: `next_cnt = cnt_out`, i.e. stay put).

This two-block "combinational next-state / sequential state register" split is the standard
Verilog idiom for FSMs and counters — separating *what the next value is* from *when it
actually gets latched* makes the design easier to reason about (and easier to extend, e.g.
Lab 10 replaces only the combinational block with a function call).

## Ports
| Signal    | Direction | Width              | Description             |
|-----------|-----------|--------------------|---------------------------|
| clk       | input     | 1                  | Clock                     |
| rst       | input     | 1                  | Asynchronous reset, active-high |
| load      | input     | 1                  | Load a new value          |
| enab      | input     | 1                  | Count enable              |
| cnt_in    | input     | WIDTH (default 5)  | Value to load             |
| cnt_out   | output    | WIDTH (default 5)  | Current counter value     |

## Verilog concepts demonstrated
- Splitting next-state logic (combinational, blocking `=`) from state storage
  (sequential, nonblocking `<=`) — the standard two-`always`-block FSM/counter pattern.
- Priority-encoded control (`rst` > `load` > `enab` > hold) via nested `if`/`else if`.
- Asynchronous reset combined with synchronous load/count.

## Testbench strategy
`testbench.v` drives (`rst`, `load`, `enab`, `cnt_in`) through a fixed sequence of scenarios —
successive loads with different patterns, a mid-sequence reset, and a plain "hold" case
(`load=0, enab=0`) — checking `cnt_out` after each with a `drive_and_check` task, and stops
immediately (`$finish`) on the first mismatch.

## Files
- `maincode.v` — counter design (module `counter`).
- `testbench.v` — self-checking testbench (module `counter_tb`).

## Running the simulation (Icarus Verilog)
```
iverilog -g2005 -o sim.out maincode.v testbench.v
vvp sim.out
```

## Expected output
```
At time 20 rst=0 load=1 enab=1 cnt_in=10101 cnt_out=10101
At time 30 rst=0 load=1 enab=1 cnt_in=01010 cnt_out=01010
At time 40 rst=0 load=1 enab=1 cnt_in=11111 cnt_out=11111
At time 50 rst=1 load=1 enab=1 cnt_in=11111 cnt_out=00000
At time 60 rst=0 load=1 enab=1 cnt_in=11111 cnt_out=11111
At time 70 rst=0 load=0 enab=1 cnt_in=11111 cnt_out=00000
TEST PASSED
```
