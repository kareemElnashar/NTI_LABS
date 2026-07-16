`timescale 1ns / 1ps

module alu_tb;

    parameter WIDTH = 8;

    reg  [WIDTH-1:0] in_a;
    reg  [WIDTH-1:0] in_b;
    reg  [2:0]       opcode;
    wire [WIDTH-1:0] alu_out;
    wire             a_is_zero;

    alu #(
        .WIDTH(WIDTH)
    ) dut (
        .in_a      (in_a),
        .in_b      (in_b),
        .opcode    (opcode),
        .alu_out   (alu_out),
        .a_is_zero (a_is_zero)
    );

    task check;
        input [WIDTH-1:0] exp_out;
        input             exp_zero;
        begin
            if (alu_out !== exp_out || a_is_zero !== exp_zero) begin
                $display("TEST FAILED");
                $display("At time %0d opcode=%b in_a=%b in_b=%b a_is_zero=%b alu_out=%b (expected zero=%b out=%b)",
                          $time, opcode, in_a, in_b, a_is_zero, alu_out, exp_zero, exp_out);
                $finish;
            end else begin
                $display("At time %0d opcode=%b in_a=%b in_b=%b a_is_zero=%b alu_out=%b",
                          $time, opcode, in_a, in_b, a_is_zero, alu_out);
            end
        end
    endtask

    initial begin
        in_a = 8'b01000010;
        in_b = 8'b10000110;

        opcode = 3'b000; #1; check(8'b01000010, 1'b0);
        opcode = 3'b001; #1; check(8'b01000010, 1'b0);
        opcode = 3'b010; #1; check(8'b11001000, 1'b0);
        opcode = 3'b011; #1; check(8'b00000010, 1'b0);
        opcode = 3'b100; #1; check(8'b11000100, 1'b0);
        opcode = 3'b101; #1; check(8'b10000110, 1'b0);
        opcode = 3'b110; #1; check(8'b01000010, 1'b0);
        opcode = 3'b111; #1; check(8'b01000010, 1'b0);

        in_a = 8'b00000000;
        opcode = 3'b111; #1; check(8'b00000000, 1'b1);

        $display("TEST PASSED");
        $finish;
    end

endmodule
