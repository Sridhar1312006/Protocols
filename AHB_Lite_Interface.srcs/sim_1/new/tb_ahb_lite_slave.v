`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.04.2026 18:19:06
// Design Name: 
// Module Name: tb_ahb_lite_slave
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

`timescale 1ns / 1ps

module tb_ahb_lite_slave();

    // Signals to connect to the Slave
    reg         HCLK;
    reg         HRESETn;
    reg         HSEL;
    reg  [31:0] HADDR;
    reg  [1:0]  HTRANS;
    reg         HWRITE;
    reg  [31:0] HWDATA;
    wire [31:0] HRDATA;
    reg         HREADY;
    wire        HREADYOUT;
    wire        HRESP;

    // Instantiate the 4KB Slave
    ahb_lite_slave uut (
        .HCLK(HCLK),
        .HRESETn(HRESETn),
        .HSEL(HSEL),
        .HADDR(HADDR),
        .HTRANS(HTRANS),
        .HWRITE(HWRITE),
        .HWDATA(HWDATA),
        .HRDATA(HRDATA),
        .HREADY(HREADY),
        .HREADYOUT(HREADYOUT),
        .HRESP(HRESP)
    );

    // Clock Generation: 100MHz (10ns period)
    always #5 HCLK = ~HCLK;

    // Task: AHB Write Transaction
    task ahb_write(input [31:0] addr, input [31:0] data);
        begin
            @(posedge HCLK);
            #1; // Drive after edge
            HSEL   = 1'b1;
            HADDR  = addr;
            HTRANS = 2'b10; // NONSEQ
            HWRITE = 1'b1;
            HREADY = 1'b1;

            @(posedge HCLK);
            #1;
            // Data Phase starts here
            HWDATA = data;
            HTRANS = 2'b00; // IDLE for next cycle
            
            @(posedge HCLK);
            #1;
            HSEL = 1'b0;
        end
    endtask

    // Task: AHB Read Transaction
    task ahb_read(input [31:0] addr);
        begin
            @(posedge HCLK);
            #1;
            HSEL   = 1'b1;
            HADDR  = addr;
            HTRANS = 2'b10; // NONSEQ
            HWRITE = 1'b0;  // READ
            HREADY = 1'b1;

            @(posedge HCLK);
            #1;
            // Data Phase: Wait for Slave to drive HRDATA
            HTRANS = 2'b00; // IDLE
            
            @(posedge HCLK);
            #1;
            $display("Read Address %h: Received Data %h", addr, HRDATA);
            HSEL = 1'b0;
        end
    endtask

    // Stimulus Process
    initial begin
        // Initialize
        HCLK    = 0;
        HRESETn = 0;
        HSEL    = 0;
        HADDR   = 0;
        HTRANS  = 0;
        HWRITE  = 0;
        HWDATA  = 0;
        HREADY  = 1;

        // Reset Sequence
        #20 HRESETn = 1;
        #10;

        // Test 1: Write to first location (Address 0)
        $display("--- Starting Write Test ---");
        ahb_write(32'h0000_0000, 32'hDEADBEEF);
        
        // Test 2: Write to a middle location (Address 4)
        ahb_write(32'h0000_0004, 32'hCAFEBABE);

        // Test 3: Read back and Verify
        $display("--- Starting Read Test ---");
        ahb_read(32'h0000_0000);
        ahb_read(32'h0000_0004);

        // Test 4: Write to end of 4KB range (Address 4092)
        ahb_write(32'h0000_0FFC, 32'h12345678);
        ahb_read(32'h0000_0FFC);

        #50;
        $display("--- Simulation Finished ---");
        $finish;
    end

endmodule
