`timescale 1ns / 1ps

module counter_with_function_tb;

    parameter WIDTH = 5;

    reg clk;
    reg rst;
    reg load;
    reg enab;
    reg  [WIDTH-1:0] cnt_in;
    wire [WIDTH-1:0] cnt_out;

    counter_with_function #(
        .WIDTH(WIDTH)
    ) dut (
        .clk     (clk),
        .rst     (rst),
        .load    (load),
        .enab    (enab),
        .cnt_in  (cnt_in),
        .cnt_out (cnt_out)
    );

    always #5 clk = ~clk;

    task drive_and_check;
        input t_rst;
        input t_load;
        input t_enab;
        input [WIDTH-1:0] t_cnt_in;
        input [WIDTH-1:0] exp_out;
        begin
            rst = t_rst;
            load = t_load;
            enab = t_enab;
            cnt_in = t_cnt_in;
            #10;
            if (cnt_out !== exp_out) begin
                $display("TEST FAILED");
                $finish;
            end else begin
                $display("At time %0d rst=%b load=%b enab=%b cnt_in=%b cnt_out=%b", $time, rst, load, enab, cnt_in, cnt_out);
            end
        end
    endtask

    initial begin
        clk = 0;
        rst = 0;
        load = 0;
        enab = 0;
        cnt_in = 0;

        #10;

        drive_and_check(0, 1, 1, 5'b10101, 5'b10101);
        drive_and_check(0, 1, 1, 5'b01010, 5'b01010);
        drive_and_check(0, 1, 1, 5'b11111, 5'b11111);
        drive_and_check(1, 1, 1, 5'b11111, 5'b00000);
        drive_and_check(0, 1, 1, 5'b11111, 5'b11111);
        drive_and_check(0, 0, 1, 5'b11111, 5'b00000);

        $display("TEST PASSED");
        $finish;
    end

endmodule
