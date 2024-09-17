module Ram #(
    parameter Mem_DEBTH=256, ADDR=8
) (
    input [9 :0 ] din,
    input rx_valid, clk, reset_n,
    output reg [ADDR-1 :0] dout,
    output reg tx_valid
);
    
   reg [ADDR-1:0] mem [0:Mem_DEBTH-1];
   reg [7:0] Q_next, Q_reg;

   always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            Q_reg <= 0;
        else if (rx_valid)
            Q_reg <= Q_next;
        else
            Q_reg <= Q_reg;
    end

    always @(*) begin
        tx_valid = 1'b0;
        dout = 0;
        Q_next = Q_reg;  // Default value to avoid latching
        case (din[9:8])
            2'b00: Q_next = din[7:0];
            2'b01: begin
                if (rx_valid)
                    mem[Q_reg] = din[7:0];
            end
            2'b10: Q_next = din[7:0];
            2'b11: begin
                if (rx_valid) begin
                    dout = mem[Q_reg];
                    tx_valid = 1'b1;
                end    
            end
            default: tx_valid = 1'b0;
        endcase
    end
endmodule
