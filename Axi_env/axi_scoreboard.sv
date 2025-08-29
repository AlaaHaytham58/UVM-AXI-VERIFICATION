`ifndef AXI_SCOREBOARD_SV
`define AXI_SCOREBOARD_SV
`include "uvm_macros.svh"
import uvm_pkg::*;

class axi_scoreboard extends uvm_component;
  `uvm_component_utils(axi_scoreboard)

  // Single analysis port for backward compatibility
  uvm_analysis_imp#(axi_transaction, axi_scoreboard) imp;

  // reference memory (golden)
  int MEM_DEPTH = 1024;
  bit [31:0] ref_mem[];

  // Store read requests for later comparison
  axi_transaction read_requests[$];

  function new(string name="axi_scoreboard", uvm_component parent=null);
    super.new(name,parent);
    imp = new("imp", this);
  endfunction

  function void build_phase(uvm_phase phase);
    int i;
    super.build_phase(phase);
    
    // Initialize memory same as your testbench
    ref_mem = new[MEM_DEPTH];
    for (i = 0; i < MEM_DEPTH; i++) begin
      ref_mem[i] = i;
    end
    
    `uvm_info(get_type_name(), $sformatf("AXI Scoreboard built with MEM_DEPTH=%0d", MEM_DEPTH), UVM_LOW);
  endfunction

  function void write(axi_transaction tr);
    `uvm_info("SCB", $sformatf("Received %s transaction%s", 
              tr.is_write ? "WRITE" : "READ",
              tr.printtrans()), UVM_MEDIUM)

    if (tr.is_write) begin
      handle_write(tr);
    end else begin
      handle_read(tr);
    end
  endfunction

  function void handle_write(axi_transaction tr);
    int i;
    int word_addr;
    
    // Update golden memory for write transactions
    if (tr.wdata.size() > 0) begin  // This is a write with data
      for (i = 0; i <= tr.awlen; i++) begin
        word_addr = (tr.awaddr >> 2) + i;
        if (word_addr < MEM_DEPTH) begin
          ref_mem[word_addr] = tr.wdata[i];
          `uvm_info("SCB_WRITE", 
            $sformatf("Golden Memory Write: Addr=%0h, Data=%0h", 
                     tr.awaddr + i*4, tr.wdata[i]), UVM_HIGH)
        end
      end
    end
    
    // Check write response if available
    if (tr.bresp inside {2'b01, 2'b10, 2'b11}) begin
      if (tr.bresp !== 2'b00) begin
        `uvm_error("SCB_WRITE_ERR",
          $sformatf("Unexpected write error response: %0b", tr.bresp))
      end
    end
  endfunction

  function void handle_read(axi_transaction tr);
    if (tr.rdata.size() == 0) begin
      // This is a read request - store it
      read_requests.push_back(tr);
      `uvm_info("SCB_READ_REQ", 
        $sformatf("Stored read request: Addr=%0h, Len=%0d", tr.araddr, tr.arlen), UVM_HIGH)
    end else begin
      // This is a read response - check against expected data
      check_read_response(tr);
    end
  endfunction

  function void check_read_response(axi_transaction response);
    int i;
    int word_addr;
    bit [31:0] expected_data;
    bit mismatch;
    axi_transaction request;
    
    if (read_requests.size() == 0) begin
      `uvm_error("SCB_READ_ERR", "Read response without matching request")
      return;
    end
    
    // Find matching request (simple FIFO approach)
    request = read_requests.pop_front();
    mismatch = 0;
    
    for (i = 0; i <= request.arlen; i++) begin
      word_addr = (request.araddr >> 2) + i;
      
      if (word_addr < MEM_DEPTH) begin
        expected_data = ref_mem[word_addr];
      end else begin
        expected_data = '0;
      end
      
      // Compare with actual response data
      if (response.rdata[i] !== expected_data) begin
        mismatch = 1;
        `uvm_error("SCB_READ_MISMATCH",
          $sformatf("Beat %0d: Addr=%0h, Exp=%0h, Act=%0h",
                    i, request.araddr + i*4, expected_data, response.rdata[i]))
      end
    end
    
    // Check read response code
    if (response.rresp !== 2'b00) begin
      `uvm_error("SCB_READ_RESP_ERR",
        $sformatf("Unexpected read response: %0b", response.rresp))
    end
    
    if (!mismatch && (response.rresp == 2'b00)) begin
      `uvm_info("SCB_READ_OK",
        $sformatf("Read OK @0x%0h len=%0d", request.araddr, request.arlen), UVM_LOW)
    end
  endfunction

endclass
`endif