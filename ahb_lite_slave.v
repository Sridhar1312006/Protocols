`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.04.2026 18:17:19
// Design Name: 
// Module Name: ahb_lite_slave
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

module ahb_lite_slave (
    input  wire        HCLK,      
    input  wire        HRESETn,   
    input  wire        HSEL,      
    input  wire [31:0] HADDR,     
    input  wire [1:0]  HTRANS,    
    input  wire        HWRITE,    
    input  wire [31:0] HWDATA,    
    output reg  [31:0] HRDATA,    
    input  wire        HREADY,    
    output wire        HREADYOUT, 
    output wire        HRESP      
);

    // Memory array: 1024 rows (4KB total), each 32 bits wide
    reg [31:0] memory_array [0:1023];

    // Pipeline registers to hold Address Phase info for the Data Phase
    reg [31:0] addr_reg;
    reg        write_reg;
    reg        sel_reg;

    // --- Address Phase ---
    always @(posedge HCLK or negedge HRESETn) begin
        if (!HRESETn) begin
            addr_reg  <= 32'h0;
            write_reg <= 1'b0;
            sel_reg   <= 1'b0;
        end 
        else if (HREADY) begin
            addr_reg  <= HADDR;
            write_reg <= HWRITE;
            // Check MSB of HTRANS to see if a transfer is active (NONSEQ/SEQ)
            sel_reg   <= HSEL && HTRANS[1]; 
        end
    end

    // --- Data Phase ---
    always @(posedge HCLK) begin
        if (sel_reg && write_reg) begin
            // memory_array now indexed [11:2] to access 1024 locations
            memory_array[addr_reg[11:2]] <= HWDATA;
        end
    end

    always @(*) begin
        if (sel_reg && !write_reg) begin
            // Read from the 10-bit address range
            HRDATA = memory_array[addr_reg[11:2]];
        end else begin
            HRDATA = 32'h0;
        end
    end

    assign HREADYOUT = 1'b1; 
    assign HRESP     = 1'b0; 

endmodule
