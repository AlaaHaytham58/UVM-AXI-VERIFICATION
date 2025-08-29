`ifndef AXI_DRIVER_SV
`define AXI_DRIVER_SV
`include "uvm_macros.svh"
import uvm_pkg::*;

typedef virtual arb_if.axi_tb axi_vif_t;

class axi_driver extends uvm_driver#(axi_transaction);
  `uvm_component_utils(axi_driver)

  axi_vif_t vif;
 int data_w,addr_w;
 int wait_valid;
  function new(string name="axi_driver", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(axi_vif_t)::get(this, "", "vif", vif))
      `uvm_fatal(get_type_name(), "No virtual interface set for driver (arb_if.axi_tb)")
    `uvm_info(get_type_name(), "AXI Driver built", UVM_LOW);
    void'(uvm_config_db#(int)::get(this, "", "CFG_DATA_W", data_w));
    void'(uvm_config_db#(int)::get(this, "", "CFG_ADDR_W", addr_w));

  endfunction

task run_phase(uvm_phase phase);
    axi_transaction tr;
    forever begin
      seq_item_port.get_next_item(tr);
      if (tr.is_write) drive_write(tr);
      else             drive_read(tr);
      seq_item_port.item_done();
    end
  endtask
  
  // ------------------------------
  // KEEPING YOUR OLD LOGIC
  // ------------------------------
  task automatic drive_write(ref axi_transaction tr);
    $display("Write Started");
    @(negedge vif.ACLK);
    vif.AWLEN   <= tr.awlen;
    vif.AWSIZE  <= tr.awsize;
    vif.BREADY  <= 1;
    vif.AWADDR  <= tr.awaddr;
    vif.AWVALID <= 1;

    $display("Writing to Address: %0h", vif.AWADDR);

    wait_valid = 500;
    while (~vif.AWREADY) begin
      @(negedge vif.ACLK);
      if (!(--wait_valid)) begin
        $error("AWREADY timeout");
        break;
      end
    end

    @(negedge vif.ACLK);
    vif.AWVALID <= 0;

    for (int i = 0; i <= tr.awlen; i++) begin
      @(negedge vif.ACLK);
      vif.WDATA  <= tr.wdata[i];
      vif.WVALID <= 1;
      vif.WLAST  <= (i == tr.awlen);

      $display("Waiting on WREADY...");
      while (~vif.WREADY) begin
        @(negedge vif.ACLK);
        if (!(--wait_valid)) begin
          $error("WREADY timeout");
          break;
        end
      end

      $display("Writing data: Addr=%0h, Data=%0h", tr.awaddr + i*4, tr.wdata[i]);
    end

    @(negedge vif.ACLK);
    vif.WVALID <= 0;
    vif.WLAST  <= 0;
    vif.WDATA  <= 0;
  endtask

  task automatic drive_read(ref axi_transaction tr);
    $display("Read Started");
    @(negedge vif.ACLK);
    vif.ARLEN   <= tr.arlen;
    vif.ARSIZE  <= tr.arsize;
    vif.ARADDR  <= tr.araddr;
    vif.ARVALID <= 1;

    $display("Reading from Address: %0h", vif.ARADDR);

    wait_valid = 500;
    while (~vif.ARREADY) begin
      @(negedge vif.ACLK);
      if (!(--wait_valid)) begin
        $error("ARREADY timeout");
        break;
      end
    end

    @(negedge vif.ACLK);
    vif.ARVALID <= 0;
  endtask

endclass
`endif