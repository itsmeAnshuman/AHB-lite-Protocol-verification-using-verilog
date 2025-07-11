`timescale 1ns / 1ps

module AHB_tb();

  reg Hclk;
  reg Hresetn;
  reg enable;
  reg [31:0] addr;
  reg [31:0] data_in_1, data_in_2;
  reg Wr;
  reg [1:0] slave_sel;
  wire [31:0] d_out;

  // Clock generation
  initial begin
    Hclk = 0;
    forever #10 Hclk = ~Hclk;
  end

  // Initialization
  initial begin
    Hresetn = 1;
    enable = 1'b0;
    data_in_1 = 32'd0;
    data_in_2 = 32'd0;
    Wr = 1'b0;
    slave_sel = 2'b00;  
  end

  // Reset task
  task reset_dut();
    begin 
      @(negedge Hclk)
        Hresetn = 0;
      @(negedge Hclk)
        Hresetn = 1;
    end
  endtask

  // Write task
  task write_dut(input [1:0] sel, input [31:0] address_input, input [31:0] a_1, input [31:0] b_1);
    begin
      @(negedge Hclk)
        slave_sel = sel;
        enable = 1'b1;
        addr = address_input;

      @(negedge Hclk)
        data_in_1 = a_1;
        data_in_2 = b_1;
        Wr = 1'b1;

      repeat(2) @(negedge Hclk);  

      enable = 1'b0;
      Wr = 1'b0;
    end
  endtask

  // Read task
  task read_dut(input [1:0] sel, input [31:0] address_input);
    begin 
      @(negedge Hclk)
        slave_sel = sel;
        enable = 1'b1;
        addr = address_input;
        Wr = 1'b0;

      repeat(3) @(negedge Hclk);  

      enable = 1'b0;
    end
  endtask

 
  initial begin 
    reset_dut(); 
    write_dut(2'b00, 32'd1, 32'd5, 32'd10);    
    read_dut(2'b00, 32'd1);

    write_dut(2'b01, 32'd2, 32'd11, 32'd13);
    read_dut(2'b01, 32'd2);

    write_dut(2'b10, 32'd3, 32'd17, 32'd13);
    read_dut(2'b10, 32'd3);

    write_dut(2'b11, 32'd4, 32'd23, 32'd13);
    read_dut(2'b11, 32'd4);

    #120;
    $display("Simulation completed.");
    $finish;
  end  

 
  AHB_module dut(
    .Hclk(Hclk),
    .Hresetn(Hresetn),
    .data_in_1(data_in_1),
    .data_in_2(data_in_2),
    .addr(addr),
    .Wr(Wr),
    .enable(enable),
    .slave_sel(slave_sel),
    .d_out(d_out)
  );

  
  always @(posedge Hclk) begin
    $display("Time: %0t | Hresetn=%b | Wr=%b | enable=%b | slave_sel=%b | addr=%0d | data_in_1=%0d | data_in_2=%0d | d_out=%0d",
             $time, Hresetn, Wr, enable, slave_sel, addr, data_in_1, data_in_2, d_out);
  end

  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, AHB_tb);
  end

endmodule
