`ifndef DCACHE_COVERAGE__SV
`define DCACHE_COVERAGE__SV
class dcache_coverage extends uvm_subscriber #(dcache_sequence_item);
  `uvm_component_utils(dcache_coverage)
  dcache_sequence_item m_item;
  covergroup cg;
    option.per_instance = 1;
    cp_req_valid: coverpoint m_item.req_valid;
    cp_req_addr: coverpoint m_item.req_addr;
    cp_req_wdata: coverpoint m_item.req_wdata;
    cp_req_we: coverpoint m_item.req_we;
    cp_req_ready: coverpoint m_item.req_ready;
    cp_resp_valid: coverpoint m_item.resp_valid;
    cp_resp_rdata: coverpoint m_item.resp_rdata;
    cp_resp_hit: coverpoint m_item.resp_hit;
    cp_mem_req_valid: coverpoint m_item.mem_req_valid;
    cp_mem_req_addr: coverpoint m_item.mem_req_addr;
    cp_mem_req_we: coverpoint m_item.mem_req_we;
    cp_mem_req_wdata: coverpoint m_item.mem_req_wdata;
    cp_mem_resp_valid: coverpoint m_item.mem_resp_valid;
    cp_mem_resp_rdata: coverpoint m_item.mem_resp_rdata;
  endgroup
  function new(string name="dcache_coverage", uvm_component parent=null);
    super.new(name, parent);
    cg = new();
  endfunction
  function void write(dcache_sequence_item t);
    m_item = t;
    cg.sample();
  endfunction
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("COV", $sformatf("[COV_REPORT] Overall Coverage: %0.1f%%", cg.get_inst_coverage()), UVM_NONE)
    `uvm_info("COV", $sformatf("[COV_REPORT] cp_req_valid: %0.1f%%", cg.cp_req_valid.get_coverage()), UVM_NONE)
    `uvm_info("COV", $sformatf("[COV_REPORT] cp_req_addr: %0.1f%%", cg.cp_req_addr.get_coverage()), UVM_NONE)
    `uvm_info("COV", $sformatf("[COV_REPORT] cp_req_wdata: %0.1f%%", cg.cp_req_wdata.get_coverage()), UVM_NONE)
    `uvm_info("COV", $sformatf("[COV_REPORT] cp_req_we: %0.1f%%", cg.cp_req_we.get_coverage()), UVM_NONE)
    `uvm_info("COV", $sformatf("[COV_REPORT] cp_req_ready: %0.1f%%", cg.cp_req_ready.get_coverage()), UVM_NONE)
    `uvm_info("COV", $sformatf("[COV_REPORT] cp_resp_valid: %0.1f%%", cg.cp_resp_valid.get_coverage()), UVM_NONE)
    `uvm_info("COV", $sformatf("[COV_REPORT] cp_resp_rdata: %0.1f%%", cg.cp_resp_rdata.get_coverage()), UVM_NONE)
    `uvm_info("COV", $sformatf("[COV_REPORT] cp_resp_hit: %0.1f%%", cg.cp_resp_hit.get_coverage()), UVM_NONE)
    `uvm_info("COV", $sformatf("[COV_REPORT] cp_mem_req_valid: %0.1f%%", cg.cp_mem_req_valid.get_coverage()), UVM_NONE)
    `uvm_info("COV", $sformatf("[COV_REPORT] cp_mem_req_addr: %0.1f%%", cg.cp_mem_req_addr.get_coverage()), UVM_NONE)
    `uvm_info("COV", $sformatf("[COV_REPORT] cp_mem_req_we: %0.1f%%", cg.cp_mem_req_we.get_coverage()), UVM_NONE)
    `uvm_info("COV", $sformatf("[COV_REPORT] cp_mem_req_wdata: %0.1f%%", cg.cp_mem_req_wdata.get_coverage()), UVM_NONE)
    `uvm_info("COV", $sformatf("[COV_REPORT] cp_mem_resp_valid: %0.1f%%", cg.cp_mem_resp_valid.get_coverage()), UVM_NONE)
    `uvm_info("COV", $sformatf("[COV_REPORT] cp_mem_resp_rdata: %0.1f%%", cg.cp_mem_resp_rdata.get_coverage()), UVM_NONE)
  endfunction
endclass : dcache_coverage

`endif  // DCACHE_COVERAGE__SV
