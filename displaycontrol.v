//`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
//// Company: 
//// Engineer: 
//// 
//// Create Date: 09/06/2024 01:33:51 PM
//// Design Name: 
//// Module Name: displaycontrol
//// Project Name: 
//// Target Devices: 
//// Tool Versions: 
//// Description: 
//// 
//// Dependencies: 
//// 
//// Revision:
//// Revision 0.01 - File Created
//// Additional Comments:
//// 
////////////////////////////////////////////////////////////////////////////////////


module displaycontrol(
input clk_100MHz, //Maybe change to divided clock for movement of objects
input btnL,
input btnR,
input rst, // btnC
input video_on,
input [9:0] x,
input [9:0] y,
output reg[11:0] rgb
);

    
    parameter xmax = 639;
    parameter ymax = 479;
    
    wire refresh_tick;
    assign refresh_tick = ((y == 481) && (x == 0)) ? 1 : 0; // start of vsync(vertical retrace)
    
//    // Object parameters
    
    // Wall & Goal
    parameter wall_height = 45;
    parameter goal_left = 259;
    parameter goal_right = 379;
    
    
    //Paddle
    reg [9:0] padleftnext = 269, pad_left;
    parameter pad_width = 100;
    parameter pad_top = 400;
    parameter pad_bot = 410;
    parameter pad_speed = 2;
    
    //Goalkeeper
    reg [9:0] gkleftnext = 304, gk_left;
    parameter gk_width = 30;
    parameter gk_top = 40;
    parameter gk_bot = 70;
    parameter gk_speed = 1;
    reg gk_direction = 0;
    
    reg [9:0] ballnextl, ball_left  = xmax/2;
    reg [9:0] balltopnext, ball_top  = ymax/2;
    parameter ball_size = 12;
    reg h_ball = 1;
    reg v_ball = 1;
    reg h_ball_next, v_ball_next;
    parameter ball_speed_h = 1;
    parameter ball_speed_v = 3;
    
   
   // Coordinates (for collision and visual)
       
    wire [9:0] ball_l, ball_r, ball_t, ball_b; 
   
    wire [9:0] pad_l, pad_r;
 
    wire [9:0] gk_l, gk_r;
   
    // Visual Wires
    
    wire wall_on, ball_on, gk_on, pad_on;
   
   // Wires for Collision Logic
   
    wire bounds;
    
    assign bounds = ((ball_b <= 0) || (ball_t >= ymax)) ? 1 : 0;
   
   // Ball Coordinate Wires 
   
   assign ball_l = ball_left;
   assign ball_r = ball_left + ball_size;
   assign ball_t = ball_top;
   assign ball_b = ball_top + ball_size; 
   
   
   // Pad Coordinate Wires
   
   assign pad_l = pad_left;
   assign pad_r = pad_left + pad_width; 
   
  // Gk Coordinate Wires
  
   assign gk_l = gk_left;
   assign gk_r = gk_left + gk_width;
    
    
  // Visual Output Wires
  
    
  assign wall_on = (y <= wall_height && ((x <= goal_left) || (x >= goal_right))) ? 1 : 0;
  assign ball_on = ((y <= ball_b) && (y >= ball_t) && (x <= ball_r) && (x >= ball_l)) ? 1 : 0;
  assign gk_on = ((y <= gk_bot) && (y >= gk_top) && (x <= gk_r) && (x >= gk_l)) ? 1 : 0;
  assign pad_on = ((y <= pad_bot) && (y >= pad_top) && (x <= pad_r) && (x >= pad_l)) ? 1 : 0;
 
// ---------------------- RESET ---------------------------------------    
    
    always @(posedge clk_100MHz or posedge rst)begin
        if (rst)begin
            pad_left <= 9'd269;
            gk_left <= 9'd304;
            ball_left <= xmax/2;
            ball_top <= ymax/2;
            h_ball <= 1;
            v_ball <= 1;
        end
        else if (bounds)begin
            ball_left <= xmax/2;
            ball_top <= ymax/2;
            h_ball <= ~h_ball;
            v_ball <= 0;
        end
        else begin
            pad_left <= padleftnext;
            gk_left <= gkleftnext;
            ball_left <= ballnextl;
            ball_top <= balltopnext;
            h_ball <= h_ball_next;
            v_ball <= v_ball_next;
        end     
    end
//-------------------------- PADDLE MOVEMENT -----------------------------    
    always @(*)begin 
        padleftnext = pad_left;        
        if (refresh_tick)begin                 
             
                // Right Movement
                
                if (btnR && (pad_left <= 537))                    
                        padleftnext <= pad_left + pad_speed;
                else if (btnR && (pad_left > 537))
                        padleftnext <= 539;
                
                // Left Movement
                
                else if (btnL && (pad_left >= 2))
                    padleftnext <= pad_left - pad_speed;
                
                else if (btnL & (pad_left < 2))
                    padleftnext <= 0;                    
        end
   
    end    
// ---------------------- GK MOVEMENT -------------------------------------   
    always @(posedge refresh_tick)begin 
            if (gk_l <= goal_left & (gk_direction == 1))
                gk_direction = 0;
            else if (gk_r >= goal_right & (gk_direction == 0))
                gk_direction = 1;
            
            if (gk_direction == 0)
                gkleftnext = gk_left + gk_speed;
            else if (gk_direction == 1)
                gkleftnext = gk_left - gk_speed;        
        
    end
//------------------- Ball Movement and Collision --------------------------
    always @(posedge refresh_tick)begin // Ball collision
        
        //#####  Collision Logic  #####  
         
         h_ball_next = h_ball;
         v_ball_next = v_ball;
         
         
        // Wall Collision
        if (ball_t <= wall_height && ((ball_l <= goal_left) || (ball_r >= goal_right)))begin
            v_ball_next = 0;
        end
        
        
        // Screen Border Collision 
        
        if (ball_l <= 0)
            h_ball_next = 0;
            
        if  (ball_r >= xmax)
            h_ball_next = 1;
        
       // GK Collision
       
        if ((ball_t <= gk_bot) && (ball_b >= gk_top) && (ball_l <= gk_r) && (ball_r >= gk_l))begin
            v_ball_next = 0;
        end
       
        if ((ball_b >= pad_top) && (ball_t <= pad_bot) && (ball_l <= pad_r) && (ball_r >= pad_l))begin
            v_ball_next = 1;
            if((ball_left + 6) <= (pad_l + 50))
                h_ball_next <= 1;
            else
                h_ball_next <= 0;
        end

//       Ball Movement        
        if (h_ball == 0)
            ballnextl = ball_left + ball_speed_h;
        else if (h_ball == 1)
            ballnextl = ball_left - ball_speed_h;    
        
        if (v_ball == 0)
            balltopnext = ball_top + ball_speed_v;   
        else if (v_ball == 1)
            balltopnext = ball_top - ball_speed_v;
   
    end

    always @(*) begin // Generates Color output based on
        if (~video_on)            
            rgb = 12'h000;
        else begin
            if (ball_on)
                rgb = 12'hFFF;
            else if (wall_on)
                rgb = 12'h444;            
           else if (gk_on)
                rgb = 12'h22F;
           else if (pad_on)
                rgb = 12'hFFF;            
            else
                rgb = 12'h0E1;
        end      
    end
    
 endmodule
