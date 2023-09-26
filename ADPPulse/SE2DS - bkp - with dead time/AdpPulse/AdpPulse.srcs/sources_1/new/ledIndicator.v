`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/14/2022 07:43:13 AM
// Design Name: 
// Module Name: ledIndicator
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


module ledIndicator(
    input clk,
    output ledline
    );
    
    reg [31:0]clkdiv = 32'd0;

    reg led;
    
    assign ledline = led;
    
    always @ (posedge clk) begin
        clkdiv <= clkdiv +1'd1;
        if (clkdiv >= 50000000) begin   //1 second f 500ms
            clkdiv <= 0;
            led <= ~led;
        end
    end
endmodule
