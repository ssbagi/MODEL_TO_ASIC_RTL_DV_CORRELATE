`ifndef DCACHE_ENV__SV
`define DCACHE_ENV__SV
class dcache_env extends uvm_env;
  `uvm_component_utils(dcache_env)

  dcache_agent      m_agent;
  dcache_scoreboard m_scoreboard;

  function new(string name="dcache_env", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_agent      = dcache_agent::type_id::create("m_agent", this);
    m_scoreboard = dcache_scoreboard::type_id::create("m_scoreboard", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    m_agent.m_monitor.ap.connect(m_scoreboard.ap_imp);
  endfunction
endclass : dcache_env

`endif  // DCACHE_ENV__SV
