module aes_enc_dec_top_dbg (
    input clk,
    input reset,
    input start,

    input  [127:0] plaintext,
    input  [127:0] user_key,

    output [127:0] ciphertext,
    output [127:0] decrypted_text,
    output done,

    // ===== DEBUG OUTPUTS =====
    output [3:0]   round_dbg,
    output [127:0] subkey_dbg,
    output         all_valid_dbg,
    output         aes_start_dbg
);

    // -------------------------
    // Key expansion → memory
    // -------------------------
    wire        w_en;
    wire [3:0]  waddr;
    wire [127:0] wkey;

    wire [127:0] subkey;
    wire all_valid_bits;

    // -------------------------
    // Encrypt
    // -------------------------
    wire [3:0] enc_addr;
    wire enc_done;

    // -------------------------
    // Decrypt
    // -------------------------
    wire [3:0] dec_addr;
    wire dec_done;

    // -------------------------
    // Control FSM
    // -------------------------
    localparam S_IDLE=0, S_KEYEXP=1, S_ENC=2, S_DEC=3;
    reg [1:0] state;

    reg keyexp_start, enc_start, dec_start;

    // =========================
    // KEY EXPANSION
    // =========================
    Aes_key_expansion_128 KE (
        .clk(clk),
        .reset(reset),
        .key_expansion_start(keyexp_start),
        .user_sub_key(user_key),
        .w_en(w_en),
        .waddr(waddr),
        .wkey(wkey)
    );

    // =========================
    // KEY MEMORY
    // =========================
    wire [3:0] keymem_raddr =
        (state == S_DEC) ? (dec_addr) : enc_addr;

    keymem KM (
        .clk(clk),
        .reset(reset),
        .w_en(w_en),
        .waddr(waddr),
        .wkey(wkey),
        .raddr_read(keymem_raddr),
        .rkey_read(subkey),
        .all_valid_bits(all_valid_bits)
    );

    // =========================
    // AES ENCRYPT
    // =========================
    AES_Encrypt ENC (
        .clk(clk),
        .reset(reset),
        .start(enc_start),
        .subkey_valid(all_valid_bits),
        .plaintext(plaintext),
        .subkey(subkey),
        .subkey_addr(enc_addr),
        .ciphertext(ciphertext),
        .ciphertext_done(enc_done)
    );

    // =========================
    // AES DECRYPT
    // =========================
    AES_Decrypt DEC (
        .clk(clk),
        .reset(reset),
        .start(dec_start),
        .subkey_valid(all_valid_bits),
        .ciphertext(ciphertext),
        .subkey(subkey),
        .subkey_addr(dec_addr),
        .plaintext(decrypted_text),
        .plaintext_done(dec_done)
    );

    assign done = dec_done;

    // =========================
    // DEBUG SIGNALS
    // =========================
    assign round_dbg     = (state == S_DEC) ? dec_addr : enc_addr;
    assign subkey_dbg    = subkey;
    assign all_valid_dbg = all_valid_bits;
    assign aes_start_dbg = enc_start | dec_start;

    // =========================
    // SYSTEM SEQUENCER
    // =========================
    always @(posedge clk) begin
        if (reset) begin
            state <= S_IDLE;
            keyexp_start <= 0;
            enc_start <= 0;
            dec_start <= 0;
        end else begin
            keyexp_start <= 0;
            enc_start <= 0;
            dec_start <= 0;

            case (state)

            S_IDLE: begin
                if (start) begin
                    keyexp_start <= 1;
                    state <= S_KEYEXP;
                end
            end

            S_KEYEXP: begin
                if (all_valid_bits) begin
                    enc_start <= 1;
                    state <= S_ENC;
                end
            end

            S_ENC: begin
                if (enc_done) begin
                    dec_start <= 1;
                    state <= S_DEC;
                end
            end

            S_DEC: begin
                if (dec_done)
                    state <= S_IDLE;
            end

            endcase
        end
    end

endmodule
