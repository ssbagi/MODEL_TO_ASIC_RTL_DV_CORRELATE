//============================================================
// Simple Direct-Mapped Data Cache (Prototype RTL)
// DIAGRAM LIKE RTL ENGINEER
// CPU ---> Cache <--> Memory
// Signals on CPU side: req_valid, req_addr, req_wdata, req_we, req_ready, resp_valid, resp_rdata, resp_hit
// Signals on Memory side: mem_req_valid, mem_req_addr, mem_req_we, mem_req_wdata, mem_resp_valid, mem_resp_rdata
// Cache parameters: ADDR_W=32, LINE_BITS=128 (16B line), NUM_LINES=64 (1KB cache), INDEX_W=6, OFFSET_W=4, TAG_W=22
// req_valid ----> |              |  <---- mem_resp_valid
// req_addr  ----> | CACHE BLOCK  |  ----> mem_req_addr
// req_wdata ----> | CACHE BLOCK  |  ---->  mem_req_wdata
// req_we    ----> | CACHE BLOCK  |  ---->  mem_req_we
// req_ready <---- | CACHE BLOCK  |  ----> mem_req_valid
// resp_valid <--- |              |
// resp_rdata <--- |              |  <----  mem_resp_rdata
// resp_hit   <--- |              |
//============================================================
module dcache #(
  parameter ADDR_W    = 32,
  parameter LINE_BITS = 128,
  parameter NUM_LINES = 64,
  parameter INDEX_W   = 6,
  parameter OFFSET_W  = 4,
  parameter TAG_W     = ADDR_W - INDEX_W - OFFSET_W
)(
  input  logic                  clk,
  input  logic                  rst,

  // CPU side
  input  logic                  req_valid,
  input  logic [ADDR_W-1:0]     req_addr,
  input  logic [LINE_BITS-1:0]  req_wdata,
  input  logic                  req_we,
  output logic                  req_ready,

  output logic                  resp_valid,
  output logic [LINE_BITS-1:0]  resp_rdata,
  output logic                  resp_hit,

  // Memory side
  output logic                  mem_req_valid,
  output logic [ADDR_W-1:0]     mem_req_addr,
  output logic                  mem_req_we,
  output logic [LINE_BITS-1:0]  mem_req_wdata,
  input  logic                  mem_resp_valid,
  input  logic [LINE_BITS-1:0]  mem_resp_rdata
);

  // ----------------------------------------------------------
  // Address helpers
  // ----------------------------------------------------------
  function automatic [TAG_W-1:0] get_tag(input [ADDR_W-1:0] a);
    get_tag = a[ADDR_W-1 -: TAG_W];
  endfunction

  function automatic [INDEX_W-1:0] get_index(input [ADDR_W-1:0] a);
    get_index = a[OFFSET_W+INDEX_W-1 -: INDEX_W];
  endfunction

  // ----------------------------------------------------------
  // Latched request
  // ----------------------------------------------------------
  logic [ADDR_W-1:0]     req_addr_q;
  logic [LINE_BITS-1:0]  req_wdata_q;
  logic                  req_we_q;
  logic [TAG_W-1:0]      tag_q;
  logic [INDEX_W-1:0]    index_q;

  // ----------------------------------------------------------
  // Cache arrays
  // ----------------------------------------------------------
  logic [TAG_W-1:0]      tag_array   [NUM_LINES];
  logic                  valid_array [NUM_LINES];
  logic                  dirty_array [NUM_LINES];
  logic [LINE_BITS-1:0]  data_array  [NUM_LINES];

  wire hit_q = valid_array[index_q] && (tag_array[index_q] == tag_q);

  // ----------------------------------------------------------
  // FSM
  // ----------------------------------------------------------
  typedef enum logic [1:0] {S_IDLE, S_MISS, S_REFILL, S_RESP} state_t;
  state_t state, next;

  // CPU response registers
  logic                  resp_valid_q;
  logic [LINE_BITS-1:0]  resp_rdata_q;
  logic                  resp_hit_q;

  assign resp_valid = resp_valid_q;
  assign resp_rdata = resp_rdata_q;
  assign resp_hit   = resp_hit_q;

  // ----------------------------------------------------------
  // Sequential
  // ----------------------------------------------------------
  integer i;
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      state <= S_IDLE;
      resp_valid_q <= 0;
      resp_rdata_q <= 0;
      resp_hit_q   <= 0;

      for (i = 0; i < NUM_LINES; i++) begin
        valid_array[i] <= 0;
        dirty_array[i] <= 0;
        tag_array[i]   <= 0;
        data_array[i]  <= 0;
      end

      $display("[%0t] RESET: Cache cleared", $time);
    end
    else begin
      state <= next;
      resp_valid_q <= 0;

      // Latch request
      if (state == S_IDLE && req_valid && req_ready) begin
        req_addr_q  <= req_addr;
        req_wdata_q <= req_wdata;
        req_we_q    <= req_we;
        tag_q       <= get_tag(req_addr);
        index_q     <= get_index(req_addr);

        $display("[%0t] REQ_ACCEPT: we=%0b addr=%h index=%0d tag=%h",
                 $time, req_we, req_addr, get_index(req_addr), get_tag(req_addr));
      end

      // Write hit update
      if (state == S_RESP && req_we_q && hit_q) begin
        data_array[index_q]  <= req_wdata_q;
        dirty_array[index_q] <= 1'b1;

        $display("[%0t] WRITE_HIT: index=%0d tag=%h data=%h",
                 $time, index_q, tag_q, req_wdata_q);
      end

      // Refill completion
      if (state == S_REFILL && mem_resp_valid) begin
        data_array[index_q]  <= mem_resp_rdata;
        tag_array[index_q]   <= tag_q;
        valid_array[index_q] <= 1'b1;
        dirty_array[index_q] <= 1'b0;

        $display("[%0t] REFILL_DONE: index=%0d tag=%h data=%h",
                 $time, index_q, tag_q, mem_resp_rdata);
      end

      // CPU response
      if (state == S_RESP) begin
        resp_valid_q <= 1'b1;
        resp_hit_q   <= hit_q;
        resp_rdata_q <= data_array[index_q];

        $display("[%0t] RESP: hit=%0b index=%0d tag=%h data=%h",
                 $time, hit_q, index_q, tag_q, data_array[index_q]);
      end
    end
  end

  // ----------------------------------------------------------
  // Combinational FSM
  // ----------------------------------------------------------
  always_comb begin
    req_ready     = 0;
    mem_req_valid = 0;
    mem_req_we    = 0;
    mem_req_addr  = 0;
    mem_req_wdata = 0;

    next = state;

    case (state)

      // ------------------------------------------------------
      // IDLE
      // ------------------------------------------------------
      S_IDLE: begin
        req_ready = 1;

        if (req_valid) begin
          logic [TAG_W-1:0]   t = get_tag(req_addr);
          logic [INDEX_W-1:0] i = get_index(req_addr);

          if (valid_array[i] && tag_array[i] == t) begin
            $display("[%0t] HIT: addr=%h index=%0d tag=%h", $time, req_addr, i, t);
            next = S_RESP;
          end
          else begin
            $display("[%0t] MISS: addr=%h index=%0d tag=%h", $time, req_addr, i, t);

            mem_req_valid = 1;
            mem_req_we    = 0;
            mem_req_addr  = {t, i, {OFFSET_W{1'b0}}};

            $display("[%0t] MISS_REQ: mem_addr=%h", $time, mem_req_addr);

            next = S_MISS;
          end
        end
      end

      // ------------------------------------------------------
      // MISS
      // ------------------------------------------------------
      S_MISS: begin
        if (valid_array[index_q] && dirty_array[index_q]) begin
          mem_req_valid = 1;
          mem_req_we    = 1;
          mem_req_addr  = {tag_array[index_q], index_q, {OFFSET_W{1'b0}}};
          mem_req_wdata = data_array[index_q];

          $display("[%0t] WRITEBACK: index=%0d old_tag=%h data=%h",
                   $time, index_q, tag_array[index_q], data_array[index_q]);
        end

        next = S_REFILL;
      end

      // ------------------------------------------------------
      // REFILL
      // ------------------------------------------------------
      S_REFILL: begin
        if (mem_resp_valid) begin
          $display("[%0t] REFILL_RESP: data=%h", $time, mem_resp_rdata);
          next = S_RESP;
        end
      end

      // ------------------------------------------------------
      // RESP
      // ------------------------------------------------------
      S_RESP: begin
        next = S_IDLE;
      end

    endcase
  end

endmodule