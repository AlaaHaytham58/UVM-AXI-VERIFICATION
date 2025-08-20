`ifndef AXI_DRIVER_SV
`define AXI_DRIVER_SV
`include "uvm_macros.svh"
import uvm_pkg::*;

typedef virtual arb_if.axi_tb axi_vif_t;

class axi_driver extends uvm_driver#(axi_transaction);
  `uvm_component_utils(axi_driver)

  axi_vif_t vif;

  function new(string name="axi_driver", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(axi_vif_t)::get(this, "", "vif", vif))
      `uvm_fatal(get_type_name(), "No virtual interface set for driver (arb_if.axi_tb)")
    `uvm_info(get_type_name(), "AXI Driver built", UVM_LOW);
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      axi_transaction tr; 
      seq_item_port.get_next_item(tr);
      // TODO: drive AXI here; stub keeps compilation clean
      `uvm_info(get_type_name(), "Driving (stub)", UVM_HIGH)
      seq_item_port.item_done();
      @(posedge vif.ACLK);
    end
  endtask
endclass
`endif
