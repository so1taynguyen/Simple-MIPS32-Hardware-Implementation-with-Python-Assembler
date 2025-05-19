`include "../src/processor.v"
// `timescale 1ps/1fs

module testbench;
    reg clk;
    reg rstn;
    reg ready;

    reg [4:0] read_addr_from_RF;
    wire [31:0] read_data_from_RF;
    wire [9:0] pc_from_dut;

    reg [31:0] ref_mdl_imem[0:(2**10-1)];
    reg [31:0] ref_mdl_dmem[0:(2**10-1)];
    reg [31:0] ref_mdl_regfile[0:31];
    integer i_counter;
    reg [9:0] ref_mdl_imem_counter;
    reg [4:0]  ref_mdl_rd, ref_mdl_rs1, ref_mdl_rs2, ref_mdl_shamt, ref_mdl_type;
    reg [15:0] ref_mdl_imm;
    reg [25:0] ref_mdl_label;
    reg [7:0] ref_mdl_operator;
    reg [31:0] temp_data1, temp_data2;

    event scb_start_sample_dut, end_test;
    reg [31:0] scb_RF_data, scb_ref_mdl_data;
    reg [63:0] scb_passed_cmd_counter, scb_failed_cmd_counter, scb_cmd_counter;
    reg [31:0] scb_data_from_dmem[0:(2**10-1)];
    reg [9:0] scb_imem_counter;

    localparam add      = 8'b0000_0000;
    localparam sub      = 8'b0000_0001;
    localparam inc      = 8'b0000_0010;
    localparam dec      = 8'b0000_0011;
    localparam andd     = 8'b0000_0100;
    localparam orr      = 8'b0000_1000;
    localparam xorr     = 8'b0001_0000;
    localparam nott     = 8'b0010_0000;
    localparam sll      = 8'b0100_0000;
    localparam srl      = 8'b0100_0001;
    localparam sra      = 8'b0100_0010;
    localparam slt      = 8'b1000_0000;
    localparam sltu     = 8'b1000_0001;
    localparam seq      = 8'b1000_0010;
    localparam lw       = 8'b0010_1000;
    localparam sw       = 8'b0010_1001;
    localparam beq      = 8'b0011_0000;
    localparam bne      = 8'b0011_0001;
    localparam jump     = 8'b0011_1000;

    localparam R_type   = 5'b0001;
    localparam I_type   = 5'b0010;
    localparam J_type   = 5'b0100;

    // ---------- DUT ----------
    processor proc(
        .clk(clk),
        `ifdef RTL_VERIFY
            .read_addr_from_RF(read_addr_from_RF),
            .read_data_from_RF(read_data_from_RF),
            .pc_from_dut(pc_from_dut),
        `endif
        .rstn(rstn)
    );
    // -------------------------

    // ---- Clock generator ----
    localparam CLK_PERIOD = 10;
    always #(CLK_PERIOD/2) clk = ~clk;
    // -------------------------

    // --- Dumping waveform ---
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, testbench);
    end
    // -------------------------

    // ----- DUT operation -----
    initial begin
        // ******** Initialization ********
        ready = 1'b0;
        #1 rstn = 1'bx;
        clk = 1'bx;
        #(CLK_PERIOD*3) 
        rstn = 1;
        #(CLK_PERIOD*3) 
        rstn = 0;
        clk = 0;
        repeat (5) 
            @(posedge clk);
        #4;
        rstn <= 1;
        $readmemh("../include/imem_data.mem", proc.imem.mem_arr);
        $readmemh("../include/dmem_data.mem", proc.dp.dmem.mem_arr);
        ready = 1'b1;
        // ********************************

        // ******* Driving commands *******
        repeat (2**10) begin
            @(posedge clk);
        end
        $finish(2);
        // ********************************
    end
    // -------------------------

    `ifdef RTL_VERIFY
    // ---- Reference model ----
    initial begin
        @(posedge ready);
        @(posedge clk);
        $readmemh("../include/imem_data.mem", ref_mdl_imem);
        $readmemh("../include/dmem_data.mem", ref_mdl_dmem);
        ref_mdl_imem_counter = 9'd0;
        scb_cmd_counter = 64'd0;
        for (i_counter = 0; i_counter < 32; i_counter = i_counter + 1) begin
            ref_mdl_regfile[i_counter] = 32'd0;
        end

        while (ref_mdl_imem[ref_mdl_imem_counter] != 32'd0) begin
            @(negedge clk);
            ref_mdl_decode(ref_mdl_imem[ref_mdl_imem_counter], ref_mdl_rd, ref_mdl_rs1, ref_mdl_rs2, ref_mdl_shamt, ref_mdl_type, ref_mdl_imm, ref_mdl_label, ref_mdl_operator);

            if ((ref_mdl_type == R_type) || (ref_mdl_type == I_type)) begin
                temp_data1 = ref_mdl_regfile[ref_mdl_rs1];
                temp_data2 = ((ref_mdl_type == I_type) ? {16'd0, ref_mdl_imm} : ref_mdl_regfile[ref_mdl_rs2]);

                case (ref_mdl_operator)
                    add: ref_mdl_regfile[ref_mdl_rd] = temp_data1 + temp_data2;
                    sub: ref_mdl_regfile[ref_mdl_rd] = temp_data1 - temp_data2;
                    inc: ref_mdl_regfile[ref_mdl_rd] = temp_data1 + 1'b1;
                    dec: ref_mdl_regfile[ref_mdl_rd] = temp_data1 - 1'b1;
                    andd: ref_mdl_regfile[ref_mdl_rd] = temp_data1 & temp_data2;
                    orr: ref_mdl_regfile[ref_mdl_rd] = temp_data1 | temp_data2;
                    xorr: ref_mdl_regfile[ref_mdl_rd] = temp_data1 ^ temp_data2;
                    nott: ref_mdl_regfile[ref_mdl_rd] = ~temp_data1;
                    sll: ref_mdl_regfile[ref_mdl_rd] = temp_data1 << ref_mdl_shamt;
                    srl: ref_mdl_regfile[ref_mdl_rd] = temp_data1 >> ref_mdl_shamt;
                    sra: ref_mdl_regfile[ref_mdl_rd] = ref_mdl_arith_right_shift(temp_data1, ref_mdl_shamt);
                    slt: ref_mdl_regfile[ref_mdl_rd] = ($signed(temp_data1) < $signed(temp_data2)) ? 32'd1 : 32'd0;
                    sltu: ref_mdl_regfile[ref_mdl_rd] = ($unsigned(temp_data1) < $unsigned(temp_data2)) ? 32'd1 : 32'd0;
                    seq: ref_mdl_regfile[ref_mdl_rd] = (temp_data1 == temp_data2) ? 32'd1 : 32'd0;
                    lw: ref_mdl_regfile[ref_mdl_rd] = ref_mdl_dmem[temp_data1 + {16'd0, ref_mdl_imm}];
                    sw: ref_mdl_dmem[temp_data1 + {16'd0, ref_mdl_imm}] = ref_mdl_regfile[ref_mdl_rd];
                    beq: ref_mdl_imem_counter = (ref_mdl_regfile[ref_mdl_rd] == temp_data1) ? (ref_mdl_imem_counter + ref_mdl_imm + 1'b1) : ref_mdl_imem_counter;
                    bne: ref_mdl_imem_counter = (ref_mdl_regfile[ref_mdl_rd] != temp_data1) ? (ref_mdl_imem_counter + ref_mdl_imm + 1'b1) : ref_mdl_imem_counter;
                endcase
            end
            else begin
                ref_mdl_imem_counter = ref_mdl_imem_counter + ref_mdl_label + 1'b1;
            end
    
            ref_mdl_imem_counter = ref_mdl_imem_counter + 1'b1;
            scb_cmd_counter = scb_cmd_counter + 1'b1;
        end

        -> end_test;
    end
    // -------------------------

    // ------ Scoreboard -------
    initial begin: scb_block
        scb_passed_cmd_counter = 64'd0;
        scb_failed_cmd_counter = 64'd0;
        @(posedge ready);
        @(posedge clk);
        fork
            begin
                forever begin
                    @(negedge clk);
                    case (ref_mdl_operator)
                        sw: scb_ref_mdl_data <= ref_mdl_dmem[temp_data1 + {16'd0, ref_mdl_imm}];
                        beq, bne, jump: scb_imem_counter <= ref_mdl_imem_counter;
                        default: scb_ref_mdl_data <= ref_mdl_regfile[ref_mdl_rd];
                    endcase
                    -> scb_start_sample_dut;
                end
            end
            begin
                forever begin
                    @(scb_start_sample_dut);
                    
                    case (ref_mdl_operator)
                        sw: begin
                            #1;

                            $readmemh("../include/dmem_data.mem", scb_data_from_dmem);
                            if (scb_data_from_dmem[temp_data1 + {16'd0, ref_mdl_imm}] != scb_ref_mdl_data) begin
                                $display("@%0t [ERROR] DATA MISMATCHED ==== EXPECTED DATA: 'h%0h - RECEIVED DATA: 'h%0h", $time, scb_ref_mdl_data, scb_data_from_dmem[temp_data1 + {16'd0, ref_mdl_imm}]);
                                scb_failed_cmd_counter = scb_failed_cmd_counter + 1'b1;
                            end
                            else begin
                                $display("@%0t DATA MATCHED", $time);
                                scb_passed_cmd_counter = scb_passed_cmd_counter + 1'b1;
                            end
                        end
                        beq, bne, jump: begin
                            #1;

                            if (pc_from_dut != scb_imem_counter) begin
                                $display("@%0t [ERROR] INSTRUCTION MISMATCHED ==== EXPECTED INSTRUCTION ADDRESS: 'h%0h - RECEIVED INSTRUCTION ADDRESS: 'h%0h", $time, scb_imem_counter, pc_from_dut);
                                scb_failed_cmd_counter = scb_failed_cmd_counter + 1'b1;
                            end
                            else begin
                                $display("@%0t INSTRUCTION MATCHED", $time);
                                scb_passed_cmd_counter = scb_passed_cmd_counter + 1'b1;
                            end
                        end
                        default: begin
                            @(posedge clk);
                            read_addr_from_RF = ref_mdl_rd;
                            #1;

                            if (read_data_from_RF != scb_ref_mdl_data) begin
                                $display("@%0t [ERROR] DATA MISMATCHED ==== EXPECTED DATA: 'h%0h - RECEIVED DATA: 'h%0h", $time, scb_ref_mdl_data, read_data_from_RF);
                                scb_failed_cmd_counter = scb_failed_cmd_counter + 1'b1;
                            end
                            else begin
                                $display("@%0t DATA MATCHED", $time);
                                scb_passed_cmd_counter = scb_passed_cmd_counter + 1'b1;
                            end
                        end 
                    endcase
                end
            end
            begin
                @(end_test);
                $display("========================= SCOREBOARD REPORT =========================");
                $display("|| Total number of tests: %5d                                    ||", scb_cmd_counter - 1);
                $display("|| Number of passed test: %5d                                    ||", scb_passed_cmd_counter);
                $display("|| Number of failed test: %5d                                    ||", scb_failed_cmd_counter);
                $display("=====================================================================");
                disable scb_block;
            end
        join
    end
    // -------------------------

    // --- Tasks & funtions ---
    task ref_mdl_decode(
        input [31:0]  instr, 
        output [4:0]  rd, rs1, rs2, shamt, type, 
        output [15:0] imm, 
        output [25:0] label, 
        output [7:0] operator
    );
        begin
            if ((instr[31] == 1'b0) && (instr[31:29] != 3'b111)) begin
                rd       = instr[15:11];
                rs1      = instr[25:21];
                rs2      = instr[20:16];
                shamt    = instr[10:6];
                imm      = 16'd0;
                label    = 26'd0;
                operator = {instr[27:26], instr[5:0]};
                type     = R_type;
            end
            else if ((instr[31] == 1'b1) && (instr[31:29] != 3'b111)) begin
                rd       = instr[20:16];
                rs1      = instr[25:21]; 
                rs2      = 5'd0;
                shamt    = 5'd0;
                imm      = instr[15:0];
                label    = 26'd0;
                type     = I_type;
                case (instr[31:26])
                    6'b100000: operator = add;
                    6'b100001: operator = sub;
                    6'b100010: operator = andd;
                    6'b100011: operator = orr;
                    6'b100100: operator = xorr;
                    6'b100101: operator = slt;
                    6'b100110: operator = sltu;
                    6'b100111: operator = seq;
                    default:   operator = instr[31:26];
                endcase
            end
            else begin
                rd       = 5'd0;
                rs1      = 5'd0; 
                rs2      = 5'd0;
                shamt    = 5'd0;
                imm      = 16'd0;
                label    = instr[25:0];
                type     = J_type;
                operator = {2'd0, instr[31:26]};
            end
        end
    endtask

    function [31:0] ref_mdl_arith_right_shift (
        input [31:0]        din,
        input [4:0]         amount
    );
        begin: ars_block
            reg [31:0] logic_shift;
            logic_shift = din >> amount;

            if (din[31]) begin
                case (amount)
                    5'd0 : ref_mdl_arith_right_shift = logic_shift;
                    5'd1 : ref_mdl_arith_right_shift = logic_shift | 32'b10000000000000000000000000000000;
                    5'd2 : ref_mdl_arith_right_shift = logic_shift | 32'b11000000000000000000000000000000;
                    5'd3 : ref_mdl_arith_right_shift = logic_shift | 32'b11100000000000000000000000000000;
                    5'd4 : ref_mdl_arith_right_shift = logic_shift | 32'b11110000000000000000000000000000;
                    5'd5 : ref_mdl_arith_right_shift = logic_shift | 32'b11111000000000000000000000000000;
                    5'd6 : ref_mdl_arith_right_shift = logic_shift | 32'b11111100000000000000000000000000;
                    5'd7 : ref_mdl_arith_right_shift = logic_shift | 32'b11111110000000000000000000000000;
                    5'd8 : ref_mdl_arith_right_shift = logic_shift | 32'b11111111000000000000000000000000;
                    5'd9 : ref_mdl_arith_right_shift = logic_shift | 32'b11111111100000000000000000000000;
                    5'd10: ref_mdl_arith_right_shift = logic_shift | 32'b11111111110000000000000000000000;
                    5'd11: ref_mdl_arith_right_shift = logic_shift | 32'b11111111111000000000000000000000;
                    5'd12: ref_mdl_arith_right_shift = logic_shift | 32'b11111111111100000000000000000000;
                    5'd13: ref_mdl_arith_right_shift = logic_shift | 32'b11111111111110000000000000000000;
                    5'd14: ref_mdl_arith_right_shift = logic_shift | 32'b11111111111111000000000000000000;
                    5'd15: ref_mdl_arith_right_shift = logic_shift | 32'b11111111111111100000000000000000;
                    5'd16: ref_mdl_arith_right_shift = logic_shift | 32'b11111111111111110000000000000000;
                    5'd17: ref_mdl_arith_right_shift = logic_shift | 32'b11111111111111111000000000000000;
                    5'd18: ref_mdl_arith_right_shift = logic_shift | 32'b11111111111111111100000000000000;
                    5'd19: ref_mdl_arith_right_shift = logic_shift | 32'b11111111111111111110000000000000;
                    5'd20: ref_mdl_arith_right_shift = logic_shift | 32'b11111111111111111111000000000000;
                    5'd21: ref_mdl_arith_right_shift = logic_shift | 32'b11111111111111111111100000000000;
                    5'd22: ref_mdl_arith_right_shift = logic_shift | 32'b11111111111111111111110000000000;
                    5'd23: ref_mdl_arith_right_shift = logic_shift | 32'b11111111111111111111111000000000;
                    5'd24: ref_mdl_arith_right_shift = logic_shift | 32'b11111111111111111111111100000000;
                    5'd25: ref_mdl_arith_right_shift = logic_shift | 32'b11111111111111111111111110000000;
                    5'd26: ref_mdl_arith_right_shift = logic_shift | 32'b11111111111111111111111111000000;
                    5'd27: ref_mdl_arith_right_shift = logic_shift | 32'b11111111111111111111111111100000;
                    5'd28: ref_mdl_arith_right_shift = logic_shift | 32'b11111111111111111111111111110000;
                    5'd29: ref_mdl_arith_right_shift = logic_shift | 32'b11111111111111111111111111111000;
                    5'd30: ref_mdl_arith_right_shift = logic_shift | 32'b11111111111111111111111111111100;
                    5'd31: ref_mdl_arith_right_shift = logic_shift | 32'b11111111111111111111111111111110;
                    default: ref_mdl_arith_right_shift = 32'd0;
                endcase
            end
            else begin
                ref_mdl_arith_right_shift = logic_shift;
            end
        end
    endfunction
    // -------------------------
    `endif
endmodule