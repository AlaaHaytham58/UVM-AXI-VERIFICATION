`ifndef AXI_TEST_SVH
`define AXI_TEST_SVH
`include "uvm_macros.svh"
import uvm_pkg::*;
import axi_pkg::*;

class axi_test extends uvm_test;
  `uvm_component_utils(axi_test)

  axi_env env;
  seq_type_e test_type = SEQ_WRITE;

  function new(string name="axi_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = axi_env::type_id::create("env", this);
     if (!uvm_config_db#(seq_type_e)::get(this, "", "test_type", test_type)) begin
      `uvm_info("TEST", $sformatf("Using default test type: %s", test_type.name()), UVM_LOW)
    end else begin
      `uvm_info("TEST", $sformatf("Test type set from config: %s", test_type.name()), UVM_LOW)
    end
    `uvm_info(get_type_name(), "axi test build phase", UVM_LOW)
  endfunction

   task run_phase(uvm_phase phase);
  axi_seq seq;
  phase.raise_objection(this);
  
  case (test_type)
    "WRITE": begin
      seq = axi_seq::type_id::create("seq");
      if (!seq.randomize() with { seq_type == SEQ_WRITE; num_trans inside {[10:20]}; }) begin
        `uvm_error("TEST", "Write sequence randomization failed")
      end
      seq.start(env.agent.seq);
    end
    "READ": begin
      seq = axi_seq::type_id::create("seq");
      if (!seq.randomize() with { seq_type == SEQ_READ; num_trans inside {[10:20]}; }) begin
        `uvm_error("TEST", "Read sequence randomization failed")
      end
      seq.start(env.agent.seq);
    end
    "MIXED": begin
      seq = axi_seq::type_id::create("seq");
      if (!seq.randomize() with { seq_type == SEQ_MIXED; num_trans inside {[10:20]}; }) begin
        `uvm_error("TEST", "Mixed sequence randomization failed")
      end
      seq.start(env.agent.seq);
    end
    default: begin
      `uvm_error("TEST", $sformatf("Unknown test type: %s", test_type))
    end
  endcase
  
  phase.drop_objection(this);
endtask
endclass
`endif
