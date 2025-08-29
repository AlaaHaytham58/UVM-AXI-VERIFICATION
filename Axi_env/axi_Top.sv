// axi_Top.sv  (testbench top)
`include "Axi_env/axi_Interface.sv"
`include "Axi_env/axi_pkg.sv"
`include "uvm_macros.svh"
import uvm_pkg::*;
import axi_pkg::*;

module axi_Top;
  parameter DATA_W = 32;
  parameter ADDR_W = 16; 
  parameter MEM_DEPTH = 1024;

  logic ACLK;
  logic ARESETn;
  
  always #5 ACLK = ~ACLK;

  // Instantiate your interface with proper parameters
  arb_if #(DATA_W, ADDR_W, MEM_DEPTH) vif(ACLK);

  // DUT / memory model (hook your rtl here)
  // axi4 dut(.ACLK(ACLK), .ARESETn(ARESETn), ... connect vif signals ...);

  initial begin
    ACLK = 0;
    ARESETn = 0; 
    repeat(5) @(posedge ACLK); 
    ARESETn = 1;

    // push into config DB - use proper hierarchical paths
    uvm_config_db#(virtual arb_if.axi_tb)::set(null, "uvm_test_top.env.agent.drv", "vif", vif);
    uvm_config_db#(virtual arb_if.monitor)::set(null, "uvm_test_top.env.agent.mon", "vif", vif);
    
    // Set configuration parameters
    uvm_config_db#(int)::set(null, "*", "DATA_W", DATA_W);
    uvm_config_db#(int)::set(null, "*", "ADDR_W", ADDR_W);
    uvm_config_db#(int)::set(null, "*", "MEM_DEPTH", MEM_DEPTH);

    run_test("axi_test");
  end
endmodule