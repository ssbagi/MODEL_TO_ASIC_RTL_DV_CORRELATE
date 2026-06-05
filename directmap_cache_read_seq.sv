// ============================================================
// File: directmap_cache_read_seq.sv
// Author : Shreyas S Bagi + Copilot
// Description: Derived sequence producing multiple read transactions.
//              Exercises the cache read data path and response timing.
// ============================================================
`include "uvm_macros.svh"
import uvm_pkg::*;

class dcache_read_seq extends dcache_base_seq;
  `uvm_object_utils(dcache_read_seq)

  function new(string name = "dcache_read_seq");
    super.new(name);
  endfunction

  task body();
    dcache_seq_item tr;
    repeat (16) begin
      tr = dcache_seq_item::type_id::create("tr");
      `uvm_do_with(tr, { tr.we == 0; tr.addr == 32'h2000 + $urandom_range(0,15)*16; tr.wdata == '0; })
    end
  endtask
endclass
