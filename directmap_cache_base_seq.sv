`include "uvm_macros.svh"
import uvm_pkg::*;

class dcache_base_seq extends uvm_sequence#(.REQ(dcache_seq_item));
  `uvm_object_utils(dcache_base_seq)

  uvm_phase phase;

  function new(string name = "dcache_base_seq");
    super.new(name);
  endfunction

  task pre_body();
    phase = get_starting_phase();
    if (phase != null) begin
      `uvm_info("DCACHE_SEQ", "Raising objection in base sequence", UVM_MEDIUM)
      phase.phase_done.set_drain_time(this, 100);
      phase.raise_objection(this);
    end
  endtask

  task post_body();
    phase = get_starting_phase();
    if (phase != null) begin
      `uvm_info("DCACHE_SEQ", "Dropping objection in base sequence", UVM_MEDIUM)
      phase.drop_objection(this);
    end
  endtask
endclass
