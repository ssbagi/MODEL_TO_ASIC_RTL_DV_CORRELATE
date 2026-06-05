#include "TrafficGenerator.h"
#include <systemc.h>
#include <iostream>
#include <iomanip>

TrafficGenerator::TrafficGenerator(sc_core::sc_module_name name)
    : sc_core::sc_module(name), rng(0x5A5A5A5AULL) {
  SC_CTHREAD(generate, clk.pos());
  reset_signal_is(rst, true);
  SC_CTHREAD(memory_model, clk.pos());
  reset_signal_is(rst, true);
}

void TrafficGenerator::generate() {
  req_valid.write(false);
  req_addr.write(0);
  req_wdata.write(0);
  req_we.write(false);

  unsigned request_count = 0;
  unsigned response_count = 0;
  bool pending_request = false;
  sc_dt::sc_uint<ADDR_W> pending_addr = 0;
  sc_dt::sc_biguint<LINE_BITS> pending_data = 0;
  bool pending_we = false;

  wait();

  while (true) {
    if (rst.read()) {
      request_count = 0;
      response_count = 0;
      pending_request = false;
      req_valid.write(false);
      req_addr.write(0);
      req_wdata.write(0);
      req_we.write(false);
      wait();
      continue;
    }

    const bool ready = req_ready.read();
    const bool response_valid = resp_valid.read();
    const bool response_hit = resp_hit.read();

    if (!pending_request && request_count < 400 && ready) {
      const unsigned phase = request_count / 80;
      const uint32_t base_line = (request_count % NUM_LINES) * 16;
      const uint32_t aligned_addr = (phase == 0)
          ? base_line
          : (phase == 1)
              ? 0x00000040
              : (phase == 2)
                  ? (rng() & 0x00000FF0)
                  : (rng() & 0x0003FFF0);

      pending_addr = aligned_addr;
      pending_we = ((request_count % 3) == 0);
      pending_data = ((sc_dt::sc_biguint<LINE_BITS>)rng() << 64) | rng();
      pending_request = true;
      request_count += 1;

      std::cout << sc_core::sc_time_stamp() << " [Traffic] Issuing "
                << (pending_we ? "WRITE" : "READ") << " addr=0x" << std::hex
                << pending_addr << std::dec << " data=0x" << pending_data << "\n";
    }

    if (pending_request) {
      req_valid.write(true);
      req_addr.write(pending_addr);
      req_wdata.write(pending_data);
      req_we.write(pending_we);
    } else {
      req_valid.write(false);
      req_addr.write(0);
      req_wdata.write(0);
      req_we.write(false);
    }

    if (pending_request && ready) {
      pending_request = false;
    }

    if (response_valid) {
      response_count += 1;
      std::cout << sc_core::sc_time_stamp() << " [Traffic] Response " << response_count << " hit="
                << response_hit << " data=0x" << std::hex << resp_rdata.read() << std::dec << "\n";
    }

    if (request_count >= 400 && response_count >= 400) {
      std::cout << "[Traffic] Completed 400 transactions, stopping simulation." << std::endl;
      sc_core::sc_stop();
    }

    wait();
  }
}

void TrafficGenerator::memory_model() {
  mem_resp_valid.write(false);
  mem_resp_rdata.write(0);
  response_queue.clear();
  memory_store.clear();

  std::uniform_int_distribution<unsigned> latency_dist(2, 4);

  wait();

  while (true) {
    if (rst.read()) {
      response_queue.clear();
      mem_resp_valid.write(false);
      mem_resp_rdata.write(0);
      wait();
      continue;
    }

    const bool req_valid_i = mem_req_valid.read();
    const bool req_we_i = mem_req_we.read();
    const uint32_t addr_i = mem_req_addr.read().to_uint();
    const sc_dt::sc_biguint<LINE_BITS> write_data = mem_req_wdata.read();

    if (req_valid_i) {
      if (req_we_i) {
        memory_store[addr_i] = write_data;
        std::cout << sc_core::sc_time_stamp() << " [Memory] WRITEBACK addr=0x" << std::hex << addr_i << std::dec << "\n";
      } else {
        sc_dt::sc_biguint<LINE_BITS> line_data = 0;
        if (memory_store.count(addr_i)) {
          line_data = memory_store[addr_i];
        }
        response_queue.push_back({line_data, latency_dist(rng)});
        std::cout << sc_core::sc_time_stamp() << " [Memory] READ request addr=0x" << std::hex << addr_i << std::dec << " delay="
                  << response_queue.back().delay << "\n";
      }
    }

    bool responded = false;
    for (auto it = response_queue.begin(); it != response_queue.end(); ++it) {
      if (it->delay == 0) {
        mem_resp_valid.write(true);
        mem_resp_rdata.write(it->data);
        response_queue.erase(it);
        responded = true;
        break;
      }
    }

    if (!responded) {
      mem_resp_valid.write(false);
      mem_resp_rdata.write(0);
      for (auto& entry : response_queue) {
        if (entry.delay > 0) {
          entry.delay -= 1;
        }
      }
    }

    wait();
  }
}
