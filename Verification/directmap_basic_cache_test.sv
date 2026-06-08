`timescale 1ns/1ps

module tb_dcache;

  reg clk, rst;
  reg [31:0] ADDR_A, ADDR_B;
  reg         req_valid;
  reg [31:0]  req_addr;
  reg [127:0] req_wdata;
  reg         req_we;
  wire        req_ready;
  real hit_ratio;
  real miss_ratio;
  wire        resp_valid;
  wire [127:0] resp_rdata;
  wire        resp_hit;

  wire        mem_req_valid;
  wire [31:0] mem_req_addr;
  wire        mem_req_we;
  wire [127:0] mem_req_wdata;
  reg         mem_resp_valid;
  reg [127:0] mem_resp_rdata;

  // DUT
  dcache dut(
    .clk(clk),
    .rst(rst),
    .req_valid(req_valid),
    .req_addr(req_addr),
    .req_wdata(req_wdata),
    .req_we(req_we),
    .req_ready(req_ready),
    .resp_valid(resp_valid),
    .resp_rdata(resp_rdata),
    .resp_hit(resp_hit),
    .mem_req_valid(mem_req_valid),
    .mem_req_addr(mem_req_addr),
    .mem_req_we(mem_req_we),
    .mem_req_wdata(mem_req_wdata),
    .mem_resp_valid(mem_resp_valid),
    .mem_resp_rdata(mem_resp_rdata)
  );

  // Clock
  always #5 clk = ~clk;

  // Simple memory model: respond 2 cycles after request
  reg [1:0] mem_delay;

  always @(posedge clk) begin
    if (mem_req_valid && !mem_req_we) begin
      mem_delay <= 2;
      mem_resp_valid <= 0;
      mem_resp_rdata <= {4{mem_req_addr}};
      $display("[%0t] MEM: READ req addr=%h", $time, mem_req_addr);
    end
    else if (mem_req_valid && mem_req_we) begin
      $display("[%0t] MEM: WRITEBACK addr=%h data=%h",
               $time, mem_req_addr, mem_req_wdata);
    end
    else if (mem_delay != 0) begin
      mem_delay <= mem_delay - 1;
      if (mem_delay == 1) begin
        mem_resp_valid <= 1;
        $display("[%0t] MEM: RESP data=%h", $time, mem_resp_rdata);
      end
    end
    else begin
      mem_resp_valid <= 0;
    end
  end

  // ---------------------------------------------------------
  // HIT / MISS COUNTERS
  // ---------------------------------------------------------
  integer hit_count;
  integer miss_count;

  always @(posedge clk) begin
    if (dut.state == dut.S_IDLE && req_valid && req_ready) begin
        if (!(dut.valid_array[dut.get_index(req_addr)] &&
              dut.tag_array[dut.get_index(req_addr)] == dut.get_tag(req_addr))) begin
            miss_count <= miss_count + 1;
        end
        else begin
            hit_count <= hit_count + 1;
        end
    end
end


  // ------------------------------
  // TASKS
  // ------------------------------

  task cpu_read(input [31:0] addr);
    begin
      @(posedge clk);
      req_valid <= 1;
      req_we    <= 0;
      req_addr  <= addr;
      req_wdata <= 0;

      @(posedge clk);
      while (!req_ready) @(posedge clk);
      req_valid <= 0;

      while (!resp_valid) @(posedge clk);
      $display("[%0t] CPU READ: addr=%h hit=%b data=%h",
               $time, addr, resp_hit, resp_rdata);
    end
  endtask

  task cpu_write(input [31:0] addr, input [127:0] data);
    begin
      @(posedge clk);
      req_valid <= 1;
      req_we    <= 1;
      req_addr  <= addr;
      req_wdata <= data;

      @(posedge clk);
      while (!req_ready) @(posedge clk);
      req_valid <= 0;

      while (!resp_valid) @(posedge clk);
      $display("[%0t] CPU WRITE: addr=%h hit=%b data=%h",
               $time, addr, resp_hit, data);
    end
  endtask

  // ------------------------------
  // TEST SEQUENCE
  // ------------------------------

  initial begin
    clk = 0;
    rst = 1;
    req_valid = 0;
    mem_resp_valid = 0;
    mem_delay = 0;

    hit_count = 0;
    miss_count = 0;

    repeat(5) @(posedge clk);
    rst = 0;

    ADDR_A = 32'h0000_1000;
    ADDR_B = 32'h1000_1000;

    // ---------------------------------------------------------
    // 10 READS
    // ---------------------------------------------------------
    $display("\n===== TEST 1: 10 READS =====");
    repeat (10) begin
      cpu_read(ADDR_A);
    end

    // ---------------------------------------------------------
    // 10 WRITES
    // ---------------------------------------------------------
    $display("\n===== TEST 2: 10 WRITES =====");
    repeat (10) begin
      cpu_write(ADDR_A, {$random, $random, $random, $random});
    end

    // ---------------------------------------------------------
    // 10 READ + WRITE pairs
    // ---------------------------------------------------------
    $display("\n===== TEST 3: 10 READ + WRITE pairs =====");
    repeat (10) begin
      cpu_read(ADDR_A);
      cpu_write(ADDR_A, {$random, $random, $random, $random});
    end

    // ---------------------------------------------------------
    // Conflict Miss Stress
    // ---------------------------------------------------------
    $display("\n===== TEST 4: CONFLICT MISS STRESS =====");
    repeat (10) begin
      cpu_read(ADDR_A);
      cpu_read(ADDR_B);
    end

    // ---------------------------------------------------------
    // Memory Copyback Style Stress
    // ---------------------------------------------------------
    $display("\n===== TEST 5: MEMORY COPYBACK STYLE =====");
    repeat (10) begin
      cpu_write(ADDR_A, {$random, $random, $random, $random});
      cpu_read(ADDR_B);
      cpu_read(ADDR_A);
    end

    // ---------------------------------------------------------
    // FINAL STATS
    // ---------------------------------------------------------
    $display("\n=========================================");
    $display("              CACHE STATS");
    $display("=========================================");
    $display("Total Hits   = %0d", hit_count);
    $display("Total Misses = %0d", miss_count);

    hit_ratio  = hit_count  * 1.0 / (hit_count + miss_count);
    miss_ratio = miss_count * 1.0 / (hit_count + miss_count);

    $display("Hit Ratio    = %f", hit_ratio);
    $display("Miss Ratio   = %f", miss_ratio);
    $display("=========================================\n");

    #50 $finish;
  end

endmodule
