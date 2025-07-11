`timescale 1ns / 1ps

module decoder(
    input  [1:0] sel,
    output reg   Hsel_1,
    output reg   Hsel_2,
    output reg   Hsel_3,
    output reg   Hsel_4
);

always @(*) begin
    case (sel)
        2'b00: begin
            Hsel_1 = 1'b1;
            Hsel_2 = 1'b0;
            Hsel_3 = 1'b0;
            Hsel_4 = 1'b0;
        end

        2'b01: begin
            Hsel_1 = 1'b0;
            Hsel_2 = 1'b1;
            Hsel_3 = 1'b0;
            Hsel_4 = 1'b0;
        end

        2'b10: begin
            Hsel_1 = 1'b0;
            Hsel_2 = 1'b0;
            Hsel_3 = 1'b1;
            Hsel_4 = 1'b0;
        end

        2'b11: begin
            Hsel_1 = 1'b0;
            Hsel_2 = 1'b0;
            Hsel_3 = 1'b0;
            Hsel_4 = 1'b1;
        end

        default: begin
            Hsel_1 = 1'b0;
            Hsel_2 = 1'b0;
            Hsel_3 = 1'b0;
            Hsel_4 = 1'b0;
        end
    endcase
end

endmodule
