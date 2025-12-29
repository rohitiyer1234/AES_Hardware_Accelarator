module xor_128 (
    input  [127:0] a,
    input  [127:0] b,
    output [127:0] y
);
    assign y = a ^ b;
endmodule