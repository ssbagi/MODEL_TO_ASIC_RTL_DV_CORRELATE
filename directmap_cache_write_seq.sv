`include "uvm_macros.svh"
import uvm_pkg::*;

class dcache_write_seq extends dcache_base_seq;
  `uvm_object_utils(dcache_write_seq)

  function new(string name = "dcache_write_seq");
    super.new(name);
  endfunction

  task body();
    dcache_seq_item tr;
    repeat (16) begin
      tr = dcache_seq_item::type_id::create("tr");
      `uvm_do_with(tr, { tr.we == 1; tr.addr == 32'h2000 + $urandom_range(0,15)*16; tr.wdata == {$random, $random, $random, $random}; })
    end
  endtask
endclass
