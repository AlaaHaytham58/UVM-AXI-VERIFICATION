`ifndef AXI_MONITOR_SV
`define AXI_MONITOR_SV
`include "uvm_macros.svh"
import uvm_pkg::*;

typedef virtual arb_if.monitor axi_mon_vif_t;

class axi_monitor extends uvm_monitor;
  `uvm_component_utils(axi_monitor)

  //requests and responses
  uvm_analysis_port #(axi_transaction) req_ap;
  uvm_analysis_port #(axi_transaction) rsp_ap;
  axi_mon_vif_t vif;

  integer logfile;

  function new(string name="axi_monitor", uvm_component parent=null);
    super.new(name,parent);
    req_ap = new("req_ap", this);
    rsp_ap = new("rsp_ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(axi_mon_vif_t)::get(this, "", "vif", vif))
      `uvm_fatal(get_type_name(), "No virtual interface set for monitor (arb_if.monitor)")
    `uvm_info(get_type_name(), "AXI Monitor built", UVM_LOW);
    
    // Open log file
    logfile = $fopen("axi_monitor_log.txt", "w");
    if (!logfile)
      `uvm_fatal(get_type_name(), "Could not open logfile")
  endfunction
  
  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    $fwrite(logfile, "[%0t] AXI Monitor started logging\n", $time);
  endfunction
  
  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
    if (logfile) begin
      $fwrite(logfile, "[%0t] AXI Monitor finished logging\n", $time);
      $fclose(logfile);
    end
  endfunction

  task run_phase(uvm_phase phase);
    fork
      sample_aw_w_b();
      sample_ar_r();
      monitor_signals();
    join_none
  endtask
  
  task sample_aw_w_b();
    axi_transaction tr;
    axi_transaction rsp;
    int i;
    
    forever begin
      // wait for AW handshake
      @(posedge vif.ACLK iff (vif.ARESETn && vif.AWVALID && vif.AWREADY));
      tr = axi_transaction::type_id::create("mon_write");
      tr.is_write = 1;
      tr.awaddr = vif.AWADDR; 
      tr.awlen = vif.AWLEN; 
      tr.awsize = vif.AWSIZE;
      tr.wdata = new[tr.awlen+1];

      // collect Write data
      i = 0;
      do begin
        @(posedge vif.ACLK iff (vif.ARESETn && vif.WVALID && vif.WREADY));
        tr.wdata[i] = vif.WDATA;
        tr.wlast    = vif.WLAST;
        i++;
      end while (!tr.wlast);

      req_ap.write(tr);

      // BRESP 
      @(posedge vif.ACLK iff (vif.ARESETn && vif.BVALID && vif.BREADY));
      if (!$cast(rsp, tr.clone())) begin
  `uvm_error(get_type_name(), "Failed to cast cloned transaction")
end
      rsp.is_write = 1;
      rsp.bresp = vif.BRESP;
      rsp_ap.write(rsp);
    end
  endtask

  // capture reads
  task sample_ar_r();
    axi_transaction tr;
    axi_transaction rsp;
    int i;
    
    forever begin
      @(posedge vif.ACLK iff (vif.ARESETn && vif.ARVALID && vif.ARREADY));
      tr = axi_transaction::type_id::create("mon_read");
      tr.is_write = 0;
      tr.araddr = vif.ARADDR;
      tr.arlen = vif.ARLEN;
      tr.arsize = vif.ARSIZE;
      req_ap.write(tr);

     if (!$cast(rsp, tr.clone())) begin
  `uvm_error(get_type_name(), "Failed to cast cloned transaction")
end
      rsp.rdata = new[tr.arlen+1];
      i = 0;
      do begin
        @(posedge vif.ACLK iff (vif.ARESETn && vif.RVALID && vif.RREADY));
        rsp.rdata[i] = vif.RDATA;
        rsp.rresp    = vif.RRESP;
        rsp.rlast    = vif.RLAST;
        i++;
      end while (!rsp.rlast);

      rsp_ap.write(rsp);
    end
  endtask

  task monitor_signals();
    forever begin
      @(negedge vif.ACLK iff vif.ARESETn);
      
      // Write address handshake
      if (vif.AWVALID && vif.AWREADY) begin
        $fwrite(logfile, "[%0t] AWADDR = %h, AWLEN = %0d, AWSIZE = %0d\n", 
                $time, vif.AWADDR, vif.AWLEN, vif.AWSIZE);
      end

      // Write data handshake
      if (vif.WVALID && vif.WREADY) begin
        $fwrite(logfile, "[%0t] WDATA = %h, WLAST = %b\n", 
                $time, vif.WDATA, vif.WLAST);
      end

      // Write response handshake
      if (vif.BVALID && vif.BREADY) begin
        $fwrite(logfile, "[%0t] BRESP = %b\n", $time, vif.BRESP);
      end

      // Read address handshake
      if (vif.ARVALID && vif.ARREADY) begin
        $fwrite(logfile, "[%0t] ARADDR = %h, ARLEN = %0d, ARSIZE = %0d\n", 
                $time, vif.ARADDR, vif.ARLEN, vif.ARSIZE);
      end

      // Read data handshake
      if (vif.RVALID && vif.RREADY) begin
        $fwrite(logfile, "[%0t] RDATA = %h, RRESP = %b, RLAST = %b\n", 
                $time, vif.RDATA, vif.RRESP, vif.RLAST);
      end
    end
  endtask
  
endclass
`endif