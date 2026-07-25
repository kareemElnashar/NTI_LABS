# 2-Bit Up/Down Counter — Behavioral Style

> Part of the [2-Bit Up/Down Counter — Three Design Styles](../README.md) exercise.
> See the parent README for the shared functional spec and testbench strategy.

## Description
The counter is described with a single clocked `always` block — pure "RTL" style, the way
most real Verilog is written day-to-day. On every rising edge of `clock`:
- if `reset` is asserted, `count` is cleared to `2'b00`;
- otherwise, `count` is incremented (`up = 1`) or decremented (`up = 0`) using the built-in
  `+` / `-` arithmetic operators, with nonblocking assignment (`<=`) so the update happens
  as a proper registered (flip-flop) transition rather than an immediate variable write.

`reset` is listed in the sensitivity list (`posedge clock or posedge reset`), which is what
makes it **asynchronous**: the block re-evaluates the instant `reset` rises, without waiting
for a clock edge.

```verilog
always @(posedge clock or posedge reset) begin
    if (reset)
        count <= 2'b00;
    else if (up)
        count <= count + 1'b1;
    else
        count <= count - 1'b1;
end
```

Because `count` is only 2 bits wide, `count + 1` and `count - 1` wrap around automatically
under 2-bit modular arithmetic (`11 + 1 = 00`, `00 - 1 = 11`) — no explicit wraparound logic
is needed.

## Ports
| Signal | Direction | Width | Description                          |
|--------|-----------|-------|----------------------------------------|
| clock  | input     | 1     | Clock                                  |
| reset  | input     | 1     | Asynchronous reset, active-high        |
| up     | input     | 1     | Count direction (1 = up, 0 = down)     |
| count  | output    | 2     | Current counter value                  |

## Verilog concepts demonstrated
- Clocked `always` block with an asynchronous reset in the sensitivity list.
- Nonblocking assignment (`<=`) for sequential logic.
- Implicit wraparound from fixed-width unsigned arithmetic.

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
