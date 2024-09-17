module Timer_Nbits #(
    parameter Bits = 4
) (
    input clk, reset, enable,             // Added missing comma after 'enable'
    input [Bits - 1:0] FINAL_VALUE,
    output done
);
    reg [Bits - 1:0] Q_next, Q_reg;

    // Sequential block
    always @(posedge clk or negedge reset) begin
        if (!reset)                       // Active low reset
            Q_reg <= 1'b0;
        else if (enable)
            Q_reg <= Q_next;
    end

    // Done condition when Q_reg reaches FINAL_VALUE
    assign done = (Q_reg == FINAL_VALUE);

    // Combinational logic to increment or reset counter
    always @(*) begin
        Q_next = done ? 0 : Q_reg + 1;    // Reset counter when done, else increment
    end
endmodule
