module aes_core_dummy (
    input  wire        clk,
    input  wire        reset,
    input  wire        start,
    input  wire        enc_dec,      // 0 = encrypt, 1 = decrypt
    input  wire [127:0] data_in,
    output reg  [127:0] data_out,
    output reg         done
);

    reg [3:0] cnt;

    always @(posedge clk) begin
        if (reset) begin
            cnt  <= 0;
            done <= 0;
        end else begin
            done <= 0;

            if (start) begin
                cnt <= 4'd4; // fixed latency
            end else if (cnt != 0) begin
                cnt <= cnt - 1;
                if (cnt == 1) begin
                    if (!enc_dec)
                        data_out <= data_in ^ 128'h1111_1111_1111_1111_1111_1111_1111_1111;
                    else
                        data_out <= data_in ^ 128'h2222_2222_2222_2222_2222_2222_2222_2222;
                    done <= 1'b1;
                end
            end
        end
    end
endmodule
