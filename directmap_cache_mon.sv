// ============================================================
// File: directmap_cache_mon.sv
// Description: UVM monitor that observes cache responses and forwards transactions to the scoreboard.
// Author : Shreyas S Bagi + Copilot
// ============================================================
class dcache_monitor extends uvm_component;
  `uvm_component_utils(dcache_monitor)

  virtual dcache_if.mon_mp vif;
  uvm_analysis_port #(dcache_seq_item) ap;
  int txn_count;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
    txn_count = 0;
  endfunction

  function void build_phase(uvm_phase phase);
    if (!uvm_config_db#(virtual dcache_if.mon_mp)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "dcache_if not set for monitor");
    $display("[DCACHE_MONITOR] Interface vif configured successfully.");
  endfunction

  task run_phase(uvm_phase phase);
    dcache_seq_item tr;
    forever begin
      @(posedge vif.clk);
      if (vif.resp_valid) begin
        txn_count++;
        tr = dcache_seq_item::type_id::create("tr", this);
        tr.addr  = vif.req_addr;   // single outstanding assumption
        tr.we    = vif.req_we;
        tr.wdata = vif.req_wdata;
        tr.rdata = vif.resp_rdata;
        tr.hit   = vif.resp_hit;
        
        $display("[DCACHE_MONITOR-TXN#%0d] RESPONSE CAPTURED", txn_count);
        $display("  Operation: %s", tr.we ? "WRITE" : "READ");
        $display("  Address: 0x%h", tr.addr);
        if (tr.we) begin
          $display("[DCACHE_MONITOR-TXN#%0d] WRITE RESPONSE", txn_count);
          $display("  Address : 0x%h", tr.addr);
          $display("  WData   : 0x%h", tr.wdata);
          $display("  Hit     : %s", tr.hit ? "YES" : "NO");
          $display("  Forwarding WRITE to scoreboard.\n");
        end else begin
          $display("[DCACHE_MONITOR-TXN#%0d] READ RESPONSE", txn_count);
          $display("  Address : 0x%h", tr.addr);
          $display("  RData   : 0x%h", tr.rdata);
          $display("  Hit     : %s", tr.hit ? "YES" : "NO");
          $display("  Forwarding READ to scoreboard.\n");
        end

        ap.write(tr);
      end
    end
  endtask
endclass
