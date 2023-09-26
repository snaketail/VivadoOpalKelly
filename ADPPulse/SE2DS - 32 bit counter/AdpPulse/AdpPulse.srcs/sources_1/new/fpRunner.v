`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:  Harry
// 
// Create Date: 05/13/2022 08:58:18 AM
// Design Name: 
// Module Name: fpRunner
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


module fpRunner(
	input  wire [7:0]  hi_in,
	output wire [1:0]  hi_out,
	inout  wire [15:0] hi_inout,
	inout  wire        hi_aa,
	
	output wire        hi_muxsel,

    //Ready onboard wiring (clk and LED)	
	input  wire        sys_clk_p,
	input  wire        sys_clk_n,
	output wire [7:0]  led,
	
	//Customized wires
    input wire         apd_p,
    input wire         apd_n,

	output wire        q_reset_wire,
	
	output wire        quench_p,
	output wire        quench_n,

    //Debugging Leds wires
    output wire        apd_led,
    output wire        quench_led,
    output wire        q_reset_led
	);
	
	// Opal Kelly Module Interface Connections
    wire        ti_clk;
    wire [30:0] ok1;
    wire [16:0] ok2;
	// Endpoint connections:
    wire [31:0]  ep00wire;
    wire [31:0]  ep01wire;
    wire [31:0]  ep02wire;
    wire [15:0]  ep03wire;
    wire [31:0]  ep20wire;
    wire [15:0]  ep21wire;
    wire [15:0]  ep40wire;
	
    assign hi_muxsel  = 1'b0;
	
    //clock lvds to sys_clk
    wire sys_clk;
    IBUFGDS osc_clk(.O(sys_clk), .I(sys_clk_p), .IB(sys_clk_n));
	
	wire enable, quench,Pwr_on,apd, q_reset;
	//replace with output ds buff
//	assign quench_n = 1'b0;
//    assign quench_p = quench;
    
    assign  apd_led = Pwr_on;
    assign  quench_led = Pwr_on;
    assign  q_reset_led = Pwr_on;
    
    //Convert differential Apd pulse to Single ended signal
	IBUFDS IBUFDS_inst(
        .O(apd),
        .I(apd_p),
        .IB(apd_n)
        );    
    
    //output differential signal on quench
//    OBUFDS OBUFDS_inst(
//        .O(quench_p),
//        .OB(quench_n),
//        .I(quench)
//    );

    assign quench_p = (quench == 1'b1) ? (1'b1) : (1'b0);
    assign quench_n = (quench == 1'b1) ? (1'b0) : (1'b1);
    
    assign q_reset_wire = q_reset;
	
	//Onboard LED indicator
	function [7:0] xem7010_led;
        input on, run_stop, a, q, r;
        begin
            xem7010_led[0] = (on==1'b1) ? (1'b0) : (1'bz);
            xem7010_led[1] = (run_stop==1'b1) ? (1'b0) : (1'bz);
            xem7010_led[2] = 1'bz;
            xem7010_led[3] = (a==1'b1) ? (1'b0) : (1'bz);
            xem7010_led[4] = 1'bz;
            xem7010_led[5] = (q==1'b1) ? (1'b0) : (1'bz);
            xem7010_led[6] = 1'bz;
            xem7010_led[7] = (r==1'b1) ? (1'b0) : (1'bz);
        end 
    endfunction
	assign led = xem7010_led(Pwr_on, enable, apd, quench, q_reset);
	
// Instantiate the okHost and connect endpoints.
    wire [17*5-1:0]  ok2x;
    okHost okHI(
        .hi_in(hi_in), .hi_out(hi_out), .hi_inout(hi_inout), .hi_aa(hi_aa), .ti_clk(ti_clk),
        .ok1(ok1), .ok2(ok2));
    
    okWireOR # (.N(5)) wireOR (ok2, ok2x);
    
    okWireIn     wi00(.ok1(ok1),                           .ep_addr(8'h00), .ep_dataout(ep00wire));
    okWireIn     wi01(.ok1(ok1),                           .ep_addr(8'h01), .ep_dataout(ep01wire));
    okWireIn     wi02(.ok1(ok1),                           .ep_addr(8'h02), .ep_dataout(ep02wire));
    okWireIn     wi03(.ok1(ok1),                           .ep_addr(8'h03), .ep_dataout(ep03wire));

    okWireOut    wo20(.ok1(ok1), .ok2(ok2x[ 0*17 +: 17 ]), .ep_addr(8'h20), .ep_datain(ep20wire));
    okWireOut    wo21(.ok1(ok1), .ok2(ok2x[ 1*17 +: 17 ]), .ep_addr(8'h21), .ep_datain(ep21wire));
    okTriggerIn  ti40(.ok1(ok1),                           .ep_addr(8'h40), .ep_clk(sys_clk), .ep_trigger(ep40wire));


    ledIndicator ledIndicator_i(
        .clk(sys_clk),
        .ledline(Pwr_on)
        );
    
    //Display
    wire [31:0] counterbuf;
    
    assign ep20wire = counterbuf;
    assign ep21wire[15:0] = counterbuf[31:16];
    
    //button
    assign enable  = ep03wire[0];
    
    wire clear;
    assign clear = ep40wire[0];
    
    //simulate the apd pulse
    wire apd_sim;
    assign apd_sim = ep40wire[1];
    
    wire enableus;
      
    reg [31:0] quench_tgt;
    reg [31:0] wait_tgt;
    reg [31:0] reset_tgt;
    
    reg[31:0] clk_adapter = 1000;
    
    
    always @(ep40wire[2] | ep40wire[3])
    if (ep40wire [2])
        clk_adapter = 1;
    else if (ep40wire [3])
        clk_adapter = 1000;  
     
    
    always @ (ep00wire)
        quench_tgt <= ep00wire * clk_adapter;
    always @ (ep01wire)
        wait_tgt <= ep01wire * clk_adapter;
    always @ (ep02wire)
        reset_tgt <= ep02wire * clk_adapter;
        

    ApdLogicHW ApdLogicHW_i(
        //Main Clock
        .clk(sys_clk),
        //Input pulse source
        .Adp_pulse(apd),

        //Add one more triggering source, with software button
        .AdpSim(apd_sim),

        
        //Input Delay(clk cycle) in 16bit 
        .Quench_T(quench_tgt),
        .Wait_T(wait_tgt),
        .Reset_T(reset_tgt),
        
        .enable(enable),
        .clear(clear),
        
        //Output Pulse
        .Quench(quench),
        .Reset(q_reset),
        
        //Output pulse Adp counts
        .NoP(counterbuf)
        );

        
    
//    counterDisplay counterDisplay_i(
//        .clk(sys_clk),
//        .enable(enable),
//        .clear(clear),
//        .aa(apd),
//        .NoP(counterbuf)
//        );
	  
endmodule
