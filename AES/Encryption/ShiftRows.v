module ShiftRows(
    input  [127:0] inp,
    output [127:0] out
);

    wire [7:0] b [15:0];

    // Explicit byte mapping (MSB = b[0])
    assign {
        b[0],  b[1],  b[2],  b[3],
        b[4],  b[5],  b[6],  b[7],
        b[8],  b[9],  b[10], b[11],
        b[12], b[13], b[14], b[15]
    } = inp;

    // AES ShiftRows (FIPS-197 compliant)
    assign out = {
        b[0],  b[5],  b[10], b[15],
        b[4],  b[9],  b[14], b[3],
        b[8],  b[13], b[2],  b[7],
        b[12], b[1],  b[6],  b[11]
    };

endmodule
