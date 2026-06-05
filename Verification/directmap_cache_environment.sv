// ============================================================
// File: directmap_cache_environment.sv
// Description: UVM environment that instantiates the cache agent and scoreboard.
// Author : Shreyas S Bagi + Copilot
// ============================================================
class dcache_env extends uvm_env;
  `uvm_component_utils(dcache_env)

  dcache_magent      magent;
  dcache_scoreboard  sb;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    magent = dcache_magent     ::type_id::create("magent", this);
    sb     = dcache_scoreboard  ::type_id::create("sb",     this);
  endfunction

  function void connect_phase(uvm_phase phase);
    magent.mon.ap.connect(sb.item_export);
  endfunction
endclass
