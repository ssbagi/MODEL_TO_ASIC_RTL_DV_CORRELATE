// ============================================================
// File: directmap_cache_agent.sv
// Description: UVM agent containing sequencer, driver, and monitor for the cache testbench.
// Author : Shreyas S Bagi + Copilot
// ============================================================
class dcache_agent extends uvm_agent;
  `uvm_component_utils(dcache_agent)

  dcache_sequencer  sequencer;
  dcache_driver     driver;
  dcache_monitor    monitor;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    sequencer = dcache_sequencer::type_id::create("sequencer", this);
    driver    = dcache_driver   ::type_id::create("driver",    this);
    monitor   = dcache_monitor  ::type_id::create("monitor",   this);
  endfunction

  function void connect_phase(uvm_phase phase);
    driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction
endclass
