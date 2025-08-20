`ifndef AXI_TEST_SVH
`define AXI_TEST_SVH
`include "uvm_macros.svh"
import uvm_pkg::*;
import axi_pkg::*;

class axi_test extends uvm_test;
  `uvm_component_utils(axi_test)

  axi_env env;

  function new(string name="axi_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = axi_env::type_id::create("env", this);
    `uvm_info(get_type_name(), "axi test build phase", UVM_LOW)
  endfunction

  task run_phase(uvm_phase phase);
   /* phase.raise_objection(this);
      axi_seq seq = axi_seq::type_id::create("seq");
      seq.start(env.agent.seq);
    phase.drop_objection(this);*/
  endtask
endclass
`endif
