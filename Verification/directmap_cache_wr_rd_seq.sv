// ============================================================
// File: directmap_cache_wr_rd_seq.sv
// Author : Shreyas S Bagi + Copilot
// Description: Derived UVM sequence for a write followed by a read.
//              Used to verify basic write-read cache behavior and response flow.
// ============================================================
`include "uvm_macros.svh"
import uvm_pkg::*;

class dcache_wr_rd_seq extends dcache_base_seq;
  `uvm_object_utils(dcache_wr_rd_seq)

  function new(string name = "dcache_wr_rd_seq");
    super.new(name);
  endfunction

  task body();
    dcache_seq_item write_req, read_req;
    bit [31:0] addr_t;

    write_req = dcache_seq_item::type_id::create("write_req");
    `uvm_do_with(write_req, { write_req.we == 1; })
    addr_t = write_req.addr;

    read_req = dcache_seq_item::type_id::create("read_req");
    `uvm_do_with(read_req, { read_req.we == 0; read_req.addr == addr_t; })
  endtask
endclass
