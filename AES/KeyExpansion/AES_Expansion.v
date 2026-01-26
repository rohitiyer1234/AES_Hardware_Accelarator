module Aes_key_expansion_128(
    input clk,
    input reset,
    input key_expansion_start,                   //Flag to indicate start of key expansion FSM
    input [127:0] user_sub_key,     //User given key
        //128 bit cypher key generated every round 
              //To keep count of which round is it 0-11 , for simplification rn it is 4 
             //output_key generated is valid only when status=1

    output reg w_en,
    output reg [3:0]  waddr,
    output reg [127:0] wkey

);
    //reg local_start;
    reg [3:0] i;
    reg status;
    reg [127:0] prev_period_key_1; 
    wire [127:0] output_key;
    //To hold 128 bit previous round key for next round computation
    wire [31:0] key1,key2,key3,key4;

    // didnt understand this part fully , look into it later as well
    // W4= W0 XOR G(w3)
    //W5 = W1 XOR W4

    current_word_gen_128 word1(.i({i,2'd0}),.prev_word(prev_period_key_1[31:0]),.prev_period_word(prev_period_key_1[127:96]),.current_word(key1));
    current_word_gen_128 word2(.i({i,2'd1}),.prev_word(key1),.prev_period_word(prev_period_key_1[95:64]),.current_word(key2));
    current_word_gen_128 word3(.i({i,2'd2}),.prev_word(key2),.prev_period_word(prev_period_key_1[63:32]),.current_word(key3));
    current_word_gen_128 word4(.i({i,2'd3}),.prev_word(key3),.prev_period_word(prev_period_key_1[31:0]),.current_word(key4));


    assign output_key ={key1,key2,key3,key4};    // 4 32 bit words to give 128 bit key

    always @(posedge clk)
    begin
        if(reset) begin
            i <= 0;
            prev_period_key_1 <= 0;
            status <= 0;
            //local_start <= 0;
            w_en   <= 0;
            waddr  <= 0;
            wkey   <= 0;
        end
        else begin
            w_en <= 0;   // defaul
            
            if (key_expansion_start && !status) begin
                //local_start <= 1'b1;
                i <= 1;
                prev_period_key_1 <= user_sub_key;
                status <= 1;

                // write round-0 key
                w_en   <= 1;
                waddr  <= 0;
                wkey   <= user_sub_key;
            end

            else if(status && (i>=1) && (i<10)) begin
                prev_period_key_1 <= output_key;
                i <= i+1;

                // write round-i key
                w_en   <= 1;
                waddr  <= i;
                wkey   <= output_key;
            end

            else if(status && i==10) begin
                // write final round key
                w_en   <= 1;
                waddr  <= 10;
                wkey   <= output_key;

                i <= 0;
                prev_period_key_1 <= 0;
                status <= 0;
            end
        end
end
endmodule
