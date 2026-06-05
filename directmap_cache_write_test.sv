// ============================================================
// File: directmap_cache_write_test.sv
// Author : Shreyas S Bagi + Copilot
// Description: Dedicated UVM test for the write-only sequence.
//              Starts the write sequence on the cache environment and checks flow completion.
// ============================================================
`include "uvm_macros.svh"
import uvm_pkg::*;

class dcache_write_test extends dcache_base_test;
  `uvm_component_utils(dcache_write_test)

  dcache_write_seq wseq;
  dcache_env env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    wseq = dcache_write_seq::type_id::create("wseq");
    env  = dcache_env::type_id::create("env", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.phase_done.set_drain_time(this, 100);
    phase.raise_objection(this);

    $display("[DCACHE_WRITE_TEST] Starting dcache_write_seq...");
    wseq.start(env.magent.sqr);
    $display("[DCACHE_WRITE_TEST] dcache_write_seq completed.");

    $display("\n========================================");
    $display("[DCACHE_WRITE_TEST] RUN PHASE COMPLETED");
    $display("========================================\n");

    phase.drop_objection(this);
  endtask
endclass
