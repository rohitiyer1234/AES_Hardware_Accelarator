module ShiftRows(
    input [127:0] inp,
    output [127:0] out
);

    // Break input into 16 bytes for readability
    wire [7:0] b [16];
    assign {
        b[0],  b[1],  b[2],  b[3],
        b[4],  b[5],  b[6],  b[7],
        b[8],  b[9],  b[10], b[11],
        b[12], b[13], b[14], b[15]
    } = inp;

    // Apply ShiftRows transformation
    assign out = {
        // Row 0 (no shift)
        b[0],  b[4],  b[8],  b[12],

        // Row 1 (shift left by 1)
        b[5],  b[9],  b[13], b[1],

        // Row 2 (shift left by 2)
        b[10], b[14], b[2],  b[6],

        // Row 3 (shift left by 3)
        b[15], b[3],  b[7],  b[11]
    };

endmodule
