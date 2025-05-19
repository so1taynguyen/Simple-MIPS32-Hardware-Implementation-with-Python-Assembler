module pc_counter (clk, rstn, increase, pre_instr_addr, nx_instr_addr);
    input clk, rstn, increase;
    input [9:0] pre_instr_addr;
    output [9:0] nx_instr_addr;

    reg [9:0] temp;

    always @(posedge clk, negedge rstn) begin
        if (~rstn) begin
            temp <= 10'd0;
        end
        else if (increase) begin
            temp <= pre_instr_addr + 1'b1;
        end
        else begin
            temp <= pre_instr_addr;
        end
    end

    assign nx_instr_addr = temp;
    
endmodule