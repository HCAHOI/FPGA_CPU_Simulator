`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/27 23:01:03
// Design Name: 
// Module Name: Top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top(
    input clk,
    input reset
    );
    
    reg NOP;
    reg STALL;

    //IF stage
    //get the instruction
    reg [31:0] IF_PC;   //PC_OUT
    wire [31:0] IF_Inst;    //INST
    instMemory InstMemory(
        .address(IF_PC),
        .inst(IF_Inst)
    );

    //IF to ID
    reg [31:0] IF2ID_INST;
    reg [31:0] IF2ID_PC;

    //ID stage
    wire [12:0] ID_Ctr_Signal_Bus;
    wire [2:0] ID_CTR_SIGNAL_ALUOP;
    wire ID_JUMP_SIG;
    wire ID_JR_SIG;
    wire ID_EXT_SIG;
    wire ID_REG_DST_SIG;
    wire ID_JAL_SIG;
    wire ID_ALU_SRC_SIG;
    wire ID_LUI_SIG;
    wire ID_BEQ_SIG;
    wire ID_BNE_SIG;
    wire ID_MEM_WRITE_SIG;
    wire ID_MEM_READ_SIG;
    wire ID_MEM_TO_REG_SIG;
    wire ID_REG_WRITE_SIG;
    wire ID_ALU_OP;
    Ctr main_ctr(
        .opCode(IF2ID_INST[31:26]),
        .funct(IF2ID_INST[5:0]),
        .jump(ID_JUMP_SIG),
        .jrSign(ID_JR_SIG),
        .extSign(ID_EXT_SIG),
        .regDst(ID_REG_DST_SIG),
        .jalSign(ID_JAL_SIG),
        .aluSrc(ID_ALU_SRC_SIG),
        .luiSign(ID_LUI_SIG),
        .beqSign(ID_BEQ_SIG),
        .bneSign(ID_BNE_SIG),
        .memWrite(ID_MEM_WRITE_SIG),
        .memRead(ID_MEM_READ_SIG),
        .memToReg(ID_MEM_TO_REG_SIG),
        .regWrite(ID_REG_WRITE_SIG),
        .aluOp(ID_CTR_SIGNAL_ALUOP)
    );
    
    //ID signal bus
    assign ID_Ctr_Signal_Bus[0] = ID_REG_WRITE_SIG;
    assign ID_Ctr_Signal_Bus[1] = ID_MEM_TO_REG_SIG;
    assign ID_Ctr_Signal_Bus[2] = ID_MEM_READ_SIG;
    assign ID_Ctr_Signal_Bus[3] = ID_MEM_WRITE_SIG;
    assign ID_Ctr_Signal_Bus[4] = ID_BNE_SIG;
    assign ID_Ctr_Signal_Bus[5] = ID_BEQ_SIG;
    assign ID_Ctr_Signal_Bus[6] = ID_LUI_SIG;
    assign ID_Ctr_Signal_Bus[7] = ID_ALU_SRC_SIG;
    assign ID_Ctr_Signal_Bus[8] = ID_JAL_SIG;
    assign ID_Ctr_Signal_Bus[9] = ID_REG_DST_SIG;
    assign ID_Ctr_Signal_Bus[10] = ID_EXT_SIG;
    assign ID_Ctr_Signal_Bus[11] = ID_JR_SIG;
    assign ID_Ctr_Signal_Bus[12] = ID_JUMP_SIG;


    wire[31:0] ID_REG_READ_DATA1;   //REG_READ_DATA1
    wire[31:0] ID_REG_READ_DATA2;   //REG_READ_DATA2

    wire[4:0] WB_WRITE_REG_ID;         //WRITE_REG_ID
    wire[4:0] WB_WRITE_REG_ID_AFTER_JAL_MUX;         //WRITE_REG_ID_AFTER_JAL_MUX
    wire[31:0] WB_REG_WRITE_DATA;       //REG_WRITE_DATA
    wire[31:0] WB_REG_WRITE_DATA_AFTER_JAL_MUX; //REG_WRITE_DATA_AFTER_JAL_MUX
    wire WB_REG_WRITE;          //REG_WRITE

    wire [4:0] ID_REG_DEST;
    wire [4:0] ID_REG_RS = IF2ID_INST[25:21];
    wire [4:0] ID_REG_RT = IF2ID_INST[20:16];
    wire [4:0] ID_REG_RD = IF2ID_INST[15:11];
    // wire [4:0] ID_REG_READ1 = IF2ID_INST[25:21];
    // wire [4:0] ID_REG_READ2 = IF2ID_INST[20:16];

    Mux_32bits jal_data_mux(
        .sel(ID_JAL_SIG),
        .input1(IF2ID_PC+4),
        .input2(WB_REG_WRITE_DATA),
        .out(WB_REG_WRITE_DATA_AFTER_JAL_MUX)
    );

    Mux_32bits jal_reg_id_mux(
        .sel(ID_JAL_SIG),
        .input1(5'b11111),
        .input2(WB_WRITE_REG_ID),
        .out(WB_WRITE_REG_ID_AFTER_JAL_MUX)
    );
    
    //这里只产生目标寄存器ID，不直接连接到寄存器，将在WB阶段写回
    Mux_5bits reg_dst_mux(
        .sel(ID_Ctr_Signal_Bus[9]),
        .input1(ID_REG_RD),
        .input2(ID_REG_RT),
        .out(ID_REG_DEST)
    );

    Registers reg_file(
        .readReg1(ID_REG_RS),
        .readReg2(IF2ID_INST[20:16]),
        .writeReg(WB_WRITE_REG_ID_AFTER_JAL_MUX),
        .writeData(WB_REG_WRITE_DATA_AFTER_JAL_MUX),
        .regWrite(WB_REG_WRITE),
        .clk(clk),
        .reset(reset),
        .readData1(ID_REG_READ_DATA1),
        .readData2(ID_REG_READ_DATA2)
    );
    
    wire [31:0] ID_EXT_RES;

    signext sign_ext(
        .in(IF2ID_INST[15:0]),
        .extSign(ID_EXT_SIG),
        .out(ID_EXT_RES)
    );


    //ID to EX
    reg [2:0] ID2EX_ALUOP;
    reg [7:0] ID2EX_CTR_SIGNALS;
    reg [31:0] ID2EX_EXT_RES;
    reg [4:0] ID2EX_INST_RS;        //reg id of rs
    reg [4:0] ID2EX_INST_RT;        //reg id of rt
    reg [31:0] ID2EX_REG_READ_DATA1;
    reg [31:0] ID2EX_REG_READ_DATA2;
    reg [5:0] ID2EX_INST_FUNCT;
    reg [4:0] ID2EX_INST_SHAMT;
    reg [4:0] ID2EX_REG_DEST;
    reg [31:0] ID2EX_PC;


    // EX stage
    wire EX_ALU_SRC_SIG = ID2EX_CTR_SIGNALS[7];
    wire EX_LUI_SIG = ID2EX_CTR_SIGNALS[6];
    wire EX_BEQ_SIG = ID2EX_CTR_SIGNALS[5];
    wire EX_BNE_SIG = ID2EX_CTR_SIGNALS[4];

    wire [3:0] EX_ALU_CTR_OUT;    //ALU_CTR
    wire EX_SHAMT_SIGNAL;   //SHAMT_SIGN

    ALUCtr alu_ctr(
        .aluOp(ID2EX_ALUOP),
        .funct(ID2EX_INST_FUNCT),
        .shamtSign(EX_SHAMT_SIGNAL),
        .aluCtrOp(EX_ALU_CTR_OUT)
    );

    //FORWARDING
    wire [31:0] FORWARDING_RES_A;
    wire [31:0] FORWARDING_RES_B;

    wire [31:0] EX_ALU_INPUT2;
    wire [31:0] EX_ALU_INPUT1;

    Mux_32bits rt_ext_mux(
        .sel(EX_ALU_SRC_SIG),
        .input1(ID2EX_EXT_RES),
        .input2(FORWARDING_RES_B),
        .out(EX_ALU_INPUT2)
    );
    Mux_32bits rs_shamt_mux(
        .sel(EX_SHAMT_SIGNAL),
        .input1({27'b0, ID2EX_INST_SHAMT}),
        .input2(FORWARDING_RES_A),
        .out(EX_ALU_INPUT1)
    );

    wire EX_ALU_ZERO;   //ALU_ZERO
    wire [31:0] EX_ALU_RES;
    wire [31:0] EX_FINAL_DATA;
    ALU alu(
        .input1(EX_ALU_INPUT1),
        .input2(EX_ALU_INPUT2),
        .aluCtr(EX_ALU_CTR_OUT),
        .aluRes(EX_ALU_RES),
        .zero(EX_ALU_ZERO)
    );

    Mux_32bits lui_mux(
        .sel(EX_LUI_SIG),
        .input1({ID2EX_EXT_RES[15:0],16'b0}),
        .input2(EX_ALU_RES),
        .out(EX_FINAL_DATA)
    );

    wire [31:0] BRANCH_DEST = ID2EX_PC + 4 + (ID2EX_EXT_RES << 2);

    //EX to MA
    reg [3:0] EX2MA_CTR_SIGNALS;
    reg [31:0] EX2MA_ALU_RES;
    reg [31:0] EX2MA_REG_READ_DATA_2;
    reg [4:0] EX2MA_REG_DEST;

    wire MA_MEM_WRITE = EX2MA_CTR_SIGNALS[3];
    wire MA_MEM_READ = EX2MA_CTR_SIGNALS[2];
    wire MA_MEM_TO_REG = EX2MA_CTR_SIGNALS[1];
    wire MA_REG_WRITE = EX2MA_CTR_SIGNALS[0];

    //MA stage
    wire [31:0] MA_MEM_READ_DATA;
    Cache memory(
        .clk(clk),
        .address(EX2MA_ALU_RES),
        .writeData(EX2MA_REG_READ_DATA_2),
        .memWrite(MA_MEM_WRITE),
        .memRead(MA_MEM_READ),
        .readData(MA_MEM_READ_DATA)
    );

    wire [31:0] MA_FINAL_DATA;
    Mux_32bits mem_to_reg_mux(
        .sel(MA_MEM_TO_REG),
        .input1(MA_MEM_READ_DATA),
        .input2(EX2MA_ALU_RES),
        .out(MA_FINAL_DATA)
    );

    //MA to WB
    reg MA2WB_CTR_SIGNALS;
    reg [31:0] MA2WB_FINAL_DATA;
    reg [4:0] MA2WB_REG_DEST;

    //WB stage
    assign WB_WRITE_REG_ID = MA2WB_REG_DEST;
    assign WB_REG_WRITE_DATA = MA2WB_FINAL_DATA;
    assign WB_REG_WRITE = MA2WB_CTR_SIGNALS;

    // Jump or branch
    // ID stage
    wire[31:0] PC_AFTER_JUMP_MUX;
    Mux_32bits jump_mux(
        .sel(ID_JUMP_SIG), 
        .input1(((IF2ID_PC + 4) & 32'hf0000000) + (IF2ID_INST [25 : 0] << 2)),
        .input2(IF_PC + 4),
        .out(PC_AFTER_JUMP_MUX)
    );
    
    wire[31:0] PC_AFTER_JR_MUX;
    Mux_32bits jr_mux(
        .sel(ID_JR_SIG),   
        .input1(ID_REG_READ_DATA1),
        .input2(PC_AFTER_JUMP_MUX),
        .out(PC_AFTER_JR_MUX)
    );
    
    // EX stage
    wire EX_BEQ_BRANCH = EX_BEQ_SIG & EX_ALU_ZERO;
    wire[31:0] PC_AFTER_BEQ_MUX;
    Mux_32bits beq_mux(
        .sel(EX_BEQ_BRANCH),
        .input1(BRANCH_DEST),
        .input2(PC_AFTER_JR_MUX),
        .out(PC_AFTER_BEQ_MUX)
    );
    
    wire EX_BNE_BRANCH = EX_BNE_SIG & (~ EX_ALU_ZERO);
    wire[31:0] PC_AFTER_BNE_MUX;
    Mux_32bits bne_mux(
        .sel(EX_BNE_BRANCH),
        .input1(BRANCH_DEST),
        .input2(PC_AFTER_BEQ_MUX),
        .out(PC_AFTER_BNE_MUX)
    );

    wire[31:0] NEXT_PC = PC_AFTER_BNE_MUX;
    
    wire BRANCH = EX_BEQ_BRANCH | EX_BNE_BRANCH;  //decide at EX stage
    //清除IF-ID,ID-EX;EX-MA之后无需清除，因为本身没有写信号

    // forwarding
    wire[31:0] EX_FORWARDING_A_TEMP;
    wire[31:0] EX_FORWARDING_B_TEMP;
    Mux_32bits forward_A_mux1(
        .sel(WB_REG_WRITE & (MA2WB_REG_DEST == ID2EX_INST_RS)),
        .input1(MA2WB_FINAL_DATA),
        .input2(ID2EX_REG_READ_DATA1),
        .out(EX_FORWARDING_A_TEMP)
    );
    Mux_32bits forward_A_mux2(
        .sel(MA_REG_WRITE & (EX2MA_REG_DEST == ID2EX_INST_RS)),
        .input1(EX2MA_ALU_RES),
        .input2(EX_FORWARDING_A_TEMP),
        .out(FORWARDING_RES_A)
    );
    
    Mux_32bits forward_B_mux1(
        .sel(WB_REG_WRITE & (MA2WB_REG_DEST == ID2EX_INST_RT)),
        .input1(MA2WB_FINAL_DATA),
        .input2(ID2EX_REG_READ_DATA2),
        .out(EX_FORWARDING_B_TEMP)
    );
    Mux_32bits forward_B_mux2(
        .sel(MA_REG_WRITE & (EX2MA_REG_DEST == ID2EX_INST_RT)),
        .input1(EX2MA_ALU_RES),
        .input2(EX_FORWARDING_B_TEMP),
        .out(FORWARDING_RES_B)
    );
    // stall
    // wire STALL = ID2EX_CTR_SIGNALS[2] & //该信号来自于ID_MEM_READ_SIG
    //              ((ID2EX_INST_RT == ID_REG_RS) | 
    //              (ID2EX_INST_RT == ID_REG_RT)); //如果读取的两个寄存器与内存读冲突则stall
    
    initial IF_PC = 0;
    
    always @(reset)
    begin
        if (reset) begin
            // NOP = 1;
            IF_PC = 0;
            IF2ID_INST = 0;
            IF2ID_PC = 0;
            ID2EX_ALUOP = 0;
            ID2EX_CTR_SIGNALS = 0;
            ID2EX_EXT_RES = 0;
            ID2EX_INST_RS = 0;
            ID2EX_INST_RT = 0;
            ID2EX_REG_READ_DATA1 = 0;
            ID2EX_REG_READ_DATA2 = 0;
            ID2EX_INST_FUNCT = 0;
            ID2EX_INST_SHAMT = 0;
            ID2EX_REG_DEST = 0;
            EX2MA_CTR_SIGNALS = 0;
            EX2MA_ALU_RES = 0;
            EX2MA_REG_READ_DATA_2 = 0;
            EX2MA_REG_DEST = 0;
            MA2WB_CTR_SIGNALS = 0;
            MA2WB_FINAL_DATA = 0;
            MA2WB_REG_DEST = 0;
        end
    end
    
    always @(posedge clk) 
    begin
    
        NOP = BRANCH | ID_JUMP_SIG | ID_JR_SIG;
        STALL = ID2EX_CTR_SIGNALS[2] & //该信号来自于ID_MEM_READ_SIG
                 ((ID2EX_INST_RT == ID_REG_RS) | 
                 (ID2EX_INST_RT == ID_REG_RT)); //如果读取的两个寄存器与内存读冲突则stall

        // IF - ID
        if(!STALL)
        begin
            if(NOP)
            begin
                if(IF_PC == NEXT_PC)
                begin
                    IF2ID_INST <= IF_Inst;
                    IF2ID_PC <= IF_PC;
                    IF_PC <= IF_PC + 4;
                end
                else begin
                    IF2ID_INST <= 0;
                    IF2ID_PC <= 0;
                    IF_PC <= NEXT_PC;
                end
            end
            else begin
                IF2ID_INST <= IF_Inst;
                IF2ID_PC <= IF_PC;
                IF_PC <= NEXT_PC;
            end
        end
        
        // ID - EX
        if (!ID_JAL_SIG)
        begin
            if (STALL|NOP)
            begin
                //STALL：下�?个周期不进行EX阶段，等待上条指令MA完成
                //BRANCH：发生跳转，从这里截断命�?
                //JUMP的决定在ID阶段，不影响
                ID2EX_PC <= IF2ID_PC;
                ID2EX_ALUOP <= 3'b000;
                ID2EX_CTR_SIGNALS <= 0;
                ID2EX_EXT_RES <= 0;
                ID2EX_INST_RS <= 0;
                ID2EX_INST_RT <= 0;
                ID2EX_REG_READ_DATA1 <= 0;
                ID2EX_REG_READ_DATA2 <= 0;
                ID2EX_INST_FUNCT <= 0;
                ID2EX_INST_SHAMT <= 0;
                ID2EX_REG_DEST <= 0;
            end else 
            begin
                ID2EX_PC <= IF2ID_PC;
                ID2EX_ALUOP <= ID_CTR_SIGNAL_ALUOP;
                ID2EX_CTR_SIGNALS <= ID_Ctr_Signal_Bus[7:0];
                ID2EX_EXT_RES <= ID_EXT_RES;
                ID2EX_INST_RS <= ID_REG_RS;
                ID2EX_INST_RT <= ID_REG_RT;
                ID2EX_REG_DEST <= ID_REG_DEST;
                ID2EX_REG_READ_DATA1 <= ID_REG_READ_DATA1;
                ID2EX_REG_READ_DATA2 <= ID_REG_READ_DATA2;
                ID2EX_INST_FUNCT <= IF2ID_INST[5:0];
                ID2EX_INST_SHAMT <= IF2ID_INST[10:6];
            end
        end

        // EX - MA
        if (!ID_JAL_SIG)
        begin
            EX2MA_CTR_SIGNALS <= ID2EX_CTR_SIGNALS[3:0];
            EX2MA_ALU_RES <= EX_FINAL_DATA;
            EX2MA_REG_READ_DATA_2 <= FORWARDING_RES_B;
            EX2MA_REG_DEST <= ID2EX_REG_DEST;
        end

        // MA - WB
        if (!ID_JAL_SIG)
        begin
            MA2WB_CTR_SIGNALS <= EX2MA_CTR_SIGNALS[0];
            MA2WB_FINAL_DATA <= MA_FINAL_DATA;
            MA2WB_REG_DEST <= EX2MA_REG_DEST;
        end
        
    end

endmodule
