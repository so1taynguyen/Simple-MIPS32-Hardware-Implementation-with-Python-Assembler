module control_unit (rstn, opcode, funct, overflow, isZero, sign_ext_mode, regDst, memRead, memWrite, mem2reg, aluControl, aluSrc, regWrite, shamtSel, pcSrc, signExtSrc);
    input rstn;
    input [5:0] opcode, funct;
    input overflow, isZero;
    output reg sign_ext_mode, regDst, memRead, memWrite, mem2reg, aluSrc, regWrite, shamtSel, pcSrc, signExtSrc;
    output reg [3:0] aluControl;

    localparam Arith_Logic_cmd  = 6'b000000;
    localparam Shift_cmd        = 6'b000001;
    localparam Compare_cmd      = 6'b000010;

    localparam ADDI_cmd         = 6'b100000;
    localparam SUBI_cmd         = 6'b100001;
    localparam ANDI_cmd         = 6'b100010;
    localparam ORI_cmd          = 6'b100011;
    localparam XORI_cmd         = 6'b100100;
    localparam SLTI_cmd         = 6'b100101;
    localparam SLTIU_cmd        = 6'b100110;
    localparam SEQI_cmd         = 6'b100111;
    localparam LW_cmd           = 6'b101000;
    localparam SW_cmd           = 6'b101001;
    localparam BEQ_cmd          = 6'b110000;
    localparam BNE_cmd          = 6'b110001;
    localparam JUMP_cmd         = 6'b111000;

    always @(*) begin
        if (~rstn) begin
            regDst = 1'b0;
            memRead = 1'b0;
            memWrite = 1'b0;
            mem2reg = 1'b0;
            aluSrc = 1'b0;
            shamtSel = 1'b0;
            regWrite = 1'b0;
            aluControl = 4'b1111;
            sign_ext_mode = 1'b0;
            pcSrc = 1'b0;
            signExtSrc = 1'b0;
        end
        else begin
            case (opcode)
                Arith_Logic_cmd: begin
                    regDst = 1'b1;
                    memRead = 1'b0;
                    memWrite = 1'b0;
                    mem2reg = 1'b1;
                    aluSrc = 1'b0;
                    shamtSel = 1'b0;
                    regWrite = 1'b1;
                    sign_ext_mode = 1'b1;
                    pcSrc = 1'b0;
                    signExtSrc = 1'b0;

                    case (funct)
                        6'd0: begin             // ADD
                            aluControl = 4'b0101;
                        end 
                        6'd1: begin             // SUB
                            aluControl = 4'b0110;
                        end 
                        6'd2: begin             // INC
                            aluControl = 4'b0111;
                        end 
                        6'd3: begin             // DEC
                            aluControl = 4'b0100;
                        end 
                        6'd4: begin             // AND
                            aluControl = 4'b0001;
                        end 
                        6'd8: begin             // OR
                            aluControl = 4'b0011;
                        end 
                        6'd16: begin            // XOR
                            aluControl = 4'b0010;
                        end 
                        6'd32: begin            // NOT
                            aluControl = 4'b0000;
                        end 
                        default: begin
                            aluControl = 4'b1111;
                        end
                    endcase
                end 

                Shift_cmd: begin
                    regDst = 1'b1;
                    memRead = 1'b0;
                    memWrite = 1'b0;
                    mem2reg = 1'b1;
                    aluSrc = 1'b0;
                    shamtSel = 1'b1;
                    regWrite = 1'b1;
                    sign_ext_mode = 1'b1;
                    pcSrc = 1'b0;
                    signExtSrc = 1'b0;

                    case (funct)
                        6'd0: begin             // SLL
                            aluControl = 4'b1000;
                        end 
                        6'd1: begin             // SRL
                            aluControl = 4'b1001;
                        end 
                        6'd2: begin             // SRA
                            aluControl = 4'b1010;
                        end 
                        default: aluControl = 4'b1111;
                    endcase
                end

                Compare_cmd: begin
                    regDst = 1'b1;
                    memRead = 1'b0;
                    memWrite = 1'b0;
                    mem2reg = 1'b1;
                    aluSrc = 1'b0;
                    shamtSel = 1'b0;
                    regWrite = 1'b1;
                    sign_ext_mode = 1'b1;
                    pcSrc = 1'b0;
                    signExtSrc = 1'b0;

                    case (funct)
                        6'd0: aluControl = 4'b1011;     // SLT
                        6'd1: aluControl = 4'b1100;     // SLTU
                        6'd2: aluControl = 4'b1101;     // SEQ
                        default: aluControl = 4'b1111;
                    endcase
                end

                ADDI_cmd: begin         // ADDI
                    regDst = 1'b0;
                    memRead = 1'b0;
                    memWrite = 1'b0;
                    mem2reg = 1'b1;
                    aluSrc = 1'b1;
                    shamtSel = 1'b0;
                    regWrite = 1'b1;
                    sign_ext_mode = 1'b1;
                    aluControl = 4'b0101;
                    pcSrc = 1'b0;
                    signExtSrc = 1'b0;
                end

                SUBI_cmd: begin         // SUBI
                    regDst = 1'b0;
                    memRead = 1'b0;
                    memWrite = 1'b0;
                    mem2reg = 1'b1;
                    aluSrc = 1'b1;
                    shamtSel = 1'b0;
                    regWrite = 1'b1;
                    sign_ext_mode = 1'b1;
                    aluControl = 4'b0110;
                    pcSrc = 1'b0;
                    signExtSrc = 1'b0;
                end

                ANDI_cmd: begin         // ANDI
                    regDst = 1'b0;
                    memRead = 1'b0;
                    memWrite = 1'b0;
                    mem2reg = 1'b1;
                    aluSrc = 1'b1;
                    shamtSel = 1'b0;
                    regWrite = 1'b1;
                    sign_ext_mode = 1'b0;
                    aluControl = 4'b0001;
                    pcSrc = 1'b0;
                    signExtSrc = 1'b0;
                end

                ORI_cmd: begin          // ORI
                    regDst = 1'b0;
                    memRead = 1'b0;
                    memWrite = 1'b0;
                    mem2reg = 1'b1;
                    aluSrc = 1'b1;
                    shamtSel = 1'b0;
                    regWrite = 1'b1;
                    sign_ext_mode = 1'b0;
                    aluControl = 4'b0011;
                    pcSrc = 1'b0;
                    signExtSrc = 1'b0;
                end

                XORI_cmd: begin         // XORI
                    regDst = 1'b0;
                    memRead = 1'b0;
                    memWrite = 1'b0;
                    mem2reg = 1'b1;
                    aluSrc = 1'b1;
                    shamtSel = 1'b0;
                    regWrite = 1'b1;
                    sign_ext_mode = 1'b0;
                    aluControl = 4'b0010;
                    pcSrc = 1'b0;
                    signExtSrc = 1'b0;
                end

                SLTI_cmd: begin         // SLTI
                    regDst = 1'b0;
                    memRead = 1'b0;
                    memWrite = 1'b0;
                    mem2reg = 1'b1;
                    aluSrc = 1'b1;
                    shamtSel = 1'b0;
                    regWrite = 1'b1;
                    sign_ext_mode = 1'b1;
                    aluControl = 4'b1011;
                    pcSrc = 1'b0;
                    signExtSrc = 1'b0;
                end

                SLTIU_cmd: begin        // SLTIU
                    regDst = 1'b0;
                    memRead = 1'b0;
                    memWrite = 1'b0;
                    mem2reg = 1'b1;
                    aluSrc = 1'b1;
                    shamtSel = 1'b0;
                    regWrite = 1'b1;
                    sign_ext_mode = 1'b1;
                    aluControl = 4'b1100;
                    pcSrc = 1'b0;
                    signExtSrc = 1'b0;
                end

                SEQI_cmd: begin         // SEQI
                    regDst = 1'b0;
                    memRead = 1'b0;
                    memWrite = 1'b0;
                    mem2reg = 1'b1;
                    aluSrc = 1'b1;
                    shamtSel = 1'b0;
                    regWrite = 1'b1;
                    sign_ext_mode = 1'b1;
                    aluControl = 4'b1101;
                    pcSrc = 1'b0;
                    signExtSrc = 1'b0;
                end

                LW_cmd: begin           // LW
                    regDst = 1'b0;
                    memRead = 1'b1;
                    memWrite = 1'b0;
                    mem2reg = 1'b0;
                    aluSrc = 1'b1;
                    shamtSel = 1'b0;
                    regWrite = 1'b1;
                    aluControl = 4'b0101;
                    sign_ext_mode = 1'b1;
                    pcSrc = 1'b0;
                    signExtSrc = 1'b0;
                end 

                SW_cmd: begin           // SW
                    regDst = 1'b0;
                    memRead = 1'b0;
                    memWrite = 1'b1;
                    mem2reg = 1'b0;
                    aluSrc = 1'b1;
                    shamtSel = 1'b0;
                    regWrite = 1'b0;
                    aluControl = 4'b0101;
                    sign_ext_mode = 1'b1;
                    pcSrc = 1'b0;
                    signExtSrc = 1'b0;
                end 

                BEQ_cmd: begin          // BEQ
                    regDst = 1'b1;
                    memRead = 1'b0;
                    memWrite = 1'b0;
                    mem2reg = 1'b1;
                    aluSrc = 1'b0;
                    shamtSel = 1'b0;
                    regWrite = 1'b0;
                    sign_ext_mode = 1'b1;
                    aluControl = 4'b0110;
                    signExtSrc = 1'b0;

                    if (isZero == 1'b1) begin
                        pcSrc = 1'b1;
                    end
                    else begin
                        pcSrc = 1'b0;
                    end
                end

                BNE_cmd: begin          // BNE
                    regDst = 1'b1;
                    memRead = 1'b0;
                    memWrite = 1'b0;
                    mem2reg = 1'b1;
                    aluSrc = 1'b0;
                    shamtSel = 1'b0;
                    regWrite = 1'b0;
                    sign_ext_mode = 1'b1;
                    aluControl = 4'b0110;
                    signExtSrc = 1'b0;

                    if (isZero == 1'b0) begin
                        pcSrc = 1'b1;
                    end
                    else begin
                        pcSrc = 1'b0;
                    end
                end

                JUMP_cmd: begin         // J
                    regDst = 1'b0;
                    memRead = 1'b0;
                    memWrite = 1'b0;
                    mem2reg = 1'b1;
                    aluSrc = 1'b0;
                    shamtSel = 1'b0;
                    regWrite = 1'b0;
                    sign_ext_mode = 1'b1;
                    aluControl = 4'b1111;
                    pcSrc = 1'b1;
                    signExtSrc = 1'b1;
                end

                default: begin
                    regDst = 1'b0;
                    memRead = 1'b0;
                    memWrite = 1'b0;
                    mem2reg = 1'b0;
                    aluSrc = 1'b0;
                    shamtSel = 1'b0;
                    regWrite = 1'b0;
                    aluControl = 4'b0000;
                    sign_ext_mode = 1'b0;
                    pcSrc = 1'b0;
                    signExtSrc = 1'b0;
                end
            endcase
        end
    end
endmodule