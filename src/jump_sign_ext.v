module jump_sign_ext (inp, outp);
    input [25:0] inp;
    output [31:0] outp;

    assign outp = {{6{inp[25]}}, inp};
endmodule