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