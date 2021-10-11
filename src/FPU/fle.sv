`timescale 1ns / 1ps

module fle(
        input  logic [31:0] x,y,
        output logic [31:0] z
    );
    logic xs, ys;
    logic [7:0] xe, ye;
    logic [22:0] xm, ym;

    logic el, eeq;
    logic ml;
    logic absl;

    logic sl;

    logic pp, np, nn;

    logic emeq;
    always_comb begin
        xs = x[31];
        ys = y[31];
        xe = x[30:23];
        ye = y[30:23];
        xm = x[22:0];
        ym = y[22:0];

        el = xe < ye;
        eeq = ~|(xe ^ ye);
        ml = xm < ym;

        absl = el | (eeq & ml);

        pp = xs & ys;  // x y positive
        np = xs & ~ys; //x negative y positive
        nn = ~(xs | ys);// x y negative

        emeq = ~| (x[30:0] ^ y[30:0]);

        z = { 31'b0, (pp & absl) | np | (nn & ~absl & ~emeq) | x == y};
    end
endmodule
