`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/27/2024 04:24:12 PM
// Design Name: 
// Module Name: debouncer
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


module debouncer(
    input btn,
    input clk,
    output wire btnsig
    );
    
    reg q0, q1, q2;
    
    always @(clk)begin
        q0 <= btn;
        q1 <= q0;
        q2 <= q1;
    end
    
    assign btnsig = q2;
        
    
endmodule
