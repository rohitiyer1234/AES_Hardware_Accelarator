//--------------------------------------------------------------
// InvSubBytes
// Exact inverse of YOUR SubBytes using LUT construction
//--------------------------------------------------------------
module InvSubBytes (
    input  [127:0] inp,
    output [127:0] res
);

    // Inverse S-box ROM
    reg [7:0] inv_sbox [0:255];

    integer i;

    // Build inverse S-box using YOUR sbox()
    initial begin
        for (i = 0; i < 256; i = i + 1) begin
            inv_sbox[sbox(i[7:0])] = i[7:0];
        end
    end

    // Apply inverse S-box to all bytes
    genvar b;
    generate
        for (b = 0; b < 128; b = b + 8) begin : INV_BYTES
            assign res[b+7:b] = inv_sbox[inp[b+7:b]];
        end
    endgenerate


    // ==========================================================
    // === BELOW IS YOUR *EXACT* SubBytes S-BOX AND HELPERS ===
    // === DO NOT MODIFY ANYTHING                          ===
    // ==========================================================

    function automatic [7:0] sbox(input [7:0] in_byte);
        reg [7:0] out_iso;
        reg [3:0] g0, g1;
        reg [3:0] t_mul, t_sq, t_sqv;
        reg [3:0] inv;
        reg [3:0] d0, d1;
        begin
            out_iso = isomorph(in_byte);
            g1 = out_iso[7:4];
            g0 = out_iso[3:0];
            t_mul  = gf4_mul(g1, g0);
            t_sq   = gf4_sq(g0);
            t_sqv  = gf4_sq_mul_v(g1);
            inv = gf4_inv(t_mul ^ t_sq ^ t_sqv);
            d1 = gf4_mul(g1, inv);
            d0 = gf4_mul(g0 ^ g1, inv);
            sbox = inv_isomorph_and_affine({d1, d0});
        end
    endfunction

    function automatic [7:0] isomorph(input [7:0] a);
        begin
            isomorph[7] = a[5] ^ a[7];
            isomorph[6] = a[1] ^ a[5] ^ a[4] ^ a[6];
            isomorph[5] = a[3] ^ a[2] ^ a[5] ^ a[7];
            isomorph[4] = a[3] ^ a[2] ^ a[4] ^ a[7] ^ a[6];
            isomorph[3] = a[1] ^ a[2] ^ a[7] ^ a[6];
            isomorph[2] = a[3] ^ a[2] ^ a[7] ^ a[6];
            isomorph[1] = a[1] ^ a[4] ^ a[6];
            isomorph[0] = a[1] ^ a[0] ^ a[3] ^ a[2] ^ a[7];
        end
    endfunction

    function automatic [3:0] gf4_sq(input [3:0] a);
        begin
            gf4_sq[3] = a[3];
            gf4_sq[2] = a[1] ^ a[3];
            gf4_sq[1] = a[2];
            gf4_sq[0] = a[0] ^ a[2];
        end
    endfunction

    function automatic [3:0] gf4_sq_mul_v(input [3:0] a);
        reg [3:0] a_sq, a1, a2, a3;
        reg [3:0] p0, p1, p2;
        begin
            a_sq[3] = a[3];
            a_sq[2] = a[1] ^ a[3];
            a_sq[1] = a[2];
            a_sq[0] = a[0] ^ a[2];
            p0 = a_sq;
            a1 = {a_sq[2:0],1'b0} ^ (a_sq[3] ? 4'b0011 : 4'b0000);
            p1 = p0;
            a2 = {a1[2:0],1'b0} ^ (a1[3] ? 4'b0011 : 4'b0000);
            p2 = p1 ^ a2;
            a3 = {a2[2:0],1'b0} ^ (a2[3] ? 4'b0011 : 4'b0000);
            gf4_sq_mul_v = p2 ^ a3;
        end
    endfunction

    function automatic [3:0] gf4_mul(input [3:0] a, input [3:0] b);
        reg [3:0] a1, a2, a3;
        reg [3:0] p0, p1, p2;
        begin
            p0 = b[0] ? a : 4'b0000;
            a1 = {a[2:0],1'b0} ^ (a[3] ? 4'b0011 : 4'b0000);
            p1 = p0 ^ (b[1] ? a1 : 4'b0000);
            a2 = {a1[2:0],1'b0} ^ (a1[3] ? 4'b0011 : 4'b0000);
            p2 = p1 ^ (b[2] ? a2 : 4'b0000);
            a3 = {a2[2:0],1'b0} ^ (a2[3] ? 4'b0011 : 4'b0000);
            gf4_mul = p2 ^ (b[3] ? a3 : 4'b0000);
        end
    endfunction

    function automatic [3:0] gf4_inv(input [3:0] a);
        begin
            gf4_inv[3] = (a[3]&a[2]&a[1]&a[0]) |
                         (~a[3]&~a[2]&a[1]) |
                         (~a[3]&a[2]&~a[1]) |
                         (a[3]&~a[2]&~a[0]) |
                         (a[2]&~a[1]&~a[0]);
            gf4_inv[2] = (a[3]&a[2]&~a[1]&a[0]) |
                         (~a[3]&a[2]&~a[0]) |
                         (a[3]&~a[2]&~a[0]) |
                         (~a[2]&a[1]&a[0]) |
                         (~a[3]&a[1]&a[0]);
            gf4_inv[1] = (a[3]&~a[2]&~a[1]) |
                         (~a[3]&a[1]&a[0]) |
                         (~a[3]&a[2]&a[0]) |
                         (a[3]&a[2]&~a[0]) |
                         (~a[3]&a[2]&a[1]);
            gf4_inv[0] = (a[3]&~a[2]&~a[1]&~a[0]) |
                         (a[3]&~a[2]&a[1]&a[0]) |
                         (~a[3]&~a[1]&a[0]) |
                         (~a[3]&a[1]&~a[0]) |
                         (a[2]&a[1]&~a[0]) |
                         (~a[3]&a[2]&~a[1]);
        end
    endfunction

    function automatic [7:0] inv_isomorph_and_affine(input [7:0] d);
        begin
            inv_isomorph_and_affine[7] = d[1] ^ d[2] ^ d[3] ^ d[7];
            inv_isomorph_and_affine[6] = ~(d[4] ^ d[7]);
            inv_isomorph_and_affine[5] = ~(d[1] ^ d[2] ^ d[7]);
            inv_isomorph_and_affine[4] = d[0] ^ d[1] ^ d[2] ^ d[4] ^ d[6] ^ d[7];
            inv_isomorph_and_affine[3] = d[0];
            inv_isomorph_and_affine[2] = d[0] ^ d[1] ^ d[3] ^ d[4];
            inv_isomorph_and_affine[1] = ~(d[0] ^ d[2] ^ d[7]);
            inv_isomorph_and_affine[0] = ~(d[0] ^ d[5] ^ d[6] ^ d[7]);
        end
    endfunction

endmodule
