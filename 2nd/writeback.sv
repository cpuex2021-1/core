module writeback(
    input logic clk,rst,
    input logic n_stall,
    input logic [3:0] dec_rd,
    input logic [3:0] dec_mask,
    input logic dec_mre,
    output logic [3:0] wb_rd,
    output logic [3:0] wb_mask,
    output logic wb_mre
);
    always_ff @( posedge clk ) begin 
        if (rst || ~n_stall) begin
            wb_rd <= 0;
            wb_mre<= 0;
        end else begin
            if(n_stall) begin
                wb_rd  <= dec_rd;
                wb_mask<= dec_mask;
                wb_mre <= dec_mre;
            end
        end
        
    end
endmodule