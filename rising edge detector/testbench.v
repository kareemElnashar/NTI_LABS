`timescale 1ns/1ps

module edge_detector_tb;

reg clk;
reg reset;
reg level;

wire tick_moore;
wire tick_mealy;

edge_detector_moore U1(
    .clk(clk),
    .reset(reset),
    .level(level),
    .tick(tick_moore)
);

edge_detector_mealy U2(
    .clk(clk),
    .reset(reset),
    .level(level),
    .tick(tick_mealy)
);

always #5 clk = ~clk;

initial begin
    $monitor("t=%0t reset=%b level=%b tick_moore=%b tick_mealy=%b",
              $time, reset, level, tick_moore, tick_mealy);
end

initial
begin
    clk = 0;
    reset = 1;
    level = 0;

    #12;
    reset = 0;

    #7;
    level = 1;

    #30;
    level = 0;

    #20;
    level = 1;

    #30;
    level = 0;

    #20;
    $finish;
end

endmodule
