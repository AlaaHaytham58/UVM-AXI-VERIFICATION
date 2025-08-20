`ifndef AXI_SCOREBOARD_SV
`define AXI_SCOREBOARD_SV
`include "uvm_macros.svh"
import uvm_pkg::*;

class axi_scoreboard extends uvm_component;
  `uvm_component_utils(axi_scoreboard)

  uvm_analysis_imp#(axi_transaction, axi_scoreboard) imp;

  function new(string name="axi_scoreboard", uvm_component parent=null);
    super.new(name,parent);
    imp = new("imp", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "AXI Scoreboard built", UVM_LOW);
  endfunction

  function void write(axi_transaction tr);
    // placeholder check
    `uvm_info("SCB", $sformatf("Observed item awlen=%0d arlen=%0d", tr.awlen, tr.arlen), UVM_MEDIUM)
  endfunction
endclass
`endif
