`timescale 1ns / 1ps

module tb_AES_Decrypt;

    reg clk, reset, start, subkey_valid;
    reg [127:0] ciphertext, subkey;
    wire [3:0] subkey_addr;
    wire [127:0] plaintext;
    wire plaintext_done;

    AES_Decrypt dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .subkey_valid(subkey_valid),
        .ciphertext(ciphertext),
        .subkey(subkey),
        .subkey_addr(subkey_addr),
        .plaintext(plaintext),
        .plaintext_done(plaintext_done)
    );

    always #5 clk = ~clk;

    reg [127:0] round_keys [0:10];

    initial begin
        // AES-128 round keys
        round_keys[0]  = 128'h000102030405060708090A0B0C0D0E0F;
        round_keys[1]  = 128'hD6AA74FDD2AF72FADAA678F1D6AB76FE;
        round_keys[2]  = 128'hB692CF0B643DBDF1BE9BC5006830B3FE;
        round_keys[3]  = 128'hB6FF744ED2C2C9BF6C590CBF0469BF41;
        round_keys[4]  = 128'h47F7F7BC95353E03F96C32BCFD058DFD;
        round_keys[5]  = 128'h3CAAA3E8A99F9DEB50F3AF57ADF622AA;
        round_keys[6]  = 128'h5E390F7DF7A69296A7553DC10AA31F6B;
        round_keys[7]  = 128'h14F9701AE35FE28C440ADF4D4EA9C026;
        round_keys[8]  = 128'h47438735A41C65B9E016BAF4AEBF7AD2;
        round_keys[9]  = 128'h549932D1F08557681093ED9CBE2C974E;
        round_keys[10] = 128'h13111D7FE3944A17F307A78B4D2B30C5;
    end

    always @(*) subkey = round_keys[subkey_addr];

    initial begin
        clk = 0; reset = 1; start = 0; subkey_valid = 0;
        ciphertext = 128'h69C4E0D86A7B0430D8CDB78070B4C55A;

        #20 reset = 0;
        #10 subkey_valid = 1; start = 1;
        #10 start = 0;

        wait(plaintext_done);
        $display("EXPECTED PLAINTEXT = 00112233445566778899AABBCCDDEEFF");

        if (plaintext == 128'h00112233445566778899AABBCCDDEEFF)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        #20 $finish;
    end

endmodule
