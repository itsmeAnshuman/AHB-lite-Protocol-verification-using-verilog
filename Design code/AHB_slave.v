module AHB_slave (
    input         Hclk,
    input         Hresetn,
    input         Hsel,
    input  [31:0] Haddr,
    input         Hwrite,
    input  [2:0]  Hsize,
    input  [2:0]  Hburst,
    input  [3:0]  Hprot,
    input         Hmastlock,  
    input  [1:0]  Htrans,
    input  [31:0] Hwdata,
    input         Hready,

    output reg        Hready_out,
    output reg        Hresp,
    output reg [31:0] Hrdata
);

// Internal memory and address registers
reg [31:0] Mem[31:0];
reg [4:0]  Waddr;
reg [4:0]  Raddr;

// FSM states
reg [1:0] present_state;
reg [1:0] next_state;

parameter idle = 2'b00;
parameter s1   = 2'b01;
parameter s2   = 2'b10; // Write operation
parameter s3   = 2'b11; // Read operation

// Flags for burst types
reg single_flag;
reg incr_flag;
reg incr4_flag;
reg incr8_flag;
reg incr16_flag;
reg wrap4_flag;
reg wrap8_flag;
reg wrap16_flag;

// Present state logic
always @(posedge Hclk) begin
    if (!Hresetn)
        present_state <= idle;
    else
        present_state <= next_state;
end

// FSM logic
always @(posedge Hclk) begin
    case (present_state)

        idle: begin
            // Reset all flags in idle state
            single_flag  = 1'b0;
            incr_flag    = 1'b0;
            incr4_flag   = 1'b0;
            incr8_flag   = 1'b0;
            incr16_flag  = 1'b0;
            wrap4_flag   = 1'b0;
            wrap8_flag   = 1'b0;
            wrap16_flag  = 1'b0;

            if (Hsel == 1'b1)
                next_state = s1;
            else
                next_state = idle;
        end

        s1: begin
            case (Hburst)

                3'b000: begin // Single burst
                    single_flag  = 1'b1;
                    incr_flag    = 1'b0;
                    incr4_flag   = 1'b0;
                    incr8_flag   = 1'b0;
                    incr16_flag  = 1'b0;
                    wrap4_flag   = 1'b0;
                    wrap8_flag   = 1'b0;
                    wrap16_flag  = 1'b0;
                end

                3'b001: begin // INCR
                    single_flag  = 1'b0;
                    incr_flag    = 1'b1;
                    incr4_flag   = 1'b0;
                    incr8_flag   = 1'b0;
                    incr16_flag  = 1'b0;
                    wrap4_flag   = 1'b0;
                    wrap8_flag   = 1'b0;
                    wrap16_flag  = 1'b0;
                end

                3'b010: begin // WRAP4
                    single_flag  = 1'b0;
                    incr_flag    = 1'b0;
                    incr4_flag   = 1'b0;
                    incr8_flag   = 1'b0;
                    incr16_flag  = 1'b0;
                    wrap4_flag   = 1'b1;
                    wrap8_flag   = 1'b0;
                    wrap16_flag  = 1'b0;
                end

                3'b011: begin // INCR4
                    single_flag  = 1'b0;
                    incr_flag    = 1'b0;
                    incr4_flag   = 1'b1;
                    incr8_flag   = 1'b0;
                    incr16_flag  = 1'b0;
                    wrap4_flag   = 1'b0;
                    wrap8_flag   = 1'b0;
                    wrap16_flag  = 1'b0;
                end

                3'b100: begin // WRAP8
                    single_flag  = 1'b0;
                    incr_flag    = 1'b0;
                    incr4_flag   = 1'b0;
                    incr8_flag   = 1'b0;
                    incr16_flag  = 1'b0;
                    wrap4_flag   = 1'b0;
                    wrap8_flag   = 1'b1;
                    wrap16_flag  = 1'b0;
                end

                3'b101: begin // INCR8
                    single_flag  = 1'b0;
                    incr_flag    = 1'b0;
                    incr4_flag   = 1'b0;
                    incr8_flag   = 1'b1;
                    incr16_flag  = 1'b0;
                    wrap4_flag   = 1'b0;
                    wrap8_flag   = 1'b0;
                    wrap16_flag  = 1'b0;
                end

                3'b110: begin // WRAP16
                    single_flag  = 1'b0;
                    incr_flag    = 1'b0;
                    incr4_flag   = 1'b0;
                    incr8_flag   = 1'b0;
                    incr16_flag  = 1'b0;
                    wrap4_flag   = 1'b0;
                    wrap8_flag   = 1'b0;
                    wrap16_flag  = 1'b1;
                end

                3'b111: begin // INCR16
                    single_flag  = 1'b0;
                    incr_flag    = 1'b0;
                    incr4_flag   = 1'b0;
                    incr8_flag   = 1'b0;
                    incr16_flag  = 1'b1;
                    wrap4_flag   = 1'b0;
                    wrap8_flag   = 1'b0;
                    wrap16_flag  = 1'b0;
                end

                default: begin
                    single_flag  = 1'b0;
                    incr_flag    = 1'b0;
                    incr4_flag   = 1'b0;
                    incr8_flag   = 1'b0;
                    incr16_flag  = 1'b0;
                    wrap4_flag   = 1'b0;
                    wrap8_flag   = 1'b0;
                    wrap16_flag  = 1'b0;
                end

            endcase // Hburst
  
     
if ((Hwrite == 1'b1) && (Hready == 1'b1)) // Condition for Write Operation
begin
    next_state = s2;
end
else if ((Hwrite == 1'b0) && (Hready == 1'b1)) // Condition for Read Operation
begin 
    next_state = s3;
end
else 
begin 
    next_state = s1;
end
end

s2: begin 
    case (Hburst)
        3'b000: if (Hsel == 1'b1) begin
                    next_state = s1;
                end
                else begin  
                    next_state = idle;
                end

        // Increment burst of undefined length
        3'b001: begin
            next_state = s2;
        end

        // 4-bit Wrapping burst    
        3'b010: begin
            next_state = s2;
        end

        // 4-beat increment burst     
        3'b011: begin
            next_state = s2;
        end

        // 8-beat Wrapping burst
        3'b100: begin
            next_state = s2;
        end

        // 8-beat increment burst
        3'b101: begin
            next_state = s2;
        end

        // 16-beat wrapping burst
        3'b110: begin
            next_state = s2;
        end

        // 16-beat incrementing burst
        3'b111: begin
            next_state = s2;
        end

        default: begin
            if (Hsel == 1'b1) begin
                next_state = s1;
            end
            else begin
                next_state = idle;
            end
        end
    endcase // for Hburst
end

s3: begin
    case (Hburst)
        // Single transfer burst 
        3'b000: begin
            if (Hsel == 1'b1) begin 
                next_state = s1;
            end
            else begin 
                next_state = idle;
            end
        end

        // Increment burst of undefined length
        3'b001: begin
            next_state = s3;
        end

        // 4-bit Wrapping burst    
        3'b010: begin
            next_state = s3;
        end

        // 4-beat increment burst     
        3'b011: begin
            next_state = s3;
        end

        // 8-beat Wrapping burst
        3'b100: begin
            next_state = s3;
        end

        // 8-beat increment burst
        3'b101: begin
            next_state = s3;
        end

        // 16-beat wrapping burst
        3'b110: begin
            next_state = s3;
        end

        // 16-beat incrementing burst
        3'b111: begin
            next_state = s3;
        end

        default: begin
            if (Hsel == 1'b1) begin
                next_state = s1;
            end
            else begin
                next_state = idle;
            end
        end
    endcase // for Hburst
end

default: begin  
    next_state = idle;
end
endcase // for present_state
end
  
always @(posedge Hclk) begin  
    if (!Hresetn) begin
        Hready_out <= 1'b0;
        Hresp      <= 1'b0;
        Hrdata     <= 32'b0;
        Waddr      <= Waddr;
        Raddr      <= Raddr;
    end    
    else begin
        case (next_state)

            idle: begin 
                Hready_out <= 1'b0;
                Hresp      <= 1'b0;
                Hrdata     <= Hrdata;
                Waddr      <= Waddr;
                Raddr      <= Raddr;
            end  

            s1: begin
                Hready_out <= 1'b0;
                Hresp      <= 1'b0;
                Hrdata     <= Hrdata;
                Waddr      <= Haddr;
                Raddr      <= Haddr;
            end

                                                 //Write transfer operation
s2: begin
    case ({single_flag, incr_flag, wrap4_flag, incr4_flag, wrap8_flag, incr8_flag, wrap16_flag, incr16_flag})

        // Single-Transfer
        8'b1000_0000: begin
            Hready_out   <= 1'b1;
            Hresp        <= 1'b0;
            Mem[Waddr]   <= Hwdata;
        end

        // Increment Transfer (INCR)
        8'b0100_0000: begin 
            Hready_out   <= 1'b0;
            Hresp        <= 1'b0;
            Mem[Waddr]   <= Hwdata;
            Waddr        <= Waddr + 1'b1;
        end                                 

        // Wrap4
        8'b0010_0000: begin
            Hready_out   <= 1'b1;
            Hresp        <= 1'b0;

            if (Waddr < (Haddr + 2'd3)) begin
                Waddr <= Waddr + 1;
            end
            else begin
                Mem[Waddr] <= Hwdata;
                Waddr      <= Haddr;
            end
        end

        // INCR4
        8'b0001_0000: begin
            Hready_out   <= 1'b1;
            Hresp        <= 1'b0;
            Mem[Waddr]   <= Hwdata;
            Waddr        <= Waddr + 1;
        end

        // WRAP8
        8'b0000_1000: begin
            Hready_out   <= 1'b1;
            Hresp        <= 1'b0;

            if (Waddr < (Haddr + 3'd7)) begin 
                Mem[Waddr] <= Hwdata;
                Waddr      <= Haddr;
            end                  
        end

        // INCR8
        8'b0000_0100: begin 
            Hready_out   <= 1'b0;
            Hresp        <= 1'b0;
            Mem[Waddr]   <= Hwdata;
            Waddr        <= Waddr + 1'b1;
        end

        // WRAP16
        8'b0000_0010: begin
            Hready_out   <= 1'b1; // Fixed typo: was 8'b1
            Hresp        <= 1'b0;

            if (Waddr < (Haddr + 4'd15)) begin
                Mem[Waddr] <= Hwdata;
                Waddr      <= Waddr + 1'b1;
            end
            else begin
                Mem[Waddr] <= Hwdata;
                Waddr      <= Haddr;
            end
        end

        default: begin
            Hready_out   <= 1'b1;
            Hresp        <= 1'b0; 
        end

    endcase // flag case
end
         
 // Read transfer operation        
s3: begin
    case ({single_flag, incr_flag, wrap4_flag, incr4_flag, wrap8_flag, incr8_flag, wrap16_flag, incr16_flag})

        // Single transfer 
        8'b1000_0000: begin 
            Hready_out <= 1'b1;
            Hresp      <= 1'b0;
            Hrdata     <= Mem[Raddr];
        end

        // Increment transfer 
        8'b0100_0000: begin
            Hready_out <= 1'b1;
            Hresp      <= 1'b0;
            Hrdata     <= Mem[Raddr];
            Raddr      <= Raddr + 1;
        end

        // Wrap4 
        8'b0010_0000: begin
            Hready_out <= 1'b1;
            Hresp      <= 1'b0;

            if (Raddr < (Haddr + 2'd3)) begin                                                                                
                Hrdata <= Mem[Raddr];
                Raddr  <= Raddr + 1;
            end
            else begin
                Hrdata <= Mem[Raddr];
                Raddr  <= Haddr;
            end
        end  

        // INCR4
        8'b0001_0000: begin
            Hready_out <= 1'b1;
            Hresp      <= 1'b0;
            Hrdata     <= Mem[Raddr];
            Raddr      <= Raddr + 1;
        end

        // WRAP8
        8'b0000_1000: begin
            Hready_out <= 1'b1;
            Hresp      <= 1'b0;

            if (Raddr < (Haddr + 3'd7)) begin
                Hrdata <= Mem[Raddr];
                Raddr  <= Raddr + 1;
            end
            else begin
                Hrdata <= Mem[Raddr];
                Raddr  <= Haddr; 
            end
        end       

        // INCR8
        8'b0000_0100: begin
            Hready_out <= 1'b1;
            Hresp      <= 1'b0;
            Hrdata     <= Mem[Raddr];
            Raddr      <= Raddr + 1;
        end

        // WRAP16 
        8'b0000_0010: begin
            Hready_out <= 1'b1;
            Hresp      <= 1'b0;

            if (Raddr < (Haddr + 4'd15)) begin
                Hrdata <= Mem[Raddr];
                Raddr  <= Raddr + 1;
            end
            else begin
                Hrdata <= Mem[Raddr];
                Raddr  <= Haddr;                   
            end
        end     

        // INCR16
        8'b0000_0001: begin 
            Hready_out <= 1'b1;
            Hresp      <= 1'b0;
            Hrdata     <= Mem[Raddr];
            Raddr      <= Raddr + 1;
        end

        default: begin
            Hready_out <= 1'b1;
            Hresp      <= 1'b0;
        end

    endcase // flag case
end

default: begin
    Hready_out <= 1'b0;
    Hresp      <= 1'b0;
    Waddr      <= Waddr;
    Raddr      <= Waddr;
end

endcase // next_state case
end
end

endmodule
