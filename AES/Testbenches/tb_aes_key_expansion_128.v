`timescale 1ns/1ps

module tb_Aes_key_expansion_128;

    // DUT signals
    reg         clk;
    reg         reset;
    reg         start;
    reg [127:0] user_sub_key;

    wire [127:0] output_key;
    wire [3:0]   i;
    wire         status;

    // Instantiate DUT
    Aes_key_expansion_128 dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .user_sub_key(user_sub_key),
        .output_key(output_key),
        .i(i),
        .status(status)
    );

    // Clock: 10 ns period
    always #5 clk = ~clk;

    initial begin
        // --------------------------------
        // INITIAL VALUES
        // --------------------------------
        clk = 0;
        reset = 1;
        start = 0;

        user_sub_key = 128'h2b7e1516_28aed2a6_abf71588_09cf4f3c;

       
        $display(" AES-128 Key Expansion Testbench Start ");
        $display(" Input Key = %h", user_sub_key);
      

        // --------------------------------
        // APPLY RESET
        // --------------------------------
        #20;
        reset = 0;
        $display("Reset deasserted");

        // --------------------------------
        // START KEY EXPANSION (1-cycle pulse)
        // --------------------------------
        @(posedge clk);
        start = 1;

        @(posedge clk);
        start = 0;   // IMPORTANT: start only for 1 cycle

        // --------------------------------
        // MONITOR ROUND KEYS
        // --------------------------------
        while (status) begin
            @(posedge clk);
            start=1;
            $display("Round %0d Key = %h", i, output_key);
        end

      

        #20;
        $finish;
    end

endmodule
