`ifndef AXI_ENV_SV
`define AXI_ENV_SV
`include "uvm_macros.svh"
import uvm_pkg::*;

class axi_env extends uvm_env;
  `uvm_component_utils(axi_env)

  axi_agent      agent;
  axi_coverage   coverage;
  axi_scoreboard scoreboard;

  function new(string name="axi_env", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent      = axi_agent     ::type_id::create("agent", this);
    coverage   = axi_coverage  ::type_id::create("coverage", this);
    scoreboard = axi_scoreboard ::type_id::create("scoreboard", this);
    `uvm_info(get_type_name(), "AXI Environment built", UVM_LOW);
  endfunction

  function void connect_phase(uvm_phase phase);
    agent.mon.ap.connect(scoreboard.imp);
    agent.mon.ap.connect(coverage.analysis_export);
  endfunction
endclass
`endif
