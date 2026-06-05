// ============================================================
// File: directmap_cache_top_seq_test.sv
// Author : Shreyas S Bagi + Copilot
// Description: Top-level UVM test wrapping the main sequence library.
//              Provides an entry point for running the cache sequence from the environment.
// ============================================================
`include "uvm_macros.svh"
import uvm_pkg::*;

class dcache_top_seq_test extends dcache_base_test;
  `uvm_component_utils(dcache_top_seq_test)

  dcache_wr_rd_seq seq;
  dcache_env env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    seq = dcache_wr_rd_seq::type_id::create("seq");
    env = dcache_env::type_id::create("env", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.phase_done.set_drain_time(this, 100);
    phase.raise_objection(this);

    $display("[DCACHE_TOP_SEQ_TEST] Starting dcache_wr_rd_seq...");
    seq.start(env.magent.sqr);
    $display("[DCACHE_TOP_SEQ_TEST] dcache_wr_rd_seq completed.");

    $display("\n========================================");
    $display("[DCACHE_TOP_SEQ_TEST] RUN PHASE COMPLETED");
    $display("========================================\n");

    phase.drop_objection(this);
  endtask
endclass
