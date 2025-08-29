`ifndef AXI_TRANSACTION_SVH
`define AXI_TRANSACTION_SVH

`include "uvm_macros.svh"
import uvm_pkg::*;

class axi_transaction extends uvm_sequence_item;

  // Address Write
  rand logic [15:0] awaddr;
  rand logic [7:0]  awlen;
  rand logic [2:0]  awsize;

  // Write Data
  rand logic [31:0] wdata[];
  rand bit          wlast;

  // Write Response
  logic [1:0]       bresp;


  // Address Read
  rand logic [15:0] araddr;
  rand logic [7:0]  arlen;
  rand logic [2:0]  arsize;

  // Read Data & Response
  logic [31:0]      rdata[];
  logic [1:0]       rresp;
  bit               rlast;
  // logic is_write
  logic        is_write;

    constraint len_c   { awlen inside {[0:15]}; arlen inside {[0:15]}; }
    constraint size_c  { awsize inside {0,1,2}; arsize inside {0,1,2}; }

  `uvm_object_utils_begin(axi_transaction)
    `uvm_field_int(awaddr, UVM_DEFAULT)
    `uvm_field_int(awlen,  UVM_DEFAULT)
    `uvm_field_int(awsize, UVM_DEFAULT)
    `uvm_field_array_int(wdata, UVM_DEFAULT)
    `uvm_field_int(wlast,  UVM_DEFAULT)
    `uvm_field_int(bresp,  UVM_DEFAULT)
    `uvm_field_int(araddr, UVM_DEFAULT)
    `uvm_field_int(arlen,  UVM_DEFAULT)
    `uvm_field_int(arsize, UVM_DEFAULT)
    `uvm_field_array_int(rdata, UVM_DEFAULT)
    `uvm_field_int(rresp,  UVM_DEFAULT)
    `uvm_field_int(rlast,  UVM_DEFAULT)
  `uvm_object_utils_end

  // Constructor
  function new(string name = "axi_transaction");
    super.new(name);
  endfunction
  //printing 
  function string printtrans();
    return $sformatf("\n[AXI TRANSACTIONS]\n  AW: addr=%0h len=%0d size=%0d\n  WDATA.size=%0d wlast=%0b\n  BRESP=%0d\n  AR: addr=%0h len=%0d size=%0d\n  RDATA.size=%0d rlast=%0b rresp=%0d",
                     awaddr, awlen, awsize,
                     wdata.size(), wlast,
                     bresp,
                     araddr, arlen, arsize,
                     rdata.size(), rlast, rresp);
  endfunction

endclass

`endif
