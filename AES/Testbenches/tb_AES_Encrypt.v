`timescale 1ns/1ps

module tb_AES_Encrypt;

    reg clk;
    reg reset;
    reg start;
    reg subkey_valid;

    reg  [127:0] plaintext;
    reg  [127:0] subkey;

    wire [3:0]   subkey_addr;
    wire [127:0] ciphertext;
    wire         ciphertext_done;

    // DUT
    AES_Encrypt dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .subkey_valid(subkey_valid),
        .plaintext(plaintext),
        .subkey(subkey),
        .subkey_addr(subkey_addr),
        .ciphertext(ciphertext),
        .ciphertext_done(ciphertext_done)
    );

    // Clock: 100 MHz
    always #5 clk = ~clk;

    // AES-128 round keys (K0-K10)
    reg [127:0] round_keys [0:10];

    initial begin
        round_keys[0]  = 128'h2B7E151628AED2A6ABF7158809CF4F3C;
        round_keys[1]  = 128'hA0FAFE1788542CB123A339392A6C7605;
        round_keys[2]  = 128'hF2C295F27A96B9435935807A7359F67F;
        round_keys[3]  = 128'h3D80477D4716FE3E1E237E446D7A883B;
        round_keys[4]  = 128'hEF44A541A8525B7FB671253BDB0BAD00;
        round_keys[5]  = 128'hD4D1C6F87C839D87CAF2B8BC11F915BC;
        round_keys[6]  = 128'h6D88A37A110B3EFDDBF98641CA0093FD;
        round_keys[7]  = 128'h4E54F70E5F5FC9F384A64FB24EA6DC4F;
        round_keys[8]  = 128'hEAD27321B58DBAD2312BF5607F8D292F;
        round_keys[9]  = 128'hAC7766F319FADC2128D12941575C006E;
        round_keys[10] = 128'hD014F9A8C9EE2589E13F0CC8B6630CA6;

    end

    // Drive subkeys based on address
    always @(*) begin
        subkey = round_keys[subkey_addr];
    end

    initial begin
        // Init
        clk = 0;
        reset = 1;
        start = 0;
        subkey_valid = 0;

        plaintext = 128'h6BC1BEE22E409F96E93D7E117393172A;

        #20;
        reset = 0;

        // Start encryption
        #10;
        subkey_valid = 1;
        start = 1;

        #10;   
        start = 0;

        // Wait for completion
        wait(ciphertext_done);

        
        $display("AES ENCRYPTION COMPLETE");
        $display("Ciphertext = %h", ciphertext);
        $display("Expected   = 128'h3AD77BB40D7A3660A89ECAF32466EF97");
        

        if (ciphertext == 128'h3AD77BB40D7A3660A89ECAF32466EF97
)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        #20;
        $finish;
    end

endmodule
