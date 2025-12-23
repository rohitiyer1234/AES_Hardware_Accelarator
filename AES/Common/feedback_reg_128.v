module feedback_reg_128(
    input clk, reset, update, load_iv,
    input [127:0]data_in,
    input [127:0] iv,
    output reg [127:0] feedback
    );

    always @ (posedge clk)
    begin
    if ( reset )
        feedback <= 128'b0;
    else if ( load_iv )
        feedback <= iv;   //Initial IV load for CBC, CTR, oFB modes encryption as value to be XOR'ed
    else if (update)
        feedback <= data_in; //stores prev cycle result to be XOR'ed with next before AES
    end
endmodule
