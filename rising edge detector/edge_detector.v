module edge_detector_moore(
    input clk,
    input reset,
    input level,
    output reg tick
);

localparam [1:0]
    ZERO = 2'b00,
    EDG  = 2'b01,
    ONE  = 2'b10;

reg [1:0] current_state;
reg [1:0] next_state;

always @(posedge clk or posedge reset)
begin
    current_state <= reset ? ZERO : next_state;
end

always @(*)
begin
    case(current_state)
        ZERO    : next_state = level ? EDG : ZERO;
        EDG     : next_state = level ? ONE : ZERO;
        ONE     : next_state = level ? ONE : ZERO;
        default : next_state = ZERO;
    endcase
end

always @(*)
begin
    tick = (current_state == EDG) ? 1'b1 : 1'b0;
end

endmodule

module edge_detector_mealy(
    input clk,
    input reset,
    input level,
    output reg tick
);

localparam
    ZERO = 1'b0,
    ONE  = 1'b1;

reg current_state;
reg next_state;

always @(posedge clk or posedge reset)
begin
    current_state <= reset ? ZERO : next_state;
end

always @(*)
begin
    case(current_state)
        ZERO    : next_state = level ? ONE : ZERO;
        ONE     : next_state = level ? ONE : ZERO;
        default : next_state = ZERO;
    endcase
end

always @(*)
begin
    tick = (current_state == ZERO && level) ? 1'b1 : 1'b0;
end

endmodule
