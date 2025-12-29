module axi_slave #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input  wire                   clk,
    input  wire                   resetn,

    /* ================= AXI WRITE ADDRESS ================= */
    input  wire [ADDR_WIDTH-1:0]  s_axi_awaddr,
    input  wire                   s_axi_awvalid,
    output reg                    s_axi_awready,

    /* ================= AXI WRITE DATA ==================== */
    input  wire [DATA_WIDTH-1:0]  s_axi_wdata,
    input  wire [3:0]             s_axi_wstrb,
    input  wire                   s_axi_wvalid,
    output reg                    s_axi_wready,

    /* ================= AXI WRITE RESPONSE ================ */
    output reg  [1:0]             s_axi_bresp,
    output reg                    s_axi_bvalid,
    input  wire                   s_axi_bready,

    /* ================= AXI READ ADDRESS ================== */
    input  wire [ADDR_WIDTH-1:0]  s_axi_araddr,
    input  wire                   s_axi_arvalid,
    output reg                    s_axi_arready,

    /* ================= AXI READ DATA ===================== */
    output reg  [DATA_WIDTH-1:0]  s_axi_rdata,
    output reg  [1:0]             s_axi_rresp,
    output reg                    s_axi_rvalid,
    input  wire                   s_axi_rready,

    /* ============== INTERNAL REGISTER INTERFACE ========== */
    output reg                    wr_en,
    output reg [ADDR_WIDTH-1:0]   wr_addr,
    output reg [DATA_WIDTH-1:0]   wr_data,
    output reg [3:0]              wr_strb,

    output reg                    rd_en,
    output reg [ADDR_WIDTH-1:0]   rd_addr,
    input  wire [DATA_WIDTH-1:0]  rd_data
);

    /* =====================================================
       Internal tracking for write channel
       ===================================================== */
    reg aw_seen;
    reg w_seen;

    /* =====================================================
       Sequential logic
       ===================================================== */
    always @(posedge clk) begin
        if (!resetn) begin
            /* Reset AXI outputs */
            s_axi_awready <= 1'b0;
            s_axi_wready  <= 1'b0;
            s_axi_bvalid  <= 1'b0;
            s_axi_bresp   <= 2'b00;

            s_axi_arready <= 1'b0;
            s_axi_rvalid  <= 1'b0;
            s_axi_rresp   <= 2'b00;
            s_axi_rdata   <= {DATA_WIDTH{1'b0}};

            /* Internal strobes */
            wr_en   <= 1'b0;
            rd_en   <= 1'b0;

            aw_seen <= 1'b0;
            w_seen  <= 1'b0;
        end else begin
            /* Default deassert strobes */
            wr_en <= 1'b0;
            rd_en <= 1'b0;

            /* ================= WRITE ADDRESS ================= */
            s_axi_awready <= !aw_seen;
            if (s_axi_awvalid && s_axi_awready) begin
                wr_addr <= s_axi_awaddr;
                aw_seen <= 1'b1;
            end

            /* ================= WRITE DATA ==================== */
            s_axi_wready <= !w_seen;
            if (s_axi_wvalid && s_axi_wready) begin
                wr_data <= s_axi_wdata;
                wr_strb <= s_axi_wstrb;
                w_seen  <= 1'b1;
            end

            /* ================= WRITE COMPLETE ================= */
            if (aw_seen && w_seen && !s_axi_bvalid) begin
                wr_en        <= 1'b1;   // one-cycle write pulse
                s_axi_bvalid <= 1'b1;
                s_axi_bresp  <= 2'b00;  // OKAY

                aw_seen <= 1'b0;
                w_seen  <= 1'b0;
            end

            if (s_axi_bvalid && s_axi_bready) begin
                s_axi_bvalid <= 1'b0;
            end

            /* ================= READ ADDRESS ================== */
            s_axi_arready <= !s_axi_rvalid;
            if (s_axi_arvalid && s_axi_arready) begin
                rd_addr      <= s_axi_araddr;
                rd_en        <= 1'b1;   // one-cycle read pulse
                s_axi_rvalid <= 1'b1;
                s_axi_rresp  <= 2'b00;  // OKAY
            end

            /* ================= READ DATA ===================== */
            if (s_axi_rvalid) begin
                s_axi_rdata <= rd_data;
                if (s_axi_rready) begin
                    s_axi_rvalid <= 1'b0;
                end
            end
        end
    end

endmodule

