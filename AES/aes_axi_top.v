module aes_axi_top (
    input wire clk,
    input wire resetn,

    // AXI4-Lite slave interface
    input  wire [31:0] s_axi_awaddr,
    input  wire        s_axi_awvalid,
    output wire        s_axi_awready,

    input  wire [31:0] s_axi_wdata,
    input  wire [3:0]  s_axi_wstrb,
    input  wire        s_axi_wvalid,
    output wire        s_axi_wready,

    output wire [1:0]  s_axi_bresp,
    output wire        s_axi_bvalid,
    input  wire        s_axi_bready,

    input  wire [31:0] s_axi_araddr,
    input  wire        s_axi_arvalid,
    output wire        s_axi_arready,

    output wire [31:0] s_axi_rdata,
    output wire [1:0]  s_axi_rresp,
    output wire        s_axi_rvalid,
    input  wire        s_axi_rready
);

    /* ================= AXI internal wires ================= */
    wire        wr_en;
    wire [31:0] wr_addr;
    wire [31:0] wr_data;
    wire [3:0]  wr_strb;

    wire        rd_en;
    wire [31:0] rd_addr;
    wire [31:0] rd_data;

    /* ================= Registers ================= */
    wire [31:0] ctrl_reg1;
    wire [31:0] ctrl_reg2;
    wire [31:0] mode_reg;
    wire [31:0] status_reg;

    wire [31:0] base_key_reg [0:3];
    wire [31:0] data_in_mem  [0:3];
    wire [31:0] data_out_mem [0:3];
    wire [31:0] IV_W         [0:3];

    /* ================= AXI SLAVE ================= */
    axi_slave u_axi_slave (
        .clk(clk),
        .resetn(resetn),

        .s_axi_awaddr (s_axi_awaddr),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_awready(s_axi_awready),

        .s_axi_wdata  (s_axi_wdata),
        .s_axi_wstrb  (s_axi_wstrb),
        .s_axi_wvalid (s_axi_wvalid),
        .s_axi_wready (s_axi_wready),

        .s_axi_bresp  (s_axi_bresp),
        .s_axi_bvalid (s_axi_bvalid),
        .s_axi_bready (s_axi_bready),

        .s_axi_araddr (s_axi_araddr),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_arready(s_axi_arready),

        .s_axi_rdata  (s_axi_rdata),
        .s_axi_rresp  (s_axi_rresp),
        .s_axi_rvalid (s_axi_rvalid),
        .s_axi_rready (s_axi_rready),

        .wr_en   (wr_en),
        .wr_addr (wr_addr),
        .wr_data (wr_data),
        .wr_strb (wr_strb),

        .rd_en   (rd_en),
        .rd_addr (rd_addr),
        .rd_data (rd_data)
    );

    /* ================= AXI REGS ================= */
    axi_regs u_axi_regs (
        .clk(clk),
        .resetn(resetn),

        .wr_en   (wr_en),
        .wr_addr (wr_addr),
        .wr_data (wr_data),

        .rd_en   (rd_en),
        .rd_addr (rd_addr),
        .rd_data (rd_data),

        .status_reg (status_reg),
        .data_out_mem(data_out_mem),

        .ctrl_reg1  (ctrl_reg1),
        .ctrl_reg2  (ctrl_reg2),
        .mode_reg   (mode_reg),
        .base_key_reg(base_key_reg),
        .IV_W       (IV_W),
        .data_in_mem(data_in_mem)
    );

    /* ================= CONTROL ================= */
    wire        aes_start;
    wire        enc_dec_lat;
    wire [2:0]  mode_lat;
    wire [127:0] plaintext_lat;
    wire [127:0] iv_lat;

    axi_control u_axi_control (
        .clk(clk),
        .resetn(resetn),

        .ctrl_reg (ctrl_reg1),
        .mode_reg (mode_reg),
        .base_key_reg(base_key_reg),
        .data_in_mem(data_in_mem),
        .iv_in     (IV_W),

        .aes_done  (aes_done),
        .aes_result(aes_result),

        .status_reg(status_reg),
        .data_out_mem(data_out_mem),

        .aes_start (aes_start),
        .plaintext_lat(plaintext_lat),
        .mode_lat  (mode_lat),
        .iv_lat    (iv_lat),
        .enc_dec_lat(enc_dec_lat)
    );

    /* ================= AES TOP ================= */
    wire [127:0] aes_result;
    wire         aes_done;

    aes_encrypt_top u_aes_top (
        .clk(clk),
        .reset(~resetn),

        .start(aes_start),
        .enc_dec(enc_dec_lat),
        .mode(mode_lat),

        .plaintext(plaintext_lat),
        .iv(iv_lat),

        .result(aes_result),
        .done(aes_done)
    );

endmodule
