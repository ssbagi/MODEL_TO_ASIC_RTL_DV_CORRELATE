#ifndef TRAFFIC_GENERATOR_H
#define TRAFFIC_GENERATOR_H

#include <systemc.h>
#include <random>
#include <map>
#include <vector>

static const unsigned ADDR_WTG    = 32;
static const unsigned LINE_BITSTG = 128;
static const unsigned NUM_LINESTG = 64;

SC_MODULE(TrafficGenerator) {
  // Clock / reset
  sc_core::sc_in<bool> clk{"clk"};
  sc_core::sc_in<bool> rst{"rst"};

  // CPU side (to cache)
  sc_core::sc_out<bool>                           req_valid{"req_valid"};
  sc_core::sc_out<sc_dt::sc_uint<ADDR_WTG>>       req_addr{"req_addr"};
  sc_core::sc_out<sc_dt::sc_biguint<LINE_BITSTG>> req_wdata{"req_wdata"};
  sc_core::sc_out<bool>                           req_we{"req_we"};
  sc_core::sc_in<bool>                            req_ready{"req_ready"};

  sc_core::sc_in<bool>                            resp_valid{"resp_valid"};
  sc_core::sc_in<sc_dt::sc_biguint<LINE_BITSTG>>  resp_rdata{"resp_rdata"};
  sc_core::sc_in<bool>                            resp_hit{"resp_hit"};

  // Memory side (from cache)
  //sc_core::sc_in<bool>                            mem_req_valid{"mem_req_valid"};
  //sc_core::sc_in<sc_dt::sc_uint<ADDR_WTG>>        mem_req_addr{"mem_req_addr"};
  //sc_core::sc_in<bool>                            mem_req_we{"mem_req_we"};
  //sc_core::sc_in<sc_dt::sc_biguint<LINE_BITSTG>> mem_req_wdata{"mem_req_wdata"};
  //sc_core::sc_out<bool>                        mem_resp_valid{"mem_resp_valid"};
  //sc_core::sc_out<sc_dt::sc_biguint<LINE_BITSTG>> mem_resp_rdata{"mem_resp_rdata"};

  SC_CTOR(TrafficGenerator)
      : rng(0x5A5A5A5AULL) {
    //SC_CTHREAD(generate, clk.pos());
    SC_CTHREAD(dvtestcase_generate, clk.pos());
    reset_signal_is(rst, true);
    hit_count = 0;
    miss_count = 0;
    request_count = 0;
    response_count = 0;

    //SC_CTHREAD(memory_model, clk.pos());
    //reset_signal_is(rst, true);
  }

private:
  // Simple random engine
  std::mt19937_64 rng;

  struct RespEntry {
    sc_dt::sc_biguint<LINE_BITSTG> data;
    unsigned                     delay;
  };

  std::vector<RespEntry> response_queue;
  std::map<uint32_t, sc_dt::sc_biguint<LINE_BITSTG>> memory_store;
  unsigned hit_count;
  unsigned miss_count;
  unsigned request_count;
  unsigned response_count;

  virtual void end_of_simulation() override;
  void generate();
  void memory_model();
  void dvtestcase_generate();
};

#endif // TRAFFIC_GENERATOR_H
