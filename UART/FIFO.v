module Fifo_genrator #(
    parameter ADDR = 8,    // Width of the data
    parameter DEBTH = 8    // Depth of the FIFO (number of entries)
) (
    input wr_en,           // Write enable
    input rd_en,           // Read enable
    input clk,             // Clock
    input reset_n,         // Active low reset
    input [ADDR - 1 : 0] Data_in, // Data input
    output reg [ADDR - 1 : 0] Data_out, // Data output (FWFT behavior)
    output full,           // Full flag
    output empty           // Empty flag
);

    reg [ADDR - 1: 0] memory [0 : DEBTH - 1];   // Memory array for the FIFO
    reg [$clog2(DEBTH) - 1 : 0] count, wr_ptr, rd_ptr; // Counters and pointers

    // Full and empty flags
    assign full = (count == DEBTH);
    assign empty = (count == 0);

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            count <= 0;
            Data_out <= 0;
        end
        else begin
            // Write operation
            if (wr_en && !full) begin
                memory[wr_ptr] <= Data_in;
                wr_ptr <= wr_ptr + 1;
                if (count == 0) // If FIFO was empty, immediately output first value
                    Data_out <= Data_in;
                count <= count + 1;
            end
            
            // Read operation
            if (rd_en && !empty) begin
                Data_out <= memory[rd_ptr];
                rd_ptr <= rd_ptr + 1;
                count <= count - 1;
            end
        end
    end

endmodule
