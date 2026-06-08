module tb_top;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import dcache_pkg::*;

  logic clk = 0;
  always #5 clk = ~clk;
  logic rstn;

  dcache_if_tb vif(.clk(clk), .rst(~rstn));

  dcache dut (
    .clk(clk),
    .rst(~rstn),
    .req_valid(vif.req_valid),
    .req_addr(vif.req_addr),
    .req_wdata(vif.req_wdata),
    .req_we(vif.req_we),
    .req_ready(vif.req_ready),
    .resp_valid(vif.resp_valid),
    .resp_rdata(vif.resp_rdata),
    .resp_hit(vif.resp_hit),
    .mem_req_valid(vif.mem_req_valid),
    .mem_req_addr(vif.mem_req_addr),
    .mem_req_we(vif.mem_req_we),
    .mem_req_wdata(vif.mem_req_wdata),
    .mem_resp_valid(vif.mem_resp_valid),
    .mem_resp_rdata(vif.mem_resp_rdata)
  );

  initial begin
    rstn = 1'b0;
    repeat (3) @(negedge clk);
    rstn = 1'b1;
  end

  // Global watchdog: a deadlocked valid/ready handshake spins on clock edges
  // with no sim-time progress and burns unbounded CPU time. Force a hard stop
  // so a stuck sim fails fast instead of hanging for tens of minutes.
  initial begin
    uvm_top.set_timeout(1ms, 1);
  end

  initial begin
    string testname;
    if (!$value$plusargs("UVM_TESTNAME=%s", testname))
      testname = "dcache_base_test";
    uvm_config_db#(virtual dcache_if_tb)::set(null, "*", "vif", vif);
    run_test(testname);
  end
endmodule : tb_top
