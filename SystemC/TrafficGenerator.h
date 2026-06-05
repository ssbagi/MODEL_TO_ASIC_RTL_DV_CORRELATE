#ifndef TRAFFIC_GENERATOR_H
#define TRAFFIC_GENERATOR_H

#include <systemc.h>
#include <deque>
#include <random>
#include <unordered_map>

static const unsigned ADDR_W = 32;
static const unsigned LINE_BITS = 128;
static const unsigned NUM_LINES = 64;

SC_MODULE(TrafficGenerator) {
  sc_core::sc_in<bool> clk{"clk"};
  sc_core::sc_in<bool> rst{"rst"};

  sc_core::sc_in<bool> req_ready{"req_ready"};
  sc_core::sc_out<bool> req_valid{"req_valid"};
  sc_core::sc_out<sc_dt::sc_uint<ADDR_W>> req_addr{"req_addr"};
  sc_core::sc_out<sc_dt::sc_biguint<LINE_BITS>> req_wdata{"req_wdata"};
  sc_core::sc_out<bool> req_we{"req_we"};

  sc_core::sc_in<bool> resp_valid{"resp_valid"};
  sc_core::sc_in<sc_dt::sc_biguint<LINE_BITS>> resp_rdata{"resp_rdata"};
  sc_core::sc_in<bool> resp_hit{"resp_hit"};

  sc_core::sc_in<bool> mem_req_valid{"mem_req_valid"};
  sc_core::sc_in<sc_dt::sc_uint<ADDR_W>> mem_req_addr{"mem_req_addr"};
  sc_core::sc_in<bool> mem_req_we{"mem_req_we"};
  sc_core::sc_in<sc_dt::sc_biguint<LINE_BITS>> mem_req_wdata{"mem_req_wdata"};
  sc_core::sc_out<bool> mem_resp_valid{"mem_resp_valid"};
  sc_core::sc_out<sc_dt::sc_biguint<LINE_BITS>> mem_resp_rdata{"mem_resp_rdata"};

  TrafficGenerator(sc_core::sc_module_name name);

private:
  struct PendingResponse {
    sc_dt::sc_biguint<LINE_BITS> data;
    unsigned delay;
  };

  std::deque<PendingResponse> response_queue;
  std::unordered_map<uint32_t, sc_dt::sc_biguint<LINE_BITS>> memory_store;
  std::mt19937_64 rng;

  void generate();
  void memory_model();
};

#endif // TRAFFIC_GENERATOR_H
