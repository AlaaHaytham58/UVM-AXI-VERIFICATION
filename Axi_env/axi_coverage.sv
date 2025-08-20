`ifndef AXI_COVERAGE_SV
`define AXI_COVERAGE_SV
`include "uvm_macros.svh"
import uvm_pkg::*;

class axi_coverage extends uvm_subscriber#(axi_transaction);
  `uvm_component_utils(axi_coverage)

  covergroup cg with function sample(axi_transaction tr);
    cp_awlen : coverpoint tr.awlen;
    cp_arsize: coverpoint tr.arsize;
  endgroup

  function new(string name="axi_coverage", uvm_component parent=null);
    super.new(name,parent);
    cg = new();
  endfunction

  virtual function void write(axi_transaction t);
    cg.sample(t);
  endfunction
endclass
`endif
