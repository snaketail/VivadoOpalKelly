`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/13/2022 08:35:41 AM
// Design Name: 
// Module Name: SlowLogicHW
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


module ApdLogicHW(
    //Main Clock
    input wire clk,
    //Input pulse source
    input wire Adp_pulse,
    
    input wire AdpSim,
    
    //Input Delay(clk cycle) in 16bit 
    input wire [31:0] Quench_T,
    input wire [31:0] Wait_T,
    input wire [31:0] Reset_T,
    
    input wire enable,
    input wire clear,
    
    //Output Pulse
    output reg Quench,
    output reg Reset,
    
    //Output pulse Adp counts
    output reg [31:0] NoP,
    
    //output pulse speed
    output reg [31:0] Speed
    );

reg [1:0] state = 2'd0;

reg [31:0]clk_tgt = 32'd0;

reg [31:0] speedclk = 32'd0;

reg [31:0] Nop_Speed = 32'd0;

reg AfterReset = 0;

reg AdpPE, AdpPre; 
//reg AdpSimPE, AdpSimPre;

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

initial NoP <= 0;


always @ (posedge clk) 
begin
    if (clear)
        NoP <= 0;

// if the counter is enabled, update the speed at the interval of 100ms    
    if (enable)
        begin
            speedclk <= speedclk + 1;
            //d'200000000 x 5ns = 1s
            if (speedclk >= 32'd200000000)
                begin
                    Speed = Nop_Speed;
                    Nop_Speed <= 32'd0;
                    speedclk  <= 32'd0;
                end
        end
        
    if (!enable && state ==S0) 
        begin
            state <= S0;
            clk_tgt <= 0;
            AdpPre <= Adp_pulse;
            speedclk <= 0;
            Speed <= 0;
            Nop_Speed <= 0;
            //AdpSimPre <=AdpSim;
        end
    else 
        begin
            case (state)
               S1:
               begin
                  if(clk_tgt >= Quench_T) 
                      begin
                        AfterReset <= 0;
                        clk_tgt <= 0;
                        state <= S2;
                      end
                  else
                      clk_tgt<=clk_tgt+1;
               end
               S2:
               begin
                  if(clk_tgt >= Wait_T)
                    if (AfterReset) 
                      begin
                        state <= S0;
                        clk_tgt <= 0;
                        NoP <= NoP +1;
                        Nop_Speed <= Nop_Speed +1;
                        AdpPre <= Adp_pulse;
                       // AdpSimPre <=AdpSim;
                        
                      end
                    else
                      begin
                        clk_tgt <= 0;
                        state <= S3;
                      end
                  else
                      clk_tgt=clk_tgt+1;
               end
               S3:
               begin
                  if(clk_tgt >= Reset_T) 
                      begin
                        clk_tgt <= 0;
                        state <= S2;
                        AfterReset <= 1;
                      end
                  else
                      clk_tgt<=clk_tgt+1;
               end
               default:
               begin
                  AdpPE = ((Adp_pulse == 1) && (AdpPre == 0));
                  //AdpSimPE= ((AdpSim ==1) && (AdpSimPre ==0));
                  AdpPre <= Adp_pulse;
                  //AdpSimPre <=AdpSim;
                  if(Adp_pulse || AdpSim) 
                      begin
                        clk_tgt <= 0;
                        state = S1;
                      end
                  else
                      state <= S0;
               end
            endcase
        end
end

endmodule


