///////////////////////////////////////////////////////////////////
// File Name: fps_constants.sv
// Engineer:  Carl Grace (crgrace@lbl.gov)
// Description:  Constants for FPS operation and simulation
//          
///////////////////////////////////////////////////////////////////

`ifndef _fps_constants_
`ifndef SYNTHESIS 
`define _fps_constants_
`endif

// declare needed variables
localparam TRUE = 1;
localparam FALSE = 0;
localparam SILENT = 0;
localparam VERBOSE = 1;          // high to print out verification results

// localparams to define config registers
// configuration word definitions
localparam LVDS_TRIGGER = 0;
localparam LVDS_CONFIG = 1;
localparam CML_DRIVER = 2;
localparam PREAMP = 3;
localparam VOLTAGE_FOLLOWER = 4;
localparam IMONITOR = 6;
localparam SPARE0 = 6;
localparam SPARE1 = 7;
localparam SPARE2 = 8;

// UART ops
localparam WRITE = 1;
localparam READ = 0;


`endif // _fps_constants_
