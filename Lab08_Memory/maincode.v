module memory #(
    parameter AWIDTH = 5,
    parameter DWIDTH = 8
) (
    input wire clk,
    input wire wr,
    input wire rd,
    input wire [AWIDTH-1:0] addr,
    inout wire [DWIDTH-1:0] data
);

    reg [DWIDTH-1:0] mem_array [0:(1<<AWIDTH)-1];

    always @(posedge clk) begin
        if (wr) begin
            mem_array[addr] <= data;
        end
    end

    assign data = (rd) ? mem_array[addr] : {DWIDTH{1'bz}};

endmodule