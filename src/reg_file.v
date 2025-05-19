module reg_file #(
    parameter DataWidth  = 32,
    parameter NumRegs    = 32,
    parameter IndexWidth = 5
) (
    input                   clk,
    input                   rstn,
    input                   writeEn,
    input [IndexWidth-1:0]  writeAddr,
    input [DataWidth-1:0]   writeData,
    input [IndexWidth-1:0]  readAddr1,
    input [IndexWidth-1:0]  readAddr2,
    `ifdef RTL_VERIFY
        input [IndexWidth-1:0]  read_addr_from_RF,
        output [DataWidth-1:0]  read_data_from_RF,
    `endif
    output [DataWidth-1:0]  readData1,
    output [DataWidth-1:0]  readData2
);

    integer i;
    reg [DataWidth-1:0] regs[0:(NumRegs-1)];
    
    always @(posedge clk, negedge rstn) begin
        if (~rstn) begin
            for (i = 0; i < NumRegs; i = i + 1) begin
                regs[i] <= 'd0;
            end
        end
        else if ((writeEn == 1'b1) & (writeAddr != 0) & (writeAddr < NumRegs)) begin
            regs[writeAddr] <= writeData;
        end
        else begin
            for (i = 0; i < NumRegs; i = i + 1) begin
                regs[i] <= regs[i];
            end
        end
    end
    
    assign readData1 = regs[readAddr1];
    assign readData2 = regs[readAddr2];
    `ifdef RTL_VERIFY
        assign read_data_from_RF = regs[read_addr_from_RF];
    `endif
endmodule