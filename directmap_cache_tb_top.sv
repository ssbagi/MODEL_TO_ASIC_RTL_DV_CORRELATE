// ============================================================
// File: directmap_cache_tb_top.sv
// Description: Top-level UVM testbench wrapper for the direct-mapped cache.
// Author : Shreyas S Bagi + Copilot
// This file instantiates the interface, clock/reset, DUT, and connects the UVM testbench.
// ============================================================

`include "dcache_pkg.sv"
`include "uvm_macros.svh"
import uvm_pkg::*;

module dcache_tb_top;

  localparam ADDR_W   = 32;
  localparam LINE_BITS= 128;

  logic clk;
  dcache_if #(ADDR_W, LINE_BITS) cache_if(clk);

  // Clock
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Reset
  initial begin
    cache_if.rst = 1;
    #50 cache_if.rst = 0;
  end

  // DUT
  dcache dut (
    .clk          (clk),
    .rst          (cache_if.rst),
    .req_valid    (cache_if.req_valid),
    .req_addr     (cache_if.req_addr),
    .req_wdata    (cache_if.req_wdata),
    .req_we       (cache_if.req_we),
    .req_ready    (cache_if.req_ready),
    .resp_valid   (cache_if.resp_valid),
    .resp_rdata   (cache_if.resp_rdata),
    .resp_hit     (cache_if.resp_hit),
    .mem_req_valid(cache_if.mem_req_valid),
    .mem_req_addr (cache_if.mem_req_addr),
    .mem_req_we   (cache_if.mem_req_we),
    .mem_req_wdata(cache_if.mem_req_wdata),
    .mem_resp_valid(cache_if.mem_resp_valid),
    .mem_resp_rdata(cache_if.mem_resp_rdata)
  );

  // Simple memory model: always hit, returns address as data pattern
  initial begin
    cache_if.mem_resp_valid = 0;
    cache_if.mem_resp_rdata = '0;
    forever begin
      @(posedge clk);
      if (cache_if.mem_req_valid) begin
        // 1-cycle later respond
        @(posedge clk);
        cache_if.mem_resp_valid <= 1;
        cache_if.mem_resp_rdata <= {4{cache_if.mem_req_addr}}; // pattern
        @(posedge clk);
        cache_if.mem_resp_valid <= 0;
      end
    end
  end

  // Hook virtual interfaces (wildcarded paths to avoid brittle exact instance naming)
  initial begin
    uvm_config_db#(virtual dcache_if.drv_mp)::set(null, "uvm_test_top.env.*.drv", "vif", cache_if);
    uvm_config_db#(virtual dcache_if.mon_mp)::set(null, "uvm_test_top.env.*.mon", "vif", cache_if);
    run_test("dcache_test");
  end

  // Waveform dump and configurable simulation stop
  int SIM_TIME = 100000;

  initial begin
    if ($value$plusargs("SIM_TIME=%d", SIM_TIME)) begin
      $display("[DCACHE_TB_TOP] SIM_TIME overridden by plusarg: %0d", SIM_TIME);
    end
    $dumpfile("wave.vcd");
    $dumpvars(0, dcache_tb_top);
  end

  initial begin
    #SIM_TIME; // Run for a configurable time or until test completion
    $display("[DCACHE_TB_TOP] SIM_TIME expired after %0d time units", SIM_TIME);
    $finish;
  end

endmodule
