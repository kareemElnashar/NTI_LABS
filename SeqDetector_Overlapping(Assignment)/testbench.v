`timescale 1ns/1ps

module seq_detector_overlapping_tb;

    reg clk;
    reg reset;
    reg serial_in;
    wire sequence_detected;

    seq_detector_overlapping uut (
        .clk(clk),
        .reset(reset),
        .serial_in(serial_in),
        .sequence_detected(sequence_detected)
    );

    always #5 clk = ~clk;

    initial begin
        $monitor("Time=%0t reset=%b serial_in=%b sequence_detected=%b",
                  $time, reset, serial_in, sequence_detected);
    end

    initial begin
        clk = 0;
        reset = 1;
        serial_in = 0;
        #20;
        
        @(negedge clk);
        reset = 0;
        
        @(negedge clk); serial_in = 1;
        @(negedge clk); serial_in = 1;
        @(negedge clk); serial_in = 0;
        @(negedge clk); serial_in = 1;
        @(negedge clk); serial_in = 0;
        @(negedge clk); serial_in = 1;
        
        @(negedge clk); serial_in = 1;
        @(negedge clk); serial_in = 0;
        @(negedge clk); serial_in = 1;
        @(negedge clk); serial_in = 0;
        @(negedge clk); serial_in = 1;
        
        @(negedge clk); serial_in = 0;
        @(negedge clk); serial_in = 0;
        
        #50;
        $finish;
    end

endmodule