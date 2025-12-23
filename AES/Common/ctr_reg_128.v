module ctr_reg_128 (
    input  clk, load, reset, inc,
    input  [127:0] ctr_init,
    output reg  [127:0] ctr
);
    always @(posedge clk) begin
        if (reset)
            ctr <= 128'd0;
        else if (load)
            ctr <= ctr_init;
        else if (inc)
            ctr <= ctr + 128'd1;
    end
endmodule
