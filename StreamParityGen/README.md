# Stream Parity Generator

## Objective
Design a circuit that continuously tracks the parity of the **most recent 8 bits** of an
incoming serial stream, using a Verilog `function` to compute the parity itself — combining
a shift register (state) with a pure combinational calculation (the function) that's re-run
every time the state changes.

## How it works
```verilog
reg [7:0] shift_reg;

function calc_parity;
    input [7:0] data_window;
    begin
        calc_parity = ^data_window;
    end
endfunction

always @(posedge clk) begin
    if (reset) shift_reg <= 8'b0000_0000;
    else       shift_reg <= {shift_reg[6:0], serial_in};
end

assign parity_out = calc_parity(shift_reg);
```

- **`shift_reg`** is an 8-bit shift register: on every rising clock edge, the oldest bit falls
  off the top (`shift_reg[7]` is discarded) and the new incoming `serial_in` bit is shifted in
  at the bottom — `{shift_reg[6:0], serial_in}` is Verilog's concatenation operator being used
  to build the new 8-bit value from the low 7 bits of the old one plus the new bit.
- **`calc_parity`** is a one-line function that reduces its 8-bit input to a single bit using
  the **reduction XOR operator** (`^data_window`), which XORs all 8 bits of the argument
  together — the result is `1` if an odd number of bits in the window are `1`, and `0` if
  an even number are.
- **`parity_out`** is a continuous assignment that calls `calc_parity(shift_reg)` — so it's
  always "live": as soon as `shift_reg` updates on a clock edge, `parity_out` recomputes
  combinationally, with no extra clock-cycle delay.

Effectively, this is a running/sliding-window parity checker: at any moment, `parity_out`
reflects the parity of whatever 8 bits have arrived most recently (with the window sliding
by one bit per clock cycle), which is the kind of block you'd use for a streaming parity
check over a continuous serial link rather than a one-shot, fixed-length message.

## Ports
| Signal      | Direction | Width | Description                     |
|-------------|-----------|-------|-------------------------------------|
| clk         | input     | 1     | Clock                              |
| reset       | input     | 1     | Clears the shift register          |
| serial_in   | input     | 1     | Incoming bit                       |
| parity_out  | output    | 1     | Parity (XOR) of the last 8 bits    |

## Verilog concepts demonstrated
- Concatenation operator (`{a, b}`) for shift-register style updates.
- Reduction XOR operator (`^vector`) for parity computation.
- A `function` used purely as a named, reusable combinational calculation (no state of its own).
- Continuous assignment that calls a function.

## Testbench strategy
This lab uses a **self-checking, randomized** testbench rather than fixed test vectors:
`testbench.v` maintains its own independent copy of the shift register (`expected_shift_reg`),
updated with the exact same shift logic as the DUT, and its own `expected_parity` derived with
the same reduction-XOR operator. On every negative clock edge it compares `parity_out` against
`expected_parity` and reports (and stops with `$stop`) on the first mismatch. The stimulus
itself is 100 pseudo-random bits (`serial_in = $random % 2`), so the test isn't relying on a
handful of hand-picked patterns — if the design is correct for *any* bit sequence, it should
survive all 100 random draws.

## Files
- `maincode.v` — design (module `stream_parity_gen`).
- `testbench.v` — self-checking testbench (module `stream_parity_gen_tb`) that runs 100 randomized cases against an independent reference.

## Running the simulation (Icarus Verilog)
```
iverilog -g2005 -o sim.out maincode.v testbench.v
vvp sim.out
```

## Expected output
```
[INFO] Starting Randomized Self-Checking Test...
[SUCCESS] TEST PASSED! 100 Random cases matched perfectly.
```
