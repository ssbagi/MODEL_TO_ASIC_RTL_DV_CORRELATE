// ============================================================
// File: directmap_cache_mult_wr_rd_seq.sv
// Author : Shreyas S Bagi + Copilot
// Description: Sequence generating random writes followed by matching reads.
//              Verifies data consistency and read-back behavior after writes.
// ============================================================
`include "uvm_macros.svh"
import uvm_pkg::*;

class dcache_mult_wr_rd_seq extends dcache_base_seq;
  `uvm_object_utils(dcache_mult_wr_rd_seq)

  function new(string name = "dcache_mult_wr_rd_seq");
    super.new(name);
  endfunction

  task body();
    int loop_var;
    bit [31:0] addrQ[$];
    bit [31:0] addr_gen, addr_t;
    dcache_seq_item tr;

    if (!uvm_config_db#(int)::get(null, "LOOP_VAR", "loop_var", loop_var)) begin
      `uvm_info("DCACHE_SEQ", "No LOOP_VAR in config DB, defaulting to 10", UVM_LOW)
      loop_var = 10;
    end
    if (loop_var <= 0)
      loop_var = 10;

    repeat (loop_var) begin
      addr_gen = $urandom_range(0, 32'hFFFFFFFF);
      addr_t = addr_gen & 32'hFFFFFFF0;

      tr = dcache_seq_item::type_id::create("tr");
      `uvm_do_with(tr, { tr.we == 1; tr.addr == addr_t; })
      addrQ.push_back(addr_t);
    end

    repeat (loop_var) begin
      addr_t = addrQ.pop_front();
      tr = dcache_seq_item::type_id::create("tr");
      `uvm_do_with(tr, { tr.we == 0; tr.addr == addr_t; })
    end
  endtask
endclass
