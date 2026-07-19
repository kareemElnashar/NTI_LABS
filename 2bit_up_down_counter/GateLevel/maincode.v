module counter2 ( 
    input  clock,    
    input  reset,
    input  up,
    output [1:0] count 
);

    wire not_q0, not_q1, not_up;
    wire w1, w2, w3, w4;
    wire d0, d1;
    reg [1:0] q_reg;

    assign count = q_reg;

    not n0 (not_q0, q_reg[0]);
    not n1 (not_q1, q_reg[1]);
    not n2 (not_up, up);

    buf b0 (d0, not_q0);

    and a1 (w1, up, not_q1, q_reg[0]);
    and a2 (w2, up, q_reg[1], not_q0);
    and a3 (w3, not_up, not_q1, not_q0);
    and a4 (w4, not_up, q_reg[1], q_reg[0]);

    or  o0 (d1, w1, w2, w3, w4);

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            q_reg <= 2'b00;
        end else begin
            q_reg <= {d1, d0};
        end
    end

endmodule