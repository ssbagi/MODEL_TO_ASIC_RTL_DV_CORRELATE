#include "DcacheSystemC.h"
#include <iostream>

DcacheSystemC::DcacheSystemC(sc_core::sc_module_name name)
    : sc_core::sc_module(name) {
  SC_CTHREAD(process, clk.pos());
  reset_signal_is(rst, true);
}

void DcacheSystemC::process() {
  // Reset outputs
  req_ready.write(false);
  resp_valid.write(false);
  resp_hit.write(false);
  resp_rdata.write(0);
  mem_req_valid.write(false);
  mem_req_we.write(false);
  mem_req_addr.write(0);
  mem_req_wdata.write(0);

  // Reset internal state
  state      = S_IDLE;
  req_addr_q = 0;
  req_wdata_q = 0;
  req_we_q   = false;
  tag_q      = 0;
  index_q    = 0;
  resp_hit_q = false;

  for (unsigned i = 0; i < NUM_LINES; ++i) {
    tag_array[i]   = 0;
    valid_array[i] = false;
    dirty_array[i] = false;
    data_array[i]  = 0;
  }

  wait();

  while (true) {
    // Sample inputs
    const bool                         req_valid_i      = req_valid.read();
    const sc_dt::sc_uint<ADDR_W>       req_addr_i       = req_addr.read();
    const sc_dt::sc_biguint<LINE_BITS> req_wdata_i      = req_wdata.read();
    const bool                         req_we_i         = req_we.read();
    const bool                         mem_resp_valid_i = mem_resp_valid.read();
    const sc_dt::sc_biguint<LINE_BITS> mem_resp_rdata_i = mem_resp_rdata.read();

    // Default outputs
    bool                         req_ready_o     = false;
    bool                         resp_valid_o    = false;
    bool                         resp_hit_o      = false;
    sc_dt::sc_biguint<LINE_BITS> resp_rdata_o    = 0;

    bool                         mem_req_valid_o = false;
    bool                         mem_req_we_o    = false;
    sc_dt::sc_uint<ADDR_W>       mem_req_addr_o  = 0;
    sc_dt::sc_biguint<LINE_BITS> mem_req_wdata_o = 0;

    state_t next_state = state;

    switch (state) {
      // ----------------------------------------------------
      // IDLE: accept new request, detect hit/miss
      // ----------------------------------------------------
      case S_IDLE: {
        req_ready_o = true;

        if (req_valid_i) {
          // Decode address
          sc_dt::sc_uint<TAG_W>   t   = req_addr_i.range(ADDR_W - 1, OFFSET_W + INDEX_W);
          sc_dt::sc_uint<INDEX_W> idx = req_addr_i.range(OFFSET_W + INDEX_W - 1, OFFSET_W);

          bool valid_now = valid_array[idx];
          bool hit_now   = valid_now && (tag_array[idx] == t);
          bool dirty_now = valid_now && dirty_array[idx];

          // Latch request and hit info
          req_addr_q  = req_addr_i;
          req_wdata_q = req_wdata_i;
          req_we_q    = req_we_i;
          tag_q       = t;
          index_q     = idx;
          resp_hit_q  = hit_now;

          if (hit_now) {
            // Hit: go directly to RESP
            std::cout << sc_core::sc_time_stamp()
                      << " [Dcache] HIT addr=0x" << std::hex << req_addr_i
                      << std::dec << " index=" << idx << " tag=0x" << std::hex << t << std::dec
                      << " we=" << req_we_i << "\n";
            next_state = S_RESP;
          } else {
            // Miss: decide writeback vs direct refill
            std::cout << sc_core::sc_time_stamp()
                      << " [Dcache] MISS addr=0x" << std::hex << req_addr_i
                      << std::dec << " index=" << idx << " tag=0x" << std::hex << t
                      << std::dec << " dirty=" << dirty_now << "\n";

            if (dirty_now) {
              // Dirty victim: writeback first
              mem_req_valid_o = true;
              mem_req_we_o    = true;
              mem_req_addr_o  =
                  (sc_dt::sc_uint<ADDR_W>(tag_array[idx]) << (INDEX_W + OFFSET_W)) |
                  (sc_dt::sc_uint<ADDR_W>(idx) << OFFSET_W);
              mem_req_wdata_o = data_array[idx];

              std::cout << sc_core::sc_time_stamp()
                        << " [Dcache] WRITEBACK_REQ addr=0x" << std::hex << mem_req_addr_o
                        << std::dec << " index=" << idx << "\n";

              next_state = S_MISS;
            } else {
              // Clean/invalid: direct refill
              mem_req_valid_o = true;
              mem_req_we_o    = false;
              mem_req_addr_o  =
                  (sc_dt::sc_uint<ADDR_W>(t) << (INDEX_W + OFFSET_W)) |
                  (sc_dt::sc_uint<ADDR_W>(idx) << OFFSET_W);

              std::cout << sc_core::sc_time_stamp()
                        << " [Dcache] REFILL_REQ (clean/invalid) addr=0x"
                        << std::hex << mem_req_addr_o << std::dec
                        << " index=" << idx << "\n";

              next_state = S_REFILL;
            }
          }
        }
        break;
      }

      // ----------------------------------------------------
      // MISS: writeback done, now issue refill for latched line
      // ----------------------------------------------------
      case S_MISS: {
        mem_req_valid_o = true;
        mem_req_we_o    = false;
        mem_req_addr_o  =
            (sc_dt::sc_uint<ADDR_W>(tag_q) << (INDEX_W + OFFSET_W)) |
            (sc_dt::sc_uint<ADDR_W>(index_q) << OFFSET_W);

        std::cout << sc_core::sc_time_stamp()
                  << " [Dcache] REFILL_REQ (after WB) addr=0x"
                  << std::hex << mem_req_addr_o << std::dec
                  << " index=" << index_q << "\n";

        next_state = S_REFILL;
        break;
      }

      // ----------------------------------------------------
      // REFILL: wait for memory response, install line
      // ----------------------------------------------------
      case S_REFILL: {
        if (mem_resp_valid_i) {
          // Install line
          data_array[index_q]  = mem_resp_rdata_i;
          tag_array[index_q]   = tag_q;
          valid_array[index_q] = true;

          if (req_we_q) {
            // Write-miss: apply write and mark dirty
            data_array[index_q]  = req_wdata_q;
            dirty_array[index_q] = true;

            std::cout << sc_core::sc_time_stamp()
                      << " [Dcache] REFILL+WRITE index=" << index_q
                      << " tag=0x" << std::hex << tag_q << std::dec << "\n";
          } else {
            // Read-miss: clean line
            dirty_array[index_q] = false;

            std::cout << sc_core::sc_time_stamp()
                      << " [Dcache] REFILL_DONE index=" << index_q
                      << " tag=0x" << std::hex << tag_q << std::dec << "\n";
          }

          next_state = S_RESP;
        }
        break;
      }

      // ----------------------------------------------------
      // RESP: one-cycle response to CPU
      // ----------------------------------------------------
      case S_RESP: {
        resp_valid_o = true;
        resp_hit_o   = resp_hit_q;
        // For reads: return line data; for writes: completion only (0)
        if (req_we_q) {
          resp_rdata_o = 0;
        } else {
          resp_rdata_o = data_array[index_q];
        }

        // Write-hit update (only if original access was a hit)
        if (req_we_q && resp_hit_q) {
          data_array[index_q]  = req_wdata_q;
          dirty_array[index_q] = true;

          std::cout << sc_core::sc_time_stamp()
                    << " [Dcache] WRITE_HIT index=" << index_q
                    << " tag=0x" << std::hex << tag_q << std::dec << "\n";
        }

        next_state = S_IDLE;
        break;
      }
    }

    // Drive outputs
    req_ready.write(req_ready_o);
    resp_valid.write(resp_valid_o);
    resp_hit.write(resp_hit_o);
    resp_rdata.write(resp_rdata_o);

    mem_req_valid.write(mem_req_valid_o);
    mem_req_we.write(mem_req_we_o);
    mem_req_addr.write(mem_req_addr_o);
    mem_req_wdata.write(mem_req_wdata_o);

    // Update state
    state = next_state;

    wait();
  }
}
