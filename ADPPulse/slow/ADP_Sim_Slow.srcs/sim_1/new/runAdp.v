`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/12/2022 11:20:20 PM
// Design Name: 
// Module Name: runAdp
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


module runAdp;
    reg clk, Adp;
    wire Q, R, apdPE;
    
    always begin
        clk = 1; #5;
        clk = 0; #5;
    end    
    
    always begin
        Adp = 0; #100;
        Adp = 1; #20;
        Adp = 0; #100;
    end
    
    slowLogic slowLogic_i(
        .clk(clk),
        .Adp_pulse(Adp),
        .Quench(Q),
        .Reset(R),
        .AdpPE(apdPE)
        );

endmodule
