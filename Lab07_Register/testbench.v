`timescale 1ns / 1ps

module register_tb;

    parameter WIDTH = 8;

    reg              clk;
    reg              rst;
    reg              load;
    reg  [WIDTH-1:0] data_in;
    wire [WIDTH-1:0] data_out;

    register #(
        .WIDTH(WIDTH)
    ) dut (
        .clk      (clk),
        .rst      (rst),
        .load     (load),
        .data_in  (data_in),
        .data_out (data_out)
    );

    always #5 clk = ~clk;

    task check;
        input [WIDTH-1:0] exp_out;
        begin
            if (data_out !== exp_out) begin
                $display("TEST FAILED");
                $display("At time %0d rst=%b load=%b data_in=%b data_out=%b (expected %b)",
                          $time, rst, load, data_in, data_out, exp_out);
                $finish;
            end else begin
                $display("At time %0d rst=%b load=%b data_in=%b data_out=%b",
                          $time, rst, load, data_in, data_out);
            end
        end
    endtask

    initial begin
        clk = 0;
        rst = 0;
        load = 0;
        data_in = 0;

        #10;
        rst = 0; load = 1; data_in = 8'b01010101;
        #10; check(8'b01010101);

        data_in = 8'b10101010;
        #10; check(8'b10101010);

        data_in = 8'b11111111;
        #10; check(8'b11111111);

        rst = 1;
        #10; check(8'b00000000);

        $display("TEST PASSED");
        $finish;
    end

endmodule
