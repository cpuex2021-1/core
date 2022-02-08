module writeback(
    input logic clk,rst,
    input logic stall,
    input logic [6:0] dec_rd1,dec_rd2,dec_rd3,dec_rd4,
    output logic [6:0] wb_rd1,wb_rd2, wb_rd3, wb_rd4,
    input logic [31:0] 
);
    always_ff @( posedge clk ) begin 
        if (rst || ~n_stall) begin
            wb_rd <= 0;
            wb_mre<= 0;
        end else begin
            if(n_stall) begin
                wb_rd <= dec_rd;
                wb_mre <= dec_mre;
            end
        end
        
    end
endmodule