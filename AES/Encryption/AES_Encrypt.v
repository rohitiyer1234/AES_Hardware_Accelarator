module AES_Encrypt (
    input  clk,
    input  reset,
    input  start,
    input  subkey_valid,
    input  [127:0] plaintext,
    input  [127:0] subkey,

    output reg [3:0]   subkey_addr,
    output reg [127:0] ciphertext,
    output reg         ciphertext_done
);

    localparam IDLE  = 2'd0;
    localparam ROUND = 2'd1;
    localparam WAIT  = 2'd2;
    localparam DONE  = 2'd3;

    reg [1:0]   status;
    reg [3:0]   round_count;
    reg [127:0] state_reg;
    reg start_seen;

    // -------------------------------
    // Combinational datapath wires
    // -------------------------------
    wire [127:0] subbytes_out;
    wire [127:0] shiftrows_out;
    wire [127:0] mixcols_out;
    wire [127:0] state_next;

    // AES datapath (PURE combinational)
    SubBytes   u_sb (.inp(state_reg),    .res(subbytes_out));
    ShiftRows  u_sr (.inp(subbytes_out), .out(shiftrows_out));
    MixColumns u_mc (.inp(shiftrows_out),.res(mixcols_out));

    // AddRoundKey + final-round select
    assign state_next =
        (round_count == 1) ?
            (shiftrows_out ^ subkey) :  // final round
            (mixcols_out  ^ subkey);    // normal rounds

    // -------------------------------
    // FSM (ONLY place state_reg updates)
    // -------------------------------
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

    // Clear latch ONLY when start is deasserted
            if (!start)
                 start_seen <= 1'b0;

    // Start exactly once per start assertion
            if (start && !start_seen && subkey_valid) begin
                 start_seen  <= 1'b1;
                state_reg   <= plaintext ^ subkey; // round 0
                round_count <= 10;
                subkey_addr <= 1;
                status      <= ROUND;
             end
            end


            ROUND: begin
                if (subkey_valid) begin
                    state_reg   <= state_next;
                    round_count <= round_count - 1;
                    subkey_addr <= subkey_addr + 1;

                    if (round_count == 1)
                        status <= DONE;
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
