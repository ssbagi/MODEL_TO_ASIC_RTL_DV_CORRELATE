`ifndef DCACHE_PKG__SV
`define DCACHE_PKG__SV
package dcache_pkg;
  `include "uvm_macros.svh"
  import uvm_pkg::*;

  `include "dcache_sequence_item.sv"
  `include "dcache_sequences.sv"
  `include "dcache_driver.sv"
  `include "dcache_monitor.sv"
  `include "dcache_scoreboard.sv"
  `include "dcache_coverage.sv"
  `include "dcache_agent.sv"
  `include "dcache_env.sv"
  `include "dcache_base_test.sv"
  `include "dcache_tests.sv"
endpackage : dcache_pkg
`endif  // DCACHE_PKG__SV
