// ============================================================
// File: dcache_one_wr_one_rd_seq.sv
// Author : Shreyas S Bagi + Copilot
// Description: Sequence that issues one write then one read to the same address.
//              Used for quick verification of write and read transaction handling.
// ============================================================
`include "uvm_macros.svh"
import uvm_pkg::*;

class dcache_one_wr_one_rd_seq extends dcache_base_seq;
  `uvm_object_utils(dcache_one_wr_one_rd_seq)

  function new(string name = "dcache_one_wr_one_rd_seq");
    super.new(name);
  endfunction

  task body();
    dcache_seq_item write_req, read_req;
    write_req = dcache_seq_item::type_id::create("write_req");
    $display("[DCACHE_ONE_WR_ONE_RD_SEQ] Issuing WRITE addr=0x%h data=0x%h", 32'h1000, 128'hCAFEBABE_CAFEBABE_CAFEBABE_CAFEBABE);
    `uvm_do_with(write_req, { write_req.we == 1;
                               write_req.addr == 32'h1000;
                               write_req.wdata == 128'hCAFEBABE_CAFEBABE_CAFEBABE_CAFEBABE; })
    $display("[DCACHE_ONE_WR_ONE_RD_SEQ] WRITE issued.");

    read_req = dcache_seq_item::type_id::create("read_req");
    $display("[DCACHE_ONE_WR_ONE_RD_SEQ] Issuing READ addr=0x%h", 32'h1000);
    `uvm_do_with(read_req, { read_req.we == 0;
                              read_req.addr == 32'h1000;
                              read_req.wdata == '0; })
    $display("[DCACHE_ONE_WR_ONE_RD_SEQ] READ issued.");
  endtask
endclass
