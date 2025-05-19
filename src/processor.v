`include "../src/datapath.v"
`include "../src/control_unit.v"
`include "../src/mux2_1.v"
`include "../src/pc_counter.v"
`include "../src/mem.v"

module processor (clk, rstn `ifdef RTL_VERIFY , read_addr_from_RF, read_data_from_RF, pc_from_dut `endif);
    input clk, rstn;
    `ifdef RTL_VERIFY
        input [4:0] read_addr_from_RF;
        output [31:0] read_data_from_RF;
        output [9:0] pc_from_dut;
    `endif

    wire [31:0] instr;
    wire sign_ext_mode, regDst, memRead, memWrite, mem2reg, aluSrc, regWrite, shamtSel, pcSrc, signExtSrc;
    wire [3:0] aluControl;
    wire [9:0] nx_instr_addr, instr_addr, addr2imem;
    wire isZero, overflow;

    pc_counter pc_counter(
        .clk(clk),
        .rstn(rstn),
        .increase(pcSrc),
        .pre_instr_addr(instr_addr),
        .nx_instr_addr(nx_instr_addr)
    );
 
    mux2_1 #(.DWIDTH(10)) addr2imem_mux(
        .inpA(instr_addr),
        .inpB(nx_instr_addr),
        .sel(~pcSrc),
        .outp(addr2imem)
    );
    
    `ifdef RTL_VERIFY
        assign pc_from_dut = addr2imem;
    `endif

    mem #(.ISDATA(0)) imem(
        .clk(clk),
        .rstn(rstn),
        .wr_en(1'b0),
        .addr(addr2imem),
        .wr_data('d0),
        .rd_en(1'b1),
        .rd_data(instr)
    );

    datapath dp(
        .clk(clk),
        .rstn(rstn),
        .instr(instr),
        `ifdef RTL_VERIFY
            .read_addr_from_RF(read_addr_from_RF),
            .read_data_from_RF(read_data_from_RF),
        `endif
        .pc_address(nx_instr_addr),
        .sign_ext_mode(sign_ext_mode),
        .shamtSel(shamtSel),
        .regDst(regDst),
        .regWrite(regWrite),
        .aluSrc(aluSrc),
        .signExtSrc(signExtSrc),
        .aluControl(aluControl),
        .memWrite(memWrite),
        .memRead(memRead),
        .mem2reg(mem2reg),
        .pcSrc(pcSrc),
        .overflow(overflow),
        .isZero(isZero),
        .instr_addr(instr_addr)
    );

    control_unit cu(
        .rstn(rstn),
        .opcode(instr[31:26]),
        .funct(instr[5:0]),
        .overflow(overflow),
        .isZero(isZero),
        .sign_ext_mode(sign_ext_mode),
        .shamtSel(shamtSel),
        .regDst(regDst),
        .memRead(memRead),
        .memWrite(memWrite),
        .mem2reg(mem2reg),
        .aluControl(aluControl),
        .aluSrc(aluSrc),
        .regWrite(regWrite),
        .pcSrc(pcSrc),
        .signExtSrc(signExtSrc)
    );
endmodule