`ifndef AXI_MONITOR_SV
`define AXI_MONITOR_SV
`include "uvm_macros.svh"
import uvm_pkg::*;

typedef virtual arb_if.monitor axi_mon_vif_t;

class axi_monitor extends uvm_monitor;
  `uvm_component_utils(axi_monitor)

  uvm_analysis_port#(axi_transaction) ap;
  axi_mon_vif_t vif;

  function new(string name="axi_monitor", uvm_component parent=null);
    super.new(name,parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(axi_mon_vif_t)::get(this, "", "vif", vif))
      `uvm_fatal(get_type_name(), "No virtual interface set for monitor (arb_if.monitor)")
    `uvm_info(get_type_name(), "AXI Monitor built", UVM_LOW);
  endfunction
endclass
`endif
