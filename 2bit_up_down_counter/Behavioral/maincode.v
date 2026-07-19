module counter2 ( 
    input  clock,    
    input  reset,
    input  up,
    output reg [1:0] count 
);

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            count <= 2'b00;
        end else begin
            if (up) begin
                count <= count + 1'b1;
            end else begin
                count <= count - 1'b1;
            end
        end
    end

endmodule