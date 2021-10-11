`default_nettype none

module uart_rx #(CLK_PER_HALF_BIT = 5208) (
               output logic [7:0] rdata,
               output logic       rdata_ready,
               output logic       ferr,
               input wire         rxd,
               input wire         clk,
               input wire         rstn);
   
   
   localparam e_clk_bit = CLK_PER_HALF_BIT * 2 - 1;
    
   localparam s_idle = 4'd0;
   localparam s_start_bit = 4'd1;
   localparam s_bit_0 = 4'd2;
   localparam s_bit_1 = 4'd3;
   localparam s_bit_2 = 4'd4;
   localparam s_bit_3 = 4'd5;
   localparam s_bit_4 = 4'd6;
   localparam s_bit_5 = 4'd7;
   localparam s_bit_6 = 4'd8;
   localparam s_bit_7 = 4'd9;
   localparam s_stop_bit = 4'd10;
   localparam s_send  = 4'd11;
   
   (* mark_debug = "true" *)logic [31:0] counter;
  (* mark_debug = "true" *) logic        rst_ctr;
  (* mark_debug = "true" *) logic [9:0] rdatabuf;
   (* ASYNC_REG = "true" *) reg [2:0] sync_reg;
   (* ASYNC_REG = "true" *) reg [2:0] chat_reg;
  (* mark_debug = "true" *) wire start = ~(|chat_reg);
  (* mark_debug = "true" *) logic [3:0] status;
  (* mark_debug = "true" *) logic start_next;
  (* mark_debug = "true" *) logic next;

   always @(posedge clk) begin
    if(~rstn) begin
      ferr <= 1'b0;
      sync_reg <= 3'b111;
      chat_reg <= 3'b111;

      start_next <= 1'b0;
      next <= 1'b0;
    end else begin
      sync_reg <= {sync_reg[1:0], rxd};
      chat_reg <= {chat_reg[1:0], sync_reg[2]};
        if(counter == e_clk_bit || rst_ctr)begin
            counter <= 32'd0;
        end else begin
            counter <= counter + 32'd1;
        end
        if (~rst_ctr && counter == e_clk_bit) begin
            next <= 1'b1;
         end else begin
            next <= 1'b0;
         end
         if (~rst_ctr && counter == CLK_PER_HALF_BIT) begin
            start_next <= 1'b1;
         end else begin
            start_next <= 1'b0;
         end
    end
   end
   
   always @(posedge clk) begin
    if (~rstn) begin
        rst_ctr <= 1'b0;
        rdata <= 8'b0;
        rdatabuf <= 10'b0;
        rdata_ready <= 1'b0;
        status <= 4'd0;
    end else begin
      rst_ctr <= 1'b0;
      rdata_ready <= 1'b0;
      if(status == 0)begin
         if(start) begin
                status <= s_start_bit;
                rst_ctr <= 1'b1;
            end
     end else if (status == s_start_bit) begin
        if(start_next) begin
            rdatabuf[9] <= chat_reg[2];
            status <= status + 4'd1;
            rst_ctr <= 1'b1;
        end
    end else if (next) begin
           if(status == s_send) begin
              rdata <= rdatabuf[8:1];
              rdata_ready <= 1'b1;
             ferr <= ~rdatabuf[9];
             status <= s_idle;
         end else begin
             rdatabuf <= {chat_reg[2], rdatabuf[9:1]};
             rst_ctr <= 1'b1;
              status <= status + 4'd1;
         end
       end
     end
   end
endmodule
`default_nettype wire