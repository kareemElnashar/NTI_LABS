`timescale 1ns/1ps

module counter_tb;

    reg clock;
    reg reset;
    reg up;
    wire [1:0] count;

    counter2 uut (
        .clock(clock),
        .reset(reset),
        .up(up),
        .count(count)
    );

    always #5 clock = ~clock;

    function [1:0] get_expected_count(input [1:0] current, input up_dir);
        begin
            if (up_dir)
                get_expected_count = current + 1'b1;
            else
                get_expected_count = current - 1'b1;
        end
    endfunction

    task run_test_cycles(input dir, input integer cycles);
        integer i;
        reg [1:0] expected;
        begin
            up = dir;
            for (i = 0; i < cycles; i = i + 1) begin
                expected = get_expected_count(count, up);
                @(posedge clock);
                #1; 
                $display("Time: %0t | Reset: %b | Up: %b | Count: %b | Expected: %b", 
                         $time, reset, up, count, expected);
                
                if (count !== expected && !reset) begin
                    $display(">>> ERROR: Output Mismatch Found!");
                end
            end
        end
    endtask

    initial begin
        clock = 0;
        reset = 0;
        up = 0;
        
        $display("\n--- Checking Asynchronous Reset Behavior ---");
        #3;
        reset = 1;
        #5;
        if (count !== 2'b00) $display(">>> ERROR: Counter failed to clear on Reset.");
        #12;
        reset = 0;
        
        $display("\n--- Executing Count Up Sequence ---");
        run_test_cycles(1'b1, 5);

        $display("\n--- Executing Count Down Sequence ---");
        run_test_cycles(1'b0, 5);

        $display("\n--- Executing Mid-cycle Asynchronous Reset ---");
        run_test_cycles(1'b1, 2);
        #2;
        reset = 1; 
        #2;
        if (count !== 2'b00) $display(">>> ERROR: Asynchronous reset failed mid-cycle.");
        #10;
        reset = 0;
        
        run_test_cycles(1'b1, 2);

        $display("\n--- Simulation Successfully Finished ---");
        $finish;
    end

endmodule