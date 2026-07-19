module dff (
    input  clk,
    input  rst,
    input  d,
    output reg q
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            q <= 1'b0;
        end else begin
            q <= d;
        end
    end
endmodule

module counter2 ( 
    input  clock,    
    input  reset,
    input  up,
    output [1:0] count 
);

    wire d0, d1;

    assign d0 = ~count[0];
    assign d1 = count[1] ^ (up ^ ~count[0]);

    dff ff0 (
        .clk(clock),
        .rst(reset),
        .d(d0),
        .q(count[0])
    );

    dff ff1 (
        .clk(clock),
        .rst(reset),
        .d(d1),
        .q(count[1])
    );

endmodule