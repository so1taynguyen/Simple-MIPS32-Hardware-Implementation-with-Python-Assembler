module sign_ext (inp, outp, mode);
    input [15:0] inp;
    input mode;
    output [31:0] outp;

    assign outp = (mode == 1'b0) ? {16'd0, inp} : ((mode == 1'b1) ? {{16{inp[15]}}, inp} : 32'bx);
endmodule