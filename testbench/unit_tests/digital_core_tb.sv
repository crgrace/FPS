///////////////////////////////////////////////////////////////////
// File Name: digital_core_tb.sv
// Engineer:  Carl Grace (crgrace@lbl.gov)
// Description: SystemVerilog testbench for digital_core.sv.
//              The purpose of the digital_core is to read 
//              and write the regfile and send the config bits
//              to the analog core. 
//
//          UART packet definition:
//  bit:      17       16:9         8:1       0 
//                  |          |          |
//          parity     addr        data      wrb  
// 
///////////////////////////////////////////////////////////////////


module digital_core_tb();
    timeunit 1ns/10ps;
    localparam NUMREGS = 9;

// config bits

logic [5:0] i_lvds_trigger; // lvds current programming
logic [5:0] i_lvds_config; // lvds config programming
logic [5:0] i_cml_driver; // cml current programming
logic [5:0] i_preamp; // preamp current programming
logic [5:0] i_voltage_follower; // follower current programming
logic [4:0] i_monitor; // measure internal current (one hot)
                                 // bit 0 = i_lvds_trigger
                                 // bit 1 = i_lvds_conifg
                                 // bit 2 = i_lvds_cml_driver
                                 // bit 3 = i_preamp
                                 // bit 4 = i_voltage_follower
logic [7:0] spare0; // 8 spare config bits
logic [7:0] spare1; // 8 spare config bits
logic [7:0] spare2; // 8 spare config bits


// local digital_signals

logic reset_n;          // active low reset
logic clk;           // system clock (sent to FPS)
logic clk_free_running;       // clock ANDed with en to get system clk
logic clk_en;       // high to enable clk

// uart
logic piso;     // output from current chip (input to FPGA)
logic posi;     // input to current chip (output from FPGA)
logic posi_tx;     // (output from FPGA)
logic posi_tx_en; // high to enable posi

// external FPGA signals
logic txclk_fpga; // clock used to define data sent to FPS
logic tx_busy_fpga;
logic ld_tx_data_fpga;
logic [17:0] tx_data_fpga;
logic rx_empty_fpga;
logic uld_rx_data_fpga;
logic [17:0] rx_data_fpga;

// parse rx data

logic [17:0] receivedData;
logic rcvd_wrb;
logic [7:0] rcvd_data_word;
logic [7:0] rcvd_data_address;
logic rcvd_parity_bit;
logic first; // suppress first readout
logic verbose;
logic debug;
`include "../tasks/uart_tasks.sv"
`include "../tasks/uart_tests.sv"

       
initial begin
    verbose = FALSE;
    debug = TRUE;
    reset_n = 1;
    clk_free_running = 0;
    txclk_fpga = 1;
    ld_tx_data_fpga = 0;
    receivedData = 0;
    uld_rx_data_fpga = 1'b0;
    first = 1;
    posi_tx_en = 1;
    clk_en = 0;
// reset DUT
    #100 reset_n = 0;
    #100 reset_n = 1;
//    #100 clk_en = 0;
#1000   isDefaultConfig();
#1000   randomTestExternalInterface(40,debug);

// test RX rejection of run start bit
    #1000 clk_en = 1;
    #1000 $display("Testing runt start bit rejection");
    posi_tx_en = 0;
    #15 posi_tx_en = 1;
    #1000 clk_en = 0;
    $display("all testing complete");
end  // initial

always_comb begin
    posi = posi_tx & posi_tx_en;
    clk = clk_free_running & clk_en;
end // always_comb

// system clock generator
initial begin
    forever begin
      #5 clk_free_running = ~clk_free_running;
    end
end  // initial

initial begin
    forever begin
        // this is the clock that controls the data being sent out   
        #80 txclk_fpga = ~txclk_fpga; // 1/16th speed of clk
    end
end // initial

// read out FPGA received UART
always @(negedge rx_empty_fpga) begin

    @(posedge txclk_fpga);
        uld_rx_data_fpga = 1'b1;
    @(posedge clk);
        uld_rx_data_fpga = 1'b0;
    @(posedge clk);
        receivedData = rx_data_fpga;
    
end // always
 
always_comb begin
    rcvd_wrb = receivedData[0];
    rcvd_data_word = receivedData[8:1];
    rcvd_data_address = receivedData[16:9];
    rcvd_parity_bit = receivedData[17];
end

always @(receivedData) begin
    if (first) begin
        first = 0;
    end
    else begin
        if (verbose) begin
            #10 $display("UART data received:");
            $display("rcvd_data_address = 0x%h", rcvd_data_address);
            $display("rcvd_data_word = 0x%h",rcvd_data_word);
            $display("wrb = 0x%h",rcvd_wrb);
            $display("parity bit = 0x%h",rcvd_parity_bit);
        end
    end
end
// DUT

digital_core digital_core_inst (.*);


// external UART RX & TX models FPGA interface
uart_tx
    uart_tx_FPGA_inst
    (.tx_out        (posi_tx),
    .tx_busy        (tx_busy_fpga),
    .tx_data        (tx_data_fpga),
    .ld_tx_data     (ld_tx_data_fpga),
    .txclk          (txclk_fpga),
    .reset_n        (reset_n)
    );

uart_rx
    uart_rx_FPGA_inst
    (.rx_data       (rx_data_fpga),
    .rx_empty       (rx_empty_fpga),
    .rx_in          (piso),
    .uld_rx_data    (uld_rx_data_fpga),
    .rxclk          (clk),
    .reset_n        (reset_n)
    );

endmodule
