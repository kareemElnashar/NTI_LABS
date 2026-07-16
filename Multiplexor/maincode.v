module multiplexor #(parameter WIDTH=5)(
input wire [WIDTH-1:0] in0,
input wire [WIDTH-1:0] in1,
input wire sel,
output wire [WIDTH-1:0] mux_out
);
assign mux_out = (sel == 1'b1) ? in1 : in0;
endmodule
