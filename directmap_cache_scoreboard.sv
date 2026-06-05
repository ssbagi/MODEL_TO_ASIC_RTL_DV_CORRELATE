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

  function new(string name, uvm_component parent);
    super.new(name, parent);
    item_export = new("item_export", this);
  endfunction

  function void write(dcache_seq_item tr);
    if (tr.we) begin
      ref_mem[tr.addr] = tr.wdata;
    end
    else begin
      if (ref_mem.exists(tr.addr)) begin
        if (ref_mem[tr.addr] !== tr.rdata) begin
          `uvm_error("DCACHE_SB",
            $sformatf("LOAD MISMATCH addr=%h exp=%h got=%h",
                      tr.addr, ref_mem[tr.addr], tr.rdata))
        end
      end
      else begin
        // First load: accept and initialize
        ref_mem[tr.addr] = tr.rdata;
      end
    end
  endfunction

endclass
