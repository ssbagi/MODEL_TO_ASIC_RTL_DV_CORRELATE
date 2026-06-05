#include <systemc.h>
#include "DcacheSystemC.h"
#include "TrafficGenerator.h"

int sc_main(int argc, char* argv[]) {
  sc_core::sc_clock clk("clk", 10, sc_core::SC_NS);
  sc_core::sc_signal<bool> rst;

  sc_core::sc_signal<bool> req_valid;
  sc_core::sc_signal<sc_dt::sc_uint<32>> req_addr;
  sc_core::sc_signal<sc_dt::sc_biguint<128>> req_wdata;
  sc_core::sc_signal<bool> req_we;
  sc_core::sc_signal<bool> req_ready;

  sc_core::sc_signal<bool> resp_valid;
  sc_core::sc_signal<sc_dt::sc_biguint<128>> resp_rdata;
  sc_core::sc_signal<bool> resp_hit;

  sc_core::sc_signal<bool> mem_req_valid;
  sc_core::sc_signal<sc_dt::sc_uint<32>> mem_req_addr;
  sc_core::sc_signal<bool> mem_req_we;
  sc_core::sc_signal<sc_dt::sc_biguint<128>> mem_req_wdata;
  sc_core::sc_signal<bool> mem_resp_valid;
  sc_core::sc_signal<sc_dt::sc_biguint<128>> mem_resp_rdata;

  DcacheSystemC dcache("dcache");
  dcache.clk(clk);
  dcache.rst(rst);
  dcache.req_valid(req_valid);
  dcache.req_addr(req_addr);
  dcache.req_wdata(req_wdata);
  dcache.req_we(req_we);
  dcache.req_ready(req_ready);
  dcache.resp_valid(resp_valid);
  dcache.resp_rdata(resp_rdata);
  dcache.resp_hit(resp_hit);
  dcache.mem_req_valid(mem_req_valid);
  dcache.mem_req_addr(mem_req_addr);
  dcache.mem_req_we(mem_req_we);
  dcache.mem_req_wdata(mem_req_wdata);
  dcache.mem_resp_valid(mem_resp_valid);
  dcache.mem_resp_rdata(mem_resp_rdata);

  TrafficGenerator traffic("traffic");
  traffic.clk(clk);
  traffic.rst(rst);
  traffic.req_ready(req_ready);
  traffic.req_valid(req_valid);
  traffic.req_addr(req_addr);
  traffic.req_wdata(req_wdata);
  traffic.req_we(req_we);
  traffic.resp_valid(resp_valid);
  traffic.resp_rdata(resp_rdata);
  traffic.resp_hit(resp_hit);
  traffic.mem_req_valid(mem_req_valid);
  traffic.mem_req_addr(mem_req_addr);
  traffic.mem_req_we(mem_req_we);
  traffic.mem_req_wdata(mem_req_wdata);
  traffic.mem_resp_valid(mem_resp_valid);
  traffic.mem_resp_rdata(mem_resp_rdata);

  rst.write(true);
  sc_core::sc_start(50, sc_core::SC_NS);
  rst.write(false);

  std::cout << "[SystemC] Starting direct-mapped cache stress simulation" << std::endl;
  sc_core::sc_start(10000, sc_core::SC_NS);
  std::cout << "[SystemC] Simulation finished at " << sc_core::sc_time_stamp() << std::endl;

  return 0;
}
