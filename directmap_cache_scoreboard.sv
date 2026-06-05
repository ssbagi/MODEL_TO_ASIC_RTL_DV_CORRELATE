// ============================================================
// File: directmap_cache_scoreboard.sv
// Description: UVM scoreboard for checking cache behavior and validating read/write data.
// Author : Shreyas S Bagi + Copilot
// ============================================================
class dcache_scoreboard extends uvm_component;
  `uvm_component_utils(dcache_scoreboard)

  uvm_analysis_imp #(dcache_seq_item, dcache_scoreboard) item_export;

  typedef bit [127:0] line_t;
  typedef bit [31:0]  addr_t;

  line_t ref_mem[addr_t];
  int hit_count;
  int miss_count;
  int txn_count;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    item_export = new("item_export", this);
    hit_count = 0;
    miss_count = 0;
    txn_count = 0;
  endfunction
  function void write(dcache_seq_item tr);
    txn_count++;
    $display("[DCACHE_SCOREBOARD-TXN#%0d] Captured transaction: addr=0x%h op=%s", txn_count, tr.addr, tr.we ? "WRITE" : "READ");

    if (tr.we) begin
      $display("  WRITE (write-back): updating reference data for addr=0x%h", tr.addr);
      $display("  WRITE data: 0x%h", tr.wdata);
      ref_mem[tr.addr] = tr.wdata;
    end
    else begin
      if (tr.hit) begin
        hit_count++;
        $display("  Cache Hit: YES");
      end else begin
        miss_count++;
        $display("  Cache Hit: NO");
      end

      $display("  READ expected/reference check for addr=0x%h", tr.addr);
      if (ref_mem.exists(tr.addr)) begin
        if (ref_mem[tr.addr] !== tr.rdata) begin
          `uvm_error("DCACHE_SB",
            $sformatf("LOAD MISMATCH addr=%h exp=%h got=%h",
                      tr.addr, ref_mem[tr.addr], tr.rdata))
        end else begin
          $display("  READ matched reference: 0x%h", tr.rdata);
        end
      end
      else begin
        `uvm_warning("DCACHE_SB",
          $sformatf("READ addr=%h has no reference data; cannot verify rdata=%h",
                    tr.addr, tr.rdata));
      end
    end
  endfunction

  function void final_phase(uvm_phase phase);
    $display("\n========================================");
    $display("[DCACHE_SCOREBOARD] SUMMARY: txns=%0d hits=%0d misses=%0d", txn_count, hit_count, miss_count);
    $display("========================================\n");
  endfunction

endclass
