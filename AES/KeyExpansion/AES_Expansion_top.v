module AES_nsion(
    input reset, clk, start,
    input [127:0] short_subkey,
    output reg [127:0] subkey,
    output subkey_valid
    );


     // FSM states
    localparam IDLE = 3'd0;
    localparam LOAD_BASE_KEY = 3'd1;
    localparam GENERATE_WORD = 3'd2;
    localparam WRITE_WORD = 3'd3;
    localparam DONE = 3'd4;

    reg [3:0] i; //word index
    reg status;
    reg [127:0] prev_period_suubkey;

    wire [31:0] key1, key2, key3, key4;
    Keyword_gen K1(.i({i,2'd0}),.prev_word(prev_period_key_1[31:0]),.prev_period_word(prev_period_key_1[127:96]),.current_word(key1));
    Keyword_gen K2(.i({i,2'd1}),.prev_word(key1),.prev_period_word(prev_period_key_1[95:64]),.current_word(key2));
    Keyword_gen K3(.i({i,2'd2}),.prev_word(key2),.prev_period_word(prev_period_key_1[63:32]),.current_word(key3));
    Keyword_gen K4(.i({i,2'd3}),.prev_word(key3),.prev_period_word(prev_period_key_1[31:0]),.current_word(key4));

    assign subkey = {key1, key2, key3, key4};

    always @ (posedge clk)
    begin
        if (reset) begin
            status <= IDLE;
            i <= 0;
            prev_period_subkey <= 0;
        end else begin
            case (status)
            IDLE: begin
                if (start) begin
                    status <= LOAD_BASE_KEY;
                end
            end

            LOAD_BASE_KEY: begin
                prev_period_subkey <= short_subkey;
                i <= 0;
                status <= GENERATE_WORD;
            end

            GENERATE_WORD: begin
                if (i == 4) begin
                    status <= DONE;
                end else begin
                    i <= i + 1;
                    status <= WRITE_WORD;
                end
            end

            WRITE_WORD: begin
                prev_period_subkey <= subkey;
                status <= GENERATE_WORD;
            end

            DONE: begin
                status <= IDLE;
            end

            endcase

        end
    end
endmodule