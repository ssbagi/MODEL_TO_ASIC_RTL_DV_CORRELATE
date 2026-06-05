// ============================================================
// File: directmap_cache_mon.sv
// Description: UVM monitor that observes cache responses and forwards transactions to the scoreboard.
// Author : Shreyas S Bagi + Copilot
// ============================================================
class dcache_monitor extends uvm_component;
  `uvm_component_utils(dcache_monitor)

  virtual dcache_if.mon_mp vif;
  uvm_analysis_port #(dcache_seq_item) ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    if (!uvm_config_db#(virtual dcache_if.mon_mp)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "dcache_if not set for monitor");
  endfunction

  task run_phase(uvm_phase phase);
    dcache_seq_item tr;
    forever begin
      @(posedge vif.clk);
      if (vif.resp_valid) begin
        tr = dcache_seq_item::type_id::create("tr", this);
        tr.addr  = vif.req_addr;   // single outstanding assumption
        tr.we    = vif.req_we;
        tr.wdata = vif.req_wdata;
        tr.rdata = vif.resp_rdata;
        tr.hit   = vif.resp_hit;
        ap.write(tr);
      end
    end
  endtask
endclass
