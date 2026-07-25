# Lab 8 — Single Bidirectional-Port Memory

## Objective
Practice combining **continuous** and **procedural** assignments to model memory with a
single, shared, bidirectional (`inout`) data port — the same style of interface a real SRAM
or a memory-mapped peripheral typically presents on a narrow bus.

## Description
```verilog
reg [DWIDTH-1:0] mem_array [0:(1<<AWIDTH)-1];

always @(posedge clk) begin
    if (wr)
        mem_array[addr] <= data;
end

assign data = (rd) ? mem_array[addr] : {DWIDTH{1'bz}};
```

- `mem_array` is a **memory array** — an array of `reg`s, declared as `[DWIDTH-1:0] name [0:DEPTH-1]`,
  Verilog's native way to model RAM. Its depth is `2^AWIDTH` words, sized entirely from the
  `AWIDTH` parameter (`(1<<AWIDTH)-1` computes the top address).
- **Write path (procedural, clocked):** on the rising edge of `clk`, if `wr = 1`, whatever is
  currently being driven onto `data` by the *testbench/external device* is captured into
  `mem_array[addr]`.
- **Read path (continuous, combinational):** `data` is driven out with `mem_array[addr]`
  whenever `rd = 1`; otherwise the memory releases the bus to `z` so it doesn't fight
  whatever else might be driving `data` (the same tri-state discipline as Lab 4's driver).
- Because `data` is a single `inout` wire used for *both* directions, `wr` and `rd` must
  never both be asserted at once — one side is trying to read the bus's value, the other is
  trying to drive it, and Verilog can't be a memory's read and write path on the same wire in
  the same cycle. This is why the module explicitly states "simultaneous write and read is
  not supported."

## Ports
| Signal | Direction | Width              | Description       |
|--------|-----------|--------------------|---------------------|
| clk    | input     | 1                  | Clock               |
| wr     | input     | 1                  | Write enable        |
| rd     | input     | 1                  | Read enable         |
| addr   | input     | AWIDTH (default 5) | Memory address      |
| data   | inout     | DWIDTH (default 8) | Bidirectional data port |

## Verilog concepts demonstrated
- Memory arrays (`reg [W-1:0] mem [0:D-1]`) as RAM modeling.
- `inout` ports and tri-state (`z`) bus sharing, combining `assign` (read) with a clocked
  `always` block (write) on the *same physical port*.
- Parameterized address (`AWIDTH`) and data (`DWIDTH`) widths.

## Testbench strategy
`testbench.v` uses a separate `reg rdata` wired onto `data` (`assign data = rdata;`) so it can
actively drive the bus during writes and release it (`{DWIDTH{1'bz}}`) during reads — mirroring
exactly the tri-state discipline the memory itself uses. It then:
1. Writes a unique, predictable data byte to **every** address (from `AWIDTH-1` down to `0`).
2. Reads back **every** address in the same order and compares against the expected value
   with an `expect` task (using `!==` so `x`/`z` mismatches are also caught, not just `0`/`1`).

> Note: the clock-cycle count in the testbench was increased (from 67 to 140) so the
> simulation has enough cycles to complete every write/read operation before it ends —
> with `2^5 = 32` addresses each needing two clock edges for a write and two for a read,
> the loop needs well over 128 edges to finish.

## Files
- `maincode.v` — memory design (module `memory`).
- `testbench.v` — self-checking testbench (module `memory_test`) that writes every address then reads it back and compares.

## Running the simulation (Icarus Verilog)
```
iverilog -g2005 -o sim.out maincode.v testbench.v
vvp sim.out
```
> `-g2005` matters here because the testbench declares a task named `expect`, which is a reserved keyword in SystemVerilog (2012).

## Expected output (last lines)
```
...
TEST PASSED
```
