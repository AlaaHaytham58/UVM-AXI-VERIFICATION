`ifndef AXI_AGENT_SV
`define AXI_AGENT_SV
`include "uvm_macros.svh"
import uvm_pkg::*;

class axi_agent extends uvm_agent;
  `uvm_component_utils(axi_agent)

  axi_driver     drv;
  axi_sequencer  seq;
  axi_monitor    mon;

  function new(string name="axi_agent", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mon = axi_monitor::type_id::create("mon", this);
    if (is_active == UVM_ACTIVE) begin
      seq = axi_sequencer::type_id::create("seq", this);
      drv = axi_driver   ::type_id::create("drv", this);
    end
    `uvm_info(get_type_name(), "AXI Agent built", UVM_LOW);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (is_active == UVM_ACTIVE)
      drv.seq_item_port.connect(seq.seq_item_export);
    `uvm_info("my_axi_agent", "AXI Agent connected", UVM_LOW);
  endfunction
endclass
`endif
