# TopModule — RAM + PISO/SIPO Serializer + ALU Pipeline

## Objective
Integrate several previously-built blocks (a memory, two shift registers, and an ALU) into a
single system (`top_module`) and verify the *integration*, not just each block in isolation —
this is the capstone/system-level lab of the set, pulling together memory design (Lab 8),
shift registers, and the ALU (Lab 5) into one data path.

## The five modules in `maincode.v`

### 1) `sipo_reg` — Serial-In / Parallel-Out shift register
```verilog
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)      parallel_out <= 0;
    else if (shift_en)
        parallel_out <= {parallel_out[width-2:0], serial_in};
end
```
Shifts one new bit into the LSB position every cycle `shift_en` is high, discarding the oldest
bit off the top — after `width` cycles of shifting, `parallel_out` holds the full reconstructed
word. Reset here is **active-low** (`rst_n`, `negedge rst_n`), unlike most other labs in this
set which use active-high reset — worth double-checking when wiring it into a larger system.

### 2) `alu` — 8-bit ALU with an enable
```verilog
always @(*) begin
    a_is_zero = (in_a == 0);
    if (alu_en) begin
        case (opcode)
            3'b000: alu_out = in_a + in_b;
            3'b001: alu_out = in_a - in_b;
            3'b010: alu_out = in_a & in_b;
            3'b011: alu_out = in_a ^ in_b;
            3'b100: alu_out = in_a | in_b;
            3'b101: alu_out = in_a;
            default: alu_out = 0;
        endcase
    end else alu_out = 0;
end
```
Similar in spirit to Lab 5's ALU, but with a different opcode table (ADD/SUB/AND/XOR/OR/PASS)
and an explicit `alu_en` gate — when disabled, `alu_out` is forced to `0` regardless of opcode.

### 3) `piso_reg` — Parallel-In / Serial-Out shift register
```verilog
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin serial_out<=0; shift<=0; valid<=0; end
    else begin
        valid <= en;
        if (en) begin
            shift <= parallel_in;
            serial_out <= parallel_in[WIDTH-1];
        end else begin
            serial_out <= shift[WIDTH-1];
            shift <= {shift[WIDTH-2:0], 1'b0};
        end
    end
end
```
When `en = 1`, it captures a fresh parallel word and immediately outputs its MSB. When
`en = 0`, it should shift the *stored* word out one bit at a time, MSB-first, each cycle.
(See **Findings** below — this behavior has a one-cycle bug that affects everything downstream.)

### 4) `ram` — synchronous read/write memory
```verilog
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin ... end
    else if (wr_en)      mem[addr] <= din;
    else if (rd_en) begin valid <= 1; dout <= mem[addr]; end
    else valid <= 0;
end
```
A simple parametrized-depth memory: writes are immediate (registered on the write edge);
reads have **one cycle of latency** — `rd_en` is asserted, and `dout`/`valid` only reflect the
read data on the *following* clock edge.

### 5) `top_module` — wires the four blocks together
```
din -> ram (write) -> ram (read, 1-cycle latency) -> piso_reg (parallel->serial)
     -> serial_data_wire -> sipo_reg (serial->parallel) -> parallel_out
     -> split into {alu_en, opcode, in_b, in_a} -> alu -> alu_out / a_is_zero
```
`parallel_out` bit layout consumed by the ALU:
| Bits    | Field    |
|---------|----------|
| [19]    | alu_en   |
| [18:16] | opcode   |
| [15:8]  | in_b     |
| [7:0]   | in_a     |

So a full 20-bit "instruction word" is written into RAM once, and the rest of the pipeline's
job is purely mechanical: pull it back out of RAM, serialize it through `piso_reg`, deserialize
it again through `sipo_reg`, and feed the reconstructed word straight into the ALU.

## Files
- `maincode.v` — all five modules (`sipo_reg`, `alu`, `piso_reg`, `ram`, `top_module`), exactly
  as provided; **unmodified** by this documentation/organization pass.
- `testbench.v` — self-checking testbench with two parts:
  1. **Unit tests** for `alu`, `ram`, `sipo_reg`, and `piso_reg` in isolation — each block gets
     its own dedicated instance, clock, and stimulus, and is checked against manually
     worked-out expected values (see `test_alu`, `test_ram`, `test_sipo`, `test_piso`).
  2. **Integration test** (`test_top`) for `top_module`: writes one full instruction word to
     RAM, triggers a read, lets the pipeline run, and checks the word survives the full round
     trip (`uut_top.parallel_out === t_din`) and that the ALU produces the correct result.

## Verification methodology
The testbench follows a bottom-up verification strategy: prove each block works correctly in
complete isolation *first* (unit tests), and only then test the fully wired-together system
(integration test). This matters here specifically because it's what made it possible to
localize the two bugs below to their exact root cause — the `piso_reg` unit test fails on its
own, well before the integration test even runs, which immediately narrows the search instead
of just seeing "the whole system doesn't work."

## Running the simulation (Icarus Verilog)
```
iverilog -g2005 -o sim.out maincode.v testbench.v
vvp sim.out
```
Current result: **22 of 34 checks pass** (the 12 failures are fully accounted for by the two
issues below — every ALU-only and RAM-only check passes; the failures are concentrated in the
`piso_reg` unit test and the `top_module` integration test).

## Findings from verification (please read before relying on this design)
Running the testbench surfaced two real timing bugs. `maincode.v` was left untouched (this
task was only to add/organize/document the lab, not redesign it), but they're documented here
in full since they directly matter for the graduation-project verification stage this lab
feeds into.

**1) `piso_reg` duplicates its first output bit.**
Right after a parallel load (`en=1`), `serial_out` is set to the loaded word's MSB. On the
very next cycle, if `en` drops to `0`, the shift branch runs `serial_out <= shift[WIDTH-1]` —
but `shift` hasn't advanced yet on that same edge (nonblocking assignments in the *previous*
cycle only take effect *after* that edge), so the *same* MSB is emitted a second time before
the register actually starts advancing through the rest of the word. Every bit after that is
shifted out one position later than it should be — confirmed directly in `test_piso`, which
fails starting at bit #1.
→ *Fix idea:* on the transition cycle, drive `serial_out` from the shifted value (e.g. compute
the shift combinationally instead of sequentially, or emit the first bit only during the load
cycle itself and start the "else" shifting branch from the second bit onward).

**2) `sipo_reg.shift_en` and `piso_reg.en` are wired to conflicting signals in `top_module`.**
`sipo_reg`'s `shift_en` is tied to `ram.valid`, which is only `1` while `rd_en` is asserted.
But `piso_reg` only *shifts new bits out* while its own `en` (tied directly to `rd_en`) is
`0` — while `rd_en` is high, `piso_reg` just keeps re-loading the same word instead of shifting
it out. So the two enables can never both be active at the right time, and `parallel_out` never
fully reconstructs the original word — confirmed in the integration test: only the first
couple of bits get captured, the rest of `parallel_out` stays at its reset value, and the
downstream ALU result is therefore also wrong.
→ *Fix idea:* generate a dedicated one-cycle "load" pulse for `piso_reg.en` (e.g. from
`ram.valid`'s rising edge) and drive `sipo_reg.shift_en` from a separate "transfer in
progress" signal (e.g. a small counter/FSM) that stays high for the whole `WIDTH`-cycle
shift-out window, independent of `rd_en`.

Happy to help patch `maincode.v` for either of these if you'd like — just say the word.
