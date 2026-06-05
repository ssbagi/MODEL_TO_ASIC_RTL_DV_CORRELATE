// ============================================================
// File: directmap_cache_toptest.sv
// Author : Shreyas S Bagi + Copilot
// Description: Legacy compatibility test file for older top-level simulations.
//              Preserves backward compatibility while migrating to the new sequence structure.
// ============================================================
`include "uvm_macros.svh"
import uvm_pkg::*;

// directmap_cache_toptest.sv is now a lightweight compatibility file.
// Sequence and test class definitions have been moved to separate files:
//   directmap_cache_base_seq.sv
//   directmap_cache_wr_rd_seq.sv
//   directmap_cache_mult_wr_rd_seq.sv
//   directmap_cache_simple_seq.sv
//   directmap_cache_read_seq.sv
//   directmap_cache_write_seq.sv
//   directmap_cache_write_test.sv
//   directmap_cache_read_test.sv
//   directmap_cache_top_seq_test.sv

// Use the new files directly in your compilation flow.


class dcache_top_compat_test extends uvm_test;
  `uvm_component_utils(dcache_top_compat_test)

  dcache_env env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    env = dcache_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    dcache_wr_rd_seq seq;
    seq = dcache_wr_rd_seq::type_id::create("seq");
    seq.start(env.magent.sqr);
  endtask
endclass
