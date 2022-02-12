module writeback(
    input logic clk,rst,
    input logic stall,
    input logic [6:0] dec_rd1,dec_rd2,dec_rd3,dec_rd4,
    output logic [6:0] wb_rd1,wb_rd2, wb_rd3, wb_rd4
);
    always_ff @( posedge clk ) begin 
        if (rst || stall) begin
            wb_rd1 <= 0;
            wb_rd2 <= 0;
            wb_rd3 <= 0;
            wb_rd4 <= 0;
        end else begin
            if(~stall) begin
                wb_rd1 <= dec_rd1;
                wb_rd2 <= dec_rd2;
                wb_rd3 <= dec_rd3;
                wb_rd4 <= dec_rd4;
            end
        end
        
    end
endmodule