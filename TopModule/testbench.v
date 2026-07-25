`timescale 1ns/1ps

module tb_top_lab;

    integer errors = 0;
    integer tests  = 0;

    task check(input cond, input [1023:0] msg);
    begin
        tests = tests + 1;
        if (!cond) begin
            errors = errors + 1;
            $display("  [FAIL] %0s", msg);
        end else begin
            $display("  [PASS] %0s", msg);
        end
    end
    endtask

    reg  [7:0] a_in_a, a_in_b;
    reg  [2:0] a_opcode;
    reg        a_en;
    wire [7:0] a_out;
    wire       a_zero;

    alu #(.inw(8)) uut_alu (
        .in_a(a_in_a), .in_b(a_in_b), .opcode(a_opcode),
        .alu_en(a_en), .alu_out(a_out), .a_is_zero(a_zero)
    );

    task test_alu;
    begin
        $display("\n-- ALU unit test --");
        a_in_a = 8'd12; a_in_b = 8'd5; a_en = 1;
        a_opcode = 3'b000; #1; check(a_out == 8'd17, "ADD 12+5=17");
        a_opcode = 3'b001; #1; check(a_out == 8'd7,  "SUB 12-5=7");
        a_opcode = 3'b010; #1; check(a_out == (12&5), "AND 12&5");
        a_opcode = 3'b011; #1; check(a_out == (12^5), "XOR 12^5");
        a_opcode = 3'b100; #1; check(a_out == (12|5), "OR  12|5");
        a_opcode = 3'b101; #1; check(a_out == 12,      "PASS in_a");
        a_en = 0;          #1; check(a_out == 0,       "alu_en=0 forces alu_out=0");
        a_in_a = 0; a_en = 1; a_opcode = 3'b000; #1; check(a_zero == 1'b1, "a_is_zero flags in_a==0");
    end
    endtask

    reg         r_clk, r_rst_n, r_wr, r_rd;
    reg  [7:0]  r_addr;
    reg  [19:0] r_din;
    wire [19:0] r_dout;
    wire        r_valid;

    ram #(.DATA_W(20), .DEPTH(256), .ADDR_WIDTH(8)) uut_ram (
        .clk(r_clk), .rst_n(r_rst_n), .wr_en(r_wr), .rd_en(r_rd),
        .addr(r_addr), .din(r_din), .dout(r_dout), .valid(r_valid)
    );
    always #5 r_clk = ~r_clk;

    task test_ram;
    begin
        $display("\n-- RAM unit test --");
        r_clk = 0; r_rst_n = 0; r_wr = 0; r_rd = 0; r_addr = 0; r_din = 0;
        #12; r_rst_n = 1;
        @(negedge r_clk);
        r_addr = 8'd42; r_din = 20'h ABCDE; r_wr = 1;
        @(negedge r_clk);
        r_wr = 0;
        check(r_valid == 1'b0, "valid low right after a write");
        r_addr = 8'd42; r_rd = 1;
        @(negedge r_clk);
        check(r_dout == 20'hABCDE && r_valid == 1'b1, "read back written word at addr 42");
        r_rd = 0;
        @(negedge r_clk);
        check(r_valid == 1'b0, "valid drops one cycle after rd_en deasserted");
    end
    endtask

    reg  s_clk, s_rst_n, s_en, s_in;
    wire [19:0] s_out;

    sipo_reg #(.width(20)) uut_sipo (
        .shift_en(s_en), .serial_in(s_in), .clk(s_clk), .rst_n(s_rst_n), .parallel_out(s_out)
    );
    always #5 s_clk = ~s_clk;

    task test_sipo;
        integer i;
        reg [19:0] pattern;
    begin
        $display("\n-- SIPO unit test --");
        pattern = 20'b1100_1010_0000_1111_0101;
        s_clk = 0; s_rst_n = 0; s_en = 0; s_in = 0;
        #12; s_rst_n = 1;
        for (i = 19; i >= 0; i = i - 1) begin
            @(negedge s_clk);
            s_en = 1; s_in = pattern[i];
        end
        @(negedge s_clk); s_en = 0;
        check(s_out == pattern, "20 serial bits shifted in match source pattern");
    end
    endtask

    reg  p_clk, p_rst_n, p_en;
    reg  [19:0] p_pin;
    wire p_sout;
    wire [19:0] p_shift;

    piso_reg #(.WIDTH(20)) uut_piso (
        .clk(p_clk), .rst_n(p_rst_n), .en(p_en), .parallel_in(p_pin),
        .serial_out(p_sout), .shift(p_shift), .valid()
    );
    always #5 p_clk = ~p_clk;

    task test_piso;
        integer i;
        reg [19:0] pattern;
        reg [1023:0] msg;
    begin
        $display("\n-- PISO unit test --");
        pattern = 20'b1010_0000_1111_0101_0011;
        p_clk = 0; p_rst_n = 0; p_en = 0; p_pin = 0;
        #12; p_rst_n = 1;
        @(negedge p_clk);
        p_pin = pattern; p_en = 1;
        @(negedge p_clk);
        check(p_shift == pattern, "PISO loads parallel_in correctly");
        p_en = 0;
        for (i = 1; i <= 19; i = i + 1) begin
            $sformat(msg, "bit #%0d : serial_out=%b expected=%b", i, p_sout, pattern[20-i]);
            check(p_sout == pattern[20-i], msg);
            @(negedge p_clk);
        end
    end
    endtask

    reg         t_clk, t_rst_n, t_wr, t_rd;
    reg  [7:0]  t_addr;
    reg  [19:0] t_din;
    wire [7:0]  t_alu_out;
    wire        t_zero;

    top_module uut_top (
        .clock(t_clk), .rst_n(t_rst_n), .wr_en(t_wr), .rd_en(t_rd),
        .addr(t_addr), .din(t_din), .alu_out(t_alu_out), .a_is_zero(t_zero)
    );
    always #5 t_clk = ~t_clk;

    task test_top;
    begin
        $display("\n-- top_module integration test --");
        t_clk = 0; t_rst_n = 0; t_wr = 0; t_rd = 0; t_addr = 0; t_din = 0;
        #12; t_rst_n = 1;

        @(negedge t_clk);
        t_addr = 8'd10; t_din = {1'b1, 3'b000, 8'd5, 8'd3}; t_wr = 1;
        @(negedge t_clk);
        t_wr = 0;

        t_addr = 8'd10; t_rd = 1;
        repeat (2) @(negedge t_clk);
        t_rd = 0;
        repeat (25) @(negedge t_clk);

        $display("  observed: sipo.parallel_out=%b  alu_out=%0d  a_is_zero=%b", uut_top.parallel_out, t_alu_out, t_zero);
        $display("  golden written word            =%b", t_din);
        check(uut_top.parallel_out === t_din, "SIPO fully reconstructs the word written to RAM");
        check(t_alu_out === 8'd8, "top-level alu_out matches expected ADD result (8)");
    end
    endtask

    initial begin
        test_alu;
        test_ram;
        test_sipo;
        test_piso;
        test_top;
        $display("\n============================================");
        $display(" TOTAL: %0d tests, %0d passed, %0d failed", tests, tests-errors, errors);
        $display("============================================");
        $finish;
    end

endmodule
