module tb_uart_overall;

    // Parameters
    parameter FINAL_VALUE = 650;
    parameter DBIT = 8;
    parameter SB_TICK = 16;

    // Testbench Signals
    reg clk;
    reg reset_n;
    
    // RX Interface
    reg rx;
    wire [DBIT-1:0] r_data;
    reg rd_uart;
    wire rx_empty;

    // TX Interface
    reg [DBIT-1:0] W_data;
    reg wr_uart;
    wire tx_full;
    
    // TX Output
    wire tx;

    // Clock generation (50MHz)
    always #10 clk = ~clk;  // 20ns period (50 MHz)

    // Instantiate the UART overall module
    uart_overall #(
        .FINAL_VALUE(FINAL_VALUE),
        .DBIT(DBIT),
        .SB_TICK(SB_TICK)
    ) dut (
        .clk(clk),
        .reset_n(reset_n),
        .rx(rx),
        .r_data(r_data),
        .rd_uart(rd_uart),
        .rx_empty(rx_empty),
        .W_data(W_data),
        .wr_uart(wr_uart),
        .tx_full(tx_full),
        .tx(tx)
    );

    // Initial block to initialize and drive the inputs
    initial begin
        // Initialize signals
        clk = 0;
        reset_n = 0;
        rx = 1;  // Idle state for UART is high
        rd_uart = 0;
        W_data = 8'b0;
        wr_uart = 0;

        // Reset the system
        #20;
        reset_n = 1;  // Release reset

        // Simulate RX data reception
        #200;  // Wait for reset
        simulate_rx(8'hA5);  // Send byte 0xA5
        
        // Wait for data to be processed
        #100;
        rd_uart = 1;  // Simulate reading from FIFO
        #20;
        rd_uart = 0;

        // Simulate TX data transmission
        #100;
        W_data = 8'h3C;  // Write byte 0x3C to transmit
        wr_uart = 1;
        #20;
        wr_uart = 0;

        // Observe the behavior and wait for transmission
        #10000;

        // End the simulation
        $stop;
    end

    // Task to simulate RX UART reception (assuming 1 start bit, 8 data bits, 1 stop bit)
    task simulate_rx(input [DBIT-1:0] byte);
        integer i;
        begin
            rx = 0;  // Start bit (0)
            #160;    // Wait for one data period

            // Send data bits (LSB first)
            for (i = 0; i < DBIT; i = i + 1) begin
                rx = byte[i];
                #160;  // Wait for one data period
            end

            rx = 1;  // Stop bit (1)
            #160;    // Wait for stop period
        end
    endtask

endmodule
