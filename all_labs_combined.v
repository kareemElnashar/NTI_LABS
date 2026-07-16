module driver #(parameter WIDTH = 8)(
input wire [WIDTH-1:0] data_in,
input wire data_en,
output wire [WIDTH-1:0] data_out
);
assign data_out = (data_en == 1'b1) ? data_in : {WIDTH{1'bz}};
endmodule
`timescale 1ns / 1ps

module driver_tb;

    parameter WIDTH = 8;

    reg  [WIDTH-1:0] data_in;
    reg              data_en;
    wire [WIDTH-1:0] data_out;

    driver #(
        .WIDTH(WIDTH)
    ) dut (
        .data_in  (data_in),
        .data_en  (data_en),
        .data_out (data_out)
    );

    task check;
        input [WIDTH-1:0] exp_out;
        begin
            if (data_out !== exp_out) begin
                $display("TEST FAILED");
                $display("At time %0d data_en=%b data_in=%b data_out=%b (expected %b)",
                          $time, data_en, data_in, data_out, exp_out);
                $finish;
            end else begin
                $display("At time %0d data_en=%b data_in=%b data_out=%b",
                          $time, data_en, data_in, data_out);
            end
        end
    endtask

    initial begin
        data_en = 1'b0;
        data_in = {WIDTH{1'bx}};
        #1;  check({WIDTH{1'bz}});

        data_en = 1'b1;
        data_in = 8'b01010101;
        #1;  check(8'b01010101);

        data_in = 8'b10101010;
        #1;  check(8'b10101010);

        $display("TEST PASSED");
        $finish;
    end

endmodule

module alu #(parameter WIDTH = 8)(
input wire [WIDTH-1:0] in_a,
input wire [WIDTH-1:0] in_b,
input wire [2:0] opcode,
output reg [WIDTH-1:0] alu_out,
output wire a_is_zero
);
assign a_is_zero = (in_a == 0) ? 1'b1 : 1'b0;
always @(*) begin
case(opcode)
3'b000: alu_out = in_a;
3'b001: alu_out = in_a;
3'b010: alu_out = in_a + in_b;
3'b011: alu_out = in_a & in_b;
3'b100: alu_out = in_a ^ in_b;
3'b101: alu_out = in_b;
3'b110: alu_out = in_a;
3'b111: alu_out = in_a;
default: alu_out = 0;
endcase
end
endmodule
`timescale 1ns / 1ps

module alu_tb;

    parameter WIDTH = 8;

    reg  [WIDTH-1:0] in_a;
    reg  [WIDTH-1:0] in_b;
    reg  [2:0]       opcode;
    wire [WIDTH-1:0] alu_out;
    wire             a_is_zero;

    alu #(
        .WIDTH(WIDTH)
    ) dut (
        .in_a      (in_a),
        .in_b      (in_b),
        .opcode    (opcode),
        .alu_out   (alu_out),
        .a_is_zero (a_is_zero)
    );

    task check;
        input [WIDTH-1:0] exp_out;
        input             exp_zero;
        begin
            if (alu_out !== exp_out || a_is_zero !== exp_zero) begin
                $display("TEST FAILED");
                $display("At time %0d opcode=%b in_a=%b in_b=%b a_is_zero=%b alu_out=%b (expected zero=%b out=%b)",
                          $time, opcode, in_a, in_b, a_is_zero, alu_out, exp_zero, exp_out);
                $finish;
            end else begin
                $display("At time %0d opcode=%b in_a=%b in_b=%b a_is_zero=%b alu_out=%b",
                          $time, opcode, in_a, in_b, a_is_zero, alu_out);
            end
        end
    endtask

    initial begin
        in_a = 8'b01000010;
        in_b = 8'b10000110;

        opcode = 3'b000; #1; check(8'b01000010, 1'b0);
        opcode = 3'b001; #1; check(8'b01000010, 1'b0);
        opcode = 3'b010; #1; check(8'b11001000, 1'b0);
        opcode = 3'b011; #1; check(8'b00000010, 1'b0);
        opcode = 3'b100; #1; check(8'b11000100, 1'b0);
        opcode = 3'b101; #1; check(8'b10000110, 1'b0);
        opcode = 3'b110; #1; check(8'b01000010, 1'b0);
        opcode = 3'b111; #1; check(8'b01000010, 1'b0);

        in_a = 8'b00000000;
        opcode = 3'b111; #1; check(8'b00000000, 1'b1);

        $display("TEST PASSED");
        $finish;
    end

endmodule

