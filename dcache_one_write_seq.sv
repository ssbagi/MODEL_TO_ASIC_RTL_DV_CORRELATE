`include "uvm_macros.svh"
import uvm_pkg::*;

class dcache_one_write_seq extends dcache_base_seq;
  `uvm_object_utils(dcache_one_write_seq)

  function new(string name = "dcache_one_write_seq");
    super.new(name);
  endfunction

  task body();
    dcache_seq_item tr;
    tr = dcache_seq_item::type_id::create("tr");
    $display("[DCACHE_ONE_WRITE_SEQ] Issuing 1 WRITE addr=0x%h data=0x%h", 32'h1000, 128'hDEADBEEF_DEADBEEF_DEADBEEF_DEADBEEF);
    `uvm_do_with(tr, { tr.we == 1;
                       tr.addr == 32'h1000;
                       tr.wdata == 128'hDEADBEEF_DEADBEEF_DEADBEEF_DEADBEEF; })
    $display("[DCACHE_ONE_WRITE_SEQ] WRITE issued.");
  endtask
endclass
