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
`timescale 1ns / 1ns

module top;

    parameter CLK_PD = 100;               // system clock period
    logic [2:0] select;                   //
    logic enable_b;                       //
    wire [31:0] y_l;                        // DUT output signals
    bit clock = 0;                        // testbench clock
    logic [31:0] results [0:127];          // array to hold golden test values
    int e_cnt = 0;                        // counter for DATA MISMATCHES
    int v_cnt = 0;                        // verification counter

    ///////////////////////////////////////////////
    // Device Under Test: 8-to-1 multiplexer
    ///////////////////////////////////////////////
    GREY DUT (
        .S0(select[0]),
        .S1(select[1]),
        .S2(select[2]),
        .ENb(enable_b),
        .Y(y_l));

    // clock generator
    always
        #(CLK_PD/2) clock = ~clock;

    // simulation control
    initial begin
        //////////////////////////////////////////////////////////////////////
        // load results array
        //////////////////////////////////////////////////////////////////////
        $readmemb("grey.dat", top.results);
        //////////////////////////////////////////////////////////////////////
        // stimulus
        //////////////////////////////////////////////////////////////////////
        enable_b = 1'b1;
        select = 3'b000;
        @(negedge clock) vdata;
        enable_b = 1'b0;
        select = 3'b001;
        @(negedge clock) vdata;
        select = 3'b010;
        @(negedge clock) vdata;
        select = 3'b011;
        @(negedge clock) vdata;
        select = 3'b100;
        @(negedge clock) vdata;
        select = 3'b101;
        @(negedge clock) vdata;
        select = 3'b110;
        @(negedge clock) vdata;
        select = 3'b111;
        //////////////////////////////////////////////////////////////////////
        // finish simulation
        //////////////////////////////////////////////////////////////////////
        $display("\n# Simulation finished: DATA MISMATCHES = %0d\n", e_cnt);
        $finish;
    end

    // verify results and maintain error count
    task vdata;
        if ({y_l} !== results[v_cnt]) begin
            ++e_cnt;
            $display("# ERROR: %b != %b", {y_l}, results[v_cnt]);
        end
        ++v_cnt;
    endtask

endmodule

module GREY (
    output [31:0]Y,
    input  S0, S1, S2, ENb);

    // Make C function visible to verilog code
    import "DPI-C" context function int grey (
        input int select);

    reg [31:0] im0;
    reg [2:0] SELECT;
    always @(S0, S1, S2, ENb) begin
        SELECT = {S2, S1, S0};
        if (ENb == 1'b0)
            im0 = grey(SELECT);
        else
            im0 = 1'b0;
    end

    // output logic
    assign Y = im0;

endmodule
