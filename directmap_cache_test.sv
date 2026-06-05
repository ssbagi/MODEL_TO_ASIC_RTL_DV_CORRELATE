// ============================================================
// File: directmap_cache_test.sv
// Description: UVM test class for generating randomized direct-mapped cache transactions.
// Author : Shreyas S Bagi + Copilot
// ============================================================
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

    dcache_seq_item tr;
    repeat (20) begin
      tr = dcache_seq_item::type_id::create("tr");
      tr.randomize();
      env.agent.sequencer.start_item(tr);
      env.agent.sequencer.finish_item(tr);
    end

    phase.drop_objection(this);
  endtask
endclass
