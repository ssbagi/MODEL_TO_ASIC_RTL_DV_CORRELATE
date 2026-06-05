// ============================================================
// File: dcache_one_read_test.sv
// Author : Shreyas S Bagi + Copilot
// Description: Test harness for the single-read standalone sequence.
//              Runs one read transaction to verify the read response path.
// ============================================================
`include "uvm_macros.svh"
import uvm_pkg::*;

class dcache_one_read_test extends dcache_base_test;
  `uvm_component_utils(dcache_one_read_test)

  dcache_one_read_seq seq;
  dcache_env env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    seq = dcache_one_read_seq::type_id::create("seq");
    env = dcache_env::type_id::create("env", this);
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.phase_done.set_drain_time(this, 100);
    phase.raise_objection(this);

    $display("[DCACHE_ONE_READ_TEST] Starting one-read sequence...");
    seq.start(env.magent.sqr);
    $display("[DCACHE_ONE_READ_TEST] One-read sequence completed.");

    phase.drop_objection(this);
  endtask
endclass
