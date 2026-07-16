module stream_parity_gen (
    input wire clk,
    input wire reset,
    input wire serial_in,
    output wire parity_out
);

    reg [7:0] shift_reg;

    function calc_parity;
        input [7:0] data_window;
        begin
            calc_parity = ^data_window;
        end
    endfunction

    always @(posedge clk)
    begin
        if (reset)
        begin
            shift_reg <= 8'b0000_0000;
        end
        else
        begin
            shift_reg <= {shift_reg[6:0], serial_in};
        end
    end

    assign parity_out = calc_parity(shift_reg);

endmodule