module axi_status_logic (
    input  wire        clk,
    input  wire        resetn,

    input  wire [31:0] ctrl_reg,
    input  wire        aes_done,
    input  wire        aes_error,

    output reg         aes_start,
    output reg  [31:0] status_reg
);

    always @(posedge clk) begin
        if (!resetn) begin
            status_reg <= 0;
            aes_start  <= 0;
        end else begin
            aes_start <= 0;

            // START bit
            if (ctrl_reg[0] && !status_reg[0]) begin
                aes_start      <= 1;
                status_reg[0]  <= 1; // BUSY
                status_reg[1]  <= 0; // DONE clear
            end

            if (aes_done) begin
                status_reg[0] <= 0;
                status_reg[1] <= 1;
            end

            if (aes_error)
                status_reg[2] <= 1;
        end
    end
endmodule
