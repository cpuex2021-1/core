//`default_nettype none

module uart_rx (
    input  logic clk,rst,
    input  logic rxd,
    output logic [7:0] rdata,
    output logic rvalid 
);
  //parameter  WAIT_DIV = 5;  // for test
  parameter  WAIT_DIV = 434;  // for FPGA
  localparam WAIT_LEN = $clog2(WAIT_DIV);

  typedef enum{
    STATE_IDLE,
    STATE_START,
    STATE_RECV
  }state_type;
  state_type state, n_state;

  (* ASYNC_REG = "true" *) reg [2:0] sync_reg;
  logic [2:0] n_sync_reg;
  logic rxd_sync;

  logic [7:0] data_buf, n_data_buf;

  logic [7:0] n_rdata;
  logic n_rvalid;

  logic [13:0] cnt_start,n_cnt_start;
  logic [13:0] cnt,n_cnt;

  logic [3:0] data_got, n_data_got;

  assign rxd_sync = sync_reg[0];
  always_comb begin 
    n_sync_reg = {rxd, sync_reg[2:1]};
    n_data_buf = data_buf;
    n_state    = state;
    n_rdata    = rdata;
    n_rvalid   = 0;
    n_cnt      = 0;
    n_cnt_start= 0;
    n_data_got = data_got;
    if(state == STATE_IDLE) begin
      if (rxd_sync == 0) begin
        n_state = STATE_START;
      end

    end else if(state== STATE_START) begin
      n_cnt_start = rxd_sync ? 0 : cnt_start + 1;
      if(cnt_start == (WAIT_DIV /2) - 1) begin
        n_state = STATE_RECV;
      end

    end else begin
      // state == RECV
      if(cnt == WAIT_DIV -1) begin
        if(data_got == 8) begin
          n_state = STATE_IDLE;
          n_rvalid = 1;
          n_rdata = data_buf;
          n_data_got = 0;
        end else begin
          n_data_got = data_got + 1;
          n_data_buf = {rxd_sync, data_buf[7:1]};
        end
      end else begin
        n_cnt = cnt + 1;
      end
      
    end

    
  end

  always_ff @( posedge clk ) begin 
    if(rst) begin
      data_buf  <= 8'h00;
      sync_reg  <= 3'b111;
      rdata     <= 8'b0;
      rvalid    <= 0;
      cnt_start <= 0;
      cnt       <= 0;
      data_got  <= 0;
      state     <= STATE_IDLE;
    end else begin
      data_buf <= n_data_buf;
      sync_reg <= n_sync_reg;
      rdata    <= n_rdata;
      rvalid   <= n_rvalid;
      cnt_start<= n_cnt_start;
      cnt      <= n_cnt;
      data_got <= n_data_got;
      state    <= n_state;
    end

    
  end

endmodule
