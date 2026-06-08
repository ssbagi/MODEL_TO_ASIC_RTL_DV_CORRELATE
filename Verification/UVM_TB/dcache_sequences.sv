`ifndef DCACHE_SEQUENCES__SV
`define DCACHE_SEQUENCES__SV
class dcache_base_sequence extends uvm_sequence #(dcache_sequence_item);
  `uvm_object_utils(dcache_base_sequence)
  function new(string name="dcache_base_sequence");
    super.new(name);
  endfunction
endclass : dcache_base_sequence

class dcache_tc_001_seq extends dcache_base_sequence;
  `uvm_object_utils(dcache_tc_001_seq)
  function new(string name="dcache_tc_001_seq");
    super.new(name);
  endfunction
  virtual task pre_body();
    `uvm_info("SEQ", $sformatf("[SEQ] starting %s", get_type_name()), UVM_MEDIUM)
  endtask
  virtual task post_body();
    `uvm_info("SEQ", $sformatf("[SEQ] finished %s", get_type_name()), UVM_MEDIUM)
  endtask
  virtual task body();
    dcache_sequence_item tr;
    // idle_ready_high: No request pending -> expect ready high
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.req_valid = 0;
    finish_item(tr);
    // valid_ready_accept: First request valid -> expect ready high for acceptance
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.req_valid = 1;
    tr.req_addr = 8'h40;
    finish_item(tr);
    // reset_ready_state: During reset -> expect ready low
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    finish_item(tr);
    // random sweep: saturate input-coverpoint bins for coverage closure
    repeat (50) begin
      tr = dcache_sequence_item::type_id::create("tr");
      start_item(tr);
      if (!tr.randomize() with {
        req_valid inside {0, 1};
      })
        `uvm_error(get_type_name(), "randomize failed")
      finish_item(tr);
    end
  endtask
endclass : dcache_tc_001_seq

class dcache_tc_002_seq extends dcache_base_sequence;
  `uvm_object_utils(dcache_tc_002_seq)
  function new(string name="dcache_tc_002_seq");
    super.new(name);
  endfunction
  virtual task pre_body();
    `uvm_info("SEQ", $sformatf("[SEQ] starting %s", get_type_name()), UVM_MEDIUM)
  endtask
  virtual task post_body();
    `uvm_info("SEQ", $sformatf("[SEQ] finished %s", get_type_name()), UVM_MEDIUM)
  endtask
  virtual task body();
    dcache_sequence_item tr;
    // mem_req_valid_1_resp_0: Memory request issued, response pending
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.mem_resp_valid = 0;
    finish_item(tr);
    // mem_req_valid_0_resp_1: Memory response received, request cleared
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.mem_resp_valid = 1;
    finish_item(tr);
    // mem_req_valid_0_resp_0: Idle state
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.mem_resp_valid = 0;
    tr.req_valid = 0;
    finish_item(tr);
    // random sweep: saturate input-coverpoint bins for coverage closure
    repeat (200) begin
      tr = dcache_sequence_item::type_id::create("tr");
      start_item(tr);
      if (!tr.randomize() with {
        mem_resp_valid dist {0:=80, 1:=20};
      })
        `uvm_error(get_type_name(), "randomize failed")
      finish_item(tr);
    end
  endtask
endclass : dcache_tc_002_seq

class dcache_tc_003_seq extends dcache_base_sequence;
  `uvm_object_utils(dcache_tc_003_seq)
  function new(string name="dcache_tc_003_seq");
    super.new(name);
  endfunction
  virtual task pre_body();
    `uvm_info("SEQ", $sformatf("[SEQ] starting %s", get_type_name()), UVM_MEDIUM)
  endtask
  virtual task post_body();
    `uvm_info("SEQ", $sformatf("[SEQ] finished %s", get_type_name()), UVM_MEDIUM)
  endtask
  virtual task body();
    dcache_sequence_item tr;
    // dirty_evict_max_data: Evicting a dirty line with max data
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.req_wdata = 8'hFF;
    tr.req_we = 1;
    finish_item(tr);
    // clean_evict_no_we: Evicting a clean line should not trigger write-back
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.req_we = 0;
    finish_item(tr);
    // mid_data_evict: Evicting a dirty line with mid-range data
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.req_wdata = 8'h80;
    tr.req_we = 1;
    finish_item(tr);
    // random sweep: saturate input-coverpoint bins for coverage closure
    repeat (500) begin
      tr = dcache_sequence_item::type_id::create("tr");
      start_item(tr);
      if (!tr.randomize() with {
        req_addr[5:0] == 6'h10;
      })
        `uvm_error(get_type_name(), "randomize failed")
      finish_item(tr);
    end
  endtask
endclass : dcache_tc_003_seq

class dcache_tc_004_seq extends dcache_base_sequence;
  `uvm_object_utils(dcache_tc_004_seq)
  function new(string name="dcache_tc_004_seq");
    super.new(name);
  endfunction
  virtual task pre_body();
    `uvm_info("SEQ", $sformatf("[SEQ] starting %s", get_type_name()), UVM_MEDIUM)
  endtask
  virtual task post_body();
    `uvm_info("SEQ", $sformatf("[SEQ] finished %s", get_type_name()), UVM_MEDIUM)
  endtask
  virtual task body();
    dcache_sequence_item tr;
    // write_miss_fetch_start: Write miss -> expect memory fetch (read)
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.req_valid = 1;
    tr.req_we = 1;
    finish_item(tr);
    // write_hit_no_fetch: Write hit -> no memory fetch needed
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.req_valid = 1;
    tr.req_we = 1;
    finish_item(tr);
    // idle_no_fetch: Idle -> no memory activity
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.req_valid = 0;
    finish_item(tr);
    // random sweep: saturate input-coverpoint bins for coverage closure
    repeat (500) begin
      tr = dcache_sequence_item::type_id::create("tr");
      start_item(tr);
      if (!tr.randomize() with {
        req_we == 1;
        req_valid dist {1:=70, 0:=30};
      })
        `uvm_error(get_type_name(), "randomize failed")
      finish_item(tr);
    end
  endtask
endclass : dcache_tc_004_seq

class dcache_tc_005_seq extends dcache_base_sequence;
  `uvm_object_utils(dcache_tc_005_seq)
  function new(string name="dcache_tc_005_seq");
    super.new(name);
  endfunction
  virtual task pre_body();
    `uvm_info("SEQ", $sformatf("[SEQ] starting %s", get_type_name()), UVM_MEDIUM)
  endtask
  virtual task post_body();
    `uvm_info("SEQ", $sformatf("[SEQ] finished %s", get_type_name()), UVM_MEDIUM)
  endtask
  virtual task body();
    dcache_sequence_item tr;
    // rst_1_resp_0: rst(input)=1 -> expect resp_valid(output)=0 - reset state
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    finish_item(tr);
    // rst_0_resp_0: rst(input)=0 -> expect resp_valid(output)=0 - idle state
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    finish_item(tr);
    // rst_1_req_v1_resp_0: rst(input)=1 and req_valid(input)=1 -> expect resp_valid(out
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.req_valid = 1;
    finish_item(tr);
    // random sweep: saturate input-coverpoint bins for coverage closure
    repeat (50) begin
      tr = dcache_sequence_item::type_id::create("tr");
      start_item(tr);
      if (!tr.randomize())
        `uvm_error(get_type_name(), "randomize failed")
      finish_item(tr);
    end
  endtask
endclass : dcache_tc_005_seq

class dcache_tc_007_seq extends dcache_base_sequence;
  `uvm_object_utils(dcache_tc_007_seq)
  function new(string name="dcache_tc_007_seq");
    super.new(name);
  endfunction
  virtual task pre_body();
    `uvm_info("SEQ", $sformatf("[SEQ] starting %s", get_type_name()), UVM_MEDIUM)
  endtask
  virtual task post_body();
    `uvm_info("SEQ", $sformatf("[SEQ] finished %s", get_type_name()), UVM_MEDIUM)
  endtask
  virtual task body();
    dcache_sequence_item tr;
    // we1_mem_we1: req_we(input)=1 -> expect mem_req_we(output)=1 - store opera
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.req_we = 1;
    tr.req_valid = 1;
    finish_item(tr);
    // we0_mem_we0: req_we(input)=0 -> expect mem_req_we(output)=0 - load operat
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.req_we = 0;
    tr.req_valid = 1;
    finish_item(tr);
    // weX_valid0_mem_we0: req_valid(input)=0 -> expect mem_req_we(output)=0 - idle
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.req_valid = 0;
    finish_item(tr);
    // random sweep: saturate input-coverpoint bins for coverage closure
    repeat (200) begin
      tr = dcache_sequence_item::type_id::create("tr");
      start_item(tr);
      if (!tr.randomize() with {
        req_valid == 1;
      })
        `uvm_error(get_type_name(), "randomize failed")
      finish_item(tr);
    end
  endtask
endclass : dcache_tc_007_seq

class dcache_tc_008_seq extends dcache_base_sequence;
  `uvm_object_utils(dcache_tc_008_seq)
  function new(string name="dcache_tc_008_seq");
    super.new(name);
  endfunction
  virtual task pre_body();
    `uvm_info("SEQ", $sformatf("[SEQ] starting %s", get_type_name()), UVM_MEDIUM)
  endtask
  virtual task post_body();
    `uvm_info("SEQ", $sformatf("[SEQ] finished %s", get_type_name()), UVM_MEDIUM)
  endtask
  virtual task body();
    dcache_sequence_item tr;
    // mem_data_max_resp_max: mem_resp_rdata(input)=8'hFF -> expect resp_rdata(output)=8'h
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.mem_resp_rdata = 8'hFF;
    tr.mem_resp_valid = 1;
    finish_item(tr);
    // mem_data_zero_resp_zero: mem_resp_rdata(input)=8'h00 -> expect resp_rdata(output)=8'h
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.mem_resp_rdata = 8'h00;
    tr.mem_resp_valid = 1;
    finish_item(tr);
    // mem_data_mid_resp_mid: mem_resp_rdata(input)=8'h80 -> expect resp_rdata(output)=8'h
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.mem_resp_rdata = 8'h80;
    tr.mem_resp_valid = 1;
    finish_item(tr);
    // random sweep: saturate input-coverpoint bins for coverage closure
    repeat (500) begin
      tr = dcache_sequence_item::type_id::create("tr");
      start_item(tr);
      if (!tr.randomize() with {
        mem_resp_valid == 1;
      })
        `uvm_error(get_type_name(), "randomize failed")
      finish_item(tr);
    end
  endtask
endclass : dcache_tc_008_seq

class dcache_tc_010_seq extends dcache_base_sequence;
  `uvm_object_utils(dcache_tc_010_seq)
  function new(string name="dcache_tc_010_seq");
    super.new(name);
  endfunction
  virtual task pre_body();
    `uvm_info("SEQ", $sformatf("[SEQ] starting %s", get_type_name()), UVM_MEDIUM)
  endtask
  virtual task post_body();
    `uvm_info("SEQ", $sformatf("[SEQ] finished %s", get_type_name()), UVM_MEDIUM)
  endtask
  virtual task body();
    dcache_sequence_item tr;
    // refill_data_zero: mem_resp_rdata=0(input) -> expect resp_rdata=0(output) - zer
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.mem_resp_valid = 1;
    tr.mem_resp_rdata = 8'h00;
    finish_item(tr);
    // refill_data_mid: mem_resp_rdata=127(input) -> expect resp_rdata=127(output) -
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.mem_resp_valid = 1;
    tr.mem_resp_rdata = 8'h7F;
    finish_item(tr);
    // refill_data_max: mem_resp_rdata=255(input) -> expect resp_rdata=255(output) -
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.mem_resp_valid = 1;
    tr.mem_resp_rdata = 8'hFF;
    finish_item(tr);
    // random sweep: saturate input-coverpoint bins for coverage closure
    repeat (200) begin
      tr = dcache_sequence_item::type_id::create("tr");
      start_item(tr);
      if (!tr.randomize() with {
        mem_resp_valid == 1;
      })
        `uvm_error(get_type_name(), "randomize failed")
      finish_item(tr);
    end
  endtask
endclass : dcache_tc_010_seq

class dcache_tc_011_seq extends dcache_base_sequence;
  `uvm_object_utils(dcache_tc_011_seq)
  function new(string name="dcache_tc_011_seq");
    super.new(name);
  endfunction
  virtual task pre_body();
    `uvm_info("SEQ", $sformatf("[SEQ] starting %s", get_type_name()), UVM_MEDIUM)
  endtask
  virtual task post_body();
    `uvm_info("SEQ", $sformatf("[SEQ] finished %s", get_type_name()), UVM_MEDIUM)
  endtask
  virtual task body();
    dcache_sequence_item tr;
    // req_addr_max_latch: max address(input)=8'hFF -> expect mem_req_addr(output)=8'hF
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.req_addr = 8'hFF;
    tr.req_valid = 1;
    finish_item(tr);
    // req_addr_zero_latch: zero address(input)=8'h00 -> expect mem_req_addr(output)=8'h
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.req_addr = 8'h00;
    tr.req_valid = 1;
    finish_item(tr);
    // req_addr_mid_latch: mid address(input)=8'h80 -> expect mem_req_addr(output)=8'h8
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.req_addr = 8'h80;
    tr.req_valid = 1;
    finish_item(tr);
    // random sweep: saturate input-coverpoint bins for coverage closure
    repeat (50) begin
      tr = dcache_sequence_item::type_id::create("tr");
      start_item(tr);
      if (!tr.randomize() with {
        req_valid == 1; req_ready == 1;
      })
        `uvm_error(get_type_name(), "randomize failed")
      finish_item(tr);
    end
  endtask
endclass : dcache_tc_011_seq

class dcache_tc_012_seq extends dcache_base_sequence;
  `uvm_object_utils(dcache_tc_012_seq)
  function new(string name="dcache_tc_012_seq");
    super.new(name);
  endfunction
  virtual task pre_body();
    `uvm_info("SEQ", $sformatf("[SEQ] starting %s", get_type_name()), UVM_MEDIUM)
  endtask
  virtual task post_body();
    `uvm_info("SEQ", $sformatf("[SEQ] finished %s", get_type_name()), UVM_MEDIUM)
  endtask
  virtual task body();
    dcache_sequence_item tr;
    // addr_0_hit: Load hit at minimum address
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.req_addr = 8'h00;
    tr.req_valid = 1;
    tr.req_we = 0;
    finish_item(tr);
    // addr_max_hit: Load hit at maximum address
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.req_addr = 8'hFF;
    tr.req_valid = 1;
    tr.req_we = 0;
    finish_item(tr);
    // addr_mid_hit: Load hit at mid-range address
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.req_addr = 8'h80;
    tr.req_valid = 1;
    tr.req_we = 0;
    finish_item(tr);
    // random sweep: saturate input-coverpoint bins for coverage closure
    repeat (50) begin
      tr = dcache_sequence_item::type_id::create("tr");
      start_item(tr);
      if (!tr.randomize() with {
        req_valid == 1; req_we == 0; resp_hit == 1;
      })
        `uvm_error(get_type_name(), "randomize failed")
      finish_item(tr);
    end
  endtask
endclass : dcache_tc_012_seq

class dcache_tc_013_seq extends dcache_base_sequence;
  `uvm_object_utils(dcache_tc_013_seq)
  function new(string name="dcache_tc_013_seq");
    super.new(name);
  endfunction
  virtual task pre_body();
    `uvm_info("SEQ", $sformatf("[SEQ] starting %s", get_type_name()), UVM_MEDIUM)
  endtask
  virtual task post_body();
    `uvm_info("SEQ", $sformatf("[SEQ] finished %s", get_type_name()), UVM_MEDIUM)
  endtask
  virtual task body();
    dcache_sequence_item tr;
    // addr_0_miss: Load miss at minimum address
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.req_addr = 8'h00;
    tr.req_valid = 1;
    tr.req_we = 0;
    finish_item(tr);
    // addr_max_miss: Load miss at maximum address
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.req_addr = 8'hFF;
    tr.req_valid = 1;
    tr.req_we = 0;
    finish_item(tr);
    // addr_mid_miss: Load miss at mid-range address
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.req_addr = 8'h80;
    tr.req_valid = 1;
    tr.req_we = 0;
    finish_item(tr);
    // random sweep: saturate input-coverpoint bins for coverage closure
    repeat (200) begin
      tr = dcache_sequence_item::type_id::create("tr");
      start_item(tr);
      if (!tr.randomize() with {
        req_valid == 1; req_we == 0; resp_hit == 0;
      })
        `uvm_error(get_type_name(), "randomize failed")
      finish_item(tr);
    end
  endtask
endclass : dcache_tc_013_seq

class dcache_tc_014_seq extends dcache_base_sequence;
  `uvm_object_utils(dcache_tc_014_seq)
  function new(string name="dcache_tc_014_seq");
    super.new(name);
  endfunction
  virtual task pre_body();
    `uvm_info("SEQ", $sformatf("[SEQ] starting %s", get_type_name()), UVM_MEDIUM)
  endtask
  virtual task post_body();
    `uvm_info("SEQ", $sformatf("[SEQ] finished %s", get_type_name()), UVM_MEDIUM)
  endtask
  virtual task body();
    dcache_sequence_item tr;
    // wdata_max_hit: Store max data on hit -> expect no memory request
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.req_valid = 1;
    tr.req_we = 1;
    tr.req_wdata = 8'hFF;
    finish_item(tr);
    // wdata_zero_hit: Store zero data on hit -> expect no memory request
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.req_valid = 1;
    tr.req_we = 1;
    tr.req_wdata = 8'h00;
    finish_item(tr);
    // wdata_mid_hit: Store mid data on hit -> expect no memory request
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.req_valid = 1;
    tr.req_we = 1;
    tr.req_wdata = 8'h7F;
    finish_item(tr);
    // random sweep: saturate input-coverpoint bins for coverage closure
    repeat (50) begin
      tr = dcache_sequence_item::type_id::create("tr");
      start_item(tr);
      if (!tr.randomize() with {
        req_valid == 1; req_we == 1; resp_hit == 1;
      })
        `uvm_error(get_type_name(), "randomize failed")
      finish_item(tr);
    end
  endtask
endclass : dcache_tc_014_seq

class dcache_tc_015_seq extends dcache_base_sequence;
  `uvm_object_utils(dcache_tc_015_seq)
  function new(string name="dcache_tc_015_seq");
    super.new(name);
  endfunction
  virtual task pre_body();
    `uvm_info("SEQ", $sformatf("[SEQ] starting %s", get_type_name()), UVM_MEDIUM)
  endtask
  virtual task post_body();
    `uvm_info("SEQ", $sformatf("[SEQ] finished %s", get_type_name()), UVM_MEDIUM)
  endtask
  virtual task body();
    dcache_sequence_item tr;
    // mem_rdata_max_miss: Store miss with max refill data -> expect memory request
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.req_valid = 1;
    tr.req_we = 1;
    tr.mem_resp_rdata = 8'hFF;
    finish_item(tr);
    // mem_rdata_zero_miss: Store miss with zero refill data -> expect memory request
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.req_valid = 1;
    tr.req_we = 1;
    tr.mem_resp_rdata = 8'h00;
    finish_item(tr);
    // mem_rdata_mid_miss: Store miss with mid refill data -> expect memory request
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.req_valid = 1;
    tr.req_we = 1;
    tr.mem_resp_rdata = 8'h7F;
    finish_item(tr);
    // random sweep: saturate input-coverpoint bins for coverage closure
    repeat (200) begin
      tr = dcache_sequence_item::type_id::create("tr");
      start_item(tr);
      if (!tr.randomize() with {
        req_valid == 1; req_we == 1; resp_hit == 0;
      })
        `uvm_error(get_type_name(), "randomize failed")
      finish_item(tr);
    end
  endtask
endclass : dcache_tc_015_seq

class dcache_tc_016_seq extends dcache_base_sequence;
  `uvm_object_utils(dcache_tc_016_seq)
  function new(string name="dcache_tc_016_seq");
    super.new(name);
  endfunction
  virtual task pre_body();
    `uvm_info("SEQ", $sformatf("[SEQ] starting %s", get_type_name()), UVM_MEDIUM)
  endtask
  virtual task post_body();
    `uvm_info("SEQ", $sformatf("[SEQ] finished %s", get_type_name()), UVM_MEDIUM)
  endtask
  virtual task body();
    dcache_sequence_item tr;
    // addr_0_miss_wb: Zero address miss triggers write-back
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.req_addr = 8'h00;
    tr.req_valid = 1;
    finish_item(tr);
    // addr_max_miss_wb: Max address miss triggers write-back
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.req_addr = 8'hFF;
    tr.req_valid = 1;
    finish_item(tr);
    // addr_mid_hit_no_wb: Cache hit should not trigger write-back
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.req_addr = 8'h80;
    tr.req_valid = 1;
    finish_item(tr);
    // random sweep: saturate input-coverpoint bins for coverage closure
    repeat (50) begin
      tr = dcache_sequence_item::type_id::create("tr");
      start_item(tr);
      if (!tr.randomize() with {
        req_addr inside {[64:127]}; req_wdata inside {[64:127]};
      })
        `uvm_error(get_type_name(), "randomize failed")
      finish_item(tr);
    end
  endtask
endclass : dcache_tc_016_seq

class dcache_tc_017_seq extends dcache_base_sequence;
  `uvm_object_utils(dcache_tc_017_seq)
  function new(string name="dcache_tc_017_seq");
    super.new(name);
  endfunction
  virtual task pre_body();
    `uvm_info("SEQ", $sformatf("[SEQ] starting %s", get_type_name()), UVM_MEDIUM)
  endtask
  virtual task post_body();
    `uvm_info("SEQ", $sformatf("[SEQ] finished %s", get_type_name()), UVM_MEDIUM)
  endtask
  virtual task body();
    dcache_sequence_item tr;
    // wb_zero_addr_zero_data: Evicting zero address with zero data
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.req_addr = 8'h00;
    tr.req_wdata = 8'h00;
    finish_item(tr);
    // wb_max_addr_max_data: Evicting max address with max data
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.req_addr = 8'hFF;
    tr.req_wdata = 8'hFF;
    finish_item(tr);
    // wb_mid_addr_mid_data: Evicting mid address with mid data
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.req_addr = 8'h80;
    tr.req_wdata = 8'h55;
    finish_item(tr);
    // random sweep: saturate input-coverpoint bins for coverage closure
    repeat (500) begin
      tr = dcache_sequence_item::type_id::create("tr");
      start_item(tr);
      if (!tr.randomize() with {
        req_addr[3:0] == 4'h0;
      })
        `uvm_error(get_type_name(), "randomize failed")
      finish_item(tr);
    end
  endtask
endclass : dcache_tc_017_seq

class dcache_tc_018_seq extends dcache_base_sequence;
  `uvm_object_utils(dcache_tc_018_seq)
  function new(string name="dcache_tc_018_seq");
    super.new(name);
  endfunction
  virtual task pre_body();
    `uvm_info("SEQ", $sformatf("[SEQ] starting %s", get_type_name()), UVM_MEDIUM)
  endtask
  virtual task post_body();
    `uvm_info("SEQ", $sformatf("[SEQ] finished %s", get_type_name()), UVM_MEDIUM)
  endtask
  virtual task body();
    dcache_sequence_item tr;
    // addr_zero_refill: Refill at address 0 should have we=0
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.req_addr = 8'h00;
    tr.req_valid = 1;
    finish_item(tr);
    // addr_max_refill: Refill at address 255 should have we=0
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.req_addr = 8'hFF;
    tr.req_valid = 1;
    finish_item(tr);
    // addr_mid_idle: No request should result in no memory request
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.req_addr = 8'h7F;
    tr.req_valid = 0;
    finish_item(tr);
    // random sweep: saturate input-coverpoint bins for coverage closure
    repeat (50) begin
      tr = dcache_sequence_item::type_id::create("tr");
      start_item(tr);
      if (!tr.randomize() with {
        req_valid == 1;
      })
        `uvm_error(get_type_name(), "randomize failed")
      finish_item(tr);
    end
  endtask
endclass : dcache_tc_018_seq

class dcache_tc_019_seq extends dcache_base_sequence;
  `uvm_object_utils(dcache_tc_019_seq)
  function new(string name="dcache_tc_019_seq");
    super.new(name);
  endfunction
  virtual task pre_body();
    `uvm_info("SEQ", $sformatf("[SEQ] starting %s", get_type_name()), UVM_MEDIUM)
  endtask
  virtual task post_body();
    `uvm_info("SEQ", $sformatf("[SEQ] finished %s", get_type_name()), UVM_MEDIUM)
  endtask
  virtual task body();
    dcache_sequence_item tr;
    // refill_data_zero: Install zero data and verify hit
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.mem_resp_valid = 1;
    tr.mem_resp_rdata = 8'h00;
    tr.req_valid = 1;
    finish_item(tr);
    // refill_data_max: Install max data and verify hit
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.mem_resp_valid = 1;
    tr.mem_resp_rdata = 8'hFF;
    tr.req_valid = 1;
    finish_item(tr);
    // refill_data_mid: Install mid data and verify hit
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.mem_resp_valid = 1;
    tr.mem_resp_rdata = 8'h7F;
    tr.req_valid = 1;
    finish_item(tr);
    // random sweep: saturate input-coverpoint bins for coverage closure
    repeat (200) begin
      tr = dcache_sequence_item::type_id::create("tr");
      start_item(tr);
      if (!tr.randomize() with {
        mem_resp_rdata inside {[0:255]};
      })
        `uvm_error(get_type_name(), "randomize failed")
      finish_item(tr);
    end
  endtask
endclass : dcache_tc_019_seq

class dcache_tc_020_seq extends dcache_base_sequence;
  `uvm_object_utils(dcache_tc_020_seq)
  function new(string name="dcache_tc_020_seq");
    super.new(name);
  endfunction
  virtual task pre_body();
    `uvm_info("SEQ", $sformatf("[SEQ] starting %s", get_type_name()), UVM_MEDIUM)
  endtask
  virtual task post_body();
    `uvm_info("SEQ", $sformatf("[SEQ] finished %s", get_type_name()), UVM_MEDIUM)
  endtask
  virtual task body();
    dcache_sequence_item tr;
    // addr_zero_hit: Zero address hit
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.req_addr = 8'h00;
    tr.req_valid = 1;
    finish_item(tr);
    // addr_mid_hit: Mid address hit
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.req_addr = 8'h80;
    tr.req_valid = 1;
    finish_item(tr);
    // addr_max_hit: Max address hit
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.req_addr = 8'hFF;
    tr.req_valid = 1;
    finish_item(tr);
    // random sweep: saturate input-coverpoint bins for coverage closure
    repeat (50) begin
      tr = dcache_sequence_item::type_id::create("tr");
      start_item(tr);
      if (!tr.randomize() with {
        req_valid == 1;
      })
        `uvm_error(get_type_name(), "randomize failed")
      finish_item(tr);
    end
  endtask
endclass : dcache_tc_020_seq

class dcache_tc_021_seq extends dcache_base_sequence;
  `uvm_object_utils(dcache_tc_021_seq)
  function new(string name="dcache_tc_021_seq");
    super.new(name);
  endfunction
  virtual task pre_body();
    `uvm_info("SEQ", $sformatf("[SEQ] starting %s", get_type_name()), UVM_MEDIUM)
  endtask
  virtual task post_body();
    `uvm_info("SEQ", $sformatf("[SEQ] finished %s", get_type_name()), UVM_MEDIUM)
  endtask
  virtual task body();
    dcache_sequence_item tr;
    // miss_addr_zero: Miss at address 0
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.req_addr = 8'h00;
    tr.req_valid = 1;
    finish_item(tr);
    // miss_addr_mid: Miss at mid address
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.req_addr = 8'h80;
    tr.req_valid = 1;
    finish_item(tr);
    // miss_addr_max: Miss at max address
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.req_addr = 8'hFF;
    tr.req_valid = 1;
    finish_item(tr);
    // random sweep: saturate input-coverpoint bins for coverage closure
    repeat (200) begin
      tr = dcache_sequence_item::type_id::create("tr");
      start_item(tr);
      if (!tr.randomize() with {
        resp_hit == 0;
      })
        `uvm_error(get_type_name(), "randomize failed")
      finish_item(tr);
    end
  endtask
endclass : dcache_tc_021_seq

class dcache_tc_022_seq extends dcache_base_sequence;
  `uvm_object_utils(dcache_tc_022_seq)
  function new(string name="dcache_tc_022_seq");
    super.new(name);
  endfunction
  virtual task pre_body();
    `uvm_info("SEQ", $sformatf("[SEQ] starting %s", get_type_name()), UVM_MEDIUM)
  endtask
  virtual task post_body();
    `uvm_info("SEQ", $sformatf("[SEQ] finished %s", get_type_name()), UVM_MEDIUM)
  endtask
  virtual task body();
    dcache_sequence_item tr;
    // mem_req_zero_addr: Memory request active for address 0
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.mem_resp_valid = 0;
    tr.req_valid = 1;
    finish_item(tr);
    // mem_req_mid_addr: Memory request active for mid address
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.mem_resp_valid = 0;
    tr.req_valid = 1;
    finish_item(tr);
    // mem_req_max_addr: Memory request active for max address
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.mem_resp_valid = 0;
    tr.req_valid = 1;
    finish_item(tr);
    // random sweep: saturate input-coverpoint bins for coverage closure
    repeat (200) begin
      tr = dcache_sequence_item::type_id::create("tr");
      start_item(tr);
      if (!tr.randomize() with {
        mem_resp_valid inside {0, 1};
      })
        `uvm_error(get_type_name(), "randomize failed")
      finish_item(tr);
    end
  endtask
endclass : dcache_tc_022_seq

class dcache_tc_024_seq extends dcache_base_sequence;
  `uvm_object_utils(dcache_tc_024_seq)
  function new(string name="dcache_tc_024_seq");
    super.new(name);
  endfunction
  virtual task pre_body();
    `uvm_info("SEQ", $sformatf("[SEQ] starting %s", get_type_name()), UVM_MEDIUM)
  endtask
  virtual task post_body();
    `uvm_info("SEQ", $sformatf("[SEQ] finished %s", get_type_name()), UVM_MEDIUM)
  endtask
  virtual task body();
    dcache_sequence_item tr;
    // req_addr_0_hit: zero address hit latency
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.req_addr = 8'h00;
    tr.req_valid = 1;
    finish_item(tr);
    // req_addr_mid_hit: mid address hit latency
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.req_addr = 8'h7F;
    tr.req_valid = 1;
    finish_item(tr);
    // req_addr_max_hit: max address hit latency
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.req_addr = 8'hFF;
    tr.req_valid = 1;
    finish_item(tr);
    // random sweep: saturate input-coverpoint bins for coverage closure
    repeat (50) begin
      tr = dcache_sequence_item::type_id::create("tr");
      start_item(tr);
      if (!tr.randomize() with {
        req_valid == 1;
      })
        `uvm_error(get_type_name(), "randomize failed")
      finish_item(tr);
    end
  endtask
endclass : dcache_tc_024_seq

class dcache_tc_022_seq_2 extends dcache_base_sequence;
  `uvm_object_utils(dcache_tc_022_seq_2)
  function new(string name="dcache_tc_022_seq_2");
    super.new(name);
  endfunction
  virtual task pre_body();
    `uvm_info("SEQ", $sformatf("[SEQ] starting %s", get_type_name()), UVM_MEDIUM)
  endtask
  virtual task post_body();
    `uvm_info("SEQ", $sformatf("[SEQ] finished %s", get_type_name()), UVM_MEDIUM)
  endtask
  virtual task body();
    dcache_sequence_item tr;
    // req_addr_0_accept: Minimum address request acceptance
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.req_addr = 8'h00;
    tr.req_valid = 1;
    tr.req_we = 0;
    finish_item(tr);
    // req_addr_max_accept: Maximum address request acceptance
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.req_addr = 8'hFF;
    tr.req_valid = 1;
    tr.req_we = 0;
    finish_item(tr);
    // req_addr_mid_accept: Mid-range address request acceptance
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.req_addr = 8'h7F;
    tr.req_valid = 1;
    tr.req_we = 0;
    finish_item(tr);
    // random sweep: saturate input-coverpoint bins for coverage closure
    repeat (50) begin
      tr = dcache_sequence_item::type_id::create("tr");
      start_item(tr);
      if (!tr.randomize() with {
        req_valid == 1;
      })
        `uvm_error(get_type_name(), "randomize failed")
      finish_item(tr);
    end
  endtask
endclass : dcache_tc_022_seq_2

class dcache_tc_023_seq extends dcache_base_sequence;
  `uvm_object_utils(dcache_tc_023_seq)
  function new(string name="dcache_tc_023_seq");
    super.new(name);
  endfunction
  virtual task pre_body();
    `uvm_info("SEQ", $sformatf("[SEQ] starting %s", get_type_name()), UVM_MEDIUM)
  endtask
  virtual task post_body();
    `uvm_info("SEQ", $sformatf("[SEQ] finished %s", get_type_name()), UVM_MEDIUM)
  endtask
  virtual task body();
    dcache_sequence_item tr;
    // mem_req_addr_0: Miss at bottom of memory range
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.req_addr = 8'h05;
    tr.req_valid = 1;
    finish_item(tr);
    // mem_req_addr_max: Miss at top of memory range
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.req_addr = 8'hF5;
    tr.req_valid = 1;
    finish_item(tr);
    // mem_req_addr_mid: Miss at mid memory range
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.req_addr = 8'h75;
    tr.req_valid = 1;
    finish_item(tr);
    // random sweep: saturate input-coverpoint bins for coverage closure
    repeat (200) begin
      tr = dcache_sequence_item::type_id::create("tr");
      start_item(tr);
      if (!tr.randomize() with {
        req_valid == 1;
      })
        `uvm_error(get_type_name(), "randomize failed")
      finish_item(tr);
    end
  endtask
endclass : dcache_tc_023_seq

class dcache_tc_024_seq_2 extends dcache_base_sequence;
  `uvm_object_utils(dcache_tc_024_seq_2)
  function new(string name="dcache_tc_024_seq_2");
    super.new(name);
  endfunction
  virtual task pre_body();
    `uvm_info("SEQ", $sformatf("[SEQ] starting %s", get_type_name()), UVM_MEDIUM)
  endtask
  virtual task post_body();
    `uvm_info("SEQ", $sformatf("[SEQ] finished %s", get_type_name()), UVM_MEDIUM)
  endtask
  virtual task body();
    dcache_sequence_item tr;
    automatic bit [31:0] prev_addr = 0;
    // serialized_min_max: First miss at 0, second miss at max
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.req_addr = 8'h00;
    finish_item(tr);
    // serialized_mid_mid: Consecutive misses in mid-range
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.req_addr = 8'h80;
    finish_item(tr);
    // serialized_idle_resp: CPU blocked while memory response is pending
    tr = dcache_sequence_item::type_id::create("tr");
    start_item(tr);
    void'(tr.randomize());
    tr.mem_resp_valid = 0;
    finish_item(tr);
    // random sweep: saturate input-coverpoint bins for coverage closure
    repeat (500) begin
      tr = dcache_sequence_item::type_id::create("tr");
      start_item(tr);
      if (!tr.randomize() with {
        req_addr[5:0] != prev_addr[5:0];
      })
        `uvm_error(get_type_name(), "randomize failed")
      finish_item(tr);
      prev_addr = tr.req_addr;
    end
  endtask
endclass : dcache_tc_024_seq_2
`endif  // DCACHE_SEQUENCES__SV
