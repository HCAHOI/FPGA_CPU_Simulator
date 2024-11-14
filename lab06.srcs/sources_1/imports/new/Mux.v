`timescale 1ns / 1ps


//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/27 23:00:30
// Design Name: 
// Module Name: Mux
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

module Mux_32bits(
    input sel,
    input [31:0] input1,
    input [31:0] input2,
    output [31:0] out
    );
    
    assign out = sel ? input1 : input2;
endmodule

module Mux_5bits(
    input sel,
    input [4:0] input1,
    input [4:0] input2,
    output [4:0] out
    );
    
    assign out = sel ? input1 : input2;
endmodule

