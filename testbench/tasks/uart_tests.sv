///////////////////////////////////////////////////////////////////
// File Name: uart_tests.sv
// Engineer:  Carl Grace (crgrace@lbl.gov)
// Description: Tests for verifying the FPS UART
//          
///////////////////////////////////////////////////////////////////

`ifndef _uart_tests_
`define _uart_tests_

`include "fps_constants.sv"  // all sim constants defined here

task isDefaultConfig
    (input logic debug=FALSE);
logic [7:0] config_default [0:NUMREGS-1]; // default scoreboard 
integer errors;
begin
    errors = 0;
    config_default[0] = 8'h07;      
    config_default[1] = 8'h07;      
    config_default[2] = 8'h07;      
    config_default[3] = 8'h07;      
    config_default[4] = 8'h07;      
    config_default[5] = 8'h00;      
    config_default[6] = 8'h00;      
    config_default[7] = 8'h00;      
    config_default[8] = 8'h00;      

    $display("Test: isDefaultConfig");

    for (int i = 0; i < NUMREGS; i++) begin
        regfileOpUART(READ,i,0); // loop through registers
        if (debug) begin
                $display("isDefaultConfig: DEBUG\n");
                $display("at address = %h: readback = %h, expected = %h",i,rcvd_data_word,config_default[i]);
        end // if   
        assert(rcvd_data_word == config_default[i]) else begin
            $error("isDefaultConfig: error!\n");
            $error("at address = %h: readback = %h, expected = %h",i,rcvd_data_word,config_default[i]);
            errors = errors + 1;
        end // assert
    end // for
    regfileOpUART(READ,0,0); // loop through registers
    $display("Config default verification complete. %0d errors.",errors);
end
endtask // isDefaultConfig

task testExternalInterfaceUART
    (input logic [7:0] testval,
    input logic debug=FALSE);
    // verify we can read and write all registers in regfile
    // using the UART
integer errors;
begin
    $display("\nTest: testExternalInterfaceUART. Testval = 0x%h",testval);
    errors = 0;
    debug = 0;
    // we have NUMREGS config registers 
      for (int register = 0; register < NUMREGS; register++) begin
        regfileOpUART(WRITE,register,testval);
        if (debug) 
            $display("testExternalInterfaceUART: writing 0x%h to register 0x%h",testval,register);
        end
        for (int register = 0; register < NUMREGS; register++) begin
            regfileOpUART(READ,register,testval);
        if (debug)
        $display("testExternalInterfaceUART: read back 0x%h from register %h",testval,register);
        assert(rcvd_data_word == testval) 
        else begin
            $error("testExternalInterfaceUART: error!\n");
            $error("Register 0x%h: data received = 0x%h, expected = 0x%h\n",register,rcvd_data_word,testval);
                errors = errors + 1;
        end // assert
    end // for
    $display("testExternalInterfaceUART complete. %0d errors.",errors);
    $display("testval was 0x%h",testval);
end
endtask // testExternalInterfaceUART

task randomTestExternalInterface
    (input logic [15:0] NumTrials,
    input logic debug=FALSE);
    // constrained random test of external interface
int errors;
//logic debug;
logic wrb; // read or write?
logic [7:0] data;
logic [7:0] address;
logic [7:0] randData;
logic [7:0] regfileState [NUMREGS-1:0]; // scoreboard
begin
    $display("\nTest: randomTestExternalInterfaceUART. Trials = %d",NumTrials);
    errors = 0;

    // first, load all registers and scoreboard with random data
    for (int addr = 0; addr < NUMREGS; addr++) begin
        randData = $urandom()%255;
        regfileOpUART(WRITE,addr,randData);
        regfileState[addr] = randData;
    end // for
    // now randomly read and write UART data for specified number of trails
    // update scoreboard every time new data is written
    for (int trial = 0; trial < NumTrials; trial++) begin
        randomize(wrb);
        randomize(address) with {address < NUMREGS; address >= 0;};
        randomize(data) with {data < 256; data >= 0;};
        regfileOpUART(wrb,address,data);
        // if task is a write, update scoreboard
        if (wrb) begin
            regfileState[address] = data;
            if (debug) begin
                $display("randomTestExternalInterface: Trial %2d. WRITE. Update scoreboard with Register 0x%h = 0x%h",trial,address,data); 
            end // if
        end // if
        else begin // if task is a read, check scoreboard
            if (debug) begin
                $display("randomTestExternalInterface: Trial %2d, READ. Data received: Register 0x%h = 0x%h (expected = 0x%h)",trial,address,rcvd_data_word,regfileState[address]); 
            end // if
            assert(rcvd_data_word == regfileState[address])
            else begin
                $error("randomTestExternalInterface: error!\n");
                $error("Trial %2d. Register 0x%h: data received = 0x%h, expected = 0x%h\n",trial,address,rcvd_data_word,regfileState[address]);
            errors++;
            end // assert
        end // if         
    end // for
    $display("randomTestExternalInterface complete. %0d transactions executed. %0d errors.",NumTrials,errors);
end
endtask    
        

`endif // _uart_tests_
