`timescale 1ns/1ps

module tb_aes_enc_dec_dbg;

    reg clk;
    reg reset;
    reg start;

    reg [127:0] plaintext;
    reg [127:0] user_key;

    wire [127:0] ciphertext;
    wire [127:0] decrypted_text;
    wire done;

    wire [3:0]   round_dbg;
    wire [127:0] subkey_dbg;
    wire         all_valid_dbg;
    wire         aes_start_dbg;

    aes_enc_dec_top_dbg dut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .plaintext(plaintext),
        .user_key(user_key),
        .ciphertext(ciphertext),
        .decrypted_text(decrypted_text),
        .done(done),
        .round_dbg(round_dbg),
        .subkey_dbg(subkey_dbg),
        .all_valid_dbg(all_valid_dbg),
        .aes_start_dbg(aes_start_dbg)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        plaintext = 128'h00112233445566778899AABBCCDDEEFF;
        user_key  = 128'h000102030405060708090A0B0C0D0E0F;

        reset = 1; start = 0;
        #40; reset = 0;

        #40;
        start = 1; #10; start = 0;

        wait(done);

        $display("CIPHERTEXT = %h", ciphertext);
        $display("DECRYPTED  = %h", decrypted_text);

        #100;
        $stop;
    end

endmodule
