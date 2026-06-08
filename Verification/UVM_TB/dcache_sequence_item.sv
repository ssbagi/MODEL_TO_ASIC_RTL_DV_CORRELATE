`ifndef DCACHE_SEQUENCE_ITEM__SV
`define DCACHE_SEQUENCE_ITEM__SV
class dcache_sequence_item extends uvm_sequence_item;
  rand bit req_valid;
  rand bit [31:0] req_addr;
  rand bit [127:0] req_wdata;
  rand bit req_we;
  rand bit mem_resp_valid;
  rand bit [127:0] mem_resp_rdata;
  rand bit req_ready;
  rand bit resp_valid;
  rand bit [127:0] resp_rdata;
  rand bit resp_hit;
  rand bit mem_req_valid;
  rand bit [31:0] mem_req_addr;
  rand bit mem_req_we;
  rand bit [127:0] mem_req_wdata;
  `uvm_object_utils_begin(dcache_sequence_item)
    `uvm_field_int(req_valid, UVM_ALL_ON)
    `uvm_field_int(req_addr, UVM_ALL_ON)
    `uvm_field_int(req_wdata, UVM_ALL_ON)
    `uvm_field_int(req_we, UVM_ALL_ON)
    `uvm_field_int(req_ready, UVM_ALL_ON)
    `uvm_field_int(resp_valid, UVM_ALL_ON)
    `uvm_field_int(resp_rdata, UVM_ALL_ON)
    `uvm_field_int(resp_hit, UVM_ALL_ON)
    `uvm_field_int(mem_req_valid, UVM_ALL_ON)
    `uvm_field_int(mem_req_addr, UVM_ALL_ON)
    `uvm_field_int(mem_req_we, UVM_ALL_ON)
    `uvm_field_int(mem_req_wdata, UVM_ALL_ON)
    `uvm_field_int(mem_resp_valid, UVM_ALL_ON)
    `uvm_field_int(mem_resp_rdata, UVM_ALL_ON)
  `uvm_object_utils_end
  function new(string name="dcache_sequence_item");
    super.new(name);
  endfunction
endclass : dcache_sequence_item

`endif  // DCACHE_SEQUENCE_ITEM__SV
