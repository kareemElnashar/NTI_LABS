module sipo_reg #(parameter width = 20) (
    input wire shift_en,
    input wire serial_in,
    input wire clk,
    input wire rst_n,
    output reg [width-1:0] parallel_out
);
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        parallel_out <= 0;  
    else begin
        if (shift_en)
            parallel_out <= {parallel_out[width-2:0], serial_in};
    end
end
endmodule

module alu #(parameter inw = 8)(
    input wire [inw-1:0] in_a,
    input wire [inw-1:0] in_b,
    input wire [2:0] opcode,
    input wire alu_en,
    output reg [inw-1:0] alu_out,
    output reg a_is_zero
);
always @(*) begin
    a_is_zero = (in_a == 0) ? 1'b1 : 1'b0;
    
    if (alu_en) begin
        case(opcode)
            3'b000  : alu_out = in_a + in_b;
            3'b001  : alu_out = in_a - in_b;
            3'b010  : alu_out = in_a & in_b;
            3'b011  : alu_out = in_a ^ in_b;
            3'b100  : alu_out = in_a | in_b;
            3'b101  : alu_out = in_a;
            default : alu_out = 0;
        endcase
    end else begin
        alu_out = 0;
    end
end
endmodule

module piso_reg #(parameter WIDTH = 20) (
    input wire clk,
    input wire rst_n,
    input wire en,
    input wire [WIDTH-1:0] parallel_in,
    output reg serial_out,
    output reg [WIDTH-1:0] shift,
    output reg valid 
);
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        serial_out <= 0;
        shift <= 0;
        valid <= 0;
    end else begin
        valid <= en;
        if (en) begin
            shift <= parallel_in;
            serial_out <= parallel_in[WIDTH-1];
        end else begin
            serial_out <= shift[WIDTH-1];
            shift <= {shift[WIDTH-2:0], 1'b0};
        end
    end
end
endmodule

module ram #(parameter DATA_W = 20, parameter DEPTH = 256, parameter ADDR_WIDTH = 8) (
    input wire clk,
    input wire rst_n,
    input wire wr_en,
    input wire rd_en,
    input wire [ADDR_WIDTH-1:0] addr,
    input wire [DATA_W-1:0] din,
    output reg [DATA_W-1:0] dout,
    output reg valid
);
reg [DATA_W-1:0] mem [0:DEPTH-1];
integer i;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        valid <= 0;
        for (i = 0; i < DEPTH; i = i + 1)
            mem[i] <= 0;
    end else begin
        if (wr_en) begin
            mem[addr] <= din;
            valid <= 0;
        end else if (rd_en) begin
            valid <= 1;
            dout <= mem[addr];
        end else begin
            valid <= 0;
        end
    end
end
endmodule

module top_module #(parameter ADDR_WIDTH = 8, parameter DATA_W = 20, parameter inw = 8)(
    input wire clock,
    input wire rst_n,
    input wire wr_en,
    input wire rd_en,
    input wire [ADDR_WIDTH-1:0] addr,
    input wire [DATA_W-1:0] din,
    output wire [inw-1:0] alu_out,
    output wire a_is_zero
);
wire valid;
wire [DATA_W-1:0] parallel_out;
wire [DATA_W-1:0] dout;
wire serial_data_wire;
ram ramm (
    .clk(clock),
    .rst_n(rst_n),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .addr(addr),
    .din(din),
    .dout(dout),
    .valid(valid)
);
piso_reg piso (
    .clk(clock),
    .rst_n(rst_n),
    .en(rd_en),
    .parallel_in(dout),
    .serial_out(serial_data_wire),
    .shift(),
    .valid()
);
sipo_reg sipo ( 
    .clk(clock),
    .rst_n(rst_n),
    .shift_en(valid),
    .serial_in(serial_data_wire),
    .parallel_out(parallel_out)
);
alu aluu (
    .in_a(parallel_out[7:0]),
    .in_b(parallel_out[15:8]),
    .opcode(parallel_out[18:16]),
    .alu_en(parallel_out[19]),
    .alu_out(alu_out),
    .a_is_zero(a_is_zero)
);
endmodule
