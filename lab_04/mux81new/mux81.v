//
// Copyright 1991-2015 Mentor Graphics Corporation
//
// All Rights Reserved.
//
// THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY INFORMATION WHICH IS THE
// PROPERTY OF MENTOR GRAPHICS CORPORATION OR ITS LICENSORS AND IS SUBJECT TO
// LICENSE TERMS.
//
// Simple SystemVerilog DPI Example - Verilog test module for 8-to-1 MUX
//

module top (select, enable_b, Y);

   input [2:0] select;                
   input enable_b;        
	output [31:0]Y;
	wire [31:0] y_l;                      
	

    MUX81 DUT (
        .S0(select[0]),
        .S1(select[1]),
        .S2(select[2]),
        .ENb(enable_b),
        .Y(y_l));
		  
	assign Y = y_l;
endmodule

module MUX81 (
    output [31:0]Y,
    input  S0, S1, S2, ENb);

    // Make C function visible to verilog code
    import "DPI-C" context function int mux81 (
        input int select);

    reg [31:0] im0;
    reg [2:0] SELECT;
    always @(S0, S1, S2, ENb) begin
        SELECT = {S2, S1, S0};
        if (ENb == 1'b0)
            im0 = mux81(SELECT);
        else
            im0 = 1'b0;
    end

    // output logic
    assign Y = im0;

endmodule
