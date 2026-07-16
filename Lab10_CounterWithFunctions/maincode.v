module counter_with_function #(
    parameter WIDTH = 5
) (
    input wire clk,
    input wire rst,
    input wire load,
    input wire enab,
    input wire [WIDTH-1:0] cnt_in,
    output reg [WIDTH-1:0] cnt_out
);

    function [WIDTH-1:0] get_next_count;
        input load_val;
        input enab_val;
        input [WIDTH-1:0] in_val;
        input [WIDTH-1:0] current_val;
        begin
            if (load_val)
                get_next_count = in_val;
            else if (enab_val)
                get_next_count = current_val + 1;
            else
                get_next_count = current_val;
        end
    endfunction

    always @(posedge clk or posedge rst) begin
        if (rst)
            cnt_out <= {WIDTH{1'b0}};
        else
            cnt_out <= get_next_count(load, enab, cnt_in, cnt_out);
    end

endmodule