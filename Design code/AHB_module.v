`include "AHB_master.v"
`include "AHB_slave.v"
`include "AHB_decoder.v"
`include "AHB_multiplexer.v"

`timescale 1ns / 1ps
module AHB_module(
    input         Hclk,
    input         Hresetn,
    input         enable,
    input  [31:0] data_in_1, data_in_2,
    input  [31:0] addr,
    input         Wr,
    input  [1:0]  slave_sel,
    output [31:0] d_out
);

    wire [1:0] sel;
    wire [31:0] Haddr;
    wire        Hwrite;
    wire [3:0]  Hprot;
    wire [2:0]  Hsize;
    wire [2:0]  Hburst;
    wire [1:0]  Htrans;
    wire        Hmastlock;
    wire        Hready;
    wire [31:0] Hwdata;

    // Slave 1 wires
    wire [31:0] Hrdata_1;
    wire        Hready_out_1;
    wire        Hresp_1;

    // Slave 2 wires
    wire [31:0] Hrdata_2;
    wire        Hready_out_2;
    wire        Hresp_2;

    // Slave 3 wires
    wire [31:0] Hrdata_3;
    wire        Hready_out_3;
    wire        Hresp_3;

    // Slave 4 wires
    wire [31:0] Hrdata_4;
    wire        Hready_out_4;
    wire        Hresp_4;

    // Decoder
    wire Hsel_1, Hsel_2, Hsel_3, Hsel_4;

    // Multiplexer output
    wire [31:0] Hrdata;
    wire        Hready_out;
    wire        Hresp;

    // Connect Master
    ahb_master DUT(
        .Hclk(Hclk),
        .Hresetn(Hresetn),
        .enable(enable),
        .data_in_1(data_in_1),
        .data_in_2(data_in_2),
        .addr(addr),
        .WR(Wr),  
        .slave_sel(slave_sel),
        .Hready_out(Hready_out),
        .Hresp(Hresp),
        .Hrdata(Hrdata),
        .sel(sel),
        .Haddr(Haddr),
        .Hsize(Hsize),
        .Hwrite(Hwrite),
        .Hburst(Hburst),
        .Hprot(Hprot),
        .Htrans(Htrans),
        .Hready(Hready),
        .Hwdata(Hwdata),
        .d_out(d_out)
    );

    // Decoder
    decoder decoder (
        .sel(sel),
        .Hsel_1(Hsel_1),
        .Hsel_2(Hsel_2),
        .Hsel_3(Hsel_3),
        .Hsel_4(Hsel_4)
    );

    // Slave 1
    AHB_slave slave_1 (
        .Hclk(Hclk),
        .Hresetn(Hresetn),
        .Hsel(Hsel_1),
        .Haddr(Haddr),
        .Hwrite(Hwrite),
        .Hsize(Hsize),
        .Hburst(Hburst),
        .Hprot(Hprot),
        .Htrans(Htrans),
        .Hready(Hready),
        .Hwdata(Hwdata),
        .Hmastlock(1'b0),  
        .Hready_out(Hready_out_1),
        .Hresp(Hresp_1),
        .Hrdata(Hrdata_1)
    );

    // Slave 2
    AHB_slave slave_2 (
        .Hclk(Hclk),
        .Hresetn(Hresetn),
        .Hsel(Hsel_2),
        .Haddr(Haddr),
        .Hwrite(Hwrite),
        .Hsize(Hsize),
        .Hburst(Hburst),
        .Hprot(Hprot),
        .Htrans(Htrans),
        .Hready(Hready),
        .Hwdata(Hwdata),
        .Hmastlock(1'b0),  
        .Hready_out(Hready_out_2),
        .Hresp(Hresp_2),
        .Hrdata(Hrdata_2)
    );

    // Slave 3
    AHB_slave slave_3 (
        .Hclk(Hclk),
        .Hresetn(Hresetn),
        .Hsel(Hsel_3),
        .Haddr(Haddr),
        .Hwrite(Hwrite),
        .Hsize(Hsize),
        .Hburst(Hburst),
        .Hprot(Hprot),
        .Htrans(Htrans),
        .Hready(Hready),
        .Hwdata(Hwdata),
        .Hmastlock(1'b0), 
        .Hready_out(Hready_out_3),
        .Hresp(Hresp_3),
        .Hrdata(Hrdata_3)
    );

    // Slave 4
    AHB_slave slave_4 (
        .Hclk(Hclk),
        .Hresetn(Hresetn),
        .Hsel(Hsel_4),
        .Haddr(Haddr),
        .Hwrite(Hwrite),
        .Hsize(Hsize),
        .Hburst(Hburst),
        .Hprot(Hprot),
        .Htrans(Htrans),
        .Hready(Hready),
        .Hwdata(Hwdata),
        .Hmastlock(1'b0),  
        .Hready_out(Hready_out_4),
        .Hresp(Hresp_4),
        .Hrdata(Hrdata_4)
    );

    // Multiplexer
    Multiplexer mux (
        .Hrdata_1(Hrdata_1),
        .Hrdata_2(Hrdata_2),
        .Hrdata_3(Hrdata_3),
        .Hrdata_4(Hrdata_4),
        .Hready_out_1(Hready_out_1),
        .Hready_out_2(Hready_out_2),
        .Hready_out_3(Hready_out_3),
        .Hready_out_4(Hready_out_4),
        .Hresp_1(Hresp_1),
        .Hresp_2(Hresp_2),
        .Hresp_3(Hresp_3),
        .Hresp_4(Hresp_4),
        .sel(sel),
        .Hrdata(Hrdata),
        .Hready_out(Hready_out),
        .Hresp(Hresp)
    );

endmodule
