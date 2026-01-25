module AES_Decrypt(
    input  clk,
    input  reset,
    input  start,
    input  subkey_valid,
    input  [127:0] ciphertext,
    input  [127:0] subkey,

    output reg  [3:0]   subkey_addr,
    output reg  [127:0] plaintext,
    output reg          plaintext_done
);

    localparam IDLE  = 2'd0;
    localparam ROUND = 2'd1;
    localparam DONE  = 2'd2;

    reg [1:0]   state;
    reg [3:0]   round;
    reg [127:0] state_reg;

    // -------------------------
    // Decrypt datapath
    // -------------------------
    wire [127:0] isr_out, isb_out, ark_out, imc_out;

    InvShiftRows  u_isr (.inp(state_reg), .out(isr_out));
    InvSubBytes   u_isb (.in(isr_out),    .out(isb_out));
    AddRoundKey   u_ark (.inp(isb_out),   .subkey(subkey), .result(ark_out));
    InvMixColumns u_imc (.inp(ark_out),   .res(imc_out));

    // -------------------------
    // FSM
    // -------------------------
    always @(posedge clk) begin
        if (reset) begin
            state          <= IDLE;
            round          <= 0;
            state_reg      <= 0;
            plaintext      <= 0;
            plaintext_done <= 0;
            subkey_addr    <= 10;
        end else begin
            case (state)

            IDLE: begin
                plaintext_done <= 0;
                if (start && subkey_valid) begin
                    // Initial AddRoundKey with K10
                    state_reg   <= ciphertext ^ subkey; // K10
                    round       <= 4'd9;
                    subkey_addr <= 4'd9;
                    state       <= ROUND;
                end
            end

            ROUND: begin
                if (subkey_valid) begin
                    if (round == 0) begin
                        // Final round (NO InvMixColumns)
                        state_reg      <= ark_out;   // uses K0
                        plaintext      <= ark_out;
                        plaintext_done <= 1'b1;
                        state          <= DONE;
                    end else begin
                        // Normal rounds
                        state_reg   <= imc_out;
                        round       <= round - 1;
                        subkey_addr <= subkey_addr - 1;
                    end
                end
            end

            DONE: begin
                state <= IDLE;
            end

            endcase
        end
    end

endmodule
