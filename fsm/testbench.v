`timescale 1ns/1ps

module fsm_2_tb;

reg a;
reg b;
reg clk;
reg reset;

wire y0;
wire y1;

fsm_2 uut(
    .a(a),
    .b(b),
    .clk(clk),
    .reset(reset),
    .y0(y0),
    .y1(y1)
);

always #5 clk = ~clk;

initial begin

    clk = 0;
    reset = 0;
    a = 0;
    b = 0;

    #10;
    reset = 1;

    a = 0; b = 0;
    #10;

    a = 1; b = 0;
    #10;

    a = 1; b = 1;
    #10;

    a = 0; b = 0;
    #10;

    a = 1; b = 0;
    #10;

    a = 0; b = 0;
    #10;

    a = 1; b = 1;
    #10;

    a = 0; b = 1;
    #10;

    $finish;

end

initial begin
    $monitor("Time=%0t Reset=%b a=%b b=%b y0=%b y1=%b",
              $time, reset, a, b, y0, y1);
end

endmodule