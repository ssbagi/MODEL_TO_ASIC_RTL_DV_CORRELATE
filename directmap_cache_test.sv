// ============================================================
// File: directmap_cache_test.sv
// Description: UVM test class for generating randomized direct-mapped cache transactions.
// Author : Shreyas S Bagi + Copilot
// ============================================================

class dcache_base_test extends uvm_test;
    `uvm_component_utils(dcache_base_test);

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    virtual function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        //Tree Structure Print
        uvm_top.print_topology();
    endfunction

endclass

class dcache_test extends dcache_base_test;
  `uvm_component_utils(dcache_test);
  dcache_seq_item tr;
  dcache_env env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    env = dcache_env::type_id::create("env", this);
    tr = dcache_seq_item::type_id::create("tr");
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    // Start the test
    uvm_report_info("DCACHE_TEST", "Starting DCACHE TEST");
    phase.phase_done.set_drain_time(this, 100);
    phase.raise_objection(this);

    // Prefer running a sequence rather than driving the sequencer directly from the test.
    // Use an existing multi-transaction sequence to encapsulate transaction generation.
    $display("[DCACHE_TEST] Starting multi-transaction sequence (dcache_simple_seq)...");
    dcache_simple_seq seq = dcache_simple_seq::type_id::create("seq");
    seq.start(env.magent.sqr);
    $display("[DCACHE_TEST] Sequence completed.");

    // End the test
    $display("\n========================================");
    $display("[DCACHE_TEST] RUN PHASE COMPLETED");
    $display("========================================\n");
    uvm_report_info("DCACHE_TEST", "Ending DCACHE TEST");

    phase.drop_objection(this);
  endtask
endclass
