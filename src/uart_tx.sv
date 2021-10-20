module uart_tx (
    input  logic clk,rst,
    input  logic [7:0] tdata,
    input  logic tvalid,
    output logic tready,
    output logic txd
);
    parameter WAIT_DIV = 5;
    localparam WAIT_LEN = $clog2(WAIT_DIV);

    typedef enum{
        STATE_IDLE,
        STATE_SEND
    }state_type;
    state_type state, n_state;
   
   logic [9:0] senddata, n_senddata;
   logic [WAIT_LEN-1:0] wait_cnt, n_wait_cnt;
   logic [3:0] bit_cnt, n_bit_cnt;
   logic n_tready;
   assign txd = senddata[0];
   always_comb begin 
       n_senddata = senddata;
       n_wait_cnt = wait_cnt;
       n_bit_cnt  = bit_cnt;
       n_state    = state;
       n_tready   = tready;
       if(state == STATE_IDLE) begin
           n_tready = 1;
           if(tvalid) begin
               n_senddata = {1'b1, tdata, 1'b0};
               n_state = STATE_SEND;
               n_tready = 0;
           end
       end else begin
           if (wait_cnt == WAIT_DIV -1) begin
               if (bit_cnt == 4'd9) begin
                   n_state = STATE_IDLE;
                   n_wait_cnt = 0;
                   n_bit_cnt = 0;
                   n_tready = 1;
               end else begin
                   n_bit_cnt = bit_cnt + 1'b1;
                   n_wait_cnt= 0;
                   n_senddata = {1'b1, senddata[9:1]};
               end
           end else begin
               n_wait_cnt = wait_cnt + 1'b1;
           end
           
       end
   end

   always_ff @( posedge clk ) begin 
       if (rst) begin
           state    <= STATE_IDLE;
           wait_cnt <= 0;
           bit_cnt  <= 0;
           senddata <= 10'h3ff;
           tready   <= 0;
       end else begin
           state    <= n_state;
           wait_cnt <= n_wait_cnt;
           bit_cnt  <= n_bit_cnt;
           senddata <= n_senddata;
           tready   <= n_tready;
       end
   end



endmodule