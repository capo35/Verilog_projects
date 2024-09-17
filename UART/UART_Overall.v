module uart_overall #(
    parameter FINAL_VALUE=650,DBIT=8,SB_TICK=16
) (
   input clk,reset_n,
   // Rx input  
   input rx,
   // reciver rx fifo 
   output  [DBIT - 1 : 0]  r_data,
   input rd_uart,
   output rx_empty,
   // transmetter tx fifo 
   input [DBIT - 1 : 0]  W_data,
   input wr_uart,
   output tx_full,
   // tx output
   output tx
);
  wire done;
            // ! timer stage 
Timer_Nbits #(.Bits($clog2(FINAL_VALUE))) timerGen0 (
.clk(clk),
.reset(reset_n),
.enable(1'b1),
.FINAL_VALUE(FINAL_VALUE),
.done(done)
);
            //! reciver stage
wire [DBIT - 1 : 0] rx_dout;
wire rx_done_tick;

receiver #(.DBIT(DBIT),.SB_TICK(SB_TICK)) uart_Rx(
.rx(rx),
.clk(clk),
.reset_n(reset_n),
.s_tick(s_tick),
.rx_dout(rx_dout),
.rx_done_tick(rx_done_tick)
);
            //! FIFO Rx STAGE0

Fifo_genrator #(.ADDR(DBIT), .DEBTH(8)) fifo_G0(
.wr_en(rx_done_tick),
.rd_en(rd_uart),
.clk(clk),
.reset_n(reset_n),
.Data_in(rx_dout),
.Data_out(r_data),
.empty(rx_empty),
.full()
);

            //! FIFO Tx STAGE1
wire [DBIT-1:0] tx_din;
wire tx_fifo_start,tx_done_tick;
Fifo_genrator #(.ADDR(DBIT), .DEBTH(8)) fifo_G1(
.wr_en(wr_uart),
.rd_en(tx_done_tick),
.clk(clk),
.reset_n(reset_n),
.Data_in(W_data),
.Data_out(tx_din),
.empty(tx_fifo_start),
.full(tx_full)
);


        //! transmitter Tx STAGE
Transmetr #(.DBIT(DBIT),.SB_TICK(SB_TICK)) uart_tx (
.tx_din(tx_din),
.s_tick(done),
.clk(clk),
.reset_n(reset_n),
.tx_start(~tx_fifo_start),
.tx(tx),
.tx_done_tick(tx_done_tick)
); 

endmodule