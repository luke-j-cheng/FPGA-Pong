`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/09/2024 04:01:45 PM
// Design Name: 
// Module Name: top
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
input btnL,
input btnR,
input rst,
input clk,
output [11:0] rgb,
output hsync,
output vsync
    );

wire btnLsig, btnRsig;
reg [11:0] rgbreg;
wire [11:0] rgbnext;
wire [9:0] x_out, y_out;

Clockslow cs(
    .clk(clk),
    .newclk(clk_400));


vga_controller vgacon(
    .clk_100MHz(clk),
    .reset(rst),        
    .video_on(vid_on),   
    .hsync(hsync),       
    .vsync(vsync),
    .p_tick(p_tick),
    .x(x_out),
    .y(y_out)
    );      

debouncer d1(
    .btn(btnL),
    .clk(clk_400),
    .btnsig(btnLsig)
    );

debouncer d0(
    .btn(btnR),
    .clk(clk_400),
    .btnsig(btnRsig)
    );
    
displaycontrol dc(
    .clk_100MHz(clk),
    .btnL(btnLsig),
    .btnR(btnRsig),
    .rst(rst),
    .video_on(vid_on),
    .x(x_out),
    .y(y_out),
    .rgb(rgbnext));


    
 
 
always @(posedge clk)begin
    if (p_tick)
        rgbreg <= rgbnext;
end

assign rgb = rgbreg;
    
    
endmodule
