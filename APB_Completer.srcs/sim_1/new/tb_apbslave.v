`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.01.2026 23:21:26
// Design Name: 
// Module Name: tb_apbslave
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps

module tb_apbslave;

  localparam ADDRWIDTH = 16;
  localparam DATAWIDTH = 16;

  reg pclk;
  reg presetn;
  reg psel;
  reg penable;
  reg [ADDRWIDTH-1:0] paddr;
  reg pwrite;
  reg [DATAWIDTH-1:0] pwdata;
  wire [DATAWIDTH-1:0] prdata;
  wire pready;
  wire pslverr;

  apbslave #(
    .addrwidth(ADDRWIDTH),
    .datawidth(DATAWIDTH)
  ) dut (
    .pclk(pclk),
    .presetn(presetn),
    .psel(psel),
    .penable(penable),
    .paddr(paddr),
    .pwrite(pwrite),
    .pwdata(pwdata),
    .prdata(prdata),
    .pready(pready),
    .pslverr(pslverr)
  );

  initial begin
    pclk = 0;
    forever #5 pclk = ~pclk;
  end

  initial begin
    presetn = 0;
    psel = 0;
    penable = 0;
    paddr = 0;
    pwrite = 0;
    pwdata = 0;

    #12 presetn = 1;

    @(posedge pclk);
    psel = 1; pwrite = 1; paddr = 16'h0004; pwdata = 16'hABCD;
    penable = 0;
    @(posedge pclk);
    penable = 1;
    @(posedge pclk);
    penable = 0; psel = 0;

    @(posedge pclk);
    psel = 1; pwrite = 0; paddr = 16'h0004;
    penable = 0;
    @(posedge pclk);
    penable = 1;
    @(posedge pclk);
    $display("Read Data = %h", prdata);
    penable = 0; psel = 0;

    @(posedge pclk);
    psel = 1; pwrite = 0; paddr = 16'hFFFF;
    penable = 0;
    @(posedge pclk);
    penable = 1;
    @(posedge pclk);
    $display("Error flag = %b", pslverr);
    penable = 0; psel = 0;

    #50 $finish;
  end

endmodule

