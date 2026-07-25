# Lab 10 — Counter Using Functions

## Objective
Practice encapsulating combinational logic inside a Verilog **`function`**, using Lab 9's
counter as the starting point — same interface, same behavior, but the "what's the next
value?" logic is refactored out of the `always` block and into a reusable function.

## Description
```verilog
function [WIDTH-1:0] get_next_count;
    input load_val;
    input enab_val;
    input [WIDTH-1:0] in_val;
    input [WIDTH-1:0] current_val;
    begin
        if (load_val)      get_next_count = in_val;
        else if (enab_val) get_next_count = current_val + 1;
        else               get_next_count = current_val;
    end
endfunction

always @(posedge clk or posedge rst) begin
    if (rst) cnt_out <= {WIDTH{1'b0}};
    else     cnt_out <= get_next_count(load, enab, cnt_in, cnt_out);
end
```

Compare directly with Lab 9: the priority logic (`load` > `enab` > hold) is *identical*, but
instead of living inside its own combinational `always @(*)` block with an intermediate
`next_cnt` signal, it's packaged as a **function** — `get_next_count` — that takes the
relevant signals as explicit arguments and *returns* the next value. The sequential block
then simply calls the function directly inside the nonblocking assignment.

### Function vs. separate combinational block
This is functionally 100% equivalent to Lab 9 (same testbench, same expected output), but
it's a different way of *organizing* the same logic:
- A **function** always executes instantaneously (zero simulation time), takes explicit
  inputs, and returns a single value — much like a function in software. It's automatically
  combinational; there's no need for a separate `always @(*)` block or an intermediate wire.
- It naturally documents the *inputs the next-state logic actually depends on* (the function's
  argument list), rather than relying on an implicit sensitivity list.
- It's directly reusable: the same `get_next_count` logic could be called from more than one
  place in a larger design without duplicating the `if`/`else if` chain.

## Ports
| Signal    | Direction | Width              | Description             |
|-----------|-----------|--------------------|---------------------------|
| clk       | input     | 1                  | Clock                     |
| rst       | input     | 1                  | Reset, active-high        |
| load      | input     | 1                  | Load a new value          |
| enab      | input     | 1                  | Count enable              |
| cnt_in    | input     | WIDTH (default 5)  | Value to load             |
| cnt_out   | output    | WIDTH (default 5)  | Current counter value     |

## Verilog concepts demonstrated
- `function` declaration with a return width (`function [WIDTH-1:0] name;`) and multiple
  `input` arguments.
- Calling a function directly from inside a procedural (nonblocking) assignment.
- Refactoring identical behavior between two different Verilog coding styles (Lab 9 vs. Lab 10)
  while keeping the module's external interface and testbench unchanged.

## Testbench strategy
Identical stimulus to Lab 9 — the whole point of this lab is that the *interface and
behavior* haven't changed, only the internal implementation style has, so the same test
sequence should produce the same pass/fail result.

## Files
- `maincode.v` — counter design using a function (module `counter_with_function`).
- `testbench.v` — same stimulus as Lab 9 (module `counter_with_function_tb`).

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
