`include "uvm_macros.svh"
import uvm_pkg::*;

class dcache_alt_rw_test extends dcache_base_test;
  `uvm_component_utils(dcache_alt_rw_test)

  dcache_alt_rw_seq seq;
  dcache_env env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    seq = dcache_alt_rw_seq::type_id::create("seq");
    env = dcache_env::type_id::create("env", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.phase_done.set_drain_time(this, 100);
    phase.raise_objection(this);

    $display("[DCACHE_ALT_RW_TEST] Starting alternating read/write sequence...");
    seq.start(env.magent.sqr);
    $display("[DCACHE_ALT_RW_TEST] Alternating read/write sequence completed.");

    phase.drop_objection(this);
  endtask
endclass
