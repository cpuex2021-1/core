module exe_fwd(
    input logic [31:0] dec_op1, dec_op2,
    input logic [31:0] wb_memdata,
    input logic [6:0] dec_rs1, dec_rs2, wb_rd,
    input logic  wb_mre,
    output logic [31:0] op1, op2
);
    //dec_rs1 {valid, fromfreg, register number}
    //forwarding should be done when...
    //register is valid 
    //writeback is valid
    // both intregister (or both f register)
    // same register number
    always_comb begin 

        op1 = dec_rs1[6] && (dec_rs1 ==  wb_rd) && wb_mre ? wb_memdata : dec_op1;
        op2 = dec_rs2[6] && (dec_rs2 ==  wb_rd) && wb_mre ? wb_memdata : dec_op2;
    end
endmodule