// ============================================================
// File: dcache_alt_rw_seq.sv
// Author : Shreyas S Bagi + Copilot
// Description: Sequence alternating writes and reads across different addresses.
//              Helpful for exercising both write and read paths in one run.
// ============================================================
`include "uvm_macros.svh"
import uvm_pkg::*;

class dcache_alt_rw_seq extends dcache_base_seq;
  `uvm_object_utils(dcache_alt_rw_seq)

  function new(string name = "dcache_alt_rw_seq");
    super.new(name);
  endfunction

  task body();
    dcache_seq_item tr;
    foreach (int i[0:7]) begin
      tr = dcache_seq_item::type_id::create($sformatf("tr_%0d", i));
      if ((i % 2) == 0) begin
        $display("[DCACHE_ALT_RW_SEQ] Issuing WRITE addr=0x%h", 32'h3000 + i*16);
        `uvm_do_with(tr, { tr.we == 1;
                           tr.addr == 32'h3000 + i*16;
                           tr.wdata == {4{$random}}; })
      end else begin
        $display("[DCACHE_ALT_RW_SEQ] Issuing READ addr=0x%h", 32'h3000 + i*16);
        `uvm_do_with(tr, { tr.we == 0;
                           tr.addr == 32'h3000 + i*16;
                           tr.wdata == '0; })
      end
    end
  endtask
endclass
