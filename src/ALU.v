module ALU (opcode, inpA, inpB, outp, overflow, isZero);
    input [3:0] opcode;
    input [31:0] inpA, inpB;
    output [31:0] outp;
    output reg overflow;
    output isZero;

    reg [31:0] temp;
    wire [31:0] sra_output;

    wire [32:0] ua, ub, uc;
	wire [31:0] c;

    assign ua = {1'b0, inpA};
	assign ub = {1'b0, inpB};
	assign uc = ua + ~ub + 33'h1;
	assign c = inpA + ~inpB + 32'h1;

    arith_right_shift ars(
        .din(inpA),
        .amount(inpB[4:0]),
        .dout(sra_output)
    );

    always @(*) begin
        case (opcode)
            4'b0000: begin              // NOT
                temp = ~inpA;
                overflow = 1'b0;
            end
            4'b0001: begin              // AND
                temp = inpA & inpB;
                overflow = 1'b0;
            end 
            4'b0010: begin              // XOR
                temp = inpA ^ inpB;
                overflow = 1'b0;
            end 
            4'b0011: begin
                temp = inpA | inpB;     // OR
                overflow = 1'b0;
            end 
            4'b0100: begin              // DEC
                temp = inpA - 32'd1;
                overflow = ($signed(inpA) == $signed(32'h80000000));
            end 
            4'b0101: begin              // ADD
                temp = inpA + inpB;
                overflow = (($signed(inpA) > 0 && $signed(inpB) > 0 && $signed(temp) < 0) || 
                            ($signed(inpA) < 0 && $signed(inpB) < 0 && $signed(temp) > 0));
            end 
            4'b0110: begin              // SUB
                temp = inpA - inpB;
                overflow = (($signed(inpA) > 0 && $signed(inpB) < 0 && $signed(temp) < 0) ||
                            ($signed(inpA) < 0 && $signed(inpB) > 0 && $signed(temp) > 0));
            end 
            4'b0111: begin              // INC
                temp = inpA + 32'd1;
                overflow = (($signed(inpA) == $signed(32'h7FFFFFFF)));
            end 
            4'b1000: begin              // SLL
                temp = inpA << inpB[4:0];
                overflow = 1'b0;
            end 
            4'b1001: begin              // SRL
                temp = inpA >> inpB[4:0];
                overflow = 1'b0;
            end 
            4'b1010: begin              // SRA
                temp = sra_output;
                overflow = 1'b0;
            end 
            4'b1011: begin              // SLT
                temp = (c[31]) ? 32'h1 : 32'h0;
                overflow = 1'b0;
            end 
            4'b1100: begin              // SLTU
                temp = (uc[32]) ? 32'h1 : 32'h0;
                overflow = 1'b0;
            end 
            4'b1101: begin              // SEQ
                temp = (inpA == inpB) ? 32'd1 : 32'd0;
                overflow = 1'b0;
            end 
            default: begin
                temp = 32'd0;
                overflow = 1'b0;
            end 
        endcase
    end 

    assign outp = temp;
    assign isZero = ~|temp;
endmodule

module arith_right_shift (
	input [31:0]        din,
	input [4:0]         amount,
	output reg [31:0]   dout
);

	wire [31:0] logic_shift;

	assign logic_shift = din >> amount;
	
	always @(*) begin
		if (din[31]) begin
			case (amount)
				5'd0 : dout = logic_shift;
				5'd1 : dout = logic_shift | 32'b10000000000000000000000000000000;
				5'd2 : dout = logic_shift | 32'b11000000000000000000000000000000;
				5'd3 : dout = logic_shift | 32'b11100000000000000000000000000000;
				5'd4 : dout = logic_shift | 32'b11110000000000000000000000000000;
				5'd5 : dout = logic_shift | 32'b11111000000000000000000000000000;
				5'd6 : dout = logic_shift | 32'b11111100000000000000000000000000;
				5'd7 : dout = logic_shift | 32'b11111110000000000000000000000000;
				5'd8 : dout = logic_shift | 32'b11111111000000000000000000000000;
				5'd9 : dout = logic_shift | 32'b11111111100000000000000000000000;
				5'd10: dout = logic_shift | 32'b11111111110000000000000000000000;
				5'd11: dout = logic_shift | 32'b11111111111000000000000000000000;
				5'd12: dout = logic_shift | 32'b11111111111100000000000000000000;
				5'd13: dout = logic_shift | 32'b11111111111110000000000000000000;
				5'd14: dout = logic_shift | 32'b11111111111111000000000000000000;
				5'd15: dout = logic_shift | 32'b11111111111111100000000000000000;
				5'd16: dout = logic_shift | 32'b11111111111111110000000000000000;
				5'd17: dout = logic_shift | 32'b11111111111111111000000000000000;
				5'd18: dout = logic_shift | 32'b11111111111111111100000000000000;
				5'd19: dout = logic_shift | 32'b11111111111111111110000000000000;
				5'd20: dout = logic_shift | 32'b11111111111111111111000000000000;
				5'd21: dout = logic_shift | 32'b11111111111111111111100000000000;
				5'd22: dout = logic_shift | 32'b11111111111111111111110000000000;
				5'd23: dout = logic_shift | 32'b11111111111111111111111000000000;
				5'd24: dout = logic_shift | 32'b11111111111111111111111100000000;
				5'd25: dout = logic_shift | 32'b11111111111111111111111110000000;
				5'd26: dout = logic_shift | 32'b11111111111111111111111111000000;
				5'd27: dout = logic_shift | 32'b11111111111111111111111111100000;
				5'd28: dout = logic_shift | 32'b11111111111111111111111111110000;
				5'd29: dout = logic_shift | 32'b11111111111111111111111111111000;
				5'd30: dout = logic_shift | 32'b11111111111111111111111111111100;
				5'd31: dout = logic_shift | 32'b11111111111111111111111111111110;
                default: dout = 32'd0;
			endcase
        end
		else begin
            dout = logic_shift;
        end
    end
endmodule