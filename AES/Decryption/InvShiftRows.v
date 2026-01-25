module InvShiftRows(
    input  [127:0] inp,
    output [127:0] out
);
    wire [7:0] s [0:15];

    assign {
        s[0],  s[1],  s[2],  s[3],
        s[4],  s[5],  s[6],  s[7],
        s[8],  s[9],  s[10], s[11],
        s[12], s[13], s[14], s[15]
    } = inp;

    assign out = {
        // column 0
        s[0],  s[13], s[10], s[7],
        // column 1
        s[4],  s[1],  s[14], s[11],
        // column 2
        s[8],  s[5],  s[2],  s[15],
        // column 3
        s[12], s[9],  s[6],  s[3]
    };
endmodule
