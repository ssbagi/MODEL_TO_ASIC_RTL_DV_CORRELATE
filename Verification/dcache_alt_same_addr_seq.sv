// ============================================================
// File: dcache_alt_same_addr_seq.sv
// Author : Shreyas S Bagi + Copilot
// Description: Sequence alternating write and read transactions to one address.
//              Provides focused coverage on cache line reuse and coherence.
// ============================================================
`include "uvm_macros.svh"
import uvm_pkg::*;

class dcache_alt_same_addr_seq extends dcache_base_seq;
  `uvm_object_utils(dcache_alt_same_addr_seq)

  function new(string name = "dcache_alt_same_addr_seq");
    super.new(name);
  endfunction

  task body();
    dcache_seq_item tr;
    foreach (int i[0:7]) begin
      tr = dcache_seq_item::type_id::create($sformatf("tr_%0d", i));
      if ((i % 2) == 0) begin
        $display("[DCACHE_ALT_SAME_ADDR_SEQ] Issuing WRITE #%0d addr=0x%h", i/2, 32'h2000);
        `uvm_do_with(tr, { tr.we == 1;
                           tr.addr == 32'h2000;
                           tr.wdata == {4{$random}}; })
      end else begin
        $display("[DCACHE_ALT_SAME_ADDR_SEQ] Issuing READ #%0d addr=0x%h", i/2, 32'h2000);
        `uvm_do_with(tr, { tr.we == 0;
                           tr.addr == 32'h2000;
                           tr.wdata == '0; })
      end
    end
  endtask
endclass
