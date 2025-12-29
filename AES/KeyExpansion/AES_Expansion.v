module AES_Expansion(
    input reset, clk, start,
    input [127:0] short_subkey,
    output reg [127:0] subkey,
    output subkey_valid
);

    reg [3:0] key_count; // Counts words generated (0 to 43 for 44 words)
    reg status;
    reg [127:0] prev_period_subkey;

    



endmodule