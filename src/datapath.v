`include "../src/ALU.v"
`include "../src/reg_file.v"
`include "../src/sign_ext.v"
`include "../src/jump_sign_ext.v"
`include "../src/adder.v"

module datapath (clk, rstn, instr, regDst, regWrite, signExtSrc, aluSrc, shamtSel, aluControl, memWrite, memRead, mem2reg, sign_ext_mode, pcSrc, pc_address, overflow, isZero, instr_addr `ifdef RTL_VERIFY , read_addr_from_RF, read_data_from_RF `endif);
    input clk, rstn;
    input [31:0] instr;
    input sign_ext_mode, regDst, regWrite, aluSrc, shamtSel;
    input [3:0] aluControl;
    input memWrite, memRead, mem2reg;
    input pcSrc, signExtSrc;
    input [9:0] pc_address;
    `ifdef RTL_VERIFY
        input [4:0] read_addr_from_RF;
        output [31:0] read_data_from_RF;
    `endif
    output overflow, isZero;
    output [9:0] instr_addr;

    wire [4:0] rf_wr_addr;
    wire [31:0] data2rf, rf_rddata1, rf_rddata2, sign_ext_data, alu_inpB, alu_result, mem_rddata, shamt_outp, branch_adder_output, jump_sign_ext_data, signExt_mux_output;
    wire [9:0] pc_addr_mux_output;

    mux2_1 #(.DWIDTH(5)) rg_wr_addr_mux(
        .inpA(instr[20:16]),
        .inpB(instr[15:11]),
        .sel(regDst),
        .outp(rf_wr_addr)
    );

    mux2_1 #(.DWIDTH(32)) inpB_ALU_mux(
        .inpA(rf_rddata2),
        .inpB(sign_ext_data),
        .sel(aluSrc),
        .outp(alu_inpB)
    );

    mux2_1 #(.DWIDTH(32)) shamt_mux(
        .inpA(alu_inpB),
        .inpB({27'd0, instr[10:6]}),
        .sel(shamtSel),
        .outp(shamt_outp)
    );

    mux2_1 #(.DWIDTH(32)) data2rf_mux(
        .inpA(mem_rddata),
        .inpB(alu_result),
        .sel(mem2reg),
        .outp(data2rf)
    );

    mux2_1 #(.DWIDTH(32)) signExt_mux(
        .inpA(sign_ext_data),
        .inpB(jump_sign_ext_data),
        .sel(signExtSrc),
        .outp(signExt_mux_output)
    );

    mux2_1 #(.DWIDTH(10)) pc_addr_mux(
        .inpA(pc_address),
        .inpB(branch_adder_output[9:0]),
        .sel(pcSrc),
        .outp(pc_addr_mux_output)
    );

    reg_file RF(
        .clk(clk),
        .rstn(rstn),
        .writeEn(regWrite),
        .writeAddr(rf_wr_addr),
        .writeData(data2rf),
        `ifdef RTL_VERIFY
            .read_addr_from_RF(read_addr_from_RF),
            .read_data_from_RF(read_data_from_RF),
        `endif
        .readAddr1(instr[25:21]),
        .readAddr2(instr[20:16]),
        .readData1(rf_rddata1),
        .readData2(rf_rddata2)
    );

    sign_ext sign_ext(
        .inp(instr[15:0]),
        .mode(sign_ext_mode),
        .outp(sign_ext_data)
    );

    jump_sign_ext jump_sign_ext(
        .inp(instr[25:0]),
        .outp(jump_sign_ext_data)
    );

    ALU ALU(
        .opcode(aluControl),
        .inpA(rf_rddata1),
        .inpB(shamt_outp),
        .outp(alu_result),
        .overflow(overflow),
        .isZero(isZero)
    );

    mem #(.ISDATA(1)) dmem(
        .clk(clk),
        .rstn(rstn),
        .wr_en(memWrite),
        .addr(alu_result[9:0]),
        .wr_data(rf_rddata2),
        .rd_en(memRead),
        .rd_data(mem_rddata)
    );

    adder #(.DWIDTH(10)) pc_adder(
        .inpA(pc_addr_mux_output),
        .inpB(10'd1),
        .result(instr_addr)
    );
 
    adder #(.DWIDTH(32)) branch_adder(
        .inpA({22'd0, pc_address}),
        .inpB(signExt_mux_output),
        .result(branch_adder_output)
    );

endmodule