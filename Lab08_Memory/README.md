# Lab 8 — Single Bidirectional-Port Memory

## Objective
Use continuous and procedural assignments to model a memory with a single bidirectional (inout) data port.

## Description
Data is written into memory when `wr = 1` on the rising clock edge, and read out (combinationally, through the
inout port) when `rd = 1`. Simultaneous write and read is not supported.

## Ports
| Signal | Direction | Width              | Description       |
|--------|-----------|--------------------|---------------------|
| clk    | input     | 1                  | Clock               |
| wr     | input     | 1                  | Write enable        |
| rd     | input     | 1                  | Read enable         |
| addr   | input     | AWIDTH (default 5) | Memory address      |
| data   | inout     | DWIDTH (default 8) | Data port           |

## Files
- `maincode.v` — memory design (module `memory`).
- `testbench.v` — self-checking testbench (module `memory_test`) that writes every address then reads it back and compares.

> Note: the clock-cycle count in the testbench was increased (from 67 to 140) so the simulation has enough
> cycles to complete every write/read operation before it ends.

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
