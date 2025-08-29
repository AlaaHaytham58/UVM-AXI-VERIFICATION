`ifndef AXI_SEQ_SV
`define AXI_SEQ_SV
`include "uvm_macros.svh"
import uvm_pkg::*;
typedef enum {SEQ_WRITE, SEQ_READ, SEQ_MIXED} seq_type_e;

class axi_seq extends uvm_sequence #(axi_transaction);
  `uvm_object_utils(axi_seq)


  // random sequence type
  rand seq_type_e seq_type;
  rand int num_trans;//no of transactions


  //constraints for seq_type and num_trans
  constraint c1 { seq_type inside {SEQ_WRITE, SEQ_READ, SEQ_MIXED}; }
  constraint c2 { num_trans inside {[1:20]}; }

  function new(string name="axi_seq"); super.new(name); endfunction

  virtual task body();
   axi_transaction tr;
   `uvm_info(get_type_name(),$sformatf("sequencetype %s transaction no %0d ",  seq_type.name(), num_trans), UVM_MEDIUM);
  repeat(num_trans)begin
    tr = axi_transaction::type_id::create("tr");

      start_item(tr);
      if(!tr.randomize()) begin
        `uvm_error(get_type_name(), "Randomization failed for transaction")
      end
      else begin
        case(seq_type)
          SEQ_WRITE: begin
            tr.araddr = '0;
            tr.arlen  = '0;
            tr.arsize = '0;
            tr.rdata.delete();
            tr.wdata = new[4];
            foreach(tr.wdata[i]) tr.wdata[i] = $urandom;
            tr.wlast = 1;
          end
          SEQ_READ: begin
            tr.awaddr = '0;
            tr.awlen  = '0;
            tr.awsize = '0;
            tr.wdata.delete();
            tr.arlen = 3; 
            tr.arsize = 2; 
          end
          SEQ_MIXED: begin
            if($urandom_range(0,1)) begin
              //  write
              tr.araddr = '0;
              tr.wdata = new[4];
              foreach(tr.wdata[i]) tr.wdata[i] = $urandom;
              tr.wlast = 1;
            end
            else begin
              //  read
              tr.awaddr = '0;
              tr.wdata.delete();
              tr.arlen = $urandom_range(0,7);
              tr.arsize = 2;
            end
          end

        endcase

        //  print
        `uvm_info(get_type_name(), $sformatf("Transaction:\n%s", tr.sprint()), UVM_HIGH)
      end
      finish_item(tr);
  end
  endtask
endclass
`endif
