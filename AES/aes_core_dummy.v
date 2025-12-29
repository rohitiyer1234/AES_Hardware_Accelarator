module aes_core_dummy (
    input  wire        clk,
    input  wire        reset,
    input  wire        start,
    input  wire        enc_dec,   // 0=enc, 1=dec
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
                cnt <= 4'd5;
            end else if (cnt != 0) begin
                cnt <= cnt - 1;
                if (cnt == 1) begin
                    if (!enc_dec)
                        data_out <= data_in ^ 128'hA5A5_A5A5_A5A5_A5A5_A5A5_A5A5_A5A5_A5A5;
                    else
                        data_out <= data_in ^ 128'h5A5A_5A5A_5A5A_5A5A_5A5A_5A5A_5A5A_5A5A;
                    done <= 1'b1;
                end
            end
        end
    end
endmodule
