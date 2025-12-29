module aes_mode_controller (
    input  wire        clk,
    input  wire        reset,

    input  wire        start,
    input  wire        block_done,
    input  wire [2:0]  mode,

    input  wire [127:0] plaintext,
    input  wire [127:0] aes_out,
    input  wire [127:0] iv,

    output reg         fb_load_iv,
    output reg         fb_update,
    output reg         ctr_load,
    output reg         ctr_inc,

    output reg         data_valid
);

    localparam MODE_ECB = 3'd0;
    localparam MODE_CBC = 3'd1;
    localparam MODE_CFB = 3'd2;
    localparam MODE_OFB = 3'd3;
    localparam MODE_CTR = 3'd4;

    localparam S_IDLE = 2'd0;
    localparam S_INIT = 2'd1;
    localparam S_RUN  = 2'd2;
    localparam S_DONE = 2'd3;

    reg [1:0] state, next_state;

    /* ================= FSM STATE ================= */
    always @(posedge clk) begin
        if (reset)
            state <= S_IDLE;
        else
            state <= next_state;
    end

    /* ================= FSM NEXT ================= */
    always @(*) begin
        next_state = state;

        case (state)
            S_IDLE:
                if (start)
                    next_state = S_INIT;

            S_INIT:
                next_state = S_RUN;

            S_RUN:
                if (block_done)
                    next_state = S_DONE;

            S_DONE:
                next_state = S_IDLE;

            default:
                next_state = S_IDLE;
        endcase
    end

    /* ================= OUTPUT CONTROL ================= */
    always @(*) begin
        fb_load_iv = 0;
        fb_update  = 0;
        ctr_load   = 0;
        ctr_inc    = 0;
        data_valid = 0;

        case (state)

            S_INIT: begin
                if (mode == MODE_CBC || mode == MODE_CFB || mode == MODE_OFB)
                    fb_load_iv = 1;

                if (mode == MODE_CTR)
                    ctr_load = 1;
            end

            S_RUN: begin
                // AES core active; no control here
            end

            S_DONE: begin
                data_valid = 1;

                if (mode == MODE_CBC || mode == MODE_CFB || mode == MODE_OFB)
                    fb_update = 1;

                if (mode == MODE_CTR)
                    ctr_inc = 1;
            end
        endcase
    end

endmodule
