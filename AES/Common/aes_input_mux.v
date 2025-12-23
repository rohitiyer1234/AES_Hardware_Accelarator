module aes_input_mux(

    input [2:0] mode,
    input [127:0] plaintext,
    input [127:0] feedback,
    input [127:0] ctr,
    output reg [127:0] aes_in
    );

    // AES modes
    localparam MODE_ECB = 3'd0;
    localparam MODE_CBC = 3'd1;
    localparam MODE_CFB = 3'd2;
    localparam MODE_OFB = 3'd3;
    localparam MODE_CTR = 3'd4;

    always @ (*)
    begin
    case ( mode )
        MODE_ECB : aes_in = plaintext;
        MODE_CBC: aes_in = plaintext ^ feedback;
        MODE_CFB: aes_in = feedback;
        MODE_OFB: aes_in = feedback;
        MODE_CTR: aes_in = ctr;
        default:  aes_in = plaintext;
        endcase
    end

endmodule