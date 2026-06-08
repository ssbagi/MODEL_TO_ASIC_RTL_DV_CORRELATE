`ifndef DCACHE_AGENT__SV
`define DCACHE_AGENT__SV
class dcache_agent extends uvm_agent;
  `uvm_component_utils(dcache_agent)

  dcache_driver   m_driver;
  dcache_monitor  m_monitor;
  dcache_coverage m_coverage;
  uvm_sequencer #(dcache_sequence_item) m_seqr;

  function new(string name="dcache_agent", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_driver   = dcache_driver::type_id::create("m_driver", this);
    m_monitor  = dcache_monitor::type_id::create("m_monitor", this);
    m_coverage = dcache_coverage::type_id::create("m_coverage", this);
    m_seqr     = uvm_sequencer#(dcache_sequence_item)::type_id::create("m_seqr", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    m_driver.seq_item_port.connect(m_seqr.seq_item_export);
    m_monitor.ap.connect(m_coverage.analysis_export);
  endfunction
endclass : dcache_agent

`endif  // DCACHE_AGENT__SV
