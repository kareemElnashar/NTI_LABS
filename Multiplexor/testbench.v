`timescale 1ns / 1ps

module multiplexor_tb;

    parameter WIDTH = 5;

    reg  [WIDTH-1:0] in0;
    reg  [WIDTH-1:0] in1;
    reg              sel;
    wire [WIDTH-1:0] mux_out;

    multiplexor #(
        .WIDTH(WIDTH)
    ) dut (
        .in0     (in0),
        .in1     (in1),
        .sel     (sel),
        .mux_out (mux_out)
    );

    task check;
        input [WIDTH-1:0] exp_out;
        begin
            if (mux_out !== exp_out) begin
                $display("TEST FAILED");
                $display("At time %0d sel=%b in0=%b in1=%b mux_out=%b (expected %b)",
                          $time, sel, in0, in1, mux_out, exp_out);
                $finish;
            end else begin
                $display("At time %0d sel=%b in0=%b in1=%b mux_out=%b", $time, sel, in0, in1, mux_out);
            end
        end
    endtask

    initial begin
        in0 = 5'b00001; in1 = 5'b11110;

        sel = 1'b0; #1; check(5'b00001);
        sel = 1'b1; #1; check(5'b11110);

        in0 = 5'b10101; in1 = 5'b01010;

        sel = 1'b0; #1; check(5'b10101);
        sel = 1'b1; #1; check(5'b01010);

        $display("TEST PASSED");
        $finish;
    end

endmodule
