module branchjump(
    input  logic beq, bne, blt,bge,
    input  logic dec_jumpr,
    input  logic stall,
    output logic [31:0] op11,op12,
    output logic npc_enn,
    output logic flush
);
    logic eq,lt;

    always_comb begin 
        eq = op11 == op12;
        lt = $signed(op11) < $signed(op12);
        npc_enn = (beq && eq || bne && ~eq || blt && lt || bge && ~lt || dec_jumpr) && ~stall;
        flush = npc_enn;
    end
endmodule