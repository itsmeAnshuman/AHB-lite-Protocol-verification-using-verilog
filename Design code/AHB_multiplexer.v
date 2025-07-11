`timescale 1ns / 1ps

module Multiplexer(
    input  [31:0] Hrdata_1, Hrdata_2, Hrdata_3, Hrdata_4,
    input         Hready_out_1, Hready_out_2, Hready_out_3, Hready_out_4,
    input         Hresp_1, Hresp_2, Hresp_3, Hresp_4,
    input  [1:0]  sel,
    output reg [31:0] Hrdata,
    output reg        Hready_out,
    output reg        Hresp
);

always @(*) begin 
    case (sel)
        2'b00: begin
            Hrdata     = Hrdata_1;
            Hready_out = Hready_out_1;
            Hresp      = Hresp_1;
        end

        2'b01: begin
            Hrdata     = Hrdata_2;
            Hready_out = Hready_out_2;
            Hresp      = Hresp_2;
        end

        2'b10: begin 
            Hrdata     = Hrdata_3;
            Hready_out = Hready_out_3;
            Hresp      = Hresp_3;
        end

        2'b11: begin
            Hrdata     = Hrdata_4;
            Hready_out = Hready_out_4;
            Hresp      = Hresp_4;
        end
    endcase
end

endmodule
