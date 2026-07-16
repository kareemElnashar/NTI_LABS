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
