# Define the Primary Clock (100 MHz = 10ns period)
create_clock -period 10.000 -name sys_clk [get_ports HCLK]

# Set Input/Output Delays (Tells Vivado how fast the bus signals move)
# We assume a 2ns setup time for AHB signals
set_input_delay -clock [get_clocks sys_clk] 2.000 [get_ports {HADDR[*] HTRANS[*] HWRITE HSEL HREADY HWDATA[*]}]
set_output_delay -clock [get_clocks sys_clk] 2.000 [get_ports {HRDATA[*] HREADYOUT HRESP}]

# Configuration Bank Voltage (Standard for Artix-7 boards)
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]