module AddRoundKey(inp,subkey,result);

    input [127:0] inp, subkey;
    output [127:0] result;

    assign result = inp ^ subkey;

endmodule

