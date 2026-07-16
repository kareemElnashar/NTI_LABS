# NTI Verilog Labs — Index

Each folder contains:
- `maincode.v` — the design code (main code).
- `testbench.v` — the matching testbench.
- `README.md` — a short description of the lab, its ports, and how to run it.

| Folder | Lab |
|---|---|
| Lab04_Driver | Data Driver (Tri-State) |
| Lab05_ALU | Arithmetic Logic Unit |
| Lab06_Controller | VeriRISC Controller |
| Lab07_Register | Generic Register |
| Lab08_Memory | Single Bidirectional-Port Memory |
| Lab09_Counter | Generic Counter |
| Lab10_CounterWithFunctions | Counter Using Functions |
| Multiplexor | 2:1 Multiplexer |
| StreamParityGen | Stream Parity Generator |

## Running any lab (Icarus Verilog)
```
cd <LabFolder>
iverilog -g2005 -o sim.out maincode.v testbench.v
vvp sim.out
```
