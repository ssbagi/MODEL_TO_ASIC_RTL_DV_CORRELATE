// ============================================================
// File: directmap_cache_drv.sv
// Description: UVM driver that drives requests into the direct-mapped cache interface.
// Author : Shreyas S Bagi + Copilot
// ============================================================
class dcache_driver extends uvm_driver #(dcache_seq_item);
  `uvm_component_utils(dcache_driver)

  virtual dcache_if.drv_mp vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    if (!uvm_config_db#(virtual dcache_if.drv_mp)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "dcache_if not set for driver");
  endfunction

  task run_phase(uvm_phase phase);
    dcache_seq_item tr;
    forever begin
      seq_item_port.get_next_item(tr);

      // Drive request
      vif.req_valid <= 1;
      vif.req_addr  <= tr.addr;
      vif.req_wdata <= tr.wdata;
      vif.req_we    <= tr.we;

      @(posedge vif.clk);
      while (!vif.req_ready) @(posedge vif.clk);

      vif.req_valid <= 0;

      // Wait for response (simple 1-outstanding assumption)
      do @(posedge vif.clk); while (!vif.resp_valid);

      tr.rdata = vif.resp_rdata;
      tr.hit   = vif.resp_hit;

      seq_item_port.item_done();
    end
  endtask
endclass
