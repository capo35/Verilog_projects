module SPI_WRAPPER (
    input MOSI,clk,reset_n,ss_n,
    output MISO
);
    wire [9:0] rx_data ;
    wire [7:0] tx_data ;
    wire rx_valid,tx_valid;
        //? spi slave stage
Spi_slave slave0 (
.MOSI(MOSI),
.clk(clk),
.reset_n(reset_n),
.ss_n(ss_n),
.MISO(MISO),
.tx_data(tx_data),
.tx_valid(tx_valid),
.rx_data(rx_data),
.rx_valid(rx_valid)
);

        // ? RAM stage 
Ram #(.Mem_DEBTH(256),.ADDR(8)) Ram0 (
.clk(clk),
.reset_n(reset_n),
.din(rx_data),
.rx_valid(rx_valid),
.tx_valid(tx_valid),
.dout(tx_data)
);

endmodule