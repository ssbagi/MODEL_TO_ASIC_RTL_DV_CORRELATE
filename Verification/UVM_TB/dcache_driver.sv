`ifndef DCACHE_DRIVER__SV
`define DCACHE_DRIVER__SV
class dcache_driver extends uvm_driver #(dcache_sequence_item);
  `uvm_component_utils(dcache_driver)
  virtual dcache_if_tb vif;
  function new(string name="dcache_driver", uvm_component parent=null);
    super.new(name, parent);
  endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual dcache_if_tb)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "driver vif not set")
  endfunction
  task run_phase(uvm_phase phase);
    dcache_sequence_item tr;
    forever begin
      seq_item_port.get_next_item(tr);
      @(negedge vif.clk);
      vif.req_valid      <= tr.req_valid;
      vif.req_addr       <= tr.req_addr;
      vif.req_wdata      <= tr.req_wdata;
      vif.req_we         <= tr.req_we;
      vif.mem_resp_valid <= tr.mem_resp_valid;
      vif.mem_resp_rdata <= tr.mem_resp_rdata;
      `uvm_info("DRV", $sformatf("DRIVE op=%s req_valid=%0b req_addr=0x%0h req_wdata=0x%0h req_we=%0b mem_resp_valid=%0b mem_resp_rdata=0x%0h",
                (tr.req_we ? "WRITE" : "READ"), tr.req_valid, tr.req_addr, tr.req_wdata, tr.req_we, tr.mem_resp_valid, tr.mem_resp_rdata), UVM_MEDIUM)
      seq_item_port.item_done();
    end
  endtask
endclass : dcache_driver

`endif  // DCACHE_DRIVER__SV
