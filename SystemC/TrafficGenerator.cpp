#include "TrafficGenerator.h"
#include <iostream>
#include <iomanip>

void TrafficGenerator::generate() {
  req_valid.write(false);
  req_addr.write(0);
  req_wdata.write(0);
  req_we.write(false);

  bool pending_request    = false;
  sc_dt::sc_uint<ADDR_WTG>        pending_addr = 0;
  sc_dt::sc_biguint<LINE_BITSTG>  pending_data = 0;
  bool                            pending_we   = false;

  wait();

  while (true) {
    if (rst.read()) {
      request_count   = 0;
      response_count  = 0;
      hit_count       = 0;   // NEW
      miss_count      = 0;   // NEW
      pending_request = false;

      req_valid.write(false);
      req_addr.write(0);
      req_wdata.write(0);
      req_we.write(false);

      wait();
      continue;
    }

    const bool ready          = req_ready.read();
    const bool response_valid = resp_valid.read();
    const bool response_hit   = resp_hit.read();

    // Issue new request when ready and under limit
    if (!pending_request && request_count < 400 && ready) {
      const unsigned phase      = request_count / 80;
      const uint32_t base_line  = (request_count % NUM_LINESTG) * 16;
      const uint32_t aligned_addr =
          (phase == 0) ? base_line
        : (phase == 1) ? 0x00000040
        : (phase == 2) ? (rng() & 0x00000FF0)
                       : (rng() & 0x0003FFF0);

      pending_addr = aligned_addr;
      pending_we   = ((request_count % 3) == 0);
      pending_data = ((sc_dt::sc_biguint<LINE_BITSTG>)rng() << 64) | rng();

      pending_request = true;
      request_count++;

      std::cout << sc_core::sc_time_stamp()
                << " [Traffic] Issuing "
                << (pending_we ? "WRITE" : "READ")
                << " addr=0x" << std::hex << pending_addr
                << std::dec << " data=0x" << pending_data << "\n";
    }

    // Drive request
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

    // Handshake complete
    if (pending_request && ready) {
      pending_request = false;
    }

    // Consume response
    if (response_valid) {
      response_count++;

      // NEW: Count hit/miss
      if (response_hit) {
        hit_count++;
      } else {
        miss_count++;
      }

      std::cout << sc_core::sc_time_stamp()
                << " [Traffic] Response " << response_count
                << " hit=" << response_hit
                << " miss=" << !response_hit
                << " data=0x" << std::hex << resp_rdata.read()
                << std::dec << "\n";
    }
    wait();
  }
}

