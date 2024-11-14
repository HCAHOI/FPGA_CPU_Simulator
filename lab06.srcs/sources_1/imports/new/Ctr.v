`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/21 21:00:21
// Design Name: 
// Module Name: Ctr
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


module Ctr(
    input [5:0] opCode,
    input [5:0] funct,
    output regDst,
    output aluSrc,
    output memToReg,
    output regWrite,
    output memRead,
    output memWrite,
    output [2:0] aluOp,
    output jump,
    output extSign,
    output jalSign,
    //new sign
    output luiSign,
    output jrSign,
    output beqSign,
    output bneSign
    );
    
    reg RegDst;
    reg ALUSrc;
    reg MemToReg;
    reg RegWrite;
    reg MemRead;
    reg MemWrite;
    reg [2:0] ALUOp;
    reg Jump;
    reg ExtSign;
    reg JalSign;
    //new sign
    reg LuiSign;
    reg JrSign;
    reg BeqSign;
    reg BneSign;

    always @(opCode)
    begin
        case(opCode)
        //R-format, jr
        6'b000000: 
        begin
            RegDst = 1;
            ALUSrc = 0;
            MemToReg = 0;
            MemRead = 0;
            MemWrite = 0;
            Jump = 0;
            ALUOp = 3'b101;
            ExtSign = 0;
            JalSign = 0; 
            if (funct == 6'b001000) //jr
            begin
                RegWrite = 0;
                JrSign = 1;
            end
            else
            begin
                RegWrite = 1;
                JrSign = 0;
            end
            LuiSign = 0;
            BeqSign = 0;
            BneSign = 0;
        end
        
        //lw
        6'b100011: 
        begin
            RegDst = 0;
            ALUSrc = 1;
            MemToReg = 1;
            RegWrite = 1;
            MemRead = 1;
            MemWrite = 0;
            ALUOp = 3'b000;
            Jump = 0;
            ExtSign = 1;
            JalSign = 0;
            LuiSign = 0;
            JrSign = 0;
            BeqSign = 0;
            BneSign = 0;
        end
        
        //sw
        6'b101011: 
        begin
            RegDst = 0; 
            ALUSrc = 1;
            MemToReg = 0; 
            RegWrite = 0;
            MemRead = 0;
            MemWrite = 1; 
            ALUOp = 3'b000;
            Jump = 0;
            ExtSign = 1;
            JalSign = 0;
            LuiSign = 0;
            JrSign = 0;
            BeqSign = 0;
            BneSign = 0;
        end
        
        //beq
        6'b000100: 
        begin
            RegDst = 0;
            ALUSrc = 0;
            MemToReg = 0; 
            RegWrite = 0;
            MemRead = 0;
            MemWrite = 0;
            ALUOp = 3'b001;
            Jump = 0;
            ExtSign = 1;
            JalSign = 0;
            LuiSign = 0;
            JrSign = 0;
            BeqSign = 1;
            BneSign = 0;
        end

        //bne
        6'b000100: 
        begin
            RegDst = 0;
            ALUSrc = 0;
            MemToReg = 0; 
            RegWrite = 0;
            MemRead = 0;
            MemWrite = 0;
            ALUOp = 3'b001;
            Jump = 0;
            ExtSign = 1;
            JalSign = 0;
            LuiSign = 0;
            JrSign = 0;
            BeqSign = 0;
            BneSign = 1;
        end
        
        //jump
        6'b000010: 
        begin
            RegDst = 0;
            ALUSrc = 0;
            MemToReg = 0;
            RegWrite = 0;
            MemRead = 0;
            MemWrite = 0;
            ALUOp = 3'b000;
            Jump = 1;
            ExtSign = 0;
            JalSign = 0;
            LuiSign = 0;
            JrSign = 0;
            BeqSign = 0;
            BneSign = 0;
        end
        
        //jal
        6'b000011: 
        begin
            RegDst = 0;
            ALUSrc = 0;
            MemToReg = 0;
            RegWrite = 1;
            MemRead = 0;
            MemWrite = 0;
            ALUOp = 3'b000;
            Jump = 1;
            ExtSign = 0;
            JalSign = 1;
            LuiSign = 0;
            JrSign = 0;
            BeqSign = 0;
            BneSign = 0;
        end
        
        //addi
        6'b001000:      
        begin
            RegDst = 0;
            ALUSrc = 1;
            MemToReg = 0;
            RegWrite = 1;
            MemRead = 0;
            MemWrite = 0;
            ALUOp = 3'b000;
            Jump = 0;
            ExtSign = 1;
            JalSign = 0;
            LuiSign = 0;
            JrSign = 0;
            BeqSign = 0;
            BneSign = 0;
        end

        //addiu
        6'b001001:      
        begin
            RegDst = 0;
            ALUSrc = 1;
            MemToReg = 0;
            RegWrite = 1;
            MemRead = 0;
            MemWrite = 0;
            ALUOp = 3'b000;
            Jump = 0;
            ExtSign = 0;
            JalSign = 0;
            LuiSign = 0;
            JrSign = 0;
            BeqSign = 0;
            BneSign = 0;
        end
        
        //andi
        6'b001100:      
        begin
            RegDst = 0;
            ALUSrc = 1;
            MemToReg = 0;
            RegWrite = 1;
            MemRead = 0;
            MemWrite = 0;
            ALUOp = 3'b011;
            Jump = 0;
            ExtSign = 0;
            JalSign = 0;
            LuiSign = 0;
            JrSign = 0;
            BeqSign = 0;
            BneSign = 0;
        end
        
        //ori
        6'b001101:      
        begin
            RegDst = 0;
            ALUSrc = 1;
            MemToReg = 0;
            RegWrite = 1;
            MemRead = 0;
            MemWrite = 0;
            ALUOp = 3'b100;
            Jump = 0;
            ExtSign = 0;
            JalSign = 0;
            LuiSign = 0;
            JrSign = 0;
            BeqSign = 0;
            BneSign = 0;
        end
        
        //xori
        6'b001110:      
        begin
            RegDst = 0;
            ALUSrc = 1;
            MemToReg = 0;
            RegWrite = 1;
            MemRead = 0;
            MemWrite = 0;
            ALUOp = 3'b111;
            Jump = 0;
            ExtSign = 0;
            JalSign = 0;
            LuiSign = 0;
            JrSign = 0;
            BeqSign = 0;
            BneSign = 0;
        end
        
        //lui
        6'b001111:      
        begin
            RegDst = 0;
            ALUSrc = 0;
            MemToReg = 0;
            RegWrite = 1;
            MemRead = 0;
            MemWrite = 0;
            ALUOp = 3'b000;
            Jump = 0;
            ExtSign = 0;
            JalSign = 0;
            LuiSign = 1;
            JrSign = 0;
            BeqSign = 0;
            BneSign = 0;
        end
        
        //slti
        6'b001010:      
        begin
            RegDst = 0;
            ALUSrc = 1;
            MemToReg = 0;
            RegWrite = 1;
            MemRead = 0;
            MemWrite = 0;
            ALUOp = 3'b010;
            Jump = 0;
            ExtSign = 1;
            JalSign = 0;
            LuiSign = 0;
            JrSign = 0;
            BeqSign = 0;
            BneSign = 0;
        end
        
        //sltiu
        6'b001010:      
        begin
            RegDst = 0;
            ALUSrc = 1;
            MemToReg = 0;
            RegWrite = 1;
            MemRead = 0;
            MemWrite = 0;
            ALUOp = 3'b110;
            Jump = 0;
            ExtSign = 0;
            JalSign = 0;
            LuiSign = 0;
            JrSign = 0;
            BeqSign = 0;
            BneSign = 0;
        end
        
        //nop
        default:
        begin
            RegDst = 0;
            ALUSrc = 0;
            MemToReg = 0;
            RegWrite = 0;
            MemRead = 0;
            MemWrite = 0;
            ALUOp = 2'b00;
            Jump = 0;
            ExtSign = 0;
            JalSign = 0;
            LuiSign = 0;
            JrSign = 0;
            BeqSign = 0;
            BneSign = 0;
        end
        endcase
    end

    assign regDst = RegDst;
    assign aluSrc = ALUSrc;
    assign memToReg = MemToReg;
    assign regWrite = RegWrite;
    assign memRead = MemRead;
    assign memWrite = MemWrite;
    assign aluOp = ALUOp;
    assign jump = Jump;
    assign extSign = ExtSign;
    assign jalSign = JalSign;
    assign luiSign = LuiSign;
    assign jrSign = JrSign;
    assign beqSign = BeqSign;
    assign bneSign = BneSign;
    
endmodule
