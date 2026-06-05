`include "uvm_macros.svh"
import uvm_pkg::*;

class dcache_one_read_seq extends dcache_base_seq;
  `uvm_object_utils(dcache_one_read_seq)

  function new(string name = "dcache_one_read_seq");
    super.new(name);
  endfunction

  task body();
    dcache_seq_item tr;
    tr = dcache_seq_item::type_id::create("tr");
    $display("[DCACHE_ONE_READ_SEQ] Issuing 1 READ addr=0x%h", 32'h1000);
    `uvm_do_with(tr, { tr.we == 0;
                       tr.addr == 32'h1000;
                       tr.wdata == '0; })
    $display("[DCACHE_ONE_READ_SEQ] READ issued.");
  endtask
endclass