// DV Style : Performance Testcases : Same Testsuite considered for the work
void TrafficGenerator::dvtestcase_generate() {

    // ------------------------------
    // INITIALIZATION
    // ------------------------------
    req_valid.write(false);
    req_addr.write(0);
    req_wdata.write(0);
    req_we.write(false);

    hit_count = 0;
    miss_count = 0;

    wait(); // wait for reset release

    // Helper lambdas for CPU ops
    auto cpu_read = [&](uint32_t addr) {
        // Issue request
        req_valid.write(true);
        req_we.write(false);
        req_addr.write(addr);
        req_wdata.write(0);
        request_count++;
        wait(); // 1 cycle

        // Wait for handshake
        while (!req_ready.read()) wait();

        req_valid.write(false);

        // Wait for response
        while (!resp_valid.read()) wait();
        response_count++;
        bool hit = resp_hit.read();
        if (hit) hit_count++;
        else     miss_count++;

        std::cout << sc_time_stamp()
                  << " [CPU READ] addr=0x" << std::hex << addr
                  << " hit=" << hit
                  << " data=0x" << resp_rdata.read()
                  << std::dec << "\n";
    };

    auto cpu_write = [&](uint32_t addr, sc_dt::sc_biguint<128> data) {
        req_valid.write(true);
        req_we.write(true);
        req_addr.write(addr);
        req_wdata.write(data);
        request_count++;
        wait();

        while (!req_ready.read()) wait();

        req_valid.write(false);

        while (!resp_valid.read()) wait();
        response_count++;
        bool hit = resp_hit.read();
        if (hit) hit_count++;
        else     miss_count++;

        std::cout << sc_time_stamp()
                  << " [CPU WRITE] addr=0x" << std::hex << addr
                  << " hit=" << hit
                  << " data=0x" << data
                  << std::dec << "\n";
    };

    // ------------------------------
    // TEST ADDRESSES
    // ------------------------------
    uint32_t ADDR_A = 0x00001000;
    uint32_t ADDR_B = 0x10001000;

    // =========================================================
    // TEST 1: 10 READS
    // =========================================================
    std::cout << "\n===== TEST 1: 10 READS =====\n";
    for (int i = 0; i < 10; i++)
        cpu_read(ADDR_A);

    // =========================================================
    // TEST 2: 10 WRITES
    // =========================================================
    std::cout << "\n===== TEST 2: 10 WRITES =====\n";
    for (int i = 0; i < 10; i++)
        cpu_write(ADDR_A, ((sc_dt::sc_biguint<128>)rng() << 64) | rng());

    // =========================================================
    // TEST 3: 10 READ + WRITE pairs
    // =========================================================
    std::cout << "\n===== TEST 3: 10 READ + WRITE pairs =====\n";
    for (int i = 0; i < 10; i++) {
        cpu_read(ADDR_A);
        cpu_write(ADDR_A, ((sc_dt::sc_biguint<128>)rng() << 64) | rng());
    }

    // =========================================================
    // TEST 4: CONFLICT MISS STRESS
    // =========================================================
    std::cout << "\n===== TEST 4: CONFLICT MISS STRESS =====\n";
    for (int i = 0; i < 10; i++) {
        cpu_read(ADDR_A);
        cpu_read(ADDR_B);
    }

    // =========================================================
    // TEST 5: MEMORY COPYBACK STYLE
    // =========================================================
    std::cout << "\n===== TEST 5: MEMORY COPYBACK STYLE =====\n";
    for (int i = 0; i < 10; i++) {
        cpu_write(ADDR_A, ((sc_dt::sc_biguint<128>)rng() << 64) | rng());
        cpu_read(ADDR_B);
        cpu_read(ADDR_A);
    }

    // =========================================================
    // FINAL STATS
    // =========================================================
    unsigned total = hit_count + miss_count;
    double hit_ratio  = (total > 0) ? (double)hit_count / total : 0.0;
    double miss_ratio = (total > 0) ? (double)miss_count / total : 0.0;

    std::cout << "\n=========================================\n";
    std::cout << "              CACHE STATS\n";
    std::cout << "=========================================\n";
    std::cout << "Total Hits   = " << hit_count  << "\n";
    std::cout << "Total Misses = " << miss_count << "\n";
    std::cout << "Hit Ratio    = " << hit_ratio  << "\n";
    std::cout << "Miss Ratio   = " << miss_ratio << "\n";
    std::cout << "=========================================\n\n";

    sc_stop();
}
 

void TrafficGenerator::end_of_simulation() {
    double hit_ratio  = (response_count > 0)
                        ? (double)hit_count / response_count
                        : 0.0;

    double miss_ratio = (response_count > 0)
                        ? (double)miss_count / response_count
                        : 0.0;

    std::cout << "\n========== Traffic Summary ==========\n";
    std::cout << "Total Requests  : " << request_count  << "\n";
    std::cout << "Total Responses : " << response_count << "\n";
    std::cout << "Total Hits      : " << hit_count      << "\n";
    std::cout << "Total Misses    : " << miss_count     << "\n";
    std::cout << "Hit Ratio       : " << hit_ratio      << "\n";
    std::cout << "Miss Ratio      : " << miss_ratio     << "\n";
    std::cout << "=====================================\n\n";
}


/*
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

    const bool     req_valid_i = mem_req_valid.read();
    const bool     req_we_i    = mem_req_we.read();
    const uint32_t addr_i      = mem_req_addr.read().to_uint();
    const sc_dt::sc_biguint<LINE_BITSTG> write_data = mem_req_wdata.read();

    if (req_valid_i) {
      if (req_we_i) {
        // WRITEBACK from cache
        memory_store[addr_i] = write_data;
        std::cout << sc_core::sc_time_stamp()
                  << " [Memory] WRITEBACK addr=0x"
                  << std::hex << addr_i << std::dec << "\n";
      } else {
        // REFILL request
        sc_dt::sc_biguint<LINE_BITSTG> line_data = 0;
        if (memory_store.count(addr_i)) {
          line_data = memory_store[addr_i];
        }
        response_queue.push_back({line_data, latency_dist(rng)});
        std::cout << sc_core::sc_time_stamp()
                  << " [Memory] READ request addr=0x"
                  << std::hex << addr_i << std::dec
                  << " delay=" << response_queue.back().delay << "\n";
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
      for (auto &entry : response_queue) {
        if (entry.delay > 0) {
          entry.delay -= 1;
        }
      }
    }

    wait();
  }
}
*/
