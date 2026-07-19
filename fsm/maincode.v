module fsm_2 (
    input wire a,
    input wire b,
    input wire clk,
    input wire reset,

    output reg y0,
    output reg y1
);

localparam S0 = 2'b00,
           S1 = 2'b01,
           S2 = 2'b10;

reg [1:0] present_state, next_state;

always @(posedge clk or negedge reset)
    if(!reset)
        present_state <= S0;
    else
        present_state <= next_state;

always @(*) begin

    next_state = present_state;
    y0 = 0;
    y1 = (present_state != S2);

    case(present_state)

        S0: begin
            y0 = a & b;
            next_state = !a ? S0 :
                         (b ? S2 : S1);
        end

        S1:
            next_state = a ? S0 : S1;

        S2:
            next_state = S0;

        default:
            next_state = S0;

    endcase

end

endmodule