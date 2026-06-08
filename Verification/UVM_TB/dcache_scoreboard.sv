`ifndef DCACHE_SCOREBOARD__SV
`define DCACHE_SCOREBOARD__SV
class dcache_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(dcache_scoreboard)
  uvm_analysis_imp #(dcache_sequence_item, dcache_scoreboard) ap_imp;
  int pass_count, fail_count;
  function new(string name="dcache_scoreboard", uvm_component parent=null);
    super.new(name, parent);
    ap_imp = new("ap_imp", this);
  endfunction
  function void write(dcache_sequence_item tr);
    // <<SLOT predict_and_compare>>  (AI/structured reference model here)
    // On each compared output:
    //   match -> `uvm_info("SCB", $sformatf("[PASS] ..."), UVM_MEDIUM); pass_count++;
    //   else  -> `uvm_error("FAIL", $sformatf("... exp=%0h got=%0h ...")); fail_count++;
  endfunction
  function void report_phase(uvm_phase phase);
    uvm_report_server svr = uvm_report_server::get_server();
    int unsigned uvm_errs = svr.get_severity_count(UVM_ERROR);
    int unsigned uvm_fatals = svr.get_severity_count(UVM_FATAL);
    `uvm_info("SCB_REPORT", $sformatf(
      "[SCOREBOARD] Total=%0d  Pass=%0d  Fail=%0d  UVM_ERROR=%0d  UVM_FATAL=%0d  ==> %s",
      pass_count+fail_count, pass_count, fail_count, uvm_errs, uvm_fatals,
      ((fail_count==0) && (uvm_errs==0) && (uvm_fatals==0)) ? "TEST PASSED" : "TEST FAILED"),
      UVM_NONE)
  endfunction
endclass : dcache_scoreboard

`endif  // DCACHE_SCOREBOARD__SV
