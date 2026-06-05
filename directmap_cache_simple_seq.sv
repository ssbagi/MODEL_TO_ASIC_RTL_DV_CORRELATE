`include "uvm_macros.svh"
import uvm_pkg::*;

class dcache_simple_seq extends dcache_base_seq;
  `uvm_object_utils(dcache_simple_seq)

  function new(string name = "dcache_simple_seq");
    super.new(name);
  endfunction

  task body();
    dcache_seq_item tr;
    // Simple pattern: some stores then loads
    foreach (int i[0:15]) begin
      tr = dcache_seq_item::type_id::create("tr");
      `uvm_do_with(tr, { tr.we == 1; tr.addr == 32'h1000 + i*16; tr.wdata == {$random, $random, $random, $random}; })
    end

    foreach (int j[0:15]) begin
      tr = dcache_seq_item::type_id::create("tr");
      `uvm_do_with(tr, { tr.we == 0; tr.addr == 32'h1000 + j*16; tr.wdata == '0; })
    end
  endtask
endclass
