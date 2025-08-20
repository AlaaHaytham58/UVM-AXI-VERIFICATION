`ifndef AXI_SEQ_SV
`define AXI_SEQ_SV
`include "uvm_macros.svh"
import uvm_pkg::*;

class axi_seq extends uvm_sequence #(axi_transaction);
  `uvm_object_utils(axi_seq)

  function new(string name="axi_seq"); super.new(name); endfunction

  task body();
    axi_transaction tr;
    repeat (5) begin
      tr = axi_transaction::type_id::create("tr");
      /*start_item(tr);
        void'(tr.randomize() with {
          awsize == 3'd2;  // 32-bit
          arsize == 3'd2;
          awlen  inside {[0:3]};
          arlen  inside {[0:3]};
        });
        tr.wdata = new[int'(tr.awlen)+1];
        foreach (tr.wdata[i]) tr.wdata[i] = $urandom();
        tr.wlast = 1'b1;
      finish_item(tr);*/
    end
  endtask
endclass
`endif