module control(
    input clk,
    input rst,
    input zero,
    input [2:0] phase,
    input [2:0] opcode,
    output reg sel,
    output reg rd,
    output reg ld_ir,
    output reg halt,
    output reg inc_pc,
    output reg ld_ac,
    output reg ld_pc,
    output reg wr,
    output reg data_e
);

    reg alu_op;

    always @(*) begin

        if (opcode == 3'b010 || opcode == 3'b011 || opcode == 3'b100 || opcode == 3'b101)
            alu_op = 1;
        else
            alu_op = 0;
    end

    always @(posedge clk) begin
        if (rst == 1) begin

            sel <= 0; rd <= 0; ld_ir <= 0; halt <= 0; inc_pc <= 0; ld_ac <= 0; ld_pc <= 0; wr <= 0; data_e <= 0;
        end
        else begin

            sel <= 0; rd <= 0; ld_ir <= 0; halt <= 0; inc_pc <= 0; ld_ac <= 0; ld_pc <= 0; wr <= 0; data_e <= 0;

            case (phase)
                3'b000: begin
                    sel <= 1;
                end

                3'b001: begin
                    sel <= 1;
                    rd  <= 1;
                end

                3'b010: begin
                    sel   <= 1;
                    rd    <= 1;
                    ld_ir <= 1;
                end

                3'b011: begin
                    sel   <= 1;
                    rd    <= 1;
                    ld_ir <= 1;
                end

                3'b100: begin
                    inc_pc <= 1;
                    if (opcode == 3'b000) halt <= 1;
                end

                3'b101: begin
                    rd <= alu_op;
                end

                3'b110: begin
                    rd <= alu_op;
                    if (opcode == 3'b001 && zero == 1) inc_pc <= 1;
                    if (opcode == 3'b111) ld_pc <= 1;
                    if (opcode == 3'b110) data_e <= 1;
                end

                3'b111: begin
                    rd    <= alu_op;
                    ld_ac <= alu_op;
                    if (opcode == 3'b111) ld_pc  <= 1;
                    if (opcode == 3'b110) begin
                        wr     <= 1;
                        data_e <= 1;
                    end
                end

                default: begin
                    sel <= 0; rd <= 0; ld_ir <= 0; halt <= 0; inc_pc <= 0; ld_ac <= 0; ld_pc <= 0; wr <= 0; data_e <= 0;
                end
            endcase
        end
    end
endmodule

`timescale 1ns / 1ps

module controller_tb;

    localparam HLT = 3'b000;
    localparam SKZ = 3'b001;
    localparam ADD = 3'b010;
    localparam AND = 3'b011;
    localparam XOR = 3'b100;
    localparam LDA = 3'b101;
    localparam STO = 3'b110;
    localparam JMP = 3'b111;

    reg       clk;
    reg       rst;
    reg       zero;
    reg [2:0] phase;
    reg [2:0] opcode;

    wire sel, rd, ld_ir, halt, inc_pc, ld_ac, ld_pc, wr, data_e;

    control dut (
        .clk    (clk),
        .rst    (rst),
        .zero   (zero),
        .phase  (phase),
        .opcode (opcode),
        .sel    (sel),
        .rd     (rd),
        .ld_ir  (ld_ir),
        .halt   (halt),
        .inc_pc (inc_pc),
        .ld_ac  (ld_ac),
        .ld_pc  (ld_pc),
        .wr     (wr),
        .data_e (data_e)
    );

    always #5 clk = ~clk;

    reg exp_sel, exp_rd, exp_ld_ir, exp_halt, exp_inc_pc, exp_ld_ac, exp_ld_pc, exp_wr, exp_data_e;
    reg alu_op;

    task compute_expected;
        input [2:0] op;
        input [2:0] ph;
        input       z;
        begin
            alu_op = (op == ADD || op == AND || op == XOR || op == LDA);
            exp_sel = 0; exp_rd = 0; exp_ld_ir = 0; exp_halt = 0; exp_inc_pc = 0;
            exp_ld_ac = 0; exp_ld_pc = 0; exp_wr = 0; exp_data_e = 0;
            case (ph)
                3'b000: begin exp_sel = 1; end
                3'b001: begin exp_sel = 1; exp_rd = 1; end
                3'b010: begin exp_sel = 1; exp_rd = 1; exp_ld_ir = 1; end
                3'b011: begin exp_sel = 1; exp_rd = 1; exp_ld_ir = 1; end
                3'b100: begin
                    exp_inc_pc = 1;
                    if (op == HLT) exp_halt = 1;
                end
                3'b101: begin exp_rd = alu_op; end
                3'b110: begin
                    exp_rd = alu_op;
                    if (op == SKZ && z) exp_inc_pc = 1;
                    if (op == JMP)      exp_ld_pc  = 1;
                    if (op == STO)      exp_data_e = 1;
                end
                3'b111: begin
                    exp_rd = alu_op;
                    exp_ld_ac = alu_op;
                    if (op == JMP) exp_ld_pc = 1;
                    if (op == STO) begin exp_wr = 1; exp_data_e = 1; end
                end
            endcase
        end
    endtask

    task check;
        begin
            if (sel !== exp_sel || rd !== exp_rd || ld_ir !== exp_ld_ir || halt !== exp_halt ||
                inc_pc !== exp_inc_pc || ld_ac !== exp_ld_ac || ld_pc !== exp_ld_pc ||
                wr !== exp_wr || data_e !== exp_data_e) begin
                $display("TEST FAILED");
                $display("At time %0d opcode=%b phase=%b : sel=%b rd=%b ld_ir=%b halt=%b inc_pc=%b ld_ac=%b ld_pc=%b wr=%b data_e=%b",
                          $time, opcode, phase, sel, rd, ld_ir, halt, inc_pc, ld_ac, ld_pc, wr, data_e);
                $display("Expected                              : sel=%b rd=%b ld_ir=%b halt=%b inc_pc=%b ld_ac=%b ld_pc=%b wr=%b data_e=%b",
                          exp_sel, exp_rd, exp_ld_ir, exp_halt, exp_inc_pc, exp_ld_ac, exp_ld_pc, exp_wr, exp_data_e);
                $finish;
            end
        end
    endtask

    task print_opcode_name;
        input [2:0] op;
        begin
            case (op)
                HLT: $write("HLT");
                SKZ: $write("SKZ");
                ADD: $write("ADD");
                AND: $write("AND");
                XOR: $write("XOR");
                LDA: $write("LDA");
                STO: $write("STO");
                JMP: $write("JMP");
            endcase
        end
    endtask

    integer op_i, ph_i;

    initial begin
        clk = 0; rst = 1; zero = 0; phase = 0; opcode = 0;
        @(negedge clk);
        rst = 0;

        for (op_i = 0; op_i < 8; op_i = op_i + 1) begin
            $write("Testing opcode ");
            print_opcode_name(op_i[2:0]);
            $write(" phase ");
            for (ph_i = 0; ph_i < 8; ph_i = ph_i + 1) begin
                opcode = op_i[2:0];
                phase  = ph_i[2:0];
                zero   = (op_i[2:0] == SKZ) ? 1'b1 : 1'b0;
                @(posedge clk);
                #1;
                compute_expected(opcode, phase, zero);
                check;
                $write("%0d ", ph_i);
            end
            $display(" ");
        end

        $display("TEST PASSED");
        $finish;
    end

endmodule

module register #(parameter WIDTH=8)(
input wire clk,
input wire rst,
input wire load,
input wire [WIDTH-1:0] data_in,
output reg [WIDTH-1:0] data_out
);
always @(posedge clk) begin
if(rst==1'b1) begin
data_out<=0;
end
else if(load==1'b1) begin
data_out<=data_in;
end
end
endmodule

`timescale 1ns / 1ps

module register_tb;

    parameter WIDTH = 8;

    reg              clk;
    reg              rst;
    reg              load;
    reg  [WIDTH-1:0] data_in;
    wire [WIDTH-1:0] data_out;

    register #(
        .WIDTH(WIDTH)
    ) dut (
        .clk      (clk),
        .rst      (rst),
        .load     (load),
        .data_in  (data_in),
        .data_out (data_out)
    );

    always #5 clk = ~clk;

    task check;
        input [WIDTH-1:0] exp_out;
        begin
            if (data_out !== exp_out) begin
                $display("TEST FAILED");
                $display("At time %0d rst=%b load=%b data_in=%b data_out=%b (expected %b)",
                          $time, rst, load, data_in, data_out, exp_out);
                $finish;
            end else begin
                $display("At time %0d rst=%b load=%b data_in=%b data_out=%b",
                          $time, rst, load, data_in, data_out);
            end
        end
    endtask

    initial begin
        clk = 0;
        rst = 0;
        load = 0;
        data_in = 0;

        #10;
        rst = 0; load = 1; data_in = 8'b01010101;
        #10; check(8'b01010101);

        data_in = 8'b10101010;
        #10; check(8'b10101010);

        data_in = 8'b11111111;
        #10; check(8'b11111111);

        rst = 1;
        #10; check(8'b00000000);

        $display("TEST PASSED");
        $finish;
    end

endmodule

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
`timescale 1ns/100ps

module memory_test;

  localparam integer AWIDTH=5;
  localparam integer DWIDTH=8;

  reg               clk   ;
  reg               wr    ;
  reg               rd    ;
  reg  [AWIDTH-1:0] addr  ;
  wire [DWIDTH-1:0] data  ;
  reg  [DWIDTH-1:0] rdata ;

  assign data=rdata;

  memory
  #(
    .AWIDTH ( AWIDTH ),
    .DWIDTH ( DWIDTH )
   )
  memory_inst
   (
    .clk  ( clk  ),
    .wr   ( wr   ),
    .rd   ( rd   ),
    .addr ( addr ),
    .data ( data )
   );

  task expect;
    input [DWIDTH-1:0] exp_data;
    if (data !== exp_data) begin
      $display("TEST FAILED");
      $display("At time %0d addr=%b data=%b", $time, addr, data);
      $display("data should be %b", exp_data);
      $finish;
    end
    else begin
      $timeformat(-9, 0,"ns", 4);
      $display("%t addr=%b, exp_data= %b, data=%b", $time, addr, exp_data, data);
   end
  endtask

  task write;
    input [AWIDTH-1:0] waddr;
    input [DWIDTH-1:0] wdata;
    begin
      @(negedge clk);
      addr = waddr;
      rdata = wdata;
      wr = 1'b1;
      rd = 1'b0;
      @(negedge clk);
      wr = 1'b0;
      rdata = {DWIDTH{1'bz}};
    end
  endtask

  task read;
    input [AWIDTH-1:0] raddr;
    input [DWIDTH-1:0] exp_data;
    begin
      @(negedge clk);
      addr = raddr;
      rdata = {DWIDTH{1'bz}};
      wr = 1'b0;
      rd = 1'b1;
      @(negedge clk);
      expect(exp_data);
      rd = 1'b0;
    end
  endtask

  initial repeat (140) begin #5 clk=1; #5 clk=0; end

  initial @(negedge clk) begin : TEST
    reg [AWIDTH-1:0] addr;
    reg [DWIDTH-1:0] data;

    addr=-1; data=0;
    while ( addr ) begin
      write(addr,data);
      addr=addr-1;
      data=data+1;
    end
    addr=-1; data=0;
    while ( addr ) begin
      read(addr,data);
      addr=addr-1;
      data=data+1;
    end
    $display("TEST PASSED");
    $finish;
  end

endmodule
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
`timescale 1ns / 1ps

module counter_tb;

    parameter WIDTH = 5;

    reg clk;
    reg rst;
    reg load;
    reg enab;
    reg [WIDTH-1:0] cnt_in;
    wire [WIDTH-1:0] cnt_out;

    counter #(
        .WIDTH(WIDTH)
    ) dut (
        .clk(clk),
        .rst(rst),
        .load(load),
        .enab(enab),
        .cnt_in(cnt_in),
        .cnt_out(cnt_out)
    );

    always #5 clk = ~clk;

    task drive_and_check;
        input t_rst;
        input t_load;
        input t_enab;
        input [WIDTH-1:0] t_cnt_in;
        input [WIDTH-1:0] exp_out;
        begin
            rst = t_rst;
            load = t_load;
            enab = t_enab;
            cnt_in = t_cnt_in;
            #10;
            if (cnt_out !== exp_out) begin
                $display("TEST FAILED");
                $finish;
            end else begin
                $display("At time %0d rst=%b load=%b enab=%b cnt_in=%b cnt_out=%b", $time, rst, load, enab, cnt_in, cnt_out);
            end
        end
    endtask

    initial begin
        clk = 0;
        rst = 0;
        load = 0;
        enab = 0;
        cnt_in = 0;

        #10;

        drive_and_check(0, 1, 1, 5'b10101, 5'b10101);
        drive_and_check(0, 1, 1, 5'b01010, 5'b01010);
        drive_and_check(0, 1, 1, 5'b11111, 5'b11111);
        drive_and_check(1, 1, 1, 5'b11111, 5'b00000);
        drive_and_check(0, 1, 1, 5'b11111, 5'b11111);
        drive_and_check(0, 0, 1, 5'b11111, 5'b00000);

        $display("TEST PASSED");
        $finish;
    end

endmodule
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
`timescale 1ns / 1ps

module counter_with_function_tb;

    parameter WIDTH = 5;

    reg clk;
    reg rst;
    reg load;
    reg enab;
    reg  [WIDTH-1:0] cnt_in;
    wire [WIDTH-1:0] cnt_out;

    counter_with_function #(
        .WIDTH(WIDTH)
    ) dut (
        .clk     (clk),
        .rst     (rst),
        .load    (load),
        .enab    (enab),
        .cnt_in  (cnt_in),
        .cnt_out (cnt_out)
    );

    always #5 clk = ~clk;

    task drive_and_check;
        input t_rst;
        input t_load;
        input t_enab;
        input [WIDTH-1:0] t_cnt_in;
        input [WIDTH-1:0] exp_out;
        begin
            rst = t_rst;
            load = t_load;
            enab = t_enab;
            cnt_in = t_cnt_in;
            #10;
            if (cnt_out !== exp_out) begin
                $display("TEST FAILED");
                $finish;
            end else begin
                $display("At time %0d rst=%b load=%b enab=%b cnt_in=%b cnt_out=%b", $time, rst, load, enab, cnt_in, cnt_out);
            end
        end
    endtask

    initial begin
        clk = 0;
        rst = 0;
        load = 0;
        enab = 0;
        cnt_in = 0;

        #10;

        drive_and_check(0, 1, 1, 5'b10101, 5'b10101);
        drive_and_check(0, 1, 1, 5'b01010, 5'b01010);
        drive_and_check(0, 1, 1, 5'b11111, 5'b11111);
        drive_and_check(1, 1, 1, 5'b11111, 5'b00000);
        drive_and_check(0, 1, 1, 5'b11111, 5'b11111);
        drive_and_check(0, 0, 1, 5'b11111, 5'b00000);

        $display("TEST PASSED");
        $finish;
    end

endmodule

module multiplexor #(parameter WIDTH=5)(
input wire [WIDTH-1:0] in0,
input wire [WIDTH-1:0] in1,
input wire sel,
output wire [WIDTH-1:0] mux_out
);
assign mux_out = (sel == 1'b1) ? in1 : in0;
endmodule

`timescale 1ns / 1ps

module multiplexor_tb;

    parameter WIDTH = 5;

    reg  [WIDTH-1:0] in0;
    reg  [WIDTH-1:0] in1;
    reg              sel;
    wire [WIDTH-1:0] mux_out;

    multiplexor #(
        .WIDTH(WIDTH)
    ) dut (
        .in0     (in0),
        .in1     (in1),
        .sel     (sel),
        .mux_out (mux_out)
    );

    task check;
        input [WIDTH-1:0] exp_out;
        begin
            if (mux_out !== exp_out) begin
                $display("TEST FAILED");
                $display("At time %0d sel=%b in0=%b in1=%b mux_out=%b (expected %b)",
                          $time, sel, in0, in1, mux_out, exp_out);
                $finish;
            end else begin
                $display("At time %0d sel=%b in0=%b in1=%b mux_out=%b", $time, sel, in0, in1, mux_out);
            end
        end
    endtask

    initial begin
        in0 = 5'b00001; in1 = 5'b11110;

        sel = 1'b0; #1; check(5'b00001);
        sel = 1'b1; #1; check(5'b11110);

        in0 = 5'b10101; in1 = 5'b01010;

        sel = 1'b0; #1; check(5'b10101);
        sel = 1'b1; #1; check(5'b01010);

        $display("TEST PASSED");
        $finish;
    end

