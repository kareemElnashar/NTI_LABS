module seq_detector_overlapping (
    input wire clk,
    input wire reset,
    input wire serial_in,
    output reg sequence_detected
);

    localparam [2:0] S0 = 3'b000,
                     S1 = 3'b001,
                     S2 = 3'b010,
                     S3 = 3'b011,
                     S4 = 3'b100,
                     S5 = 3'b101,
                     S6 = 3'b110;

    reg [2:0] current_state, next_state;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= S0;
        end else begin
            current_state <= next_state;
        end
    end

    always @(*) begin
        case (current_state)
            S0: begin
                if (serial_in) next_state = S1;
                else           next_state = S0;
            end
            
            S1: begin
                if (serial_in) next_state = S2;
                else           next_state = S0;
            end
            
            S2: begin
                if (serial_in) next_state = S2;
                else           next_state = S3;
            end
            
            S3: begin
                if (serial_in) next_state = S4;
                else           next_state = S0;
            end
            
            S4: begin
                if (serial_in) next_state = S2;
                else           next_state = S5;
            end
            
            S5: begin
                if (serial_in) next_state = S6;
                else           next_state = S0;
            end
            
            S6: begin
                if (serial_in) next_state = S2;
                else           next_state = S0;
            end
            
            default: next_state = S0;
        endcase
    end

    always @(*) begin
        case (current_state)
            S6:      sequence_detected = 1'b1;
            default: sequence_detected = 1'b0;
        endcase
    end

endmodule