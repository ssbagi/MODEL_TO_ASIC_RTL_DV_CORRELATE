`ifndef DCACHE_IF_TB__SV
`define DCACHE_IF_TB__SV
interface dcache_if_tb (input logic clk, input logic rst);
  logic req_valid;
  logic [31:0] req_addr;
  logic [127:0] req_wdata;
  logic req_we;
  logic req_ready;
  logic resp_valid;
  logic [127:0] resp_rdata;
  logic resp_hit;
  logic mem_req_valid;
  logic [31:0] mem_req_addr;
  logic mem_req_we;
  logic [127:0] mem_req_wdata;
  logic mem_resp_valid;
  logic [127:0] mem_resp_rdata;
endinterface : dcache_if_tb
`endif  // DCACHE_IF_TB__SV
