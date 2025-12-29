module aes_encrypt_top (
    input  wire        clk,
    input  wire        reset,

    input  wire        start,
    input  wire        enc_dec,
    input  wire [2:0]  mode,

    input  wire [127:0] plaintext,
    input  wire [127:0] iv,

    output wire [127:0] result,
    output wire        done
);

    wire [127:0] feedback;
    wire [127:0] ctr;
    wire [127:0] aes_in;
    wire [127:0] aes_out;

    wire fb_load_iv, fb_update;
    wire ctr_load, ctr_inc;

    /* Mode controller */
    aes_mode_controller u_mode (
        .clk(clk),
        .reset(reset),
        .start(start),
        .block_done(done),
        .mode(mode),
        .plaintext(plaintext),
        .aes_out(aes_out),
        .iv(iv),
        .fb_load_iv(fb_load_iv),
        .fb_update(fb_update),
        .ctr_load(ctr_load),
        .ctr_inc(ctr_inc),
        .data_valid()
    );

    /* Feedback register */
    feedback_reg_128 u_fb (
        .clk(clk),
        .reset(reset),
        .load_iv(fb_load_iv),
        .update(fb_update),
        .iv(iv),
        .data_in(aes_out),
        .feedback(feedback)
    );

    /* Counter register */
    ctr_reg_128 u_ctr (
        .clk(clk),
        .reset(reset),
        .load(ctr_load),
        .inc(ctr_inc),
        .ctr_init(iv),
        .ctr(ctr)
    );

    /* AES input mux */
    aes_input_mux u_mux (
        .mode(mode),
        .plaintext(plaintext),
        .feedback(feedback),
        .ctr(ctr),
        .aes_in(aes_in)
    );

    /* Dummy AES */
    aes_core_dummy u_aes (
        .clk(clk),
        .reset(reset),
        .start(start),
        .enc_dec(enc_dec),
        .data_in(aes_in),
        .data_out(aes_out),
        .done(done)
    );

    assign result = aes_out;

endmodule
