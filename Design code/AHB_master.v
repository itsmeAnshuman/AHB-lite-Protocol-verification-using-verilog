module ahb_master(
input Hclk,
input Hresetn,
input enable,
input [31:0] data_in_1,data_in_2,
input [31:0] addr,
input WR,
input Hready_out,
input Hresp,
input [31:0] Hrdata,
input [1:0] slave_sel,

output reg [1:0] sel,
output reg [31:0] Haddr,
output reg Hwrite,Hready,
output reg [3:0] Hsize,
output reg [2:0] Hburst,
output reg [3:0] Hprot,
output reg [1:0] Htrans,
output reg [31:0] Hwdata,
output [31:0] d_out        
);

//  Internal Register to hold output data
reg [31:0] dout_reg;
assign d_out = dout_reg;   //  Connect registered value to output

reg [1:0] present_state,next_state;
parameter idle = 2'b00;
parameter s1 = 2'b01;
parameter s2 = 2'b10;
parameter s3 = 2'b11;

always@(posedge Hclk) begin 
   if(!Hresetn)
      present_state <= idle;
   else 
      present_state <= next_state;
end  

always@(*) begin 
   case(present_state)
      idle: begin
         sel    <= 2'b00;
         Haddr  <= 32'h0000_0000;
         Hwrite <= 1'b0;
         Hready <= 1'b0;
         Hsize  <= 3'b00;
         Hburst <= 3'b000;             
         Hprot  <= 4'b0000;
         Htrans <= 2'b00;
         Hwdata <= 32'h0000_0000;

         if (enable == 1'b1)
            next_state = s1;
         else
            next_state = idle;
      end

      s1: begin 
         sel    <= slave_sel;
         Haddr  <= addr;
         Hwrite <= WR;
         Hready <= 1'b1;
         Hsize  <= 3'b000;
         Hburst <= 3'b000;                         
         Hwdata <= data_in_1 + data_in_2;

         if (WR == 1'b1)
            next_state = s2;
         else 
            next_state = s3;
      end

      s2: begin 
         sel    <= slave_sel;
         Haddr  <= addr;
         Hwrite <= WR;
         Hready <= 1'b1; 
         Hburst <= 3'b000;                         
         Hwdata <= data_in_1 + data_in_2;

         if(enable == 1'b1)
            next_state = s1;
         else 
            next_state = idle;
      end

      s3: begin 
         sel    <= slave_sel;
         Haddr  <= addr;
         Hwrite <= WR;
         Hready <= 1'b1;
         Hburst <= 3'b000;                         
         Hwdata <= Hwdata;

         
         if (Hready_out)
            dout_reg <= Hrdata;

         if (enable == 1'b1)
            next_state = s1;
         else
            next_state = idle;
      end

      default: begin 
         sel    <= slave_sel;
         Haddr  <= Haddr;
         Hwrite <= Hwrite;
         Hready <= 1'b0;
         Hburst <= Hburst;                         
         Hwdata <= Hwdata;
         next_state = idle;
      end
   endcase 
end

endmodule
