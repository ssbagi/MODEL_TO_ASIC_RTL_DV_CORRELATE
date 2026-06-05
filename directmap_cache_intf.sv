// ============================================================
// File: directmap_cache_intf.sv
// Description: Virtual interface definition for CPU and memory side signals of the cache.
// Author : Shreyas S Bagi + Copilot
// ============================================================
interface dcache_if #(parameter ADDR_W=32, LINE_BITS=128)(input logic clk);

  logic rst;

  // CPU side
  logic req_valid;
  logic [ADDR_W-1:0] req_addr;
  logic [LINE_BITS-1:0] req_wdata;
  logic req_we;
  logic req_ready;

  logic resp_valid;
  logic [LINE_BITS-1:0] resp_rdata;
  logic resp_hit;

  // Memory side
  logic mem_req_valid;
  logic [ADDR_W-1:0] mem_req_addr;
  logic mem_req_we;
  logic [LINE_BITS-1:0] mem_req_wdata;
  logic mem_resp_valid;
  logic [LINE_BITS-1:0] mem_resp_rdata;

  modport drv_mp (
    input  clk, rst, req_ready, resp_valid, resp_rdata, resp_hit,
    output req_valid, req_addr, req_wdata, req_we
  );

  modport mem_mp (
    input  clk, rst, mem_req_valid, mem_req_addr, mem_req_we, mem_req_wdata,
    output mem_resp_valid, mem_resp_rdata
  );

  modport mon_mp (
    input clk, rst,
          req_valid, req_addr, req_wdata, req_we, req_ready,
          resp_valid, resp_rdata, resp_hit
  );

endinterface
