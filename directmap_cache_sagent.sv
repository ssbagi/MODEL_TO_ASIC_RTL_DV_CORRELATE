// ============================================================
// File: directmap_cache_sagent.sv
// Author : Shreyas S Bagi + Copilot
// Description: Slave-only agent containing monitor and scoreboard.
//              Used when only response observation and scoreboard checking are required.
// ============================================================
`include "uvm_macros.svh"
import uvm_pkg::*;

// Slave agent for direct-mapped cache: monitor + scoreboard
class dcache_sagent extends uvm_agent;
  `uvm_component_utils(dcache_sagent)

  dcache_monitor    mon;
  dcache_scoreboard sb;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mon = dcache_monitor   ::type_id::create("mon", this);
    sb  = dcache_scoreboard::type_id::create("sb",  this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // Connect monitor analysis port to scoreboard analysis imp
    mon.ap.connect(sb.item_export);
  endfunction

endclass
