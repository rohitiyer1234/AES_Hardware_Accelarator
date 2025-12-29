module axi_control (
    input  wire        clk,
    input  wire        resetn,

    input  wire [31:0] ctrl_reg,
    input  wire [31:0] mode_reg,
    input  wire [31:0] base_key_reg [0:3],
    input  wire [31:0] data_in_mem  [0:3],
    input  wire [31:0] iv_in[0:3],

    input  wire        aes_done,
    input  wire [127:0] aes_result,

    output reg  [31:0] status_reg,
    output reg  [31:0] data_out_mem [0:3],

    output reg         aes_start,
    output reg  [127:0] plaintext_lat,
    output reg  [2:0]  mode_lat,
    output reg [127:0] iv_lat,
    output reg enc_dec_lat

);

    localparam S_IDLE = 2'd0;
    localparam S_RUN  = 2'd1;
    localparam S_DONE = 2'd2;

    reg [1:0] state;
    reg start_seen;

    /* ================= FSM ================= */
    always @(posedge clk) begin
        if (!resetn) begin
            state      <= S_IDLE;
            status_reg <= 32'd0;
            aes_start  <= 1'b0;
        end else begin
            aes_start <= 1'b0;

            case (state)

                S_IDLE: begin
                    status_reg[0] <= 1'b0; // BUSY
                    status_reg[1] <= 1'b0; // DONE

                    if (ctrl_reg[0] && !start_seen) begin
                        plaintext_lat <= {
                            data_in_mem[0],
                            data_in_mem[1],
                            data_in_mem[2],
                            data_in_mem[3]
                        };

                        enc_dec_lat <= ctrl_reg[1];
                        mode_lat <= mode_reg[2:0];
                        iv_lat <= {
                            iv_in[0],
                            iv_in[1],
                            iv_in[2],
                            iv_in[3]
                        };

                        aes_start <= 1'b1;
                        start_seen <= 1'b1;
                        status_reg[0] <= 1'b1;
                        state <= S_RUN;
                    end
                end

                S_RUN: begin
                    status_reg[0] <= 1'b1;

                    if (aes_done) begin
                        data_out_mem[0] <= aes_result[127:96];
                        data_out_mem[1] <= aes_result[95:64];
                        data_out_mem[2] <= aes_result[63:32];
                        data_out_mem[3] <= aes_result[31:0];

                        status_reg[0] <= 1'b0;
                        status_reg[1] <= 1'b1;
                        state <= S_DONE;
                    end
                end

                S_DONE: begin
                    start_seen <= 1'b0;
                    // Wait for next START
                    if (ctrl_reg[0])
                        state <= S_IDLE;
                end
            endcase
        end
    end

endmodule
