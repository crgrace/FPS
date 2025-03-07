///////////////////////////////////////////////////////////////////
// File Name: digital_core.sv
// Engineer:  Carl Grace (crgrace@lbl.gov)
// Description: FPS synthesized digital core.  
//              Includes:
//              UARTs for inter-chip communcation
//              6-byte Register Map for configuration bits
//
//              Note that the "primary" is the chip writing to and reading
//              from the current chip. It could also be the FPGA.
//              The "secondary" is always the current chip.
//
///////////////////////////////////////////////////////////////////

module digital_core
    #(parameter NUMREGS = 9)   // number of configuration registers
    
    (output logic piso,// PRIMARY-IN-SECONDARY-OUT TX UART output bit
    
// ANALOG CORE CONFIGURATION SIGNALS
    output logic [5:0] i_lvds_trigger, // lvds trigger current programming
    output logic [5:0] i_lvds_config, // lvds config current programming
    output logic [5:0] i_cml_driver, // cml current programming
    output logic [5:0] i_preamp, // preamp current programming
    output logic [5:0] i_voltage_follower, // follower current programming
    output logic [4:0] i_monitor, // one-hot current monitor
                                 // bit 0 = i_lvds_trigger
                                 // bit 1 = i_lvds_conifg
                                 // bit 2 = i_lvds_cml_driver
                                 // bit 3 = i_preamp
                                 // bit 4 = i_voltage_follower
// SPARES
    output logic [7:0] spare0,  // 8 spare configuration bits
    output logic [7:0] spare1,  // 8 spare configuration bits
    output logic [7:0] spare2,  // 8 spare configuration bits
// INPUTS
    input logic posi,       // PRIMARY-OUT-SECONDARY-IN: RX UART input bit  
    input logic clk,        // clk for UART
    input logic reset_n);   // asynchronous reset for UART (active low)

`include "fps_constants.sv"
logic [7:0] config_bits [0:NUMREGS-1];// regmap config bit outputs

always_comb begin
    i_lvds_trigger      = config_bits[LVDS_TRIGGER][5:0];
    i_lvds_config       = config_bits[LVDS_CONFIG][5:0];
    i_cml_driver        = config_bits[CML_DRIVER][5:0];
    i_preamp            = config_bits[PREAMP][5:0];
    i_voltage_follower  = config_bits[VOLTAGE_FOLLOWER][5:0];
    i_monitor           = config_bits[IMONITOR][4:0];
    spare0              = config_bits[SPARE0][7:0];
    spare1              = config_bits[SPARE1][7:0];
    spare2              = config_bits[SPARE2][7:0];
end // always_comb

external_interface
    #(.NUMREGS(NUMREGS)
    ) external_interface_inst (
    .config_bits            (config_bits),
    .piso                   (piso),
    .posi                   (posi),
    .clk                    (clk),
    .reset_n                (reset_n)
    );

endmodule
