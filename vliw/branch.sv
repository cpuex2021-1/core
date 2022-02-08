module branch(
    input  logic clk,rst,
    input  logic op1,op2,
    input  logic [6:0] dec_branch,  // {do_branch, geu, ltu, ge, lt ,ne, eq}
    input  logic       dec_jump,
    output logic npc_enn,
    output logic flush
);
    logic [5:0] cond;
    logic eq, lt,ltu;

    always_comb begin 
        eq = op1 == op2;
        lt = $signed(op1) < $signed(op2);
        ltu= $unsigned(op1) < $unsigned(op2);
        cond[0] = eq;
        cond[1] = ~eq;
        cond[2] = lt;
        cond[3] = ~lt;
        cond[4] = ltu;
        cond[5] = ~ltu;
        npc_enn = (dec_branch[6] && |(cond & dec_branch[5:0])) | dec_jump;
        flush = npc_enn;
    end


endmodule