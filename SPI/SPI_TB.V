module tb_SPI_WRAPPER;

    // Declare inputs and outputs for the testbench
    reg clk, reset_n, ss_n, MOSI;
    wire MISO;

    // Clock period
    localparam CLK_PERIOD = 10;

    // Instantiate the SPI_WRAPPER module
    SPI_WRAPPER dut (
        .MOSI(MOSI),
        .clk(clk),
        .reset_n(reset_n),
        .ss_n(ss_n),
        .MISO(MISO)
    );

    // Clock generation
    always begin
        clk = 1'b0;
        #(CLK_PERIOD/2);
        clk = 1'b1;
        #(CLK_PERIOD/2);
    end

    // Test reset logic and different SPI transactions
    initial begin
        // Initialize inputs
        reset_n = 1'b0;  // Assert reset
        ss_n = 1'b1;     // Disable SPI (inactive)
        MOSI = 1'b0;     // Default MOSI value

        // Apply reset
        #CLK_PERIOD;
        reset_n = 1'b1;  // Deassert reset
        #CLK_PERIOD;

        // First, write address (00) over SPI
        $display("Starting Write Address (00) operation...");
        write_spi(10'b00000101_00);  // Address Write Command (00) and example address (0x05)
        #((13 * CLK_PERIOD));        // Wait for 13 cycles (Write address)

        // Write data (01) over SPI
        $display("Starting Write Data (01) operation...");
        write_spi(10'b10101010_01);  // Data Write Command (01) and example data (0xAA)
        #((13 * CLK_PERIOD));        // Wait for 13 cycles (Write data)

        // Read address (10) over SPI
        $display("Starting Read Address (10) operation...");
        write_spi(10'b00000101_10);  // Read Address Command (10) (any additional bits will be ignored)
        #((13 * CLK_PERIOD));        // Wait for 13 cycles (Read address)

        // Read data (11) over SPI
        $display("Starting Read Data (11) operation...");
        write_spi(10'b00000000_11);  // Read Data Command (11) (any additional bits will be ignored)
        ss_n=1'b0;
        #((22 * CLK_PERIOD));        // Wait for 22 cycles (Read data)
            ss_n=1'b0;
        // Finish simulation
        $stop;
    end

    // SPI Write Task
    task write_spi(input [9:0] spi_data);
        integer i;
        begin
            // Enable SPI (ss_n low)
            ss_n = 1'b0;

            // Send 10-bit SPI data (MOSI)
            for (i = 0; i <10; i = i + 1) begin
                MOSI = spi_data[i];
                #CLK_PERIOD;
            end
           ss_n = 1'b1;     
        
        end
    endtask

endmodule
