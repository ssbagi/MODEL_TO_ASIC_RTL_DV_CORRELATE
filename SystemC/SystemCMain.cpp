#include <systemc.h>
#include "DcacheSystemC.h"
#include "TrafficGenerator.h"

// Simple memory model for refill + writeback
SC_MODULE(SimpleMemory) {
  sc_in<bool> clk;
  sc_in<bool> rst;

  sc_in<bool> mem_req_valid;
  sc_in<sc_dt::sc_uint<32>> mem_req_addr;
  sc_in<bool> mem_req_we;
  sc_in<sc_dt::sc_biguint<128>> mem_req_wdata;

  sc_out<bool> mem_resp_valid;
  sc_out<sc_dt::sc_biguint<128>> mem_resp_rdata;

  static const unsigned MEM_LINES = 256;
  sc_dt::sc_biguint<128> mem_array[MEM_LINES];

  SC_CTOR(SimpleMemory) {
    SC_CTHREAD(run, clk.pos());
    reset_signal_is(rst, true);
  }

  void run() {
    mem_resp_valid.write(false);
    mem_resp_rdata.write(0);

    for (unsigned i = 0; i < MEM_LINES; i++)
      mem_array[i] = 0xABCD1234ULL + i;

    wait();

    while (true) {
      mem_resp_valid.write(false);

      if (mem_req_valid.read()) {
        unsigned index = (mem_req_addr.read() >> 4) & (MEM_LINES - 1);

        if (mem_req_we.read()) {
          mem_array[index] = mem_req_wdata.read();
        } else {
          mem_resp_rdata.write(mem_array[index]);
          mem_resp_valid.write(true);
        }
      }

      wait();
    }
  }
};

int sc_main(int argc, char* argv[]) {
  sc_clock clk("clk", 10, SC_NS);
  sc_signal<bool> rst;

  // CPU <-> Cache
  sc_signal<bool> req_valid;
  sc_signal<sc_uint<32>> req_addr;
  sc_signal<sc_biguint<128>> req_wdata;
  sc_signal<bool> req_we;
  sc_signal<bool> req_ready;

  sc_signal<bool> resp_valid;
  sc_signal<sc_biguint<128>> resp_rdata;
  sc_signal<bool> resp_hit;

  // Cache <-> Memory
  sc_signal<bool> mem_req_valid;
  sc_signal<sc_uint<32>> mem_req_addr;
  sc_signal<bool> mem_req_we;
  sc_signal<sc_biguint<128>> mem_req_wdata;
  sc_signal<bool> mem_resp_valid;
  sc_signal<sc_biguint<128>> mem_resp_rdata;

  // Cache
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

  // SimpleMemory (ONLY memory model)
  SimpleMemory mem("memory");
  mem.clk(clk);
  mem.rst(rst);
  mem.mem_req_valid(mem_req_valid);
  mem.mem_req_addr(mem_req_addr);
  mem.mem_req_we(mem_req_we);
  mem.mem_req_wdata(mem_req_wdata);
  mem.mem_resp_valid(mem_resp_valid);
  mem.mem_resp_rdata(mem_resp_rdata);

  // TrafficGenerator (CPU only)
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

  // DO NOT CONNECT traffic.mem_*  (Option B)

  rst.write(true);
  sc_start(50, SC_NS);
  rst.write(false);

  sc_start(50000, SC_NS);
  sc_stop();
  return 0;
}
