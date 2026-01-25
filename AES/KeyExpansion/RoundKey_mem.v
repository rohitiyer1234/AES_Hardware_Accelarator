module keymem(
    input  wire        clk,
    input  wire        reset,

    input  wire        w_en,
    input  wire [3:0]  waddr,
    input  wire [127:0] wkey,

    input  wire [3:0]  raddr,
    output reg  [127:0] rkey,

    output wire        all_valid
);

    reg [127:0] mem [0:10];
    reg [10:0]  valid;

    integer i;
    // DEBUG: expose memory for waveform viewing
// synthesis translate_off
genvar gi;
generate
    for (gi = 0; gi <= 10; gi = gi + 1) begin : DBG_MEM
        wire [127:0] dbg_mem = mem[gi];
    end
endgenerate
// synthesis translate_on

    assign all_valid = &valid;

    // WRITE = synchronous
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i <= 10; i = i + 1) begin
                mem[i]   <= 128'd0;
                valid[i] <= 1'b0;
            end
        end else if (w_en) begin
            mem[waddr]   <= wkey;
            valid[waddr] <= 1'b1;
        end
    end

    // READ = combinational  ✅ KEY FIX
    always @(*) begin
        rkey = mem[raddr];
    end

endmodule
