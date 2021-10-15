//`default_nettype none

module uart_rx (
    input  logic clk,rst,
    input  logic rxd,
    output logic [7:0] rdata,
    output logic rvalid 
);
  parameter  WAIT_DIV = 608;  // care frequency!!
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

//module uart_rx #(CLK_PER_HALF_BIT = 433) (
//               output logic [7:0] rdata,
//               output logic       rvalid,
//               output logic       ferr,
//               input wire         rxd,
//               input wire         clk,
//               input wire         rst);
//   
//   
//   localparam e_clk_bit = CLK_PER_HALF_BIT * 2 - 1;
//    
//   localparam s_idle = 4'd0;
//   localparam s_start_bit = 4'd1;
//   localparam s_bit_0 = 4'd2;
//   localparam s_bit_1 = 4'd3;
//   localparam s_bit_2 = 4'd4;
//   localparam s_bit_3 = 4'd5;
//   localparam s_bit_4 = 4'd6;
//   localparam s_bit_5 = 4'd7;
//   localparam s_bit_6 = 4'd8;
//   localparam s_bit_7 = 4'd9;
//   localparam s_stop_bit = 4'd10;
//   localparam s_send  = 4'd11;
//   
//   (* mark_debug = "true" *)logic [31:0] counter;
//  (* mark_debug = "true" *) logic        rst_ctr;
//  (* mark_debug = "true" *) logic [9:0] rdatabuf;
//   (* ASYNC_REG = "true" *) reg [2:0] sync_reg;
//   (* ASYNC_REG = "true" *) reg [2:0] chat_reg;
//  (* mark_debug = "true" *) wire start = ~(|chat_reg);
//  (* mark_debug = "true" *) logic [3:0] status;
//  (* mark_debug = "true" *) logic start_next;
//  (* mark_debug = "true" *) logic next;
//
//   always @(posedge clk) begin
//    if(rst) begin
//      ferr <= 1'b0;
//      sync_reg <= 3'b111;
//      chat_reg <= 3'b111;
//
//      start_next <= 1'b0;
//      next <= 1'b0;
//    end else begin
//      sync_reg <= {sync_reg[1:0], rxd};
//      chat_reg <= {chat_reg[1:0], sync_reg[2]};
//        if(counter == e_clk_bit || rst_ctr)begin
//            counter <= 32'd0;
//        end else begin
//            counter <= counter + 32'd1;
//        end
//        if (~rst_ctr && counter == e_clk_bit) begin
//            next <= 1'b1;
//         end else begin
//            next <= 1'b0;
//         end
//         if (~rst_ctr && counter == CLK_PER_HALF_BIT) begin
//            start_next <= 1'b1;
//         end else begin
//            start_next <= 1'b0;
//         end
//    end
//   end
//   
//   always @(posedge clk) begin
//    if (rst) begin
//        rst_ctr <= 1'b0;
//        rdata <= 8'b0;
//        rdatabuf <= 10'b0;
//        rvalid <= 1'b0;
//        status <= 4'd0;
//    end else begin
//      rst_ctr <= 1'b0;
//      rvalid<= 1'b0;
//      if(status == 0)begin
//         if(start) begin
//                status <= s_start_bit;
//                rst_ctr <= 1'b1;
//            end
//     end else if (status == s_start_bit) begin
//        if(start_next) begin
//            rdatabuf[9] <= chat_reg[2];
//            status <= status + 4'd1;
//            rst_ctr <= 1'b1;
//        end
//    end else if (next) begin
//           if(status == s_send) begin
//              rdata <= rdatabuf[8:1];
//              rvalid<= 1'b1;
//             ferr <= ~rdatabuf[9];
//             status <= s_idle;
//         end else begin
//             rdatabuf <= {chat_reg[2], rdatabuf[9:1]};
//             rst_ctr <= 1'b1;
//              status <= status + 4'd1;
//         end
//       end
//     end
//   end
//endmodule
//`default_nettype wire