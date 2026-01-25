module aes_debug_top (
    input clk,
    input reset,
    input start,              // user start pulse

    input [127:0] plaintext,
    input [127:0] user_key,

    output [127:0] ciphertext,
    output done,

    // ===== DEBUG OUTPUTS =====
    output [3:0]   round_dbg,
    output [127:0] subkey_dbg,
    output         all_valid_dbg,
    output         aes_start_dbg
);

    // -------------------------
    // Key Expansion → KeyMem
    // -------------------------
    wire        w_en;
    wire [3:0]  waddr;
    wire [127:0] wkey;

    // -------------------------
    // KeyMem → AES
    // -------------------------
    wire [127:0] subkey;
    wire all_valid_bits;

    // -------------------------
    // AES
    // -------------------------
    wire [3:0] subkey_addr;
    wire aes_done;

    // -------------------------
    // Control FSM
    // -------------------------
    localparam S_IDLE=0, S_KEYEXP=1, S_AES=2;
    reg [1:0] state;

    reg keyexp_start, aes_start;

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
    keymem KM (
        .clk(clk),
        .reset(reset),
        .w_en(w_en),
        .waddr(waddr),
        .wkey(wkey),
        .raddr_read(subkey_addr),
        .rkey_read(subkey),
        .all_valid_bits(all_valid_bits)
    );

    // =========================
    // AES CORE
    // =========================
    AES_Encrypt AES (
        .clk(clk),
        .reset(reset),
        .start(aes_start),
        .subkey_valid(all_valid_bits),
        .plaintext(plaintext),
        .subkey(subkey),
        .subkey_addr(subkey_addr),
        .ciphertext(ciphertext),
        .ciphertext_done(aes_done)
    );

    assign done = aes_done;

    // =========================
    // DEBUG EXPORTS
    // =========================
    assign round_dbg     = subkey_addr;
    assign subkey_dbg    = subkey;
    assign all_valid_dbg = all_valid_bits;
    assign aes_start_dbg = aes_start;

    // =========================
    // SYSTEM SEQUENCER
    // =========================
    always @(posedge clk) begin
        if (reset) begin
            state <= S_IDLE;
            keyexp_start <= 0;
            aes_start <= 0;
        end else begin
            keyexp_start <= 0;
            aes_start <= 0;

            case (state)

            S_IDLE: begin
                if (start) begin
                    keyexp_start <= 1;   // pulse
                    state <= S_KEYEXP;
                end
            end

            S_KEYEXP: begin
                if (all_valid_bits) begin
                    aes_start <= 1;      // pulse
                    state <= S_AES;
                end
            end

            S_AES: begin
                if (aes_done)
                    state <= S_IDLE;
            end

            endcase
        end
    end

endmodule
