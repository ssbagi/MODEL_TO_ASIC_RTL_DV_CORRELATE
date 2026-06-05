#include "DcacheSystemC.h"
#include <iostream>

DcacheSystemC::DcacheSystemC(sc_core::sc_module_name name)
    : sc_core::sc_module(name) {
  SC_CTHREAD(process, clk.pos());
  reset_signal_is(rst, true);
}

void DcacheSystemC::process() {
  req_ready.write(false);
  resp_valid.write(false);
  resp_hit.write(false);
  resp_rdata.write(0);
  mem_req_valid.write(false);
  mem_req_we.write(false);
  mem_req_addr.write(0);
  mem_req_wdata.write(0);

  state = S_IDLE;
  req_addr_q = 0;
  req_wdata_q = 0;
  req_we_q = false;
  pending_response = false;
  pending_request_is_write = false;
  tag_q = 0;
  index_q = 0;

  for (unsigned i = 0; i < NUM_LINES; ++i) {
    tag_array[i] = 0;
    valid_array[i] = false;
    dirty_array[i] = false;
    data_array[i] = 0;
  }

  wait();

  while (true) {
    const bool req_valid_i = req_valid.read();
    const auto req_addr_i = req_addr.read();
    const auto req_wdata_i = req_wdata.read();
    const bool req_we_i = req_we.read();
    const bool mem_resp_valid_i = mem_resp_valid.read();
    const auto mem_resp_rdata_i = mem_resp_rdata.read();

    const bool idle = (state == S_IDLE);
    req_ready.write(idle);

    const sc_dt::sc_uint<TAG_W> request_tag = req_addr_i.range(ADDR_W - 1, OFFSET_W + INDEX_W);
    const sc_dt::sc_uint<INDEX_W> request_index = req_addr_i.range(OFFSET_W + INDEX_W - 1, OFFSET_W);
    const bool issue_hit = idle && req_valid_i && valid_array[request_index] && (tag_array[request_index] == request_tag);
    const bool refill_response = (state == S_REFILL && mem_resp_valid_i && pending_response);

    if (issue_hit) {
      resp_valid.write(true);
      resp_hit.write(true);
      resp_rdata.write(data_array[request_index]);
    } else if (refill_response) {
      resp_valid.write(true);
      resp_hit.write(false);
      resp_rdata.write(mem_resp_rdata_i);
    } else {
      resp_valid.write(false);
      resp_hit.write(false);
      resp_rdata.write(0);
    }

    bool mem_req_valid_o = false;
    bool mem_req_we_o = false;
    sc_dt::sc_uint<ADDR_W> mem_req_addr_o = 0;
    sc_dt::sc_biguint<LINE_BITS> mem_req_wdata_o = 0;
    state_t next_state = state;

    switch (state) {
      case S_IDLE:
        if (req_valid_i) {
          if (issue_hit) {
            if (req_we_i) {
              data_array[request_index] = req_wdata_i;
              dirty_array[request_index] = true;
              std::cout << sc_core::sc_time_stamp() << " [Dcache] WRITE HIT addr=0x" << std::hex << req_addr_i << std::dec
                        << " index=" << request_index << "\n";
            } else {
              std::cout << sc_core::sc_time_stamp() << " [Dcache] READ HIT addr=0x" << std::hex << req_addr_i << std::dec
                        << " index=" << request_index << "\n";
            }
          } else {
            req_addr_q = req_addr_i;
            req_wdata_q = req_wdata_i;
            req_we_q = req_we_i;
            pending_response = true;
            pending_request_is_write = req_we_i;
            tag_q = request_tag;
            index_q = request_index;
            mem_req_valid_o = true;
            mem_req_we_o = false;
            mem_req_addr_o = (req_addr_i >> OFFSET_W) << OFFSET_W;
            next_state = S_MISS;
            std::cout << sc_core::sc_time_stamp() << " [Dcache] MISS addr=0x" << std::hex << req_addr_i << std::dec
                      << " index=" << request_index << "\n";
          }
        }
        break;

      case S_MISS:
        if (dirty_array[index_q]) {
          mem_req_valid_o = true;
          mem_req_we_o = true;
          mem_req_addr_o = ((sc_dt::sc_uint<ADDR_W>)tag_array[index_q] << (INDEX_W + OFFSET_W)) |
                          ((sc_dt::sc_uint<ADDR_W>)index_q << OFFSET_W);
          mem_req_wdata_o = data_array[index_q];
          std::cout << sc_core::sc_time_stamp() << " [Dcache] WRITEBACK index=" << index_q << " tag=0x" << std::hex
                    << tag_array[index_q] << std::dec << "\n";
        }
        next_state = S_REFILL;
        break;

      case S_REFILL:
        if (mem_resp_valid_i) {
          data_array[index_q] = mem_resp_rdata_i;
          tag_array[index_q] = tag_q;
          valid_array[index_q] = true;
          dirty_array[index_q] = false;
          pending_response = false;
          next_state = S_IDLE;
          std::cout << sc_core::sc_time_stamp() << " [Dcache] REFILL complete index=" << index_q << " tag=0x" << std::hex
                    << tag_q << std::dec << "\n";
        }
        break;
    }

    mem_req_valid.write(mem_req_valid_o);
    mem_req_we.write(mem_req_we_o);
    mem_req_addr.write(mem_req_addr_o);
    mem_req_wdata.write(mem_req_wdata_o);
    state = next_state;

    wait();
  }
}
