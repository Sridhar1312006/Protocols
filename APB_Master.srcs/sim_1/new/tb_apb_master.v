`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.01.2026 19:17:51
// Design Name: 
// Module Name: tb_apb_master
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

module tb_apb_master;

  localparam ADDRWIDTH = 16;
  localparam DATAWIDTH = 16;

  reg pclk;
  reg presetn;
  reg start;
  reg [ADDRWIDTH-1:0] addr;
  reg write;
  reg [DATAWIDTH-1:0] wdata;
  wire [DATAWIDTH-1:0] rdata;
  wire done;

  wire [ADDRWIDTH-1:0] paddr;
  wire [DATAWIDTH-1:0] pwdata;
  reg  [DATAWIDTH-1:0] prdata;
  wire psel;
  wire penable;
  wire pwrite;
  reg  pready;
  reg  pslverr;

  apb_master #(.addrwidth(ADDRWIDTH), .datawidth(DATAWIDTH)) dut (
    .pclk(pclk),
    .presetn(presetn),
    .start(start),
    .addr(addr),
    .write(write),
    .wdata(wdata),
    .rdata(rdata),
    .done(done),
    .paddr(paddr),
    .pwdata(pwdata),
    .prdata(prdata),
    .psel(psel),
    .penable(penable),
    .pwrite(pwrite),
    .pready(pready),
    .pslverr(pslverr)
  );

  initial begin
    pclk = 0;
    forever #5 pclk = ~pclk;
  end

  initial begin
    presetn = 0;
    start   = 0;
    addr    = 0;
    write   = 0;
    wdata   = 0;
    prdata  = 16'hABCD;
    pready  = 0;
    pslverr = 0;

    #20 presetn = 1;

    #10 addr = 16'h0010;
        wdata = 16'h1234;
        write = 1;
        start = 1;
    #10 start = 0;
    #20 pready = 1;
    #10 pready = 0;

    #50 addr = 16'h0020;
        write = 0;
        start = 1;
    #10 start = 0;
    #20 pready = 1;
    #10 pready = 0;

    #100 $finish;
  end

  initial begin
    $monitor("Time=%0t | state=%b | addr=%h | write=%b | wdata=%h | rdata=%h | done=%b | psel=%b | penable=%b | pready=%b",
             $time, dut.state, addr, write, wdata, rdata, done, psel, penable, pready);
  end

endmodule