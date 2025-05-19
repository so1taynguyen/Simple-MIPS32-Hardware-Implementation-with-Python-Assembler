module mem #(
    parameter DWIDTH = 32,
    parameter AWIDTH = 10,
    parameter ISDATA = 1
)
(clk, rstn, wr_en, addr, wr_data, rd_en, rd_data);
    input                   clk, rstn;
    input                   wr_en;
    input [AWIDTH-1:0]      addr;
    input [DWIDTH-1:0]      wr_data;
    input                   rd_en;
    output [DWIDTH-1:0]     rd_data;

    (* ram_style = "block" *) reg [DWIDTH-1:0] mem_arr [0:(2**AWIDTH-1)];
    reg [DWIDTH-1:0] temp;
    integer i;

    always @(negedge clk, negedge rstn) begin
        if (ISDATA == 1) begin
            if (~rstn) begin
                for (i = 0; i < 2**AWIDTH; i = i + 1) begin
                    mem_arr[i] = 'd0;
                end
            end
            else begin
                if (wr_en == 1'b1) begin
                    mem_arr[addr] = wr_data;
                    $writememh("../include/dmem_data.mem", mem_arr);
                end
                if (rd_en) begin
                    temp = mem_arr[addr];
                end
                else begin
                    temp = temp;
                end
            end
        end
    end

    always @(posedge clk, negedge rstn) begin
        if (ISDATA == 0) begin
            if (~rstn) begin
                for (i = 0; i < 2**AWIDTH; i = i + 1) begin
                    mem_arr[i] <= 'd0;
                end
            end
            else begin
                if (rd_en) begin
                    temp <= mem_arr[addr];
                end
                else begin
                    temp <= temp;
                end
            end
        end
    end

    assign rd_data = temp;
    
endmodule