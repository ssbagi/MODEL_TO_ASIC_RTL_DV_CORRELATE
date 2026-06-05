// ============================================================
// File: directmap_cache_seq_item.sv
// Description: UVM sequence item defining cache read/write transaction fields.
// Author : Shreyas S Bagi + Copilot
// ============================================================
class dcache_seq_item extends uvm_sequence_item;
  rand bit          we;
  rand bit [31:0]   addr;
  rand bit [127:0]  wdata;

  // For monitor/scoreboard
  bit [127:0]       rdata;
  bit               hit;

  `uvm_object_utils(dcache_seq_item)

  function new(string name="dcache_seq_item");
    super.new(name);
  endfunction

  function string convert2string();
    return $sformatf("we=%0d addr=%h wdata=%h rdata=%h hit=%0d",
                     we, addr, wdata, rdata, hit);
  endfunction
endclass
