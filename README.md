<h1>  ⚽️ FPGA Soccer Pong Game (Verilog) ⚽️</h1>
<h3>Made using Verilog in Vivado
<br/> FPGA Board: Basys 3 (Digilent)</h3>

<br/>
<b>
This project is a digital watch that is made on my FPGA board using the VGA output<br/>
The module lets the user play a soccer/football themed pong game<br/>
Click
<a href="https://youtu.be/NJnX_LAqaFY"> here</a> to see the watch being used
</b>
<h2> 
  Modules 
</h2>

<h3>
  Debouncer
</h3>
This module simply is used to prevent any "bouncing" of the buttons which could lead to unintended actions/button presses on the board<br/>
It is a shift register that is triggered by a clock cycle of 5 Hz<br/>
<h3>
  Clock Dividers
</h3>
  Clock divider primarily used for previously mentioned debouncer module - the vga_controller module has its own built in 
<h3>
  VGA Control
</h3>
  Keeps track of pixel coordinates (x, y) - 640x480 visual display, 800x525 total display (including horizontal/vertical retrace/porches)<br/>
  800*525*60 = 25 MHz (approx clock signal)<br/>
  Outputs hsync and vsync signals for the display calibration<br/>
  
<h3>
  Display Control
</h3>
  Controls all of the of the visual components - paddle, wall, goalkeeper, ball<br/>
  Controls the movement of the ball, paddle, gk every refresh_tick (start of vertical retrace, video is not on)<br/>
  Outputs RGB signals to the top module so the FPGA knows what to display on monitor<br/>
  
  
  


<h3>
  Other Info
</h3>
vga_controller module used from FPGA Discovery and other general project help/inspiration - https://www.youtube.com/watch?v=Uo1GfQFAkK8&t
