`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/14/2022 08:11:49 AM
// Design Name: 
// Module Name: counterDisplay
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


module counterDisplay(
    input clk,
    input enable,
    input clear,
    input aa,
    output [31:0] NoP
    );
    
	reg [23:0]clkdiv = 24'd0;
    
    reg [31:0] NoPbuf;
    
    assign NoP = NoPbuf;
    
    initial NoPbuf <= 0;
    
    always @ (posedge clk) begin
       if (clear)
            NoPbuf = 32'h0;
        
       if (aa)
            NoPbuf = 32'h10000000;
              
       if (enable) begin
            
            clkdiv <= clkdiv +1'd1;
            if (clkdiv >= 1000000) begin
                clkdiv <= 0;
                NoPbuf <= NoPbuf +1;
            end
        
        end
    end
endmodule
