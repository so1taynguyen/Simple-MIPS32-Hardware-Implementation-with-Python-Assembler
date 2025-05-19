module mux2_1 #(
    parameter DWIDTH = 32
)
(inpA, inpB, sel, outp);
    input [DWIDTH-1:0] inpA, inpB;
    input sel;
    output [DWIDTH-1:0] outp;

    assign outp = (sel == 1'b0) ? inpA : ((sel == 1'b1) ? inpB : 32'bx);
endmodule