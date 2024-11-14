`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/26 22:15:19
// Design Name: 
// Module Name: dataMemory
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


module dataMemory(
    input clk,
    input [31:0] address,
    input [31:0] writeData,
    input memWrite,
    input memRead,
    output [127:0] readData
    );
    
    reg [31:0] memFile[0:1023];
    reg [127:0] ReadData;
    integer i = 0;
    
    initial begin
        for(i = 0; i < 1024; i = i + 1)
            memFile[i] = 0;
    end
    
    //delete negedge memWrite there for on-board
    always @(address or memRead) 
    begin
        if(memRead)
        begin
            if(address > 1024)
                ReadData = 0;
            else 
                ReadData = {memFile[address], memFile[address + 1], memFile[address + 2], memFile[address + 3]};
        end
    end
    
    always@ (negedge clk) 
    begin
        if(memWrite)
            if(address < 1024)
                memFile[address] = writeData;
    end
    
    
   assign readData = ReadData;
endmodule
