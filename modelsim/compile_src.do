#
# Create work library
#
vlib work

#
# Map libraries
#
vmap work  

#
# Design sources
#

vlog +incdir+../testbench/tasks/ -incr -sv "../src/regfile.sv"
vlog -incr -sv "../src/uart_rx.sv" 
vlog -incr -sv "../src/uart_tx.sv" 
vlog -incr -sv "../src/uart.sv" 
vlog -incr -sv "../src/external_interface.sv"
vlog +incdir+../testbench/tasks/ -incr -sv "../src/digital_core.sv"

#
# Testbenches
#
vlog +incdir+../testbench/tasks/ -incr -vopt -sv "../testbench/unit_tests/external_interface_tb.sv" 
vlog -incr -vopt -sv "../testbench/unit_tests/digital_core_tb.sv" 


