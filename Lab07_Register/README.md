# Lab 7 — Generic Register

## Objective
Practice **nonblocking assignment** (`<=`) inside sequential logic by building a simple,
generic, parameterized-width register — the kind of block that later serves as the
accumulator or instruction register inside the small CPU built up across Labs 5–6.

## Description
```verilog
always @(posedge clk) begin
    if (rst == 1'b1)
        data_out <= 0;
    else if (load == 1'b1)
        data_out <= data_in;
end
```

On every rising edge of `clk`:
- if `rst = 1`, `data_out` clears to `0`;
- else if `load = 1`, `data_out` captures `data_in`;
- else (both low), `data_out` **holds its previous value** — this is the key behavior of a
  register versus a plain wire: with neither `rst` nor `load` asserted, no assignment at all
  executes inside the `always` block for that edge, so `data_out` implicitly retains what it
  already had (Verilog's simulation semantics for a `reg` that isn't written this cycle).

Reset here is **synchronous** — it's only checked on the rising clock edge, unlike the
asynchronous-reset counters in this lab set (compare with `2bit_up_down_counter`). This
matches the intended use as a CPU register, where control signals like `rst`/`load` are
themselves generated synchronously by the controller in Lab 6.

## Ports
| Signal    | Direction | Width              | Description            |
|-----------|-----------|--------------------|--------------------------|
| clk       | input     | 1                  | Clock, rising edge       |
| rst       | input     | 1                  | Synchronous, active-high reset |
| load      | input     | 1                  | Load enable               |
| data_in   | input     | WIDTH (default 8)  | Input data                |
| data_out  | output    | WIDTH (default 8)  | Stored data                |

## Verilog concepts demonstrated
- Nonblocking assignment (`<=`) for a clocked register.
- Implicit "hold" behavior: a `reg` that isn't written on a given clock edge keeps its value.
- Synchronous, priority-ordered `if`/`else if` (reset takes priority over load).

## Testbench strategy
`testbench.v` loads three different 8-bit patterns one after another (checking `data_out`
tracks `data_in` each time `load = 1`), then asserts `rst` and checks `data_out` clears to
`0` regardless of what was previously stored.

## Files
- `maincode.v` — register design (module `register`).
- `testbench.v` — self-checking testbench (module `register_tb`).

## Running the simulation (Icarus Verilog)
```
iverilog -g2005 -o sim.out maincode.v testbench.v
vvp sim.out
```

## Expected output
```
At time 20 rst=0 load=1 data_in=01010101 data_out=01010101
At time 30 rst=0 load=1 data_in=10101010 data_out=10101010
At time 40 rst=0 load=1 data_in=11111111 data_out=11111111
At time 50 rst=1 load=1 data_in=11111111 data_out=00000000
TEST PASSED
```
