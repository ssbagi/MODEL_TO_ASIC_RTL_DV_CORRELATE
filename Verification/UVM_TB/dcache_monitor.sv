`ifndef DCACHE_MONITOR__SV
`define DCACHE_MONITOR__SV
class dcache_monitor extends uvm_monitor;
  `uvm_component_utils(dcache_monitor)
  virtual dcache_if_tb vif;
  uvm_analysis_port #(dcache_sequence_item) ap;
  function new(string name="dcache_monitor", uvm_component parent=null);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual dcache_if_tb)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "monitor vif not set")
  endfunction
  task run_phase(uvm_phase phase);
    dcache_sequence_item tr;
    forever begin
      @(posedge vif.clk);
      if (vif.rst === 1'b1) continue;
      tr = dcache_sequence_item::type_id::create("tr");
      tr.req_valid      = vif.req_valid;
      tr.req_addr       = vif.req_addr;
      tr.req_wdata      = vif.req_wdata;
      tr.req_we         = vif.req_we;
      tr.req_ready      = vif.req_ready;
      tr.resp_valid     = vif.resp_valid;
      tr.resp_rdata     = vif.resp_rdata;
      tr.resp_hit       = vif.resp_hit;
      tr.mem_req_valid  = vif.mem_req_valid;
      tr.mem_req_addr   = vif.mem_req_addr;
      tr.mem_req_we     = vif.mem_req_we;
      tr.mem_req_wdata  = vif.mem_req_wdata;
      tr.mem_resp_valid = vif.mem_resp_valid;
      tr.mem_resp_rdata = vif.mem_resp_rdata;
      `uvm_info("MON", $sformatf("SAMPLE req_valid=%0b req_addr=0x%0h req_wdata=0x%0h req_we=%0b req_ready=%0b resp_valid=%0b resp_rdata=0x%0h resp_hit=%0b mem_req_valid=%0b mem_req_addr=0x%0h mem_req_we=%0b mem_req_wdata=0x%0h mem_resp_valid=%0b mem_resp_rdata=0x%0h",
                tr.req_valid, tr.req_addr, tr.req_wdata, tr.req_we, tr.req_ready, tr.resp_valid, tr.resp_rdata, tr.resp_hit,
                tr.mem_req_valid, tr.mem_req_addr, tr.mem_req_we, tr.mem_req_wdata, tr.mem_resp_valid, tr.mem_resp_rdata), UVM_MEDIUM)
      ap.write(tr);
    end
  endtask
endclass : dcache_monitor

`endif  // DCACHE_MONITOR__SV
