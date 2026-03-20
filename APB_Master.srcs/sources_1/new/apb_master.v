`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.01.2026 16:28:53
// Design Name: 
// Module Name: apb_master
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

module apb_master#(
  parameter addrwidth = 16,
  parameter datawidth = 16
)(
  input  pclk,
  input  presetn,
  input  start,

  // Internal interface
  input  [addrwidth-1:0] addr,
  input  write,
  input  [datawidth-1:0] wdata,
  output reg [datawidth-1:0] rdata,
  output reg done,

  // APB bus interface
  output reg [addrwidth-1:0] paddr,
  output reg [datawidth-1:0] pwdata,
  input  [datawidth-1:0] prdata,
  output reg psel,
  output reg penable,
  output reg pwrite,
  input  pready,
  input  pslverr
);

localparam idle   = 2'b00,
           setup  = 2'b01,
           access = 2'b10;

reg [1:0] state, nextstate;

// Next-state logic
always @(*) begin
  case(state)
    idle   : nextstate = start ? setup : idle;
    setup  : nextstate = access;
    access : nextstate = pready ? (start ? setup : idle) : access;
    default: nextstate = idle;
  endcase
end

// State register
always @(posedge pclk) begin
  if(!presetn)
    state <= idle;
  else
    state <= nextstate;
end

// Output logic
always @(posedge pclk) begin
  if(!presetn) begin
    psel    <= 0;
    penable <= 0;
    paddr   <= 0;
    pwrite  <= 0;
    pwdata  <= 0;
    rdata   <= 0;
    done    <= 0;
  end else begin
    case(state)
      idle: begin
        psel    <= 0;
        penable <= 0;
        done    <= 0;
      end

      setup: begin
        psel    <= 1;
        penable <= 0;
        pwrite  <= write;
        pwdata  <= wdata;
        paddr   <= addr;
        done    <= 0;
      end

      access: begin
        psel    <= 1;
        penable <= 1;
        if (pready) begin
          if (!write)
            rdata <= prdata;   // capture slave data on read
          done <= 1;           // transaction complete
        end else begin
          done <= 0;           // still waiting
        end
      end
    endcase
  end
end

endmodule
