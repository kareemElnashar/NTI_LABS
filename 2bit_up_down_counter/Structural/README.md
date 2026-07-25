# 2-Bit Up/Down Counter — Structural Style

> Part of the [2-Bit Up/Down Counter — Three Design Styles](../README.md) exercise.
> See the parent README for the shared functional spec, next-state equation derivation,
> and testbench strategy.

## Description
Instead of one `always` block describing the whole counter, the design is built from a
reusable `dff` (D flip-flop) module, instantiated **twice** — once per count bit — and
wired together at the structural level with continuous assignments.

```verilog
assign d0 = ~count[0];
assign d1 = count[1] ^ (up ^ ~count[0]);

dff ff0 ( .clk(clock), .rst(reset), .d(d0), .q(count[0]) );
dff ff1 ( .clk(clock), .rst(reset), .d(d1), .q(count[1]) );
```

`d0` and `d1` are the next-state equations derived for the counter (see the parent README
for the derivation). Each `dff` instance is a self-contained, independently-reusable flip-flop
with its own asynchronous active-high reset — the counter itself contains **no** clocked logic
of its own; all sequential behavior lives inside `dff`, and `counter2` is purely a netlist of
combinational glue (`assign`) plus two component instances.

## Submodule: `dff`
A single-bit D flip-flop with asynchronous active-high reset:
```verilog
always @(posedge clk or posedge rst) begin
    if (rst) q <= 1'b0;
    else     q <= d;
end
```
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
| count  | output    | 2     | Current counter value (count[0] = ff0.q, count[1] = ff1.q) |

## Verilog concepts demonstrated
- **Module instantiation** (`dff ff0 (...)`, `dff ff1 (...)`) — hierarchical/structural design,
  where a bigger module is built by wiring together instances of a smaller one.
- Named port connections (`.clk(clock)`, `.d(d0)`, ...) rather than positional.
- Splitting a design into pure combinational glue (`assign`) plus pure sequential
  building blocks (`dff`), which mirrors how a synthesis tool actually maps RTL onto gates
  and flip-flop cells from a standard-cell library.

## Files
- `maincode.v` — counter design (modules `dff` and `counter2`).
- `testbench.v` — self-checking testbench (module `counter_tb`), identical to the other two variants.

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
