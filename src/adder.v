module adder #(
    parameter DWIDTH = 32
) (
    input [DWIDTH-1:0] inpA, inpB,
    output [DWIDTH-1:0] result
);

    assign result = inpA + inpB;

endmodule