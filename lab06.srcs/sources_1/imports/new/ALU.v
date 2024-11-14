`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/22 09:43:35
// Design Name: 
// Module Name: ALU
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


module ALU(
    input [31:0] input1,
    input [31:0] input2,
    input [3:0] aluCtr,
    output zero,
    output [31:0] aluRes
    );
    
    
    reg Zero;
    reg [31:0] ALURes;

    always @ (input1 or input2 or aluCtr)
    begin
        case(aluCtr)
        //and
        4'b0000:    
            ALURes = input1 & input2;
            
        //or
        4'b0001:
            ALURes = input1 | input2;
        
        //add
        4'b0010:    
            ALURes = input1 + input2;
            
        //left shift
        4'b0011:    
            ALURes = input2 << input1;
            
        //right shift
        4'b0100:    
            ALURes = input2 >> input1;
            
        //nothing happened
        4'b0101:
            ALURes = input1;
                    
        //sub
        4'b0110:    
            ALURes = input1 - input2;
            
        //slt
        4'b0111:    
            ALURes = ($signed(input1) < $signed(input2));

        //nor
        4'b1100:    
            ALURes = ~(input1 | input2);
            
        //xor
        4'b1101:    
            ALURes = input1 ^ input2;
            
        //arithmetic shift right
        4'b1110:
            ALURes = ($signed(input2) >> input1);
            
        default:
            ALURes = input1;
        
        endcase
        
        Zero = (ALURes == 0);
    end

    assign zero = Zero;
    assign aluRes = ALURes;
    
endmodule
