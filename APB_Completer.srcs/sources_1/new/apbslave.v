`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.01.2026 23:15:21
// Design Name: 
// Module Name: apbslave
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





module apbslave #(
parameter addrwidth = 16,
parameter datawidth = 16

)(
input wire pclk,
input wire presetn,
input wire psel,
input wire penable,
input wire [addrwidth-1:0] paddr,
input wire pwrite,
input wire [datawidth-1:0] pwdata,
output reg [datawidth-1:0] prdata,
output reg pready,
output reg pslverr
);
localparam totalreg = 1 << addrwidth;
reg [datawidth-1:0] registers[0:totalreg-1];

localparam IDLE = 2'b00,
SETUP = 2'b01,
ACCESS = 2'b10;

reg [1:0] state, nextstate;

always @(*) begin
case (state)
IDLE: nextstate = (psel) ? SETUP : IDLE;

SETUP: nextstate = (penable)? ACCESS : SETUP;

ACCESS: nextstate = (!pready)? ACCESS: (psel&&!penable)? SETUP : IDLE;

default: nextstate = IDLE;
endcase
end

always @(posedge pclk or negedge presetn) begin
if (!presetn)
state <= IDLE;
else
state <= nextstate;
end

always @(posedge pclk or negedge presetn) begin
if (!presetn) begin
pready <= 0;
pslverr <= 0;

end
else begin
 case (state)
 SETUP: begin
    pready <= 0;
    pslverr <= 0;
 end
 ACCESS: begin
 if (paddr < totalreg) begin
 if (pwrite) begin
 registers[paddr] <= pwdata;
 pready <= 1;
 pslverr <= 0;
 end
 else begin
 prdata <= registers[paddr];
 pready <= 1;
 pslverr <= 0;
 end
 end else begin
 pready <= 0;
 pslverr <= 1;
 end
 end

 default: begin
 pready <= 0;
 pslverr <= 0;
 end
 endcase
end


end

endmodule