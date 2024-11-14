`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/10 18:35:12
// Design Name: 
// Module Name: InstMem
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


module instMemory(
    input [31 : 0] address,
    output [31 : 0] inst
    );
    
    reg [31 : 0] instFile [0 : 1023];
    
    initial begin
        instFile[0] = 32'b10001100000000010000000000000000;
        instFile[1] = 32'b10001100000000100000000000000001;
        instFile[2] = 32'b00000000000000100010000001000010;
        instFile[3] = 32'b00000000000001000010100001000000;
        instFile[4] = 32'b00010000010001010000000000000001;
        instFile[5] = 32'b00000001000000010100000000100000;
        instFile[6] = 32'b00000000000000100001000001000010;
        instFile[7] = 32'b00000000000000010000100001000000;
        instFile[8] = 32'b00010000011000100000000000000001;
        instFile[9] = 32'b00001000000000000000000000000010;
        instFile[10] = 32'b10101100000010000000000000000100;
        //instFile[11] = 32'b00001000000000000000000000000000;
    end
    
    assign inst = instFile[address / 4];
endmodule
