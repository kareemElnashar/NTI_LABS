`timescale 1ns / 1ps

module driver_tb;

    parameter WIDTH = 8;

    reg  [WIDTH-1:0] data_in;
    reg              data_en;
    wire [WIDTH-1:0] data_out;

    driver #(
        .WIDTH(WIDTH)
    ) dut (
        .data_in  (data_in),
        .data_en  (data_en),
        .data_out (data_out)
    );

    task check;
        input [WIDTH-1:0] exp_out;
        begin
            if (data_out !== exp_out) begin
                $display("TEST FAILED");
                $display("At time %0d data_en=%b data_in=%b data_out=%b (expected %b)",
                          $time, data_en, data_in, data_out, exp_out);
                $finish;
            end else begin
                $display("At time %0d data_en=%b data_in=%b data_out=%b",
                          $time, data_en, data_in, data_out);
            end
        end
    endtask

    initial begin
        data_en = 1'b0;
        data_in = {WIDTH{1'bx}};
        #1;  check({WIDTH{1'bz}});

        data_en = 1'b1;
        data_in = 8'b01010101;
        #1;  check(8'b01010101);

        data_in = 8'b10101010;
        #1;  check(8'b10101010);

        $display("TEST PASSED");
        $finish;
    end

endmodule
