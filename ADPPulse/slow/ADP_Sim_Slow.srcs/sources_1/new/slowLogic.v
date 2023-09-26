`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/12/2022 11:37:15 AM
// Design Name: 
// Module Name: slowLogic
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


module slowLogic(
    input wire clk,
    input wire Adp_pulse,
    output reg Quench,
    output reg Reset,
    output reg AdpPE
    );

reg [1:0] state = 2'd0;
reg [15:0] Quench_T = 16'd5;
reg [15:0] Wait_T = 16'd3;
reg [15:0] Reset_T = 16'd2;
reg [15:0] counter;
reg Adp_pre;


parameter S0 = 2'd0, S1 = 2'd1, S2 = 2'd2, S3 = 2'd3;

always @ (state) 
begin
    case (state)
        S1:begin
           Quench = 1'b1;
           Reset = 1'b0;
           end
        S2:begin
           Quench = 1'b0;
           Reset = 1'b0;
           end
        S3:begin
           Quench = 1'b0;
           Reset = 1'b1;
           end
        default:begin
           Quench = 1'b0;
           Reset = 1'b0;
           end
    endcase
end

always @ (posedge clk) 
begin
    //if (reset)
    //    state <= S0;
    AdpPE = (Adp_pulse == 1) & (Adp_pre == 0);
    Adp_pre = Adp_pulse;
    case (state)
       S1:
       begin
          if(counter >= Quench_T) 
              begin
                counter = 16'd0;
                state <= S2;
              end
          else
              counter=counter+1;
       end
       S2:
       begin
          if(counter >= Wait_T) 
              begin
                counter = 16'd0;
                state <= S3;
              end
          else
              counter=counter+1;
       end
       S3:
       begin
          if(counter >= Reset_T) 
              begin
                counter = 16'd0;
                state <= S0;
              end
          else
              counter=counter+1;
       end
       default:
       begin
          if(AdpPE) 
              begin
                counter = 16'd0;
                state <= S1;
              end
          else
              state <= S0;
       end
    endcase
end

endmodule
