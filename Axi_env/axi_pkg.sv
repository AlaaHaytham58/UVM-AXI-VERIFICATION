package axi_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  `include "Axi_env/axi_transaction.sv"
  `include "Axi_env/axi_seq.sv"
  `include "Axi_env/axi_sequencer.sv"
  `include "Axi_env/axi_driver.sv"
  `include "Axi_env/axi_monitor.sv"
  `include "Axi_env/axi_agent.sv"
  `include "Axi_env/axi_coverage.sv"
  `include "Axi_env/axi_scoreboard.sv"
  `include "Axi_env/axi_env.sv"
  `include "Axi_env/axi_test.sv"
endpackage
