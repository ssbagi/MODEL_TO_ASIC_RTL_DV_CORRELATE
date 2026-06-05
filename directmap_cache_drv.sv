// ============================================================
// File: directmap_cache_drv.sv
// Description: UVM driver that drives requests into the direct-mapped cache interface.
// Author : Shreyas S Bagi + Copilot
// ============================================================
class dcache_driver extends uvm_driver #(dcache_seq_item);
  `uvm_component_utils(dcache_driver)

  virtual dcache_if.drv_mp vif;
  int txn_count;
  int timeout;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    if (!uvm_config_db#(virtual dcache_if.drv_mp)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "dcache_if not set for driver");
    $display("[DCACHE_DRIVER] Interface vif configured successfully.");
  endfunction

  task run_phase(uvm_phase phase);
    dcache_seq_item tr;
    // Wait for reset to complete before starting stimulus
    wait (!vif.rst);
    @(posedge vif.clk);

    forever begin
      seq_item_port.get_next_item(tr);
      txn_count++;

      //Hierarchy print
      tr.print();

      // Drive request: separate flows for WRITE and READ
      if (tr.we) begin
        // WRITE flow
        $display("\n[DCACHE_DRIVER-TXN#%0d] WRITE TRANSACTION", txn_count);
        $display("  Address: 0x%h", tr.addr);
        $display("  Write Data: 0x%h", tr.wdata);
        vif.req_valid <= 1;
        vif.req_addr  <= tr.addr;
        vif.req_wdata <= tr.wdata;
        vif.req_we    <= 1;
        $display("  [DCACHE_DRIVER] Waiting for req_ready...");

        timeout = 0;
        @(posedge vif.clk);
        while (!vif.req_ready) begin
          @(posedge vif.clk);
          timeout++;
          if (timeout > 1000)
            `uvm_fatal("NO_REQ_RDY", $sformatf("req_ready not asserted for WRITE transaction addr=0x%h", tr.addr));
        end
        $display("  [DCACHE_DRIVER] req_ready received. Request accepted.");

        // Deassert valid after accepted
        vif.req_valid <= 0;

        // Wait for write acknowledgement (no read data expected)
        $display("  [DCACHE_DRIVER] Waiting for resp_valid...");
        timeout = 0;
        do begin
          @(posedge vif.clk);
          timeout++;
          if (timeout > 1000)
            `uvm_fatal("NO_RESP", $sformatf("resp_valid not asserted for WRITE transaction addr=0x%h", tr.addr));
        end while (!vif.resp_valid);
        $display("  [DCACHE_DRIVER] Write response received. Transaction complete.\n");
        // For write transactions we don't collect response rdata into the seq_item

        seq_item_port.item_done();
      end
      else begin
        // READ flow
        $display("\n[DCACHE_DRIVER-TXN#%0d] READ TRANSACTION", txn_count);
        $display("  Address: 0x%h", tr.addr);
        vif.req_valid <= 1;
        vif.req_addr  <= tr.addr;
        vif.req_wdata <= '0;
        vif.req_we    <= 0;
        $display("  [DCACHE_DRIVER] Waiting for req_ready...");

        timeout = 0;
        @(posedge vif.clk);
        while (!vif.req_ready) begin
          @(posedge vif.clk);
          timeout++;
          if (timeout > 1000)
            `uvm_fatal("NO_REQ_RDY", $sformatf("req_ready not asserted for READ transaction addr=0x%h", tr.addr));
        end
        $display("  [DCACHE_DRIVER] req_ready received. Request accepted.");

        vif.req_valid <= 0;

        // Wait for response acknowledgement (monitor captures response details)
        $display("  [DCACHE_DRIVER] Waiting for resp_valid...");
        timeout = 0;
        do begin
          @(posedge vif.clk);
          timeout++;
          if (timeout > 1000)
            `uvm_fatal("NO_RESP", $sformatf("resp_valid not asserted for READ transaction addr=0x%h", tr.addr));
        end while (!vif.resp_valid);
        $display("  [DCACHE_DRIVER] Read response received. Transaction complete.\n");

        seq_item_port.item_done();
      end
    end
  endtask
endclass
