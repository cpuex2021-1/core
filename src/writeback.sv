module writeback(
    input logic clk,rst,
    input logic n_stall,
    input logic [4:0] dec_rd,
    input logic dec_rwe, dec_fwe,
    input logic dec_mre,
    output logic wb_rwe, wb_fwe,
    output logic [4:0] wb_rd,
    output logic wb_mre
);
    always_ff @( posedge clk ) begin 
        if (rst) begin
            wb_rwe <= 0;
            wb_fwe <= 0;
            wb_rd <= 0;
            wb_mre<= 0;
        end else begin
            if(n_stall) begin
                wb_rwe <= dec_rwe;
                wb_fwe <= dec_fwe;
                wb_rd <= dec_rd;
                wb_mre <= dec_mre;
            end
        end
        
    end
endmodule