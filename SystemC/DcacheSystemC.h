#ifndef DCACHE_SYSTEMC_H
#define DCACHE_SYSTEMC_H

#include <systemc.h>
#include <array>

static const unsigned ADDR_W = 32;
static const unsigned LINE_BITS = 128;
static const unsigned NUM_LINES = 64;
static const unsigned INDEX_W = 6;
static const unsigned OFFSET_W = 4;
static const unsigned TAG_W = ADDR_W - INDEX_W - OFFSET_W;

SC_MODULE(DcacheSystemC) {
  sc_core::sc_in<bool> clk{"clk"};
  sc_core::sc_in<bool> rst{"rst"};

  sc_core::sc_in<bool> req_valid{"req_valid"};
  sc_core::sc_in<sc_dt::sc_uint<ADDR_W>> req_addr{"req_addr"};
  sc_core::sc_in<sc_dt::sc_biguint<LINE_BITS>> req_wdata{"req_wdata"};
  sc_core::sc_in<bool> req_we{"req_we"};
  sc_core::sc_out<bool> req_ready{"req_ready"};

  sc_core::sc_out<bool> resp_valid{"resp_valid"};
  sc_core::sc_out<sc_dt::sc_biguint<LINE_BITS>> resp_rdata{"resp_rdata"};
  sc_core::sc_out<bool> resp_hit{"resp_hit"};

  sc_core::sc_out<bool> mem_req_valid{"mem_req_valid"};
  sc_core::sc_out<sc_dt::sc_uint<ADDR_W>> mem_req_addr{"mem_req_addr"};
  sc_core::sc_out<bool> mem_req_we{"mem_req_we"};
  sc_core::sc_out<sc_dt::sc_biguint<LINE_BITS>> mem_req_wdata{"mem_req_wdata"};

  sc_core::sc_in<bool> mem_resp_valid{"mem_resp_valid"};
  sc_core::sc_in<sc_dt::sc_biguint<LINE_BITS>> mem_resp_rdata{"mem_resp_rdata"};

  enum state_t { S_IDLE, S_MISS, S_REFILL };

  DcacheSystemC(sc_core::sc_module_name name);

private:
  state_t state;
  sc_dt::sc_uint<ADDR_W> req_addr_q;
  sc_dt::sc_biguint<LINE_BITS> req_wdata_q;
  bool req_we_q;
  bool pending_response;
  bool pending_request_is_write;
  sc_dt::sc_uint<TAG_W> tag_q;
  sc_dt::sc_uint<INDEX_W> index_q;

  std::array<sc_dt::sc_uint<TAG_W>, NUM_LINES> tag_array;
  std::array<bool, NUM_LINES> valid_array;
  std::array<bool, NUM_LINES> dirty_array;
  std::array<sc_dt::sc_biguint<LINE_BITS>, NUM_LINES> data_array;

  void process();
};

#endif // DCACHE_SYSTEMC_H
