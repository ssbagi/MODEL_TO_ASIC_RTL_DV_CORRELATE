// ============================================================
// File: directmap_cache_magent.sv
// Author : Shreyas S Bagi + Copilot
// Description: Master UVM agent containing driver, sequencer, monitor, and coverage helpers.
//              Coordinates stimulus generation, response monitoring, and coverage collection.
// ============================================================
`include "uvm_macros.svh"
import uvm_pkg::*;

class dcache_magent extends uvm_agent;
  `uvm_component_utils(dcache_magent)

  dcache_driver     drv;
  dcache_sequencer  sqr;
  dcache_monitor    mon;
  dcache_coverage   cov;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    drv = dcache_driver::type_id::create("drv", this);
    sqr = dcache_sequencer::type_id::create("sqr", this);
    mon = dcache_monitor::type_id::create("mon", this);
    cov = dcache_coverage::type_id::create("cov", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    // Connect the sequencer to the driver
    drv.seq_item_port.connect(sqr.seq_item_export);
    // Connect monitor's analysis port to coverage's analysis imp
    mon.ap.connect(cov.item_export);
  endfunction
endclass
