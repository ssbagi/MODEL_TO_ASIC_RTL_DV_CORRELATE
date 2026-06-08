`ifndef DCACHE_BASE_TEST__SV
`define DCACHE_BASE_TEST__SV
class dcache_base_test extends uvm_test;
  `uvm_component_utils(dcache_base_test)

  dcache_env m_env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_env = dcache_env::type_id::create("m_env", this);
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    begin dcache_tc_001_seq s; s = dcache_tc_001_seq::type_id::create("s"); s.start(m_env.m_agent.m_seqr); end
    begin dcache_tc_002_seq s; s = dcache_tc_002_seq::type_id::create("s"); s.start(m_env.m_agent.m_seqr); end
    begin dcache_tc_003_seq s; s = dcache_tc_003_seq::type_id::create("s"); s.start(m_env.m_agent.m_seqr); end
    begin dcache_tc_004_seq s; s = dcache_tc_004_seq::type_id::create("s"); s.start(m_env.m_agent.m_seqr); end
    begin dcache_tc_005_seq s; s = dcache_tc_005_seq::type_id::create("s"); s.start(m_env.m_agent.m_seqr); end
    begin dcache_tc_007_seq s; s = dcache_tc_007_seq::type_id::create("s"); s.start(m_env.m_agent.m_seqr); end
    begin dcache_tc_008_seq s; s = dcache_tc_008_seq::type_id::create("s"); s.start(m_env.m_agent.m_seqr); end
    begin dcache_tc_010_seq s; s = dcache_tc_010_seq::type_id::create("s"); s.start(m_env.m_agent.m_seqr); end
    begin dcache_tc_011_seq s; s = dcache_tc_011_seq::type_id::create("s"); s.start(m_env.m_agent.m_seqr); end
    begin dcache_tc_012_seq s; s = dcache_tc_012_seq::type_id::create("s"); s.start(m_env.m_agent.m_seqr); end
    begin dcache_tc_013_seq s; s = dcache_tc_013_seq::type_id::create("s"); s.start(m_env.m_agent.m_seqr); end
    begin dcache_tc_014_seq s; s = dcache_tc_014_seq::type_id::create("s"); s.start(m_env.m_agent.m_seqr); end
    begin dcache_tc_015_seq s; s = dcache_tc_015_seq::type_id::create("s"); s.start(m_env.m_agent.m_seqr); end
    begin dcache_tc_016_seq s; s = dcache_tc_016_seq::type_id::create("s"); s.start(m_env.m_agent.m_seqr); end
    begin dcache_tc_017_seq s; s = dcache_tc_017_seq::type_id::create("s"); s.start(m_env.m_agent.m_seqr); end
    begin dcache_tc_018_seq s; s = dcache_tc_018_seq::type_id::create("s"); s.start(m_env.m_agent.m_seqr); end
    begin dcache_tc_019_seq s; s = dcache_tc_019_seq::type_id::create("s"); s.start(m_env.m_agent.m_seqr); end
    begin dcache_tc_020_seq s; s = dcache_tc_020_seq::type_id::create("s"); s.start(m_env.m_agent.m_seqr); end
    begin dcache_tc_021_seq s; s = dcache_tc_021_seq::type_id::create("s"); s.start(m_env.m_agent.m_seqr); end
    begin dcache_tc_022_seq s; s = dcache_tc_022_seq::type_id::create("s"); s.start(m_env.m_agent.m_seqr); end
    begin dcache_tc_024_seq s; s = dcache_tc_024_seq::type_id::create("s"); s.start(m_env.m_agent.m_seqr); end
    begin dcache_tc_022_seq_2 s; s = dcache_tc_022_seq_2::type_id::create("s"); s.start(m_env.m_agent.m_seqr); end
    begin dcache_tc_023_seq s; s = dcache_tc_023_seq::type_id::create("s"); s.start(m_env.m_agent.m_seqr); end
    begin dcache_tc_024_seq_2 s; s = dcache_tc_024_seq_2::type_id::create("s"); s.start(m_env.m_agent.m_seqr); end
    phase.drop_objection(this);
  endtask
endclass : dcache_base_test

`endif  // DCACHE_BASE_TEST__SV
