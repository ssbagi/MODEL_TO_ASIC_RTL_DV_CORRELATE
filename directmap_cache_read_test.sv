`include "uvm_macros.svh"
import uvm_pkg::*;

class dcache_read_test extends dcache_base_test;
  `uvm_component_utils(dcache_read_test)

  dcache_read_seq rseq;
  dcache_env env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    rseq = dcache_read_seq::type_id::create("rseq");
    env  = dcache_env::type_id::create("env", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.phase_done.set_drain_time(this, 100);
    phase.raise_objection(this);

    $display("[DCACHE_READ_TEST] Starting dcache_read_seq...");
    rseq.start(env.magent.sqr);
    $display("[DCACHE_READ_TEST] dcache_read_seq completed.");

    $display("\n========================================");
    $display("[DCACHE_READ_TEST] RUN PHASE COMPLETED");
    $display("========================================\n");

    phase.drop_objection(this);
  endtask
endclass