endmodule

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
`timescale 1ns / 1ps

module stream_parity_gen_tb;

    reg clk;
    reg reset;
    reg serial_in;
    wire parity_out;

    stream_parity_gen dut (
        .clk(clk),
        .reset(reset),
        .serial_in(serial_in),
        .parity_out(parity_out)
    );

    always #5 clk = ~clk;

    reg [7:0] expected_shift_reg;
    wire expected_parity;

    assign expected_parity = ^expected_shift_reg;

    always @(posedge clk) begin
        if (reset)
            expected_shift_reg <= 8'b0000_0000;
        else
            expected_shift_reg <= {expected_shift_reg[6:0], serial_in};
    end

    always @(negedge clk) begin
        if (!reset) begin
            if (parity_out !== expected_parity) begin
                $display("\n[ERROR]  Mismatch at time %0t!", $time);
                $display("Shift Reg = %b, Added Bit = %b", expected_shift_reg, serial_in);
                $display("Expected Parity = %b | DUT Parity = %b", expected_parity, parity_out);
                $stop;
            end
        end
    end

    integer i;

    initial begin
        clk = 0;
        reset = 1;
        serial_in = 0;

        #15;
        reset = 0;

        $display("\n[INFO] Starting Randomized Self-Checking Test...");

        for (i = 0; i < 100; i = i + 1) begin
            @(negedge clk);
            serial_in = $random % 2;
        end

        #20;

        $display("\n[SUCCESS] TEST PASSED! 100 Random cases matched perfectly.");
        $finish;
    end

endmodule
