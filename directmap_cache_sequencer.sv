// ============================================================
// File: directmap_cache_sequencer.sv
// Description: UVM sequencer for generating cache transaction items.
// Author : Shreyas S Bagi + Copilot
// ============================================================
class dcache_sequencer extends uvm_sequencer #(dcache_seq_item);
  `uvm_component_utils(dcache_sequencer)
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
endclass
