module InvShiftRows (
    input  logic [127:0] inp,
    output logic [127:0] out
);

    // Break input into 16 bytes (column-major AES state)
    logic [7:0] b [0:15];

    assign {
        b[0],  b[1],  b[2],  b[3],
        b[4],  b[5],  b[6],  b[7],
        b[8],  b[9],  b[10], b[11],
        b[12], b[13], b[14], b[15]
    } = inp;

    // Inverse ShiftRows
    assign out = {
        // Row 0 (no shift)
        b[0],  b[4],  b[8],  b[12],

        // Row 1 (right shift by 1)
        b[13], b[1],  b[5],  b[9],

        // Row 2 (right shift by 2)
        b[10], b[14], b[2],  b[6],

        // Row 3 (right shift by 3)
        b[7],  b[11], b[15], b[3]
    };

endmodule
