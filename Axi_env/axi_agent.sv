`ifndef AXI_AGENT_SV
`define AXI_AGENT_SV
`include "uvm_macros.svh"
import uvm_pkg::*;

class axi_agent extends uvm_agent;
  `uvm_component_utils(axi_agent)

  axi_driver     drv;
  axi_sequencer  seq;
  axi_monitor    mon;

uvm_analysis_port #(axi_transaction) req_ap;
uvm_analysis_port #(axi_transaction) rsp_ap;

  function new(string name="axi_agent", uvm_component parent=null);
    super.new(name,parent);
     req_ap = new("req_ap", this);
     rsp_ap = new("rsp_ap", this);
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
    mon.req_ap.connect(req_ap);
    mon.rsp_ap.connect(rsp_ap);
    `uvm_info("my_axi_agent", "AXI Agent connected", UVM_LOW);
  endfunction
endclass
`endif
