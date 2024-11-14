`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/26 19:34:23
// Design Name: 
// Module Name: ALUCtr
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


module ALUCtr(
    input [2:0] aluOp,
    input [5:0] funct,
    output [3:0] aluCtrOp,
    output shamtSign
    );

    reg [3:0] ALUCtrOut;
    reg ShamtSign;
    
    always @ (aluOp or funct)
    begin
        ShamtSign = 0;
        casex({aluOp,funct})
        //R type
            // jr
            9'b101001000:  
                ALUCtrOut = 4'b0101;
            
            // sll ok
            9'b101000000:  
            begin
                ALUCtrOut = 4'b0011;
                ShamtSign = 1;
            end
            
            // srl ok
            9'b101000010:  
            begin
                ALUCtrOut = 4'b0100;
                ShamtSign = 1;
            end
            
            // sra ok
            9'b101000011:  
            begin
                ALUCtrOut = 4'b1110;
                ShamtSign = 1;
            end
            
            // sllv ok
            9'b101000100:  
                ALUCtrOut = 4'b0011;
            
            // srlv ok
            9'b101000110:  
                ALUCtrOut = 4'b0100;
            
            // srav ok
            9'b101000111:  
                ALUCtrOut = 4'b1110;
            
            // add ok
            9'b101100000:  
                ALUCtrOut = 4'b0010;
            
            // addu ok
            9'b101100001:  
                ALUCtrOut = 4'b0010;
            
            // sub ok
            9'b101100010:  
                ALUCtrOut = 4'b0110;
            
            // subu ok
            9'b101100011:  
                ALUCtrOut = 4'b0110;
            
            // and ok
            9'b101100100:  
                ALUCtrOut = 4'b0000;
            
            // or ok
            9'b101100101:  
                ALUCtrOut = 4'b0001;
            
            // xor ok
            9'b101100110:  
                ALUCtrOut = 4'b1011;
            
            // nor ok
            9'b101100111:  
                ALUCtrOut = 4'b1100;
            
            // slt ok
            9'b101101010:  
                ALUCtrOut = 4'b0111;
            
            // sltu ok
            9'b101101011:  
                ALUCtrOut = 4'b1000;
        
            // lw,sw,add,addiu
            9'b000xxxxxx:  
                ALUCtrOut = 4'b0010; 
            
            // beq,bne
            9'b001xxxxxx:  
                ALUCtrOut = 4'b0110;
            
            //stli
            9'b010xxxxxx:   
                ALUCtrOut = 4'b0111;
            
            //stliu
            9'b110xxxxxx:   
                ALUCtrOut = 4'b1000;
            
            // andi
            9'b011xxxxxx:  
                ALUCtrOut = 4'b0000;
            
            // ori
            9'b100xxxxxx:  
                ALUCtrOut = 4'b0001;
            
            // xori
            9'b111xxxxxx:  
                ALUCtrOut = 4'b1011;
        
        endcase
    end
    
    assign aluCtrOut = ALUCtrOut;
    assign shamtSign = ShamtSign;

endmodule
