// ============================================================
// File: dcache_pkg.sv
// Author : Shreyas S Bagi + Copilot
// Description: UVM package include file that aggregates all cache testbench components.
//              Controls compile order for interface, transactions, sequences, driver, monitor, agent, env, and tests.
// ============================================================
`ifndef DCACHE_PKG_SV
`define DCACHE_PKG_SV

`include "uvm_macros.svh"
`include "directmap_cache_intf.sv"

package dcache_pkg;
  import uvm_pkg::*;

  /*
  Include header files in proper dependency order:
  - Interface definitions (already included above)
  - Transaction/Sequence Item definitions
  - Base and derived sequence classes
  - Sequencer class
  - Driver class
  - Monitor class
  - Scoreboard class
  - Agent class
  - Environment class
  - Test classes
  */

  // ============================================================
  // Transaction Class
  // ============================================================
  `include "directmap_cache_seq_item.sv"

  // ============================================================
  // Sequence Library - Base and Derived Sequences
  // ============================================================
  `include "directmap_cache_base_seq.sv"
  `include "directmap_cache_wr_rd_seq.sv"
  `include "directmap_cache_mult_wr_rd_seq.sv"
  `include "directmap_cache_simple_seq.sv"
  `include "directmap_cache_read_seq.sv"
  `include "directmap_cache_write_seq.sv"

  // ============================================================
  // Sequencer Class
  // ============================================================
  `include "directmap_cache_sequencer.sv"

  // ============================================================
  // Driver Class
  // ============================================================
  `include "directmap_cache_drv.sv"

  // ============================================================
  // Monitor Class
  // ============================================================
  `include "directmap_cache_mon.sv"

  // ============================================================
  // Scoreboard Class
  // ============================================================
  `include "directmap_cache_scoreboard.sv"

  // ============================================================
  // Agent Class
  // ============================================================
  `include "directmap_cache_agent.sv"

  // ============================================================
  // Environment Class
  // ============================================================
  `include "directmap_cache_environment.sv"

  // ============================================================
  // Test Classes
  // ============================================================
  `include "directmap_cache_test.sv"
  `include "directmap_cache_write_test.sv"
  `include "directmap_cache_read_test.sv"
  `include "directmap_cache_top_seq_test.sv"

endpackage

`endif
