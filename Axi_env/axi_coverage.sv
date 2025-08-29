`ifndef AXI_COVERAGE_SV
`define AXI_COVERAGE_SV
`include "uvm_macros.svh"
import uvm_pkg::*;
import axi_pkg::*;

class axi_coverage extends uvm_subscriber #(axi_transaction);
  `uvm_component_utils(axi_coverage)

  // Covergroup for AXI transaction coverage - using YOUR original structure
  covergroup axi_cg;
    // Write coverage - from your original cg
    cp_awaddr: coverpoint tr.awaddr {
      bins aligned_addr[] = {[0:2**16-1]};
      ignore_bins unaligned_addr = {[0:2**16-1]} with (item % 4 != 0);
    }
    cp_awlen: coverpoint tr.awlen { 
      bins burst_len[] = {[0:15]}; 
    }
    cp_awsize: coverpoint tr.awsize { 
      bins size_4B = {2}; 
    }

    // Read coverage - from your original cg
    cp_araddr: coverpoint tr.araddr {
      bins aligned_addr[] = {[0:2**16-1]};
      ignore_bins unaligned = {[0:2**16-1]} with (item % 4 != 0);
    }
    cp_arlen: coverpoint tr.arlen { 
      bins burst_len[] = {[0:15]}; 
    }
    cp_arsize: coverpoint tr.arsize { 
      bins size_4B = {2}; 
    }

    // Common coverage - from your original cg
    cp_bresp: coverpoint tr.bresp {
      bins resp_okay = {0};
      bins resp_exokay = {1};
      bins resp_slverr = {2};
      bins resp_decerr = {3};
    }
    cp_rresp: coverpoint tr.rresp {
      bins resp_okay = {0};
      bins resp_exokay = {1};
      bins resp_slverr = {2};
      bins resp_decerr = {3};
    }
    cp_is_write: coverpoint tr.is_write {
      bins access_read = {0};
      bins access_write = {1};
    }

    // Cross coverage - from your original cg
    cross_aw: cross cp_awlen, cp_awsize, cp_bresp, cp_is_write;
    cross_ar: cross cp_arlen, cp_arsize, cp_rresp, cp_is_write;
  endgroup

  // Local transaction reference for covergroup
  axi_transaction tr;

  function new(string name="axi_coverage", uvm_component parent=null);
    super.new(name, parent);
    axi_cg = new();
    tr = new();
  endfunction

  virtual function void write(axi_transaction t);
    // Copy transaction data for coverage sampling
    tr.copy(t);
    axi_cg.sample();
    
    `uvm_info("COV", $sformatf("Coverage sampled: %s transaction", 
              tr.is_write ? "WRITE" : "READ"), UVM_HIGH)
  endfunction

  // Function to get coverage results
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("COV", $sformatf("Overall coverage: %0.2f%%", axi_cg.get_inst_coverage()), UVM_LOW)
  endfunction

endclass
`endif