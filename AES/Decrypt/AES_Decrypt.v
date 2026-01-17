`timescale 1ns / 1ps

module AES_Decrypt (
    input  logic        clk,
    input  logic        reset,
    input  logic        start,
    input  logic        subkey_valid,
    input  logic [127:0] ciphertext,
    input  logic [127:0] subkey,

    output logic [3:0]   subkey_addr,
    output logic [127:0] plaintext,
    output logic         plaintext_done
);

    // FSM states
    localparam IDLE  = 2'd0;
    localparam ROUND = 2'd1;
    localparam WAIT  = 2'd2;
    localparam DONE  = 2'd3;

    logic [1:0]   status;
    logic [3:0]   round_count;
    logic [127:0] state_reg;

    // Datapath wires
    wire [127:0] invshift_out;
    wire [127:0] invsub_out;
    wire [127:0] addkey_out;
    wire [127:0] invmix_out;

    // Inverse AES datapath
    InvShiftRows ISR (
        .inp(state_reg),
        .out(invshift_out)
    );

    InvSubBytes ISB (
        .inp(invshift_out),
        .res(invsub_out)
    );

    addroundkey ARK (
        .state(invsub_out),
        .roundkey(subkey),
        .out(addkey_out)
    );

    InvMix IMC (
        .inp(addkey_out),
        .res(invmix_out)
    );

    // -------------------------------------------------
    // FSM
    // -------------------------------------------------
    always_ff @(posedge clk) begin
        if (reset) begin
            status          <= IDLE;
            round_count     <= 0;
            state_reg       <= 0;
            plaintext       <= 0;
            plaintext_done  <= 0;
            subkey_addr     <= 0;
        end else begin
            case (status)

            // -----------------------------------------
            IDLE: begin
                plaintext_done <= 0;
                if (start && subkey_valid) begin
                    // Initial AddRoundKey with key[10]
                    state_reg   <= ciphertext ^ subkey;
                    round_count <= 9;
                    subkey_addr <= 9;
                    status      <= ROUND;
                end
            end

            // -----------------------------------------
            ROUND: begin
                if (subkey_valid) begin
                    // Skip InvMixColumns ONLY in final round
                    if (round_count == 0)
                        state_reg <= addkey_out;
                    else
                        state_reg <= invmix_out;

                    round_count <= round_count - 1;
                    subkey_addr <= subkey_addr - 1;

                    if (round_count == 0)
                        status <= DONE;
                end else begin
                    status <= WAIT;
                end
            end

            // -----------------------------------------
            WAIT: begin
                if (subkey_valid)
                    status <= ROUND;
            end

            // -----------------------------------------
            DONE: begin
                plaintext      <= state_reg;
                plaintext_done <= 1;
                status         <= IDLE;
            end

            endcase
        end
    end

endmodule
