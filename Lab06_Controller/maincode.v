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
