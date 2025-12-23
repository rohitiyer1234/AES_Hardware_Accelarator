module AES_Encrypt (
    input  clk, reset, start, subkey_valid,
    input  [127:0] plaintext,
    input  [127:0] subkey,

    output reg [3:0] subkey_addr,
    output reg [127:0] ciphertext,
    output reg  ciphertext_done
);

    // FSM states
    localparam IDLE = 2'd0;
    localparam ROUND = 2'd1;
    localparam WAIT = 2'd2;
    localparam DONE = 2'd3;

    reg [1:0]   status;
    reg [3:0]   round_count;
    reg [127:0] state_reg;

    wire [127:0] subbytes_out, shiftrows_out, mixcols_out;
    wire [127:0] addkey_out;

    // AES datapath
    SubBytes   SB (subbytes_out, state_reg);
    ShiftRows  SR (shiftrows_out, subbytes_out);
    MixColumns MC (mixcols_out, shiftrows_out);

    // Select input to AddRoundKey
    wire [127:0] addkey_in =
        (round_count == 1) ? shiftrows_out : mixcols_out;

    AddRoundKey A1(addkey_out, addkey_in, subkey);

    always @(posedge clk) begin
        if (reset) begin
            status          <= IDLE;
            round_count     <= 0;
            state_reg       <= 0;
            ciphertext      <= 0;
            ciphertext_done <= 0;
            subkey_addr     <= 0;
        end else begin
            case (status)

            IDLE: begin
                ciphertext_done <= 0;
                subkey_addr     <= 0;

                if (start && subkey_valid) begin
                    // Initial AddRoundKey (Round 0)
                    state_reg   <= plaintext ^ subkey;
                    round_count <= 10;
                    subkey_addr <= 1;
                    status      <= ROUND;
                end
            end

            ROUND: begin
                if (subkey_valid) begin
                    state_reg   <= addkey_out;
                    round_count <= round_count - 1;
                    subkey_addr <= subkey_addr + 1;

                    if (round_count == 1)
                        status <= DONE;
                    else
                        status <= ROUND;
                end else begin
                    status <= WAIT;
                end
            end


            WAIT: begin
                if (subkey_valid)
                    status <= ROUND;
            end


            DONE: begin
                ciphertext      <= state_reg;
                ciphertext_done <= 1;
                status          <= IDLE;
            end

            endcase
        end
    end
endmodule