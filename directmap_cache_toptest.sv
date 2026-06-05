// ============================================================
// File: directmap_cache_toptest.sv
// Description: Simple top-level UVM sequence and test for direct-mapped cache functional verification.
// Author : Shreyas S Bagi + Copilot
// ============================================================
class dcache_simple_seq extends uvm_sequence #(dcache_seq_item);
  `uvm_object_utils(dcache_simple_seq)

  function new(string name="dcache_simple_seq");
    super.new(name);
  endfunction

  task body();
    dcache_seq_item tr;
    // Simple pattern: some stores then loads
    foreach (int i[0:15]) begin
      tr = dcache_seq_item::type_id::create("tr");
      tr.we    = 1;
      tr.addr  = 32'h1000 + i*16;
      tr.wdata = {$random, $random, $random, $random};
      start_item(tr);
      finish_item(tr);
    end

    foreach (int j[0:15]) begin
      tr = dcache_seq_item::type_id::create("tr");
      tr.we    = 0;
      tr.addr  = 32'h1000 + j*16;
      tr.wdata = '0;
      start_item(tr);
      finish_item(tr);
    end
  endtask
endclass


class dcache_test extends uvm_test;
  `uvm_component_utils(dcache_test)

  dcache_env env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    env = dcache_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    dcache_simple_seq seq;
    seq = dcache_simple_seq::type_id::create("seq");
    seq.start(env.agent.sequencer);

    phase.drop_objection(this);
  endtask
endclass
