`include "Axi_env/axi_Interface.sv"
`include "Axi_env/axi_pkg.sv"
`include "uvm_macros.svh"
import uvm_pkg::*;
import axi_pkg::*;

module Top;
  bit ACLK = 0;
  always #5 ACLK = ~ACLK;

  // Instantiate your interface
  arb_if #(32,16,1024) arbif(ACLK);

  // DUTs here; connect to arbif.axi/axi_tb/monitor as appropriate
  // axi4        axi    (arbif.axi);
  // axi4_tb     axi_tb (arbif.axi_tb);
  // axi4_monitor mon   (arbif.monitor);

  initial begin
    // Provide virtual interfaces to the UVM components
    uvm_config_db#(virtual arb_if.axi_tb )::set(null, "uvm_test_top.env.agent.*", "vif", arbif);
    uvm_config_db#(virtual arb_if.monitor)::set(null, "uvm_test_top.env.agent.mon", "vif", arbif);
    run_test("axi_test");
  end
endmodule
