module counter #(
    parameter WIDTH = 5
) (
    input wire clk,
    input wire rst,
    input wire load,
    input wire enab,
    input wire [WIDTH-1:0] cnt_in,
    output reg [WIDTH-1:0] cnt_out
);

    reg [WIDTH-1:0] next_cnt;

    always @(*) begin
        if (load)
            next_cnt = cnt_in;
        else if (enab)
            next_cnt = cnt_out + 1;
        else
            next_cnt = cnt_out;
    end

    always @(posedge clk or posedge rst) begin
        if (rst)
            cnt_out <= {WIDTH{1'b0}};
        else
            cnt_out <= next_cnt;
    end

endmodule